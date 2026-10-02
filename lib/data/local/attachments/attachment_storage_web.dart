import 'dart:convert';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'attachment_storage.dart';

AttachmentStorage createStorage(SharedPreferences prefs) => _PrefsAttachmentStorage(prefs);

/// En la web no hay sistema de ficheros: base64 en el almacenamiento del
/// navegador. Si se llena, [save] lanza y la pantalla avisa del error.
class _PrefsAttachmentStorage implements AttachmentStorage {
  static const _prefix = 'attachment.';

  final SharedPreferences _prefs;

  _PrefsAttachmentStorage(this._prefs);

  @override
  Future<String> save(String name, Uint8List bytes) async {
    final key = '${DateTime.now().microsecondsSinceEpoch}_$name';
    final ok = await _prefs.setString('$_prefix$key', base64Encode(bytes));
    if (!ok) throw StateError('Sin espacio en el navegador.');
    return key;
  }

  @override
  Future<Uint8List?> read(String key) async {
    final raw = _prefs.getString('$_prefix$key');
    return raw == null ? null : base64Decode(raw);
  }

  @override
  Future<void> delete(String key) => _prefs.remove('$_prefix$key');

  @override
  Future<Source> audioSource(String key) async {
    final raw = _prefs.getString('$_prefix$key') ?? '';
    return UrlSource('data:${_mime(key)};base64,$raw');
  }

  @override
  Future<Uint8List> readRecording(String pathOrUrl) async =>
      (await http.get(Uri.parse(pathOrUrl))).bodyBytes;

  @override
  Future<String> recordingPath(String extension) async => '';

  static String _mime(String key) => switch (key.split('.').last.toLowerCase()) {
        'wav' => 'audio/wav',
        'm4a' || 'mp4' || 'aac' => 'audio/mp4',
        'ogg' || 'opus' => 'audio/ogg',
        'webm' => 'audio/webm',
        _ => 'application/octet-stream',
      };
}
