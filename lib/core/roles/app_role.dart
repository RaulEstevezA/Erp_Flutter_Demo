/// Roles de usuario que devuelve el backend en `roles[].name`.
enum AppRole {
  superAdmin('superadmin'),
  admin('admin'),
  user('user'),
  worker('worker'),
  customer('customer'),
  supplier('supplier'),

  /// Usuario sin rol reconocido: no tiene permisos.
  unknown('unknown');

  /// Nombre con el que el rol viaja en la API y se guarda en sesión.
  final String key;

  const AppRole(this.key);

  static AppRole parse(String? value) {
    final normalized = value?.trim().toLowerCase();
    return AppRole.values.firstWhere(
      (role) => role.key == normalized,
      orElse: () => AppRole.unknown,
    );
  }
}
