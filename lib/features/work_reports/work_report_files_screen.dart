import 'dart:async';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';

import '../../core/state/period_list_view_model.dart' show LoadStatus;
import '../../core/theme/app_colors.dart';
import '../../core/widgets/list_parts.dart';
import '../../core/widgets/menu_leading.dart';
import '../../domain/work_reports.dart';
import '../../l10n/app_localizations.dart';
import 'work_report_files_view_model.dart';

/// Fotos y notas de voz de un parte: añadir desde cámara o galería, grabar
/// audio, reproducirlo y eliminar.
class WorkReportFilesScreen extends StatefulWidget {
  final WorkReportFilesViewModel viewModel;
  final VoidCallback onOpenDrawer;

  const WorkReportFilesScreen({super.key, required this.viewModel, required this.onOpenDrawer});

  @override
  State<WorkReportFilesScreen> createState() => _WorkReportFilesScreenState();
}

class _WorkReportFilesScreenState extends State<WorkReportFilesScreen> {
  final _picker = ImagePicker();
  final _player = AudioPlayer();
  AudioRecorder? _recorder;
  String _recordingExtension = 'm4a';
  StreamSubscription<void>? _playerDone;

  WorkReportFilesViewModel get _vm => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _playerDone = _player.onPlayerComplete.listen((_) => _vm.setPlaying(null));
    _vm.load();
  }

  @override
  void dispose() {
    _playerDone?.cancel();
    _player.dispose();
    _recorder?.dispose();
    _vm.dispose();
    super.dispose();
  }

  // ── Añadir ─────────────────────────────────────────────────────────────

  Future<void> _pickImage(ImageSource source) async {
    final l10n = AppLocalizations.of(context);
    try {
      final file = await _picker.pickImage(source: source, maxWidth: 1600, imageQuality: 80);
      if (file == null) return;
      final name = file.name.isNotEmpty ? file.name : 'foto_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await _store(name, await file.readAsBytes(), WorkReportFileType.image);
    } catch (e) {
      debugPrint('Archivos → error con la imagen: $e');
      _showError(l10n.workReportsFilesUploadError);
    }
  }

  Future<void> _startRecording() async {
    final l10n = AppLocalizations.of(context);
    final recorder = _recorder ??= AudioRecorder();
    try {
      if (!await recorder.hasPermission()) {
        _showError(l10n.workReportsFilesMicDenied);
        return;
      }
      // WAV en la web (lo reproducen todos los navegadores); AAC en el resto.
      final (encoder, extension) = kIsWeb ? (AudioEncoder.wav, 'wav') : (AudioEncoder.aacLc, 'm4a');
      await recorder.start(
        RecordConfig(encoder: encoder, sampleRate: 16000, numChannels: 1),
        path: await _vm.repository.attachments.recordingPath(extension),
      );
      _recordingExtension = extension;
      _vm.setRecording(true);
    } catch (e) {
      debugPrint('Archivos → no se pudo grabar: $e');
      _showError(l10n.workReportsFilesUploadError);
    }
  }

  Future<void> _stopRecording() async {
    final recorder = _recorder;
    if (recorder == null) return;
    try {
      final path = await recorder.stop();
      _vm.setRecording(false);
      if (path == null) return;
      final bytes = await _vm.repository.attachments.readRecording(path);
      final name = 'nota_${DateTime.now().millisecondsSinceEpoch}.$_recordingExtension';
      await _store(name, bytes, WorkReportFileType.audio);
    } catch (e) {
      debugPrint('Archivos → error al parar la grabación: $e');
      _vm.setRecording(false);
      if (mounted) _showError(AppLocalizations.of(context).workReportsFilesUploadError);
    }
  }

  Future<void> _store(String name, Uint8List bytes, WorkReportFileType type) async {
    final outcome = await _vm.add(name, bytes, type);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    switch (outcome) {
      case AddFileOutcome.added:
        break;
      case AddFileOutcome.tooLarge:
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.workReportsFilesMaxSizeErrorTitle),
            content: Text(l10n.workReportsFilesMaxSizeErrorMessage),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.dialogAccept)),
            ],
          ),
        );
      case AddFileOutcome.failed:
        _showError(l10n.workReportsFilesUploadError);
    }
  }

  void _showAddOptions() {
    final l10n = AppLocalizations.of(context);
    final canUseCamera = _picker.supportsImageSource(ImageSource.camera);

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (canUseCamera)
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: Text(l10n.workReportsFilesCamera),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickImage(ImageSource.camera);
                },
              ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.workReportsFilesGallery),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.mic_outlined),
              title: Text(l10n.workReportsFilesRecordAudio),
              onTap: () {
                Navigator.pop(sheetContext);
                _startRecording();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Reproducir y borrar ────────────────────────────────────────────────

  Future<void> _togglePlay(WorkReportFile file) async {
    try {
      if (_vm.playingId == file.id) {
        await _player.stop();
        _vm.setPlaying(null);
        return;
      }
      await _player.stop();
      _vm.setPlaying(file.id);
      final source = file.asset != null
          ? AssetSource('demo_files/${file.asset}')
          : await _vm.repository.attachments.audioSource(file.storageKey!);
      await _player.play(source);
    } catch (e) {
      debugPrint('Archivos → no se pudo reproducir: $e');
      _vm.setPlaying(null);
    }
  }

  Future<void> _confirmDelete(WorkReportFile file) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.workReportsFilesDeleteConfirmTitle),
        content: Text(l10n.workReportsFilesDeleteConfirmMessage),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.dialogCancel)),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l10n.workReportsFilesDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    if (_vm.playingId == file.id) {
      await _player.stop();
      _vm.setPlaying(null);
    }
    final ok = await _vm.delete(file);
    if (!ok && mounted) _showError(l10n.workReportsFilesDeleteError);
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), backgroundColor: AppColors.error));
  }

  void _openImage(WorkReportFile file) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _ImageViewer(file: file, load: () => _vm.repository.fileBytes(file)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            leadingWidth: MenuLeading.fullWidth,
            leading: MenuLeading(onOpenDrawer: widget.onOpenDrawer),
            title: Text(l10n.workReportsButtonFiles),
          ),
          body: Column(
            children: [
              Container(
                width: double.infinity,
                color: AppColors.pending.withValues(alpha: 0.12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 14, color: Color(0xFFB45309)),
                    const SizedBox(width: 8),
                    Text(
                      l10n.workReportsFilesMaxSizeHint,
                      style: const TextStyle(fontSize: 12, color: Color(0xFFB45309)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(child: _content(l10n)),
                    if (_vm.isSaving || _vm.isRecording)
                      Positioned.fill(child: _BusyOverlay(recording: _vm.isRecording)),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            tooltip: _vm.isRecording ? l10n.workReportsFilesStopRecord : l10n.workReportsFilesRecordAudio,
            onPressed: _vm.isSaving
                ? null
                : _vm.isRecording
                    ? _stopRecording
                    : _showAddOptions,
            backgroundColor: _vm.isRecording ? AppColors.error : null,
            foregroundColor: _vm.isRecording ? Colors.white : null,
            child: Icon(_vm.isRecording ? Icons.stop : Icons.add),
          ),
        );
      },
    );
  }

  Widget _content(AppLocalizations l10n) {
    return switch (_vm.status) {
      LoadStatus.initial || LoadStatus.loading => const Center(child: CircularProgressIndicator()),
      LoadStatus.error => LoadErrorView(message: l10n.workReportsFilesErrorLoad, onRetry: _vm.load),
      LoadStatus.loaded when _vm.files.isEmpty =>
        EmptyView(message: l10n.workReportsFilesEmpty, icon: Icons.attach_file),
      LoadStatus.loaded => ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
          itemCount: _vm.files.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final file = _vm.files[index];
            final deleting = _vm.deletingId == file.id;
            return file.isImage
                ? _ImageCard(
                    file: file,
                    load: () => _vm.repository.fileBytes(file),
                    deleting: deleting,
                    onOpen: () => _openImage(file),
                    onDelete: () => _confirmDelete(file),
                  )
                : _AudioCard(
                    file: file,
                    playing: _vm.playingId == file.id,
                    deleting: deleting,
                    onTogglePlay: () => _togglePlay(file),
                    onDelete: () => _confirmDelete(file),
                  );
          },
        ),
    };
  }
}

