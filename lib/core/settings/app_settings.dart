import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Idiomas disponibles, con la etiqueta corta que muestra el selector.
enum AppLanguage {
  es(Locale('es'), 'ESP'),
  val(Locale('ca', 'ES'), 'VAL'),
  ca(Locale('ca'), 'CAT'),
  en(Locale('en'), 'ENG');

  final Locale locale;
  final String shortLabel;

  const AppLanguage(this.locale, this.shortLabel);

  static List<Locale> get supportedLocales =>
      values.map((l) => l.locale).toList();
}

/// Preferencias de la app que sobreviven al cierre de sesión: idioma y tema.
class AppSettings extends ChangeNotifier {
  static const _languageKey = 'settings.language';
  static const _darkKey = 'settings.dark_mode';

  final SharedPreferences _prefs;

  AppSettings(this._prefs);

  AppLanguage get language => AppLanguage.values.firstWhere(
        (l) => l.name == _prefs.getString(_languageKey),
        orElse: () => AppLanguage.es,
      );

  ThemeMode get themeMode =>
      (_prefs.getBool(_darkKey) ?? false) ? ThemeMode.dark : ThemeMode.light;

  bool get isDark => themeMode == ThemeMode.dark;

  Future<void> setLanguage(AppLanguage language) async {
    await _prefs.setString(_languageKey, language.name);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    await _prefs.setBool(_darkKey, !isDark);
    notifyListeners();
  }
}
