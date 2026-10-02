import '../../core/network/api_client.dart';
import '../../core/roles/app_role.dart';
import '../../core/session/session_store.dart';

/// Motivos de fallo del login que la pantalla traduce a mensajes.
enum LoginFailure {
  invalidCredentials,
  accessDenied,
  invalidUrl,
  serverNotFound,
  network,
  timeout,
  server,
  unknown,
}

class LoginException implements Exception {
  final LoginFailure failure;

  const LoginException(this.failure);
}

/// Autenticación contra el backend estático.
///
/// Como no hay servidor que valide credenciales, el login descarga
/// `users.json` y las comprueba en el dispositivo. Para una demo con datos
/// inventados es suficiente; el flujo de la app (URL configurable, sesión,
/// restauración, cierre) es el mismo que con una API real.
class AuthRepository {
  final ApiClient _api;
  final SessionStore _session;

  const AuthRepository(this._api, this._session);

  /// Restaura el servidor de la sesión guardada. Devuelve el usuario o null.
  SessionUser? restoreSession() {
    final user = _session.user;
    final url = _session.serverUrl;
    if (user == null || url == null) return null;
    _api.configure(url);
    return user;
  }

  Future<SessionUser> login({
    required String serverUrl,
    required String email,
    required String password,
  }) async {
    final normalizedUrl = ApiClient.normalizeUrl(serverUrl);
    _api.configure(normalizedUrl);

    final List<Map<String, dynamic>> users;
    final String companyName;
    try {
      users = (await _api.get('users') as List<dynamic>)
          .cast<Map<String, dynamic>>();
      final company = await _api.get('company') as Map<String, dynamic>;
      companyName = company['name'] as String? ?? '';
    } on ApiException catch (e) {
      throw LoginException(_mapApiError(e.type));
    } catch (_) {
      throw const LoginException(LoginFailure.unknown);
    }

    final login = email.trim().toLowerCase();
    final match = users.where(
      (u) =>
          (u['email'] as String?)?.toLowerCase() == login &&
          u['password'] == password,
    );
    if (match.isEmpty) {
      throw const LoginException(LoginFailure.invalidCredentials);
    }

    final json = match.first;
    final roles = (json['roles'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>();
    final role = AppRole.parse(roles.firstOrNull?['name'] as String?);
    if (role == AppRole.unknown) {
      throw const LoginException(LoginFailure.accessDenied);
    }

    final user = SessionUser(
      id: json['id'] as int,
      name: json['name'] as String,
      role: role,
      companyName: companyName,
    );
    await _session.saveSession(
      token: 'demo-token-${user.id}-${DateTime.now().millisecondsSinceEpoch}',
      serverUrl: normalizedUrl,
      user: user,
    );
    return user;
  }

  Future<void> logout() async {
    await _session.clearSession();
    _api.clearCache();
  }

  static LoginFailure _mapApiError(ApiErrorType type) => switch (type) {
        ApiErrorType.invalidUrl => LoginFailure.invalidUrl,
        ApiErrorType.notFound => LoginFailure.serverNotFound,
        ApiErrorType.network => LoginFailure.network,
        ApiErrorType.timeout => LoginFailure.timeout,
        ApiErrorType.server => LoginFailure.server,
        ApiErrorType.badResponse => LoginFailure.serverNotFound,
      };
}