class _ImageCard extends StatefulWidget {
  final WorkReportFile file;
  final Future<Uint8List?> Function() load;
  final bool deleting;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  const _ImageCard({
    required this.file,
    required this.load,
    required this.deleting,
    required this.onOpen,
    required this.onDelete,
  });

  @override
  State<_ImageCard> createState() => _ImageCardState();
}

class _ImageCardState extends State<_ImageCard> {
  late final Future<Uint8List?> _bytes = widget.load();

  @override
  Widget build(BuildContext context) {
    final placeholder = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onOpen,
        child: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: 200,
              child: FutureBuilder<Uint8List?>(
                future: _bytes,
                builder: (context, snapshot) {
                  final bytes = snapshot.data;
                  if (bytes == null) {
                    return ColoredBox(
                      color: placeholder,
                      child: snapshot.connectionState == ConnectionState.done
                          ? const Icon(Icons.broken_image_outlined, size: 48)
                          : null,
                    );
                  }
                  return Image.memory(bytes, fit: BoxFit.cover, gaplessPlayback: true);
                },
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: _DeleteButton(deleting: widget.deleting, onDelete: widget.onDelete, onImage: true),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                color: Colors.black54,
                child: Text(
                  widget.file.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AudioCard extends StatelessWidget {
  final WorkReportFile file;
  final bool playing;
  final bool deleting;
  final VoidCallback onTogglePlay;
  final VoidCallback onDelete;

  const _AudioCard({
    required this.file,
    required this.playing,
    required this.deleting,
    required this.onTogglePlay,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final locale = Localizations.localeOf(context).toString();
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: onTogglePlay,
        leading: CircleAvatar(
          backgroundColor: brand.withValues(alpha: 0.12),
          child: Icon(playing ? Icons.pause : Icons.play_arrow, color: brand),
        ),
        title: Text(file.name, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          formatFileSize(file.size, locale),
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12),
        ),
        trailing: _DeleteButton(deleting: deleting, onDelete: onDelete),
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final bool deleting;
  final VoidCallback onDelete;
  final bool onImage;

  const _DeleteButton({required this.deleting, required this.onDelete, this.onImage = false});

  @override
  Widget build(BuildContext context) {
    if (deleting) {
      return const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2));
    }
    return IconButton(
      tooltip: AppLocalizations.of(context).workReportsFilesDelete,
      style: onImage ? IconButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.9)) : null,
      icon: const Icon(Icons.delete_outline, color: AppColors.error),
      onPressed: onDelete,
    );
  }
}

class _BusyOverlay extends StatelessWidget {
  final bool recording;

  const _BusyOverlay({required this.recording});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ColoredBox(
      color: Colors.black26,
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (recording)
                  const Icon(Icons.mic, color: AppColors.error)
                else
                  const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                const SizedBox(width: 12),
                Text(recording ? l10n.workReportsFilesRecording : l10n.workReportsFilesSaving),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Imagen a pantalla completa con zoom.
class _ImageViewer extends StatelessWidget {
  final WorkReportFile file;
  final Future<Uint8List?> Function() load;

  const _ImageViewer({required this.file, required this.load});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(file.name, overflow: TextOverflow.ellipsis),
      ),
      body: FutureBuilder<Uint8List?>(
        future: load(),
        builder: (context, snapshot) {
          final bytes = snapshot.data;
          if (bytes == null) return const Center(child: CircularProgressIndicator());
          return InteractiveViewer(
            maxScale: 5,
            child: Center(child: Image.memory(bytes)),
          );
        },
      ),
    );
  }
}
