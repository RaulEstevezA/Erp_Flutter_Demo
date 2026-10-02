import 'package:erp_flutter_demo/core/di/app_services.dart';
import 'package:erp_flutter_demo/data/repositories/auth_repository.dart';
import 'package:erp_flutter_demo/domain/attendance.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Usa el backend empaquetado (servidor "demo") con preferencias en memoria.
Future<AppServices> _loggedInAs(String email) async {
  SharedPreferences.setMockInitialValues({});
  final services = await AppServices.create();
  await services.auth.login(
    serverUrl: 'demo',
    email: email,
    password: 'demo1234',
  );
  return services;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final now = DateTime.now();
  final since = DateTime(now.year, now.month - 2);
  final until = DateTime(now.year, now.month, now.day, 23, 59, 59);

  test('credenciales incorrectas', () async {
    SharedPreferences.setMockInitialValues({});
    final services = await AppServices.create();
    expect(
      () => services.auth.login(
        serverUrl: 'demo',
        email: 'admin@erpflutter.dev',
        password: 'mala',
      ),
      throwsA(
        isA<LoginException>().having(
          (e) => e.failure,
          'failure',
          LoginFailure.invalidCredentials,
        ),
      ),
    );
  });

  test('un trabajador solo ve sus fichajes; un admin ve a todos', () async {
    final worker = await _loggedInAs('trabajador@erpflutter.dev');
    final own = await worker.attendance
        .getRecords(since: since, until: until, perPage: 10000);
    expect(own.items, isNotEmpty);
    expect(own.items.map((r) => r.userId).toSet(), {4});

    final admin = await _loggedInAs('admin@erpflutter.dev');
    final all = await admin.attendance
        .getRecords(since: since, until: until, perPage: 10000);
    expect(all.items.map((r) => r.userId).toSet().length, greaterThan(1));
    expect(all.items.every((r) => r.userName != null), isTrue);
  });

  test('la paginación respeta el tamaño de página', () async {
    final admin = await _loggedInAs('admin@erpflutter.dev');
    final first = await admin.attendance
        .getRecords(since: since, until: until, perPage: 50);
    expect(first.items, hasLength(50));
    expect(first.hasMore, isTrue);
  });

  test('fichar cambia el estado de trabajo', () async {
    // Ana López no tiene entrada hoy en los datos de fábrica.
    final user = await _loggedInAs('usuario@erpflutter.dev');
    expect(await user.attendance.isCurrentlyWorking(), isFalse);
    await user.attendance.clockIn();
    expect(await user.attendance.isCurrentlyWorking(), isTrue);
    await user.attendance.clockOut();
    expect(await user.attendance.isCurrentlyWorking(), isFalse);
  });

  test('una incidencia nueva aparece como pendiente', () async {
    final user = await _loggedInAs('usuario@erpflutter.dev');
    final record = (await user.attendance
            .getRecords(since: since, until: until, perPage: 1))
        .items
        .single;

    await user.attendance.createIncident(
      record: record,
      reason: 'Olvidé fichar la salida',
    );

    final incidents = await user.attendance
        .getIncidents(since: since, until: until, perPage: 1000);
    final created =
        incidents.items.firstWhere((i) => i.clockInRecordId == record.id &&
            i.reason == 'Olvidé fichar la salida');
    expect(created.status, IncidentStatus.pending);
    expect(created.recordDate, record.date);
    expect(incidents.items.every((i) => i.targetUserId == 3), isTrue);
  });
}
