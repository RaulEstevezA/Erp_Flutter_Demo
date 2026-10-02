import 'app_role.dart';

/// Capacidades de la app. Cada módulo comprueba la suya antes de mostrarse.
///
/// La mensajería no aparece: es un chat abierto a todos los usuarios.
enum AppPermission {
  clockInOut,
  viewOwnAttendance,
  viewAllAttendance,
  viewClients,
  viewWorkReports,
  /// Ver todos los partes, no solo aquellos en los que se está asignado.
  viewAllWorkReports,
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
    AppPermission.viewClients,
    AppPermission.viewWorkReports,
    AppPermission.viewAllWorkReports,
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
    AppRole.customer: {},
    AppRole.supplier: {},
    AppRole.unknown: {},
  };

  static bool has(AppRole role, AppPermission permission) =>
      _matrix[role]?.contains(permission) ?? false;
}

extension RolePermissionCheck on AppRole {
  bool can(AppPermission permission) => Permissions.has(this, permission);
}
