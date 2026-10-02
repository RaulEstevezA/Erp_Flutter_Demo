import '../../core/network/api_client.dart';
import '../../core/roles/permissions.dart';
import '../../core/session/session_store.dart';
import '../../core/utils/workday_calendar.dart';
import '../../domain/holidays.dart';
import '../local/local_changes_store.dart';
import 'user_repository.dart';

/// Vacaciones.
///
/// Aplica en el dispositivo las reglas que en el ERP aplica el servidor:
/// * gestión (`viewAllHolidays`) ve a toda la plantilla y aprueba/rechaza;
/// * el resto ve solo lo suyo, solicita y cancela sus solicitudes pendientes,
///   y recibe el resumen anual de días consumidos.
class HolidayRepository {
  static const _resource = 'holidays';
  static const _requests = 'holiday_requests';
  static const _statusChanges = 'holiday_status';
  static const _cancelled = 'cancelled';

  final ApiClient _api;
  final LocalChangesStore _local;
  final SessionStore _session;
  final UserRepository _users;

  const HolidayRepository(this._api, this._local, this._session, this._users);

  SessionUser get _me {
    final user = _session.user;
    if (user == null) throw StateError('No hay sesión activa.');
    return user;
  }

  Future<HolidaysResult> getHolidays({
    required DateTime since,
    required DateTime until,
  }) async {
    final me = _me;
    final seesEveryone = me.role.can(AppPermission.viewAllHolidays);
    final (:periods, :allowance) = await _load();

    final visible = periods
        .where(
          (p) =>
              (seesEveryone || p.workerId == me.id) &&
              !p.end.isBefore(since.startOfDay) &&
              !p.start.isAfter(until),
        )
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    final summary =
        seesEveryone ? null : _summary(periods, me.id, since.year, allowance);
    return HolidaysResult(visible, summary);
  }

  Future<void> request({
    required DateTime start,
    required DateTime end,
    String? reason,
  }) async {
    final me = _me;
    if (!me.role.can(AppPermission.requestHolidays)) {
      throw StateError('El rol ${me.role.key} no puede solicitar vacaciones.');
    }
    if (end.isBefore(start)) throw ArgumentError('Fin anterior al inicio.');

    await Future<void>.delayed(const Duration(milliseconds: 400));
    await _local.add(_requests, {
      'id': _local.nextId(_requests),
      'worker_id': me.id,
      'start': start.startOfDay.toIso8601String(),
      'end': end.startOfDay.toIso8601String(),
      'status': HolidayStatus.pending.name,
      'created_by': HolidayCreator.worker.name,
      'reason': reason,
    });
  }

  /// Gestión: aprueba o rechaza un período pendiente.
  Future<void> review(HolidayPeriod period, HolidayStatus status) async {
    if (!_me.role.can(AppPermission.viewAllHolidays)) {
      throw StateError('Solo gestión puede revisar vacaciones.');
    }
    await Future<void>.delayed(const Duration(milliseconds: 400));
    await _local.putInMap(_statusChanges, '${period.id}', status.name);
  }

  /// Trabajador: retira su propia solicitud mientras siga pendiente.
  Future<void> cancel(HolidayPeriod period) async {
    if (period.workerId != _me.id || !period.isPending) {
      throw StateError('Solo se pueden cancelar solicitudes propias pendientes.');
    }
    await Future<void>.delayed(const Duration(milliseconds: 400));
    await _local.putInMap(_statusChanges, '${period.id}', _cancelled);
  }

  // ── Construcción de los períodos ───────────────────────────────────────

  Future<({List<HolidayPeriod> periods, int allowance})> _load() async {
    final data = await _api.get(_resource) as Map<String, dynamic>;
    final national = (data['national_holidays'] as List).cast<String>().toSet();
    final company = (data['company_holidays'] as List).cast<String>().toSet();
    final names = await _users.byId();
    final changes = _local.readMap(_statusChanges);
    final today = DateTime.now().startOfDay;

    HolidayPeriod? build(Map<String, dynamic> json, DateTime start, DateTime end) {
      final id = json['id'] as int;
      final change = changes['$id'] as String?;
      if (change == _cancelled) return null;
      final workerId = json['worker_id'] as int;
      return HolidayPeriod(
        id: id,
        workerId: workerId,
        workerName: names[workerId]?.name,
        start: start,
        end: end,
        status: HolidayStatus.parse(change ?? json['status'] as String?),
        createdBy: HolidayCreator.parse(json['created_by'] as String?),
        reason: json['reason'] as String?,
        days: _breakdown(start, end, national, company),
      );
    }

    final remote = (data['periods'] as List).cast<Map<String, dynamic>>().map(
          (json) => build(
            json,
            today.add(Duration(days: json['start_offset'] as int)),
            today.add(Duration(days: json['end_offset'] as int)),
          ),
        );
    final local = _local.read(_requests).map(
          (json) => build(
            json,
            DateTime.parse(json['start'] as String),
            DateTime.parse(json['end'] as String),
          ),
        );
    return (
      periods: [...remote, ...local].whereType<HolidayPeriod>().toList(),
      allowance: data['annual_allowance'] as int? ?? 0,
    );
  }

  static List<HolidayDay> _breakdown(
    DateTime start,
    DateTime end,
    Set<String> national,
    Set<String> company,
  ) {
    final days = <HolidayDay>[];
    for (var d = start;
        !d.isAfter(end);
        d = DateTime(d.year, d.month, d.day + 1)) {
      final key = '${d.month.toString().padLeft(2, '0')}-'
          '${d.day.toString().padLeft(2, '0')}';
      final kind = national.contains(key)
          ? HolidayDayKind.nationalHoliday
          : company.contains(key)
              ? HolidayDayKind.companyHoliday
              : d.weekday >= DateTime.saturday
                  ? HolidayDayKind.restDay
                  : HolidayDayKind.vacation;
      days.add(HolidayDay(d, kind));
    }
    return days;
  }

  /// Días laborables aprobados del trabajador en [year], por origen.
  static HolidaySummary _summary(
    List<HolidayPeriod> all,
    int workerId,
    int year,
    int allowance,
  ) {
    var workerDays = 0;
    var companyDays = 0;
    for (final period in all) {
      if (period.workerId != workerId ||
          period.status != HolidayStatus.approved) {
        continue;
      }
      final days = period.days
          .where((d) => d.kind == HolidayDayKind.vacation && d.date.year == year)
          .length;
      if (period.createdBy == HolidayCreator.company) {
        companyDays += days;
      } else {
        workerDays += days;
      }
    }
    return HolidaySummary(
      year: year,
      total: allowance,
      workerDays: workerDays,
      companyDays: companyDays,
    );
  }
}
