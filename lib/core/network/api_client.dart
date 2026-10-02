import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

/// Motivos por los que una lectura del backend puede fallar.
enum ApiErrorType { invalidUrl, notFound, network, timeout, server, badResponse }

class ApiException implements Exception {
  final ApiErrorType type;
  final String? detail;

  const ApiException(this.type, [this.detail]);

  @override
  String toString() => 'ApiException($type${detail == null ? '' : ': $detail'})';
}

/// Cliente del backend estático.
///
/// El backend son ficheros JSON (`backend/api/<recurso>.json`) que pueden
/// servirse desde GitHub Pages o leerse del bundle de la app:
///
/// * URL `demo` → se leen los assets empaquetados (funciona sin red).
/// * Cualquier otra URL → `GET <url>/api/<recurso>.json`.
///
/// Al ser estático, las escrituras (fichajes, incidencias...) no viajan al
/// servidor: los repositorios las guardan en local y las mezclan con lo que
/// devuelve este cliente.
class ApiClient {
  /// Valor especial del campo "URL del servidor" para usar los datos locales.
  static const String demoServer = 'demo';

  static const Duration _timeout = Duration(seconds: 15);

  /// Latencia artificial para que la demo se comporte como una API real
  /// (indicadores de carga, scroll infinito...).
  static const Duration _simulatedLatency = Duration(milliseconds: 350);

  final http.Client _http;
  final Map<String, Object?> _cache = {};
  String _baseUrl = demoServer;

  ApiClient({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  String get baseUrl => _baseUrl;

  bool get isDemo => _baseUrl == demoServer;

  /// Cambia el servidor activo y descarta la caché del anterior.
  void configure(String baseUrl) {
    final normalized = normalizeUrl(baseUrl);
    if (normalized == _baseUrl) return;
    _baseUrl = normalized;
    _cache.clear();
  }

  void clearCache() => _cache.clear();

  /// Devuelve el campo `data` del recurso [resource] (p. ej. `users`).
  Future<Object?> get(String resource) async {
    await Future<void>.delayed(_simulatedLatency);
    if (_cache.containsKey(resource)) return _cache[resource];

    final body = isDemo ? await _readAsset(resource) : await _fetch(resource);
    final Object? decoded;
    try {
      decoded = jsonDecode(body);
    } on FormatException catch (e) {
      throw ApiException(ApiErrorType.badResponse, e.message);
    }
    if (decoded is! Map<String, dynamic> || !decoded.containsKey('data')) {
      throw const ApiException(ApiErrorType.badResponse, 'Falta "data"');
    }
    return _cache[resource] = decoded['data'];
  }

  Future<String> _readAsset(String resource) async {
    try {
      return await rootBundle.loadString('backend/api/$resource.json');
    } catch (_) {
      throw ApiException(ApiErrorType.notFound, resource);
    }
  }

  Future<String> _fetch(String resource) async {
    final Uri uri;
    try {
      uri = Uri.parse('$_baseUrl/api/$resource.json');
      if (!uri.hasAuthority) throw const FormatException();
    } on FormatException {
      throw const ApiException(ApiErrorType.invalidUrl);
    }

    final http.Response response;
    try {
      response = await _http.get(uri).timeout(_timeout);
    } on TimeoutException {
      throw const ApiException(ApiErrorType.timeout);
    } catch (e) {
      throw ApiException(ApiErrorType.network, '$e');
    }

    if (response.statusCode == 404) {
      throw ApiException(ApiErrorType.notFound, '$uri');
    }
    if (response.statusCode >= 500) {
      throw ApiException(ApiErrorType.server, '${response.statusCode}');
    }
    if (response.statusCode != 200) {
      throw ApiException(ApiErrorType.badResponse, '${response.statusCode}');
    }
    return utf8.decode(response.bodyBytes);
  }

  /// Limpia la URL introducida por el usuario: añade `https://` si falta y
  /// quita la barra final. `demo` (sin distinguir mayúsculas) se respeta.
  static String normalizeUrl(String raw) {
    var url = raw.trim();
    if (url.toLowerCase() == demoServer) return demoServer;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    return url;
  }
}
