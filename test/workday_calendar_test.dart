import 'package:erp_flutter_demo/core/roles/app_role.dart';
import 'package:erp_flutter_demo/core/roles/permissions.dart';
import 'package:erp_flutter_demo/core/utils/workday_calendar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WorkdayCalendar', () {
    // Viernes 2 de octubre de 2026.
    final friday = DateTime(2026, 10, 2, 12);

    test('offset 0 es hoy a la hora indicada', () {
      expect(
        WorkdayCalendar.resolve(0, '08:05', today: friday),
        DateTime(2026, 10, 2, 8, 5),
      );
    });

    test('salta fines de semana', () {
      final monday = DateTime(2026, 10, 5, 9);
      expect(
        WorkdayCalendar.resolve(1, '17:30', today: monday),
        DateTime(2026, 10, 2, 17, 30),
      );
      expect(
        WorkdayCalendar.resolve(5, '08:00', today: friday),
        DateTime(2026, 9, 25, 8),
      );
    });
  });

  group('Permissions', () {
    test('solo gestión ve los fichajes de todos', () {
      expect(AppRole.superAdmin.can(AppPermission.viewAllAttendance), isTrue);
      expect(AppRole.admin.can(AppPermission.viewAllAttendance), isTrue);
      expect(AppRole.user.can(AppPermission.viewAllAttendance), isFalse);
      expect(AppRole.worker.can(AppPermission.viewAllAttendance), isFalse);
    });

    test('clientes y proveedores no tienen módulos (solo el chat, que es libre)', () {
      for (final role in [AppRole.customer, AppRole.supplier]) {
        expect(AppPermission.values.where(role.can), isEmpty, reason: '$role');
      }
    });

    test('roles desconocidos no tienen permisos', () {
      expect(AppRole.parse('hacker'), AppRole.unknown);
      expect(
        AppPermission.values.where(AppRole.unknown.can),
        isEmpty,
      );
    });
  });
}
