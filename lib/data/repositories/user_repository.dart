import '../../core/network/api_client.dart';
import '../../domain/app_user.dart';

/// Directorio de usuarios del ERP (nombres para listados, destinatarios...).
class UserRepository {
  final ApiClient _api;

  const UserRepository(this._api);

  Future<List<AppUser>> all() async {
    final data = await _api.get('users') as List<dynamic>;
    return data.cast<Map<String, dynamic>>().map(AppUser.fromJson).toList();
  }

  Future<Map<int, AppUser>> byId() async =>
      {for (final user in await all()) user.id: user};
}
