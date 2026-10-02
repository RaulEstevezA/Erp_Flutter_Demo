import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Guarda en el dispositivo lo que en un backend real sería un POST.
///
/// Cada colección es una lista JSON bajo su propia clave. Los repositorios
/// mezclan estos elementos con los datos estáticos del servidor, de modo
/// que la demo se comporta como si las escrituras hubieran llegado al ERP.
class LocalChangesStore {
  /// Los ids locales empiezan aquí para no chocar con los del backend.
  static const int _firstLocalId = 1000000;

  final SharedPreferences _prefs;

  const LocalChangesStore(this._prefs);

  List<Map<String, dynamic>> read(String collection) {
    final raw = _prefs.getString(_key(collection));
    if (raw == null) return [];
    return (jsonDecode(raw) as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<void> add(String collection, Map<String, dynamic> item) async {
    final items = read(collection)..add(item);
    await _prefs.setString(_key(collection), jsonEncode(items));
  }

  Future<void> removeWhere(
    String collection,
    bool Function(Map<String, dynamic> item) test,
  ) async {
    final items = read(collection)..removeWhere(test);
    await _prefs.setString(_key(collection), jsonEncode(items));
  }

  /// Mapa clave → valor para modificaciones sobre datos del servidor
  /// (p. ej. el nuevo estado de una solicitud aprobada en el dispositivo).
  Map<String, dynamic> readMap(String name) {
    final raw = _prefs.getString(_key(name));
    if (raw == null) return {};
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> putInMap(String name, String key, Object? value) async {
    final map = readMap(name)..[key] = value;
    await _prefs.setString(_key(name), jsonEncode(map));
  }

  int nextId(String collection) {
    // Registros sin id numérico (de versiones anteriores) no cuentan.
    final ids = read(collection).map((e) => e['id']).whereType<int>();
    return ids.isEmpty ? _firstLocalId : ids.reduce((a, b) => a > b ? a : b) + 1;
  }

  /// Borra todos los cambios locales (vuelve a los datos de fábrica).
  Future<void> reset() async {
    final keys = _prefs.getKeys().where((k) => k.startsWith('local.'));
    for (final key in keys.toList()) {
      await _prefs.remove(key);
    }
  }

  String _key(String collection) => 'local.$collection';
}
