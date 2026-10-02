// Renderiza el logo vectorial a los PNG que usa flutter_launcher_icons.
//
//   flutter test tool/render_app_icon_test.dart
//   dart run flutter_launcher_icons
import 'dart:io';
import 'dart:ui' as ui;

import 'package:erp_flutter_demo/core/branding/erp_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _render(String path, ErpLogoPainter painter, {Color? background}) async {
  const size = 1024.0;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  if (background != null) {
    canvas.drawRect(const Rect.fromLTWH(0, 0, size, size), Paint()..color = background);
  }
  painter.paint(canvas, const Size.square(size));
  final image = await recorder.endRecording().toImage(size.toInt(), size.toInt());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  final file = File(path)..createSync(recursive: true);
  file.writeAsBytesSync(bytes!.buffer.asUint8List());
}

void main() {
  testWidgets('render app icons', (tester) async {
    await tester.runAsync(() async {
      // Icono completo (iOS, web, macOS): el degradado ocupa todo el
      // lienzo; cada plataforma aplica su propia máscara de esquinas.
      await _render(
        'assets/branding/app_icon.png',
        const _FullBleedPainter(),
      );
      // Primer plano del icono adaptativo de Android (fondo sólido aparte).
      await _render(
        'assets/branding/app_icon_foreground.png',
        const ErpLogoPainter(withBackground: false, glyphScale: 0.62),
      );
    });
  });
}

/// Fondo con degradado a sangre + glifo, sin esquinas redondeadas.
class _FullBleedPainter extends ErpLogoPainter {
  const _FullBleedPainter() : super(withBackground: false, glyphScale: 0.82);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
        ).createShader(rect),
    );
    super.paint(canvas, size);
  }
}
