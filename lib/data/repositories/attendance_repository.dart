import 'dart:math';

import '../../core/network/api_client.dart';
import '../../core/roles/permissions.dart';
import '../../core/session/session_store.dart';
import '../../core/utils/workday_calendar.dart';
import '../../domain/attendance.dart';
import '../local/local_changes_store.dart';
import 'user_repository.dart';

/// Fichajes e incidencias.
///
/// Lee los datos estáticos del backend, les suma los cambios hechos en el
/// dispositivo y aplica las mismas reglas que aplicaría la API real:
/// los perfiles de gestión ven a toda la plantilla; el resto, solo lo suyo.
class AttendanceRepository {
  static const _records = 'clock_in_records';
  static const _incidents = 'clock_in_incidents';

  /// Ubicación ficticia de la oficina para simular el GPS al fichar.
  static const _officeLat = 39.4699;
  static const _officeLng = -0.3763;

  final ApiClient _api;
  final LocalChangesStore _local;
  final SessionStore _session;
  final UserRepository _users;
  final Random _random;

  AttendanceRepository(
    this._api,
    this._local,
    this._session,
    this._users, {
    Random? random,
  }) : _random = random ?? Random();

  SessionUser get _me {
    final user = _session.user;
    if (user == null) throw StateError('No hay sesión activa.');
    return user;
  }

  bool get _seesEveryone => _me.role.can(AppPermission.viewAllAttendance);

  // ── Fichajes ───────────────────────────────────────────────────────────

  /// Todos los fichajes (servidor + locales), del más reciente al más antiguo.
  Future<List<ClockRecord>> _allRecords() async {
    final remote = (await _api.get(_records) as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(
          (json) => ClockRecord.fromJson(
            json,
            date: WorkdayCalendar.resolve(
              json['workday_offset'] as int,
              json['time'] as String,
            ),
          ),
        );
    final local = _local.read(_records).map(
          (json) => ClockRecord.fromJson(
            json,
            date: DateTime.parse(json['date'] as String),
          ),
        );
    final users = await _users.byId();
    final now = DateTime.now();
    return [...remote, ...local]
        .where((r) => !r.date.isAfter(now))
        .map((r) => r.withUserName(users[r.userId]?.name))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// `true` si el último fichaje del usuario es una entrada.
  Future<bool> isCurrentlyWorking() async {
    final me = _me.id;
    final records = await _allRecords();
    final last = records.where((r) => r.userId == me).firstOrNull;
    return last?.isClockIn ?? false;
  }

  Future<void> clockIn() => _clock(ClockType.clockIn);

  Future<void> clockOut() => _clock(ClockType.clockOut);

  Future<void> _clock(ClockType type) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final record = ClockRecord(
      id: _local.nextId(_records),
      userId: _me.id,
      date: DateTime.now(),
      type: type,
      remarks: 'Fichaje desde la app',
      latitude: _officeLat + (_random.nextDouble() - 0.5) / 100,
      longitude: _officeLng + (_random.nextDouble() - 0.5) / 100,
    );
    await _local.add(_records, record.toJson());
  }

  Future<PageResult<ClockRecord>> getRecords({
    required DateTime since,
    required DateTime until,
    int page = 1,
    int perPage = 50,
  }) async {
    final me = _me.id;
    final seesEveryone = _seesEveryone;
    final visible = (await _allRecords()).where(
      (r) =>
          (seesEveryone || r.userId == me) &&
          !r.date.isBefore(since) &&
          !r.date.isAfter(until),
    );
    return _paginate(visible.toList(), page, perPage);
  }

  // ── Incidencias ────────────────────────────────────────────────────────

  Future<PageResult<ClockIncident>> getIncidents({
    required DateTime since,
    required DateTime until,
    int page = 1,
    int perPage = 25,
  }) async {
    final me = _me.id;
    final seesEveryone = _seesEveryone;
    final records = {for (final r in await _allRecords()) r.id: r};

    final remote = (await _api.get(_incidents) as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map((json) {
      final requestedOffset = json['requested_workday_offset'] as int?;
      return ClockIncident.fromJson(
        json,
        createdAt: WorkdayCalendar.resolve(
          json['created_workday_offset'] as int,
          json['created_time'] as String,
        ),
        requestedDate: requestedOffset == null
            ? null
            : WorkdayCalendar.resolve(
                requestedOffset,
                json['requested_time'] as String,
              ),
      );
    });
    final local = _local.read(_incidents).map((json) {
      final requested = json['requested_date'] as String?;
      return ClockIncident.fromJson(
        json,
        createdAt: DateTime.parse(json['created_at'] as String),
        requestedDate: requested == null ? null : DateTime.parse(requested),
      );
    });

    final visible = [...remote, ...local]
        .where(
          (i) =>
              (seesEveryone ||
                  i.reporterUserId == me ||
                  i.targetUserId == me) &&
              !i.createdAt.isBefore(since) &&
              !i.createdAt.isAfter(until),
        )
        .map((i) => i.withRecord(records[i.clockInRecordId]))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return _paginate(visible, page, perPage);
  }

  Future<void> createIncident({
    required ClockRecord record,
    required String reason,
    DateTime? requestedDate,
    ClockType? requestedType,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final incident = ClockIncident(
      id: _local.nextId(_incidents),
      clockInRecordId: record.id,
      reporterUserId: _me.id,
      targetUserId: record.userId,
      status: IncidentStatus.pending,
      reason: reason,
      requestedDate: requestedDate,
      requestedType: requestedType,
      createdAt: DateTime.now(),
    );
    await _local.add(_incidents, incident.toJson());
  }

  static PageResult<T> _paginate<T>(List<T> items, int page, int perPage) {
    final start = (page - 1) * perPage;
    if (start >= items.length) return PageResult(<T>[], hasMore: false);
    final end = min(start + perPage, items.length);
    return PageResult(items.sublist(start, end), hasMore: end < items.length);
  }
}
