import 'package:flutter/foundation.dart';

import '../../core/state/period_list_view_model.dart' show LoadStatus;
import '../../data/repositories/work_report_repository.dart';
import '../../domain/work_reports.dart';

enum AddFileOutcome { added, tooLarge, failed }

/// Archivos de un parte. La cámara, la galería, el micrófono y el
/// reproductor los gestiona la pantalla; aquí solo los datos.
class WorkReportFilesViewModel extends ChangeNotifier {
  final WorkReportRepository _repository;
  final int reportId;

  WorkReportFilesViewModel(this._repository, {required this.reportId});

  LoadStatus _status = LoadStatus.initial;
  List<WorkReportFile> _files = const [];
  bool _isSaving = false;
  bool _isRecording = false;
  int? _deletingId;
  int? _playingId;

  LoadStatus get status => _status;
  List<WorkReportFile> get files => _files;
  bool get isSaving => _isSaving;
  bool get isRecording => _isRecording;
  int? get deletingId => _deletingId;
  int? get playingId => _playingId;
  WorkReportRepository get repository => _repository;

  Future<void> load() async {
    _status = LoadStatus.loading;
    notifyListeners();
    try {
      _files = await _repository.getFiles(reportId);
      _status = LoadStatus.loaded;
    } catch (e) {
      debugPrint('Archivos → error de carga: $e');
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  Future<AddFileOutcome> add(String name, Uint8List bytes, WorkReportFileType type) async {
    _isSaving = true;
    notifyListeners();
    try {
      await _repository.addFile(reportId, name: name, bytes: bytes, type: type);
      _files = await _repository.getFiles(reportId);
      return AddFileOutcome.added;
    } on FileTooLargeException {
      return AddFileOutcome.tooLarge;
    } catch (e) {
      debugPrint('Archivos → error al guardar: $e');
      return AddFileOutcome.failed;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> delete(WorkReportFile file) async {
    _deletingId = file.id;
    notifyListeners();
    try {
      await _repository.deleteFile(reportId, file);
      _files = [..._files]..removeWhere((f) => f.id == file.id);
      return true;
    } catch (_) {
      return false;
    } finally {
      _deletingId = null;
      notifyListeners();
    }
  }

  void setRecording(bool value) {
    _isRecording = value;
    notifyListeners();
  }

  void setPlaying(int? fileId) {
    _playingId = fileId;
    notifyListeners();
  }
}
