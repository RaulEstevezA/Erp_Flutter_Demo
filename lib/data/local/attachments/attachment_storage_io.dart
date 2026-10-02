import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'attachment_storage.dart';

AttachmentStorage createStorage(SharedPreferences prefs) => _FileAttachmentStorage();

/// Ficheros en `<soporte de la app>/attachments`.
class _FileAttachmentStorage implements AttachmentStorage {
  Directory? _dir;

  Future<Directory> _folder() async {
    return _dir ??= await Directory(
      '${(await getApplicationSupportDirectory()).path}/attachments',
    ).create(recursive: true);
  }

  Future<File> _file(String key) async => File('${(await _folder()).path}/$key');

  @override
  Future<String> save(String name, Uint8List bytes) async {
    final key = '${DateTime.now().microsecondsSinceEpoch}_$name';
    await (await _file(key)).writeAsBytes(bytes, flush: true);
    return key;
  }

  @override
  Future<Uint8List?> read(String key) async {
    final file = await _file(key);
    return await file.exists() ? file.readAsBytes() : null;
  }

  @override
  Future<void> delete(String key) async {
    final file = await _file(key);
    if (await file.exists()) await file.delete();
  }

  @override
  Future<void> clear() async {
    final folder = await _folder();
    if (await folder.exists()) await folder.delete(recursive: true);
    _dir = null;
  }

  @override
  Future<Source> audioSource(String key) async => DeviceFileSource((await _file(key)).path);

  @override
  Future<Uint8List> readRecording(String pathOrUrl) async {
    final file = File(pathOrUrl);
    final bytes = await file.readAsBytes();
    await file.delete();
    return bytes;
  }

  @override
  Future<String> recordingPath(String extension) async =>
      '${(await getTemporaryDirectory()).path}/grabacion_${DateTime.now().millisecondsSinceEpoch}.$extension';
}
