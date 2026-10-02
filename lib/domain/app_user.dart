import '../core/roles/app_role.dart';

/// Usuario del ERP tal como lo expone `users.json`.
class AppUser {
  final int id;
  final String name;
  final String email;
  final AppRole role;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final roles = (json['roles'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((r) => r['name'] as String?);
    return AppUser(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String? ?? '',
      role: AppRole.parse(roles.firstOrNull),
    );
  }
}
