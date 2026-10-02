import 'app_role.dart';

/// Capacidades de la app. Cada módulo comprueba la suya antes de mostrarse.
enum AppPermission {
  clockInOut,
  viewOwnAttendance,
  viewAllAttendance,
  viewMessages,
  viewClients,
  viewWorkReports,
  createWorkReports,
  viewVisitReports,
  createVisitReports,
  viewHolidays,
  viewAllHolidays,
  requestHolidays,
}

/// Matriz rol → permisos. Es el único sitio que hay que tocar para cambiar
/// qué ve cada perfil.
abstract final class Permissions {
  static const Set<AppPermission> _management = {
    AppPermission.clockInOut,
    AppPermission.viewOwnAttendance,
    AppPermission.viewAllAttendance,
    AppPermission.viewMessages,
    AppPermission.viewClients,
    AppPermission.viewWorkReports,
    AppPermission.createWorkReports,
    AppPermission.viewVisitReports,
    AppPermission.createVisitReports,
    AppPermission.viewHolidays,
    AppPermission.viewAllHolidays,
  };

  static const Map<AppRole, Set<AppPermission>> _matrix = {
    AppRole.superAdmin: _management,
    AppRole.admin: _management,
    AppRole.user: {
      AppPermission.clockInOut,
      AppPermission.viewOwnAttendance,
      AppPermission.viewMessages,
      AppPermission.viewWorkReports,
      AppPermission.viewHolidays,
      AppPermission.requestHolidays,
    },
    AppRole.worker: {
      AppPermission.clockInOut,
      AppPermission.viewOwnAttendance,
      AppPermission.viewWorkReports,
      AppPermission.viewHolidays,
      AppPermission.requestHolidays,
    },
    AppRole.customer: {AppPermission.viewMessages},
    AppRole.supplier: {AppPermission.viewMessages},
    AppRole.unknown: {},
  };

  static bool has(AppRole role, AppPermission permission) =>
      _matrix[role]?.contains(permission) ?? false;
}

extension RolePermissionCheck on AppRole {
  bool can(AppPermission permission) => Permissions.has(this, permission);
}
