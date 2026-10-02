import 'package:erp_flutter_demo/core/di/app_services.dart';
import 'package:erp_flutter_demo/core/roles/app_role.dart';
import 'package:erp_flutter_demo/data/repositories/holiday_repository.dart';
import 'package:erp_flutter_demo/domain/holidays.dart';
import 'package:erp_flutter_demo/features/holidays/holidays_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<AppServices> _loggedInAs(String email) async {
  SharedPreferences.setMockInitialValues({});
  final services = await AppServices.create();
  await services.auth.login(serverUrl: 'demo', email: email, password: 'demo1234');
  return services;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final now = DateTime.now();
  final yearStart = DateTime(now.year);
  final yearEnd = DateTime(now.year, 12, 31, 23, 59, 59);

  group('permisos de la pantalla', () {
    HolidaysViewModel vm(AppRole role) =>
        HolidaysViewModel(_NoRepo(), userId: 1, role: role);

    test('gestión ve a todos y revisa, pero no solicita', () {
      for (final role in [AppRole.superAdmin, AppRole.admin]) {
        final model = vm(role);
        expect(model.canViewAll, isTrue, reason: '$role');
        expect(model.canReview, isTrue, reason: '$role');
        expect(model.canRequest, isFalse, reason: '$role');
      }
    });

    test('usuario y trabajador solicitan pero no revisan', () {
      for (final role in [AppRole.user, AppRole.worker]) {
        final model = vm(role);
        expect(model.canViewAll, isFalse, reason: '$role');
        expect(model.canReview, isFalse, reason: '$role');
        expect(model.canRequest, isTrue, reason: '$role');
      }
    });
  });

  test('un trabajador ve solo lo suyo y tiene resumen anual', () async {
    final s = await _loggedInAs('trabajador@erpflutter.dev');
    final result = await s.holidays.getHolidays(since: yearStart, until: yearEnd);
    expect(result.periods, isNotEmpty);
    expect(result.periods.map((p) => p.workerId).toSet(), {4});
    expect(result.summary, isNotNull);
    expect(result.summary!.total, 23);
    expect(result.summary!.companyDays, greaterThan(0));
  });

  test('un admin ve a toda la plantilla y no tiene resumen', () async {
    final s = await _loggedInAs('admin@erpflutter.dev');
    final result = await s.holidays.getHolidays(since: yearStart, until: yearEnd);
    expect(result.periods.map((p) => p.workerId).toSet().length, greaterThan(1));
    expect(result.summary, isNull);
  });

  test('el desglose separa festivos y fines de semana', () async {
    final s = await _loggedInAs('admin@erpflutter.dev');
    final result = await s.holidays.getHolidays(since: yearStart, until: yearEnd);
    for (final period in result.periods) {
      for (final day in period.days) {
        if (day.date.weekday >= DateTime.saturday) {
          expect(day.kind, isNot(HolidayDayKind.vacation));
        }
      }
      expect(period.workingDays, lessThanOrEqualTo(period.naturalDays));
    }
  });

  test('solicitar → pendiente; el propio trabajador puede cancelarla', () async {
    final s = await _loggedInAs('usuario@erpflutter.dev');
    final start = DateTime(now.year + 1, 2, 2);
    await s.holidays.request(start: start, end: start.add(const Duration(days: 4)));

    var periods = (await s.holidays.getHolidays(
      since: DateTime(now.year + 1),
      until: DateTime(now.year + 1, 12, 31),
    )).periods;
    final created = periods.singleWhere((p) => p.start == start);
    expect(created.status, HolidayStatus.pending);
    expect(created.createdBy, HolidayCreator.worker);

    await s.holidays.cancel(created);
    periods = (await s.holidays.getHolidays(
      since: DateTime(now.year + 1),
      until: DateTime(now.year + 1, 12, 31),
    )).periods;
    expect(periods.where((p) => p.start == start), isEmpty);
  });

  test('gestión no puede solicitar y un trabajador no puede aprobar', () async {
    final admin = await _loggedInAs('admin@erpflutter.dev');
    expect(
      () => admin.holidays.request(start: DateTime(now.year + 1), end: DateTime(now.year + 1)),
      throwsStateError,
    );

    final worker = await _loggedInAs('trabajador@erpflutter.dev');
    final pending = (await worker.holidays.getHolidays(since: yearStart, until: yearEnd))
        .periods
        .firstWhere((p) => p.isPending);
    expect(() => worker.holidays.review(pending, HolidayStatus.approved), throwsStateError);
  });

  test('un admin aprueba una solicitud pendiente', () async {
    final s = await _loggedInAs('admin@erpflutter.dev');
    final pending = (await s.holidays.getHolidays(since: yearStart, until: yearEnd))
        .periods
        .firstWhere((p) => p.isPending);
    await s.holidays.review(pending, HolidayStatus.approved);
    final after = (await s.holidays.getHolidays(since: yearStart, until: yearEnd))
        .periods
        .singleWhere((p) => p.id == pending.id);
    expect(after.status, HolidayStatus.approved);
  });
}

/// Repositorio vacío: los tests de permisos no llegan a cargar datos.
class _NoRepo implements HolidayRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
