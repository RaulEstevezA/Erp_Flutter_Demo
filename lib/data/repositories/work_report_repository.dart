import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/services.dart' show rootBundle;

import '../../core/network/api_client.dart';
import '../../core/roles/permissions.dart';
import '../../core/session/session_store.dart';
import '../../core/utils/workday_calendar.dart';
import '../../domain/attendance.dart' show PageResult;
import '../../domain/work_reports.dart';
import '../local/attachments/attachment_storage.dart';
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
  static const _lineEdits = 'work_report_line_edits';
  static const _localFiles = 'work_report_files';
  static const _deletedFiles = 'work_report_files_deleted';

  /// Límite por archivo, como en el ERP.
  static const maxFileBytes = 10 * 1024 * 1024;

  final ApiClient _api;
  final LocalChangesStore _changes;
  final SessionStore _session;
  final AttachmentStorage attachments;

  const WorkReportRepository(
    this._api,
    this._changes,
    this._session,
    this.attachments,
  );

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
    final reports =
        (await _visible())
            .where(
              (r) =>
                  r.status.isActive == (filter == WorkReportFilter.active) &&
                  (clientId == null || r.clientId == clientId) &&
                  (since == null || !r.date.isBefore(since)) &&
                  (until == null || !r.date.isAfter(until)) &&
                  (query.isEmpty ||
                      [r.code, r.name].whereType<String>().any(
                        (field) => field.toLowerCase().contains(query),
                      )),
            )
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));

    final start = (page - 1) * pageSize;
    if (start >= reports.length) return const PageResult([], hasMore: false);
    final end = min(start + pageSize, reports.length);
    return PageResult(
      reports.sublist(start, end),
      hasMore: end < reports.length,
    );
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
    return (await _products()).values
        .where(
          (p) =>
              p.ref.toLowerCase().contains(q) ||
              p.concept.toLowerCase().contains(q),
        )
        .toList();
  }

  /// Catálogo completo, por referencia.
  Future<List<Product>> products() async =>
      (await _products()).values.toList()
        ..sort((a, b) => a.ref.compareTo(b.ref));

  Future<Map<int, Product>> _products() async {
    final data = await _api.get('products') as List<dynamic>;
    return {
      for (final p in data.cast<Map<String, dynamic>>().map(Product.fromJson))
        p.id: p,
    };
  }

  Future<void> addLine(
    int reportId, {
    required String concept,
    required double units,
    int duration = 0,
    int? productId,
    double? price,
  }) async {
    await getReport(reportId); // Comprueba el acceso.
    final values = await _validLine(
      concept: concept,
      units: units,
      duration: duration,
      productId: productId,
      price: price,
    );
    await _changes.add(_localLines, {
      'id': _changes.nextId(_localLines),
      'report_id': reportId,
      'product_id': productId,
      ...values,
    });
  }

  /// Cambia una línea añadida en el dispositivo. Las del servidor no se
  /// tocan. El precio es libre: se mantiene el que se indique, también 0.
  Future<void> updateLine(
    int reportId,
    String lineId, {
    required String concept,
    required double units,
    int duration = 0,
    double? price,
  }) async {
    final report = await getReport(reportId);
    final line = report.lines.where((l) => l.id == lineId).firstOrNull;
    if (line == null) throw StateError('Línea no encontrada.');
    if (!line.editable) throw StateError('Las líneas del servidor no se modifican.');
    final values = await _validLine(
      concept: concept,
      units: units,
      duration: duration,
      productId: line.productId,
      price: price,
    );
    await _changes.putInMap(_lineEdits, lineId, values);
  }

  /// Comprueba los datos de una línea y devuelve los que se guardan.
  /// En la mano de obra (por horas) las unidades salen de los minutos.
  Future<Map<String, Object?>> _validLine({
    required String concept,
    required double units,
    required int duration,
    required int? productId,
    required double? price,
  }) async {
    if (concept.trim().isEmpty) {
      throw ArgumentError('El concepto es obligatorio.');
    }
    if (price != null && price < 0) {
      throw ArgumentError('El precio no puede ser negativo.');
    }
    final product = productId == null ? null : (await _products())[productId];
    final hourly = product?.hourly ?? false;
    if (hourly && duration <= 0) {
      throw ArgumentError('La mano de obra necesita duración.');
    }
    final lineUnits = hourly ? duration / 60 : units;
    if (lineUnits <= 0) {
      throw ArgumentError('Las unidades deben ser mayores que 0.');
    }
    return {
      'concept': concept.trim(),
      'units': lineUnits,
      'duration': duration,
      'price': price,
    };
  }

  Future<void> saveSignature(int reportId, SignatureStrokes strokes) async {
    await getReport(reportId);
    if (strokes.every((s) => s.isEmpty)) throw ArgumentError('Firma vacía.');
    await _changes.putInMap(
      _localSignatures,
      '$reportId',
      _encodeStrokes(strokes),
    );
  }

  // ── Archivos ───────────────────────────────────────────────────────────

  Future<List<WorkReportFile>> getFiles(int reportId) async {
    await getReport(reportId);
    final reports = (await _api.get('work_reports') as List<dynamic>)
        .cast<Map<String, dynamic>>();
    final remote =
        reports.firstWhere((r) => r['id'] == reportId)['files'] as List? ??
        const [];
    final deleted = _changes.readMap(_deletedFiles);

    WorkReportFile file(Map<String, dynamic> f) => WorkReportFile(
      id: f['id'] as int,
      name: f['name'] as String? ?? '',
      type: f['type'] == 'audio'
          ? WorkReportFileType.audio
          : WorkReportFileType.image,
      size: (f['size'] as num?)?.toInt() ?? 0,
      asset: f['asset'] as String?,
      storageKey: f['storage_key'] as String?,
    );

    return [
      for (final f in remote.cast<Map<String, dynamic>>())
        if (!deleted.containsKey('$reportId:${f['id']}')) file(f),
      for (final f
          in _changes
              .read(_localFiles)
              .where((f) => f['report_id'] == reportId))
        file(f),
    ];
  }

  /// Adjunta un archivo. Lanza [FileTooLargeException] si supera el límite.
  Future<void> addFile(
    int reportId, {
    required String name,
    required Uint8List bytes,
    required WorkReportFileType type,
  }) async {
    await getReport(reportId);
    if (bytes.length > maxFileBytes) throw const FileTooLargeException();
    final key = await attachments.save(name, bytes);
    await _changes.add(_localFiles, {
      'id': _changes.nextId(_localFiles),
      'report_id': reportId,
      'name': name,
      'type': type.name,
      'size': bytes.length,
      'storage_key': key,
    });
  }

  Future<void> deleteFile(int reportId, WorkReportFile file) async {
    await getReport(reportId);
    if (file.storageKey != null) {
      await attachments.delete(file.storageKey!);
      await _changes.removeWhere(_localFiles, (f) => f['id'] == file.id);
    } else {
      // Los de la demo no se pueden borrar del servidor: se ocultan.
      await _changes.putInMap(_deletedFiles, '$reportId:${file.id}', true);
    }
  }

  /// Contenido del archivo (para mostrar imágenes).
  Future<Uint8List?> fileBytes(WorkReportFile file) async {
    if (file.asset != null) {
      final data = await rootBundle.load('assets/demo_files/${file.asset}');
      return data.buffer.asUint8List();
    }
    return attachments.read(file.storageKey!);
  }

  // ── Datos ──────────────────────────────────────────────────────────────

  Future<List<WorkReport>> _visible() async {
    final user = _session.user;
    if (user == null || !user.role.can(AppPermission.viewWorkReports)) {
      throw StateError('Sin permiso para ver partes de trabajo.');
    }
    final seesAll = user.role.can(AppPermission.viewAllWorkReports);

    final users = (await _api.get('users') as List<dynamic>)
        .cast<Map<String, dynamic>>();
    final myWorkerId =
        users.where((u) => u['id'] == user.id).firstOrNull?['worker_id']
            as int?;
    final workers = {
      for (final w in (await _api.get(
        'workers',
      ) as List<dynamic>).cast<Map<String, dynamic>>())
        w['id'] as int: w['name'] as String,
    };
    final clients = {
      for (final c in (await _api.get(
        'clients',
      ) as List<dynamic>).cast<Map<String, dynamic>>())
        c['id'] as int: c['name'] as String?,
    };
    final products = await _products();
    final localLines = _changes.read(_localLines);
    final localSignatures = _changes.readMap(_localSignatures);
    final edits = _changes.readMap(_lineEdits);

    WorkReportLine line(
      String id,
      Map<String, dynamic> original, {
      required bool local,
    }) {
      // Solo las líneas propias se editan; en ellas mandan los valores editados.
      final json = {
        ...original,
        if (local) ...?(edits[id] as Map<String, dynamic>?),
      };
      return WorkReportLine(
        id: id,
        editable: local,
        productId: json['product_id'] as int?,
        productRef: products[json['product_id']]?.ref,
        hourly: products[json['product_id']]?.hourly ?? false,
        concept: json['concept'] as String? ?? '',
        units: (json['units'] as num?)?.toDouble() ?? 0,
        duration: (json['duration'] as num?)?.toInt() ?? 0,
        price: (json['price'] as num?)?.toDouble(),
      );
    }

    final reports = (await _api.get('work_reports') as List<dynamic>)
        .cast<Map<String, dynamic>>();
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
              for (final (i, l)
                  in (r['lines'] as List).cast<Map<String, dynamic>>().indexed)
                line('r${r['id']}-$i', l, local: false),
              for (final (i, l)
                  in localLines.where((l) => l['report_id'] == r['id']).indexed)
                line(
                  l['id'] is int ? 'l${l['id']}' : 'l${r['id']}-$i',
                  l,
                  local: true,
                ),
            ],
            workerNames: (r['worker_ids'] as List)
                .map((id) => workers[id])
                .whereType<String>()
                .toList(),
            signature: _decodeStrokes(
              localSignatures['${r['id']}'] ?? r['signature'],
            ),
          ),
    ];
  }

  static List<List<List<double>>> _encodeStrokes(SignatureStrokes strokes) => [
    for (final stroke in strokes)
      if (stroke.isNotEmpty)
        [
          for (final p in stroke)
            [
              double.parse(p.dx.toStringAsFixed(3)),
              double.parse(p.dy.toStringAsFixed(3)),
            ],
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

class FileTooLargeException implements Exception {
  const FileTooLargeException();
}
