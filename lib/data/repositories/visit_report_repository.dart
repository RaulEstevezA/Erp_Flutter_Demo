import 'dart:math';

import '../../core/network/api_client.dart';
import '../../core/roles/permissions.dart';
import '../../core/session/session_store.dart';
import '../../core/utils/workday_calendar.dart';
import '../../domain/attendance.dart' show PageResult;
import '../../domain/visit_reports.dart';
import '../local/local_changes_store.dart';

/// Partes de visita por cliente. Ver y crear es solo para gestión
/// ([AppPermission.viewVisitReports] / [AppPermission.createVisitReports]).
///
/// Las visitas nuevas se guardan en el dispositivo y se mezclan con las
/// del servidor estático.
class VisitReportRepository {
  static const perPage = 20;
  static const _local = 'visit_reports';

  final ApiClient _api;
  final LocalChangesStore _changes;
  final SessionStore _session;

  const VisitReportRepository(this._api, this._changes, this._session);

  void _require(AppPermission permission) {
    final user = _session.user;
    if (user == null || !user.role.can(permission)) {
      throw StateError('Sin permiso: $permission');
    }
  }

  Future<List<Worker>> workers() async {
    final data = await _api.get('workers') as List<dynamic>;
    return data.cast<Map<String, dynamic>>().map(Worker.fromJson).toList();
  }

  /// Técnicos cuyo nombre contiene [query] (sin distinguir mayúsculas).
  Future<List<Worker>> searchWorkers(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return (await workers()).where((w) => w.name.toLowerCase().contains(q)).toList();
  }

  /// Visitas del cliente, de la más reciente a la más antigua.
  Future<PageResult<VisitReport>> getVisits({
    required int clientId,
    int page = 1,
    DateTime? since,
    DateTime? until,
    String? search,
  }) async {
    final query = (search ?? '').trim().toLowerCase();
    final visits = (await _all())
        .where((v) =>
            v.clientId == clientId &&
            (since == null || !v.visitedAt.isBefore(since)) &&
            (until == null || !v.visitedAt.isAfter(until)) &&
            (query.isEmpty ||
                [v.name, v.description, ...v.workerNames]
                    .whereType<String>()
                    .any((field) => field.toLowerCase().contains(query))))
        .toList()
      ..sort((a, b) => b.visitedAt.compareTo(a.visitedAt));

    final start = (page - 1) * perPage;
    if (start >= visits.length) return const PageResult([], hasMore: false);
    final end = min(start + perPage, visits.length);
    return PageResult(visits.sublist(start, end), hasMore: end < visits.length);
  }

  Future<VisitReport> getVisit(int id) async {
    final visit = (await _all()).where((v) => v.id == id).firstOrNull;
    if (visit == null) throw StateError('Visita no encontrada.');
    return visit;
  }

  Future<void> create({
    required int clientId,
    required String name,
    required DateTime visitedAt,
    int? durationMinutes,
    String? description,
    List<int> workerIds = const [],
    double? travelDistanceKm,
    int? travelTimeMinutes,
  }) async {
    _require(AppPermission.createVisitReports);
    if (name.trim().isEmpty) throw ArgumentError('El nombre es obligatorio.');
    await _changes.add(_local, {
      'id': _changes.nextId(_local),
      'client_id': clientId,
      'name': name.trim(),
      'visited_at': visitedAt.toIso8601String(),
      'duration_minutes': durationMinutes,
      'worker_ids': workerIds,
      'description': (description?.trim().isEmpty ?? true) ? null : description!.trim(),
      'travel_distance_km': travelDistanceKm,
      'travel_time_minutes': travelTimeMinutes,
    });
  }

  Future<List<VisitReport>> _all() async {
    _require(AppPermission.viewVisitReports);
    final remote = (await _api.get('visit_reports') as List<dynamic>).cast<Map<String, dynamic>>();
    final workers = {for (final w in await this.workers()) w.id: w.name};
    final clients = {
      for (final c in (await _api.get('clients') as List<dynamic>).cast<Map<String, dynamic>>())
        c['id'] as int: c['name'] as String?,
    };

    VisitReport build(Map<String, dynamic> json, DateTime visitedAt) => VisitReport(
          id: json['id'] as int,
          clientId: json['client_id'] as int,
          clientName: clients[json['client_id']],
          name: json['name'] as String? ?? '',
          visitedAt: visitedAt,
          durationMinutes: (json['duration_minutes'] as num?)?.toInt(),
          workerNames: (json['worker_ids'] as List? ?? const [])
              .map((id) => workers[id])
              .whereType<String>()
              .toList(),
          description: json['description'] as String?,
          travelDistanceKm: (json['travel_distance_km'] as num?)?.toDouble(),
          travelTimeMinutes: (json['travel_time_minutes'] as num?)?.toInt(),
        );

    return [
      for (final v in remote)
        build(v, WorkdayCalendar.resolve(v['workday_offset'] as int, v['time'] as String)),
      for (final v in _changes.read(_local))
        build(v, DateTime.parse(v['visited_at'] as String)),
    ];
  }
}
