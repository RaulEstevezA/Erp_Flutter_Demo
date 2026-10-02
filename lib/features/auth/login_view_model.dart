import 'package:flutter/foundation.dart';

import '../../core/network/api_client.dart';
import '../../core/session/session_store.dart';
import '../../data/repositories/auth_repository.dart';

/// Errores que puede mostrar el formulario (validación + fallos de login).
enum LoginError {
  emptyServerUrl,
  emptyEmail,
  emptyPassword,
  invalidCredentials,
  accessDenied,
  invalidUrl,
  serverNotFound,
  network,
  timeout,
  server,
  unknown,
}

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _auth;
  final SessionStore _session;

  LoginViewModel(this._auth, this._session)
      : rememberUrl = _session.rememberUrl,
        rememberUser = _session.rememberUser;

  bool isLoading = false;
  LoginError? error;
  bool rememberUrl;
  bool rememberUser;

  /// Valores con los que arranca el formulario.
  String get initialServerUrl {
    final saved = _session.serverUrl;
    return rememberUrl && saved != null ? saved : ApiClient.demoServer;
  }

  String get initialEmail =>
      rememberUser ? (_session.rememberedEmail ?? '') : '';

  void setRememberUrl(bool value) {
    rememberUrl = value;
    notifyListeners();
  }

  void setRememberUser(bool value) {
    rememberUser = value;
    notifyListeners();
  }

  void clearError() {
    if (error == null) return;
    error = null;
    notifyListeners();
  }

  /// Devuelve el usuario si el login es correcto; si no, deja [error].
  Future<SessionUser?> login({
    required String serverUrl,
    required String email,
    required String password,
  }) async {
    if (isLoading) return null;

    error = _validate(serverUrl, email, password);
    if (error != null) {
      notifyListeners();
      return null;
    }

    isLoading = true;
    notifyListeners();

    try {
      final user = await _auth.login(
        serverUrl: serverUrl,
        email: email,
        password: password,
      );
      await _session.saveLoginPreferences(
        rememberUrl: rememberUrl,
        rememberUser: rememberUser,
        email: email.trim(),
      );
      return user;
    } on LoginException catch (e) {
      error = _fromFailure(e.failure);
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  static LoginError? _validate(String url, String email, String password) {
    if (url.trim().isEmpty) return LoginError.emptyServerUrl;
    if (email.trim().isEmpty) return LoginError.emptyEmail;
    if (password.isEmpty) return LoginError.emptyPassword;
    return null;
  }

  static LoginError _fromFailure(LoginFailure failure) => switch (failure) {
        LoginFailure.invalidCredentials => LoginError.invalidCredentials,
        LoginFailure.accessDenied => LoginError.accessDenied,
        LoginFailure.invalidUrl => LoginError.invalidUrl,
        LoginFailure.serverNotFound => LoginError.serverNotFound,
        LoginFailure.network => LoginError.network,
        LoginFailure.timeout => LoginError.timeout,
        LoginFailure.server => LoginError.server,
        LoginFailure.unknown => LoginError.unknown,
      };
}
