// Dibuja las "fotos" de ejemplo adjuntas a los partes de trabajo de la demo.
// Son ilustraciones planas, no fotos reales, para no depender de imágenes
// con derechos de terceros.
//
//   flutter test tool/render_demo_files_test.dart
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _size = Size(960, 640);

Future<void> _render(String name, void Function(Canvas canvas, Size size) draw) async {
  final recorder = ui.PictureRecorder();
  draw(Canvas(recorder), _size);
  final image = await recorder.endRecording().toImage(_size.width.toInt(), _size.height.toInt());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  File('assets/demo_files/$name')
    ..createSync(recursive: true)
    ..writeAsBytesSync(bytes!.buffer.asUint8List());
}

Paint _fill(Color color) => Paint()..color = color;

void _wall(Canvas canvas, Size size, Color top, Color bottom, {double floor = 0.78}) {
  final rect = Offset.zero & size;
  canvas.drawRect(
    rect,
    Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [top, bottom]).createShader(rect),
  );
  canvas.drawRect(Rect.fromLTWH(0, size.height * floor, size.width, size.height), _fill(const Color(0xFF94A3B8)));
  canvas.drawRect(Rect.fromLTWH(0, size.height * floor, size.width, 6), _fill(const Color(0xFF64748B)));
}

/// Armario de red con switches, latiguillos y LEDs.
void _rack(Canvas canvas, Size size) {
  _wall(canvas, size, const Color(0xFFE2E8F0), const Color(0xFFCBD5E1));
  final cabinet = RRect.fromRectAndRadius(const Rect.fromLTWH(300, 50, 360, 470), const Radius.circular(14));
  canvas.drawRRect(cabinet.shift(const Offset(10, 12)), _fill(Colors.black.withValues(alpha: 0.18)));
  canvas.drawRRect(cabinet, _fill(const Color(0xFF1E293B)));
  canvas.drawRRect(cabinet.deflate(18), _fill(const Color(0xFF0F172A)));
  final rnd = Random(4);
  const cableColors = [Color(0xFF3B82F6), Color(0xFFF59E0B), Color(0xFF14B8A6), Color(0xFFEF4444), Color(0xFFA855F7)];
  for (var u = 0; u < 7; u++) {
    final top = 85.0 + u * 60;
    final unit = RRect.fromRectAndRadius(Rect.fromLTWH(330, top, 300, 44), const Radius.circular(4));
    canvas.drawRRect(unit, _fill(u.isEven ? const Color(0xFF334155) : const Color(0xFF475569)));
    for (var p = 0; p < 12; p++) {
      final x = 345.0 + p * 23;
      canvas.drawRect(Rect.fromLTWH(x, top + 14, 16, 14), _fill(const Color(0xFF0B1220)));
      if (u.isEven && rnd.nextDouble() < 0.75) {
        final cable = Paint()
          ..color = cableColors[rnd.nextInt(cableColors.length)]
          ..strokeWidth = 5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
        final path = Path()
          ..moveTo(x + 8, top + 21)
          ..quadraticBezierTo(x + 8 + rnd.nextDouble() * 30 - 15, top + 70, 640 + rnd.nextDouble() * 10, top + 40 + rnd.nextDouble() * 40);
        canvas.drawPath(path, cable);
      }
      if (!u.isEven) {
        canvas.drawCircle(Offset(x + 8, top + 36), 2.6, _fill(rnd.nextBool() ? const Color(0xFF22C55E) : const Color(0xFFF59E0B)));
      }
    }
  }
}

/// Cuadro eléctrico abierto con magnetotérmicos.
void _panel(Canvas canvas, Size size) {
  _wall(canvas, size, const Color(0xFFFEF3C7), const Color(0xFFFDE68A));
  final box = RRect.fromRectAndRadius(const Rect.fromLTWH(240, 70, 480, 400), const Radius.circular(12));
  canvas.drawRRect(box.shift(const Offset(10, 12)), _fill(Colors.black.withValues(alpha: 0.15)));
  canvas.drawRRect(box, _fill(const Color(0xFFF8FAFC)));
  canvas.drawRRect(box.deflate(16), _fill(const Color(0xFFE2E8F0)));
  for (var row = 0; row < 3; row++) {
    final y = 110.0 + row * 115;
    canvas.drawRect(Rect.fromLTWH(270, y + 30, 420, 14), _fill(const Color(0xFF94A3B8)));
    for (var i = 0; i < 9; i++) {
      final x = 280.0 + i * 45;
      final breaker = RRect.fromRectAndRadius(Rect.fromLTWH(x, y, 36, 80), const Radius.circular(4));
      canvas.drawRRect(breaker, _fill(Colors.white));
      canvas.drawRRect(breaker, Paint()..color = const Color(0xFFCBD5E1)..style = PaintingStyle.stroke..strokeWidth = 2);
      final on = (row * 9 + i) % 7 != 3;
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x + 10, on ? y + 14 : y + 40, 16, 26), const Radius.circular(3)),
        _fill(on ? const Color(0xFF1E293B) : const Color(0xFFDC2626)),
      );
    }
  }
  // Señal de riesgo eléctrico.
  final sign = Path()
    ..moveTo(640, 84)
    ..lineTo(672, 136)
    ..lineTo(608, 136)
    ..close();
  canvas.drawPath(sign, _fill(const Color(0xFFFACC15)));
  canvas.drawPath(sign, Paint()..color = const Color(0xFF1E293B)..style = PaintingStyle.stroke..strokeWidth = 4..strokeJoin = StrokeJoin.round);
  final bolt = Path()
    ..moveTo(644, 98)
    ..lineTo(632, 118)
    ..lineTo(642, 118)
    ..lineTo(636, 131)
    ..lineTo(651, 112)
    ..lineTo(641, 112)
    ..close();
  canvas.drawPath(bolt, _fill(const Color(0xFF1E293B)));
}

/// Techo de oficina con paneles LED nuevos.
void _leds(Canvas canvas, Size size) {
  final rect = Offset.zero & size;
  canvas.drawRect(rect, _fill(const Color(0xFFF1F5F9)));
  final grid = Paint()
    ..color = const Color(0xFFCBD5E1)
    ..strokeWidth = 4;
  for (var x = 0.0; x <= size.width; x += 160) {
    canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
  }
  for (var y = 0.0; y <= size.height; y += 160) {
    canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
  }
  for (final (cx, cy) in [(1, 1), (4, 1), (2, 2), (5, 2), (1, 3)]) {
    final panel = Rect.fromLTWH(cx * 160.0 + 6, cy * 160.0 - 154, 148, 148);
    canvas.drawRect(
      panel.inflate(30),
      Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30)..color = const Color(0xFFFEF9C3),
    );
    canvas.drawRect(panel, _fill(Colors.white));
    canvas.drawRect(panel.deflate(10), _fill(const Color(0xFFFFFBEB)));
  }
  final ladder = Paint()
    ..color = const Color(0xFF4F46E5)
    ..strokeWidth = 12
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(const Offset(700, 640), const Offset(790, 380), ladder);
  canvas.drawLine(const Offset(820, 640), const Offset(790, 380), ladder);
  for (var i = 1; i < 5; i++) {
    final t = i / 5;
    canvas.drawLine(Offset(700 + 90 * t, 640 - 260 * t), Offset(820 - 30 * t, 640 - 260 * t), ladder..strokeWidth = 7);
  }
}

void main() {
  testWidgets('render demo files', (tester) async {
    await tester.runAsync(() async {
      await _render('rack_red.png', _rack);
      await _render('cuadro_electrico.png', _panel);
      await _render('paneles_led.png', _leds);
    });
  });
}
