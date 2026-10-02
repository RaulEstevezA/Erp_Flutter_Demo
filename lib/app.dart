import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/di/app_services.dart';
import 'core/session/session_store.dart';
import 'core/settings/app_settings.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/login_view_model.dart';
import 'features/shell/app_shell.dart';
import 'features/splash/splash_screen.dart';
import 'l10n/app_localizations.dart';

/// Raíz de la app: splash → login o shell según haya sesión guardada.
class ErpFlutterApp extends StatefulWidget {
  final AppServices services;

  const ErpFlutterApp({super.key, required this.services});

  @override
  State<ErpFlutterApp> createState() => _ErpFlutterAppState();
}

class _ErpFlutterAppState extends State<ErpFlutterApp> {
  late SessionUser? _user = widget.services.auth.restoreSession();
  bool _showSplash = true;

  /// Se recrea al cerrar sesión para que el formulario arranque limpio.
  late LoginViewModel _login = _newLoginViewModel();

  LoginViewModel _newLoginViewModel() =>
      LoginViewModel(widget.services.auth, widget.services.session);

  void _onLoggedIn(SessionUser user) => setState(() => _user = user);

  Future<void> _logout() async {
    await widget.services.auth.logout();
    if (!mounted) return;
    setState(() {
      _login.dispose();
      _login = _newLoginViewModel();
      _user = null;
    });
  }

  Widget _home() {
    if (_showSplash) {
      return SplashScreen(
        key: const ValueKey('splash'),
        onFinished: () => setState(() => _showSplash = false),
      );
    }
    final user = _user;
    if (user == null) {
      return LoginScreen(
        key: const ValueKey('login'),
        viewModel: _login,
        settings: widget.services.settings,
        onLoggedIn: _onLoggedIn,
      );
    }
    return AppShell(
      key: ValueKey('shell-${user.id}'),
      services: widget.services,
      user: user,
      onLogout: _logout,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = widget.services.settings;

    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) => MaterialApp(
        title: 'ERP Flutter',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: settings.themeMode,
        locale: settings.language.locale,
        supportedLocales: AppLanguage.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: AnimatedSwitcher(
          duration: const Duration(milliseconds: 450),
          child: _home(),
        ),
      ),
    );
  }
}
