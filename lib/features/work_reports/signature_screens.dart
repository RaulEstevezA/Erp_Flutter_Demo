import 'package:flutter/material.dart';

import '../../core/widgets/menu_leading.dart';
import '../../data/repositories/work_report_repository.dart';
import '../../domain/work_reports.dart';
import '../../l10n/app_localizations.dart';

/// La firma siempre se ve sobre papel blanco con tinta oscura, también en
/// modo oscuro, como un documento firmado.
const _paper = Colors.white;
const _ink = Color(0xFF0F172A);

/// Panel para que el cliente firme con el dedo. Devuelve `true` al guardar.
class SignatureScreen extends StatefulWidget {
  final int reportId;
  final WorkReportRepository repository;
  final VoidCallback onOpenDrawer;

  const SignatureScreen({
    super.key,
    required this.reportId,
    required this.repository,
    required this.onOpenDrawer,
  });

  @override
  State<SignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  /// Trazos en coordenadas relativas al panel (0..1).
  final SignatureStrokes _strokes = [];
  bool _saving = false;

  void _start(Offset position, Size size) {
    setState(() {
      _strokes.add([_normalize(position, size)]);
    });
  }

  void _extend(Offset position, Size size) {
    setState(() {
      _strokes.last.add(_normalize(position, size));
    });
  }

  static Offset _normalize(Offset p, Size size) => Offset(
        (p.dx / size.width).clamp(0.0, 1.0),
        (p.dy / size.height).clamp(0.0, 1.0),
      );

  void _clear() {
    setState(() {
      _strokes.clear();
    });
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (_strokes.isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.workReportsSignatureEmpty)));
      return;
    }
    setState(() {
      _saving = true;
    });
    try {
      await widget.repository.saveSignature(widget.reportId, _strokes);
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.workReportsSignatureSuccess)));
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
      });
      messenger.showSnackBar(SnackBar(content: Text(l10n.workReportsSignatureError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        leadingWidth: MenuLeading.fullWidth,
        leading: MenuLeading(onOpenDrawer: widget.onOpenDrawer),
        title: Text(l10n.workReportsSignatureTitle),
        actions: [
          TextButton.icon(
            onPressed: _saving || _strokes.isEmpty ? null : _clear,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.workReportsSignatureClear),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              l10n.workReportsSignatureHint,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _Paper(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = constraints.biggest;
                    return GestureDetector(
                      key: const ValueKey('signature-pad'),
                      behavior: HitTestBehavior.opaque,
                      onPanStart: (d) => _start(d.localPosition, size),
                      onPanUpdate: (d) => _extend(d.localPosition, size),
                      child: CustomPaint(
                        size: size,
                        painter: SignaturePainter(_strokes, revision: _strokes.fold(0, (n, s) => n + s.length)),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(l10n.workReportsSignatureSave),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Firma ya guardada, con la opción de volver a firmar.
/// Devuelve `true` si se ha firmado de nuevo.
class ViewSignatureScreen extends StatelessWidget {
  final SignatureStrokes strokes;
  final int reportId;
  final WorkReportRepository repository;
  final VoidCallback onOpenDrawer;

  const ViewSignatureScreen({
    super.key,
    required this.strokes,
    required this.reportId,
    required this.repository,
    required this.onOpenDrawer,
  });

  Future<void> _resign(BuildContext context) async {
    final navigator = Navigator.of(context);
    final signed = await navigator.push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => SignatureScreen(
          reportId: reportId,
          repository: repository,
          onOpenDrawer: onOpenDrawer,
        ),
      ),
    );
    if (signed == true) navigator.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        leadingWidth: MenuLeading.fullWidth,
        leading: MenuLeading(onOpenDrawer: onOpenDrawer),
        title: Text(l10n.workReportsViewSignatureTitle),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _Paper(
                child: CustomPaint(
                  size: Size.infinite,
                  painter: SignaturePainter(strokes),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _resign(context),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  icon: const Icon(Icons.draw_outlined),
                  label: Text(l10n.workReportsButtonResign),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Paper extends StatelessWidget {
  final Widget child;

  const _Paper({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _paper,
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: SizedBox.expand(child: child),
      ),
    );
  }
}

/// Dibuja los trazos escalados al tamaño disponible, con curvas suaves.
class SignaturePainter extends CustomPainter {
  final SignatureStrokes strokes;

  /// Cambia con cada punto nuevo para repintar mientras se firma.
  final int revision;

  const SignaturePainter(this.strokes, {this.revision = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _ink
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.isEmpty) continue;
      final points = [for (final p in stroke) Offset(p.dx * size.width, p.dy * size.height)];
      if (points.length == 1) {
        canvas.drawCircle(points.first, 1.4, paint..style = PaintingStyle.fill);
        paint.style = PaintingStyle.stroke;
        continue;
      }
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (var i = 1; i < points.length - 1; i++) {
        final mid = Offset.lerp(points[i], points[i + 1], 0.5)!;
        path.quadraticBezierTo(points[i].dx, points[i].dy, mid.dx, mid.dy);
      }
      path.lineTo(points.last.dx, points.last.dy);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(SignaturePainter old) => old.strokes != strokes || old.revision != revision;
}
