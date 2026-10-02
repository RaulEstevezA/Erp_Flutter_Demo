import 'package:shared_preferences/shared_preferences.dart';

import '../roles/app_role.dart';

/// Datos del usuario autenticado que la app necesita sin ir a la red.
class SessionUser {
  final int id;
  final String name;
  final AppRole role;
  final String companyName;

  const SessionUser({
    required this.id,
    required this.name,
    required this.role,
    required this.companyName,
  });
}

/// Persistencia de la sesión y de las preferencias del login.
///
/// En una app real el token iría a almacenamiento seguro; en la demo no hay
/// secretos reales, así que basta con [SharedPreferences].
class SessionStore {
  static const _token = 'session.token';
  static const _serverUrl = 'session.server_url';
  static const _userId = 'session.user_id';
  static const _userName = 'session.user_name';
  static const _userRole = 'session.user_role';
  static const _companyName = 'session.company_name';
  static const _rememberUrl = 'login.remember_url';
  static const _rememberUser = 'login.remember_user';
  static const _rememberedEmail = 'login.remembered_email';

  final SharedPreferences _prefs;

  const SessionStore(this._prefs);

  bool get hasSession => (_prefs.getString(_token) ?? '').isNotEmpty;

  String? get serverUrl => _prefs.getString(_serverUrl);

  SessionUser? get user {
    final id = _prefs.getInt(_userId);
    if (!hasSession || id == null) return null;
    return SessionUser(
      id: id,
      name: _prefs.getString(_userName) ?? '',
      role: AppRole.parse(_prefs.getString(_userRole)),
      companyName: _prefs.getString(_companyName) ?? '',
    );
  }

  Future<void> saveSession({
    required String token,
    required String serverUrl,
    required SessionUser user,
  }) async {
    await _prefs.setString(_token, token);
    await _prefs.setString(_serverUrl, serverUrl);
    await _prefs.setInt(_userId, user.id);
    await _prefs.setString(_userName, user.name);
    await _prefs.setString(_userRole, user.role.key);
    await _prefs.setString(_companyName, user.companyName);
  }

  /// Cierra la sesión. La URL solo se conserva si el usuario pidió recordarla.
  Future<void> clearSession() async {
    for (final key in [_token, _userId, _userName, _userRole, _companyName]) {
      await _prefs.remove(key);
    }
    if (!rememberUrl) await _prefs.remove(_serverUrl);
  }

  // ── Preferencias del formulario de login ───────────────────────────────

  bool get rememberUrl => _prefs.getBool(_rememberUrl) ?? true;
  bool get rememberUser => _prefs.getBool(_rememberUser) ?? false;
  String? get rememberedEmail => _prefs.getString(_rememberedEmail);

  Future<void> saveLoginPreferences({
    required bool rememberUrl,
    required bool rememberUser,
    required String email,
  }) async {
    await _prefs.setBool(_rememberUrl, rememberUrl);
    await _prefs.setBool(_rememberUser, rememberUser);
    if (rememberUser) {
      await _prefs.setString(_rememberedEmail, email);
    } else {
      await _prefs.remove(_rememberedEmail);
    }
  }
}
