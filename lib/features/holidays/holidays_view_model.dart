import 'package:flutter/foundation.dart';

import '../../core/roles/app_role.dart';
import '../../core/roles/permissions.dart';
import '../../core/state/period_list_view_model.dart';
import '../../data/repositories/holiday_repository.dart';
import '../../domain/holidays.dart';

enum HolidaysView { list, calendar }

/// Vacaciones.
///
/// Lo que puede hacer cada perfil sale de sus permisos:
/// * [canViewAll] (superadmin, admin): ve a toda la plantilla, agrupa por
///   persona y aprueba o rechaza ([canReview]). No solicita vacaciones.
/// * [canRequest] (usuario, trabajador): ve solo lo suyo con el resumen
///   anual, solicita vacaciones y cancela sus solicitudes pendientes.
///
/// La lista muestra el año completo; el calendario, mes a mes (también
/// meses futuros, para ver lo planificado).
class HolidaysViewModel extends ChangeNotifier {
  final HolidayRepository _repository;
  final int userId;
  final bool canViewAll;
  final bool canRequest;

  HolidaysViewModel(this._repository, {required this.userId, required AppRole role})
      : canViewAll = role.can(AppPermission.viewAllHolidays),
        canRequest = role.can(AppPermission.requestHolidays);

  bool get canReview => canViewAll;

  LoadStatus status = LoadStatus.initial;
  List<HolidayPeriod> periods = const [];
  HolidaySummary? summary;
  HolidaysView view = HolidaysView.list;
  bool isGrouped = false;
  DateTime month = _currentMonth();

  int _generation = 0;

  static DateTime _currentMonth() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  /// Un trabajador solo puede cancelar lo suyo y mientras esté pendiente.
  bool canCancel(HolidayPeriod period) =>
      canRequest && period.workerId == userId && period.isPending;

  Future<void> init() {
    view = HolidaysView.list;
    isGrouped = false;
    month = _currentMonth();
    return load();
  }

  Future<void> load() async {
    final generation = ++_generation;
    status = LoadStatus.loading;
    notifyListeners();

    final (since, until) = view == HolidaysView.list
        ? (DateTime(month.year), DateTime(month.year, 12, 31, 23, 59, 59))
        : (month, DateTime(month.year, month.month + 1, 0, 23, 59, 59));

    try {
      final result = await _repository.getHolidays(since: since, until: until);
      if (generation != _generation) return;
      periods = result.periods;
      summary = result.summary;
      status = LoadStatus.loaded;
    } catch (e) {
      if (generation != _generation) return;
      debugPrint('HolidaysViewModel → error de carga: $e');
      status = LoadStatus.error;
    }
    notifyListeners();
  }

  void toggleView() {
    view = view == HolidaysView.list ? HolidaysView.calendar : HolidaysView.list;
    load();
  }

  void toggleGrouping() {
    if (!canViewAll) return;
    isGrouped = !isGrouped;
    notifyListeners();
  }

  void previousMonth() {
    month = DateTime(month.year, month.month - 1);
    load();
  }

  void nextMonth() {
    month = DateTime(month.year, month.month + 1);
    load();
  }

  Future<bool> request(DateTime start, DateTime end, String? reason) =>
      _run(() => _repository.request(start: start, end: end, reason: reason));

  Future<bool> approve(HolidayPeriod period) =>
      _run(() => _repository.review(period, HolidayStatus.approved));

  Future<bool> reject(HolidayPeriod period) =>
      _run(() => _repository.review(period, HolidayStatus.rejected));

  Future<bool> cancel(HolidayPeriod period) =>
      _run(() => _repository.cancel(period));

  Future<bool> _run(Future<void> Function() action) async {
    try {
      await action();
      await load();
      return true;
    } catch (e) {
      debugPrint('HolidaysViewModel → acción fallida: $e');
      return false;
    }
  }
}
