import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'attachment_storage_io.dart'
    if (dart.library.js_interop) 'attachment_storage_web.dart' as platform;

/// Ficheros que el usuario adjunta a los partes (fotos y notas de voz).
///
/// El backend es de solo lectura, así que se guardan en el dispositivo:
/// en móvil y escritorio como ficheros en la carpeta de la app y en la web
/// en el almacenamiento del navegador (con poco espacio, unos pocos MB).
abstract class AttachmentStorage {
  factory AttachmentStorage(SharedPreferences prefs) => platform.createStorage(prefs);

  /// Guarda [bytes] y devuelve la clave con la que recuperarlos.
  Future<String> save(String name, Uint8List bytes);

  Future<Uint8List?> read(String key);

  Future<void> delete(String key);

  /// Borra todos los adjuntos (al restablecer los datos de la demo).
  Future<void> clear();

  /// Origen reproducible de un audio guardado.
  Future<Source> audioSource(String key);

  /// Lee una grabación recién terminada: una ruta de fichero en móvil y
  /// escritorio, o una URL `blob:` en la web.
  Future<Uint8List> readRecording(String pathOrUrl);

  /// Dónde dejar la grabación en curso (`''` en la web, que usa un blob).
  Future<String> recordingPath(String extension);
}
