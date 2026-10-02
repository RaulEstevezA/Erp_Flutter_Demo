import 'dart:math';
import 'dart:ui';

import '../../core/network/api_client.dart';
import '../../core/roles/permissions.dart';
import '../../core/session/session_store.dart';
import '../../core/utils/workday_calendar.dart';
import '../../domain/attendance.dart' show PageResult;
import '../../domain/work_reports.dart';
import '../local/local_changes_store.dart';

/// Partes de trabajo.
///
/// Gestión ve todos; usuarios y trabajadores solo aquellos en los que su
/// ficha de técnico está asignada (como hace el ERP). Las líneas añadidas y
/// las firmas se guardan en el dispositivo.
class WorkReportRepository {
  static const perPage = 20;
  static const _localLines = 'work_report_lines';
  static const _localSignatures = 'work_report_signatures';

  final ApiClient _api;
  final LocalChangesStore _changes;
  final SessionStore _session;

  const WorkReportRepository(this._api, this._changes, this._session);

  Future<PageResult<WorkReport>> getReports({
    required WorkReportFilter filter,
    int? clientId,
    DateTime? since,
    DateTime? until,
    String? search,
    int page = 1,
    int pageSize = perPage,
  }) async {
    final query = (search ?? '').trim().toLowerCase();
    final reports = (await _visible())
        .where((r) =>
            r.status.isActive == (filter == WorkReportFilter.active) &&
            (clientId == null || r.clientId == clientId) &&
            (since == null || !r.date.isBefore(since)) &&
            (until == null || !r.date.isAfter(until)) &&
            (query.isEmpty ||
                [r.code, r.name]
                    .whereType<String>()
                    .any((field) => field.toLowerCase().contains(query))))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final start = (page - 1) * pageSize;
    if (start >= reports.length) return const PageResult([], hasMore: false);
    final end = min(start + pageSize, reports.length);
    return PageResult(reports.sublist(start, end), hasMore: end < reports.length);
  }

  Future<WorkReport> getReport(int id) async {
    final report = (await _visible()).where((r) => r.id == id).firstOrNull;
    if (report == null) throw StateError('Parte no disponible.');
    return report;
  }

  /// Productos cuya referencia o concepto contiene [query].
  Future<List<Product>> searchProducts(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    final data = await _api.get('products') as List<dynamic>;
    return data
        .cast<Map<String, dynamic>>()
        .map(Product.fromJson)
        .where((p) => p.ref.toLowerCase().contains(q) || p.concept.toLowerCase().contains(q))
        .toList();
  }

  Future<void> addLine(
    int reportId, {
    required String concept,
    required double units,
    int duration = 0,
    int? productId,
  }) async {
    await getReport(reportId); // Comprueba el acceso.
    if (concept.trim().isEmpty) throw ArgumentError('El concepto es obligatorio.');
    if (units <= 0) throw ArgumentError('Las unidades deben ser mayores que 0.');
    await _changes.add(_localLines, {
      'report_id': reportId,
      'product_id': productId,
      'concept': concept.trim(),
      'units': units,
      'duration': duration,
    });
  }

  Future<void> saveSignature(int reportId, SignatureStrokes strokes) async {
    await getReport(reportId);
    if (strokes.every((s) => s.isEmpty)) throw ArgumentError('Firma vacía.');
    await _changes.putInMap(_localSignatures, '$reportId', _encodeStrokes(strokes));
  }

  // ── Datos ──────────────────────────────────────────────────────────────

  Future<List<WorkReport>> _visible() async {
    final user = _session.user;
    if (user == null || !user.role.can(AppPermission.viewWorkReports)) {
      throw StateError('Sin permiso para ver partes de trabajo.');
    }
    final seesAll = user.role.can(AppPermission.viewAllWorkReports);

    final users = (await _api.get('users') as List<dynamic>).cast<Map<String, dynamic>>();
    final myWorkerId = users.where((u) => u['id'] == user.id).firstOrNull?['worker_id'] as int?;
    final workers = {
      for (final w in (await _api.get('workers') as List<dynamic>).cast<Map<String, dynamic>>())
        w['id'] as int: w['name'] as String,
    };
    final clients = {
      for (final c in (await _api.get('clients') as List<dynamic>).cast<Map<String, dynamic>>())
        c['id'] as int: c['name'] as String?,
    };
    final products = {
      for (final p in (await _api.get('products') as List<dynamic>).cast<Map<String, dynamic>>())
        p['id'] as int: p['ref'] as String?,
    };
    final localLines = _changes.read(_localLines);
    final localSignatures = _changes.readMap(_localSignatures);

    WorkReportLine line(Map<String, dynamic> json) => WorkReportLine(
          productRef: products[json['product_id']],
          concept: json['concept'] as String? ?? '',
          units: (json['units'] as num?)?.toDouble() ?? 0,
          duration: (json['duration'] as num?)?.toInt() ?? 0,
        );

    final reports = (await _api.get('work_reports') as List<dynamic>).cast<Map<String, dynamic>>();
    return [
      for (final r in reports)
        if (seesAll || (r['worker_ids'] as List).contains(myWorkerId))
          WorkReport(
            id: r['id'] as int,
            code: r['code'] as String,
            name: r['name'] as String?,
            clientId: r['client_id'] as int,
            clientName: clients[r['client_id']],
            date: WorkdayCalendar.resolve(r['workday_offset'] as int, '08:00'),
            status: WorkReportStatus.parse(r['status'] as int?),
            description: r['description'] as String?,
            remarks: r['remarks'] as String?,
            address: r['address'] as String?,
            city: r['city'] as String?,
            lines: [
              for (final l in (r['lines'] as List).cast<Map<String, dynamic>>()) line(l),
              for (final l in localLines.where((l) => l['report_id'] == r['id'])) line(l),
            ],
            workerNames: (r['worker_ids'] as List).map((id) => workers[id]).whereType<String>().toList(),
            signature: _decodeStrokes(localSignatures['${r['id']}'] ?? r['signature']),
          ),
    ];
  }

  static List<List<List<double>>> _encodeStrokes(SignatureStrokes strokes) => [
        for (final stroke in strokes)
          if (stroke.isNotEmpty)
            [
              for (final p in stroke)
                [double.parse(p.dx.toStringAsFixed(3)), double.parse(p.dy.toStringAsFixed(3))],
            ],
      ];

  static SignatureStrokes? _decodeStrokes(Object? raw) {
    if (raw is! List || raw.isEmpty) return null;
    return [
      for (final stroke in raw.cast<List>())
        [
          for (final p in stroke.cast<List>())
            Offset((p[0] as num).toDouble(), (p[1] as num).toDouble()),
        ],
    ];
  }
}
