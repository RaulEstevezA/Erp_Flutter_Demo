import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Logo de ERP Flutter dibujado en vectorial.
///
/// Una "E" formada por barras modulares (los módulos del ERP) sobre un
/// cuadrado redondeado con degradado índigo → violeta. El punto turquesa
/// representa el dispositivo móvil conectado al sistema.
class ErpLogo extends StatelessWidget {
  final double size;

  /// Sin fondo se dibuja solo el glifo en blanco (p. ej. sobre la cabecera
  /// del menú lateral, que ya tiene el degradado de marca).
  final bool withBackground;

  /// Progreso de la animación de entrada (0 → 1). Con 1 el logo está completo.
  final double progress;

  /// Escala del glifo dentro de su caja (útil al meterlo en un círculo).
  final double glyphScale;

  const ErpLogo({
    super.key,
    this.size = 96,
    this.withBackground = true,
    this.progress = 1,
    this.glyphScale = 1,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: ErpLogoPainter(
          withBackground: withBackground,
          progress: progress,
          glyphScale: glyphScale,
        ),
      ),
    );
  }
}

/// Painter del logo. Trabaja sobre una rejilla lógica de 100 × 100.
///
/// Es público para poder renderizar el icono de la app a PNG desde
/// `tool/render_app_icon_test.dart`.
class ErpLogoPainter extends CustomPainter {
  final bool withBackground;
  final double progress;

  /// Escala del glifo respecto al lienzo (el icono adaptativo de Android
  /// necesita el glifo más pequeño para respetar la zona segura).
  final double glyphScale;

  const ErpLogoPainter({
    this.withBackground = true,
    this.progress = 1,
    this.glyphScale = 1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.shortestSide / 100;
    canvas.save();
    canvas.scale(unit);

    if (withBackground) {
      final rect = const Rect.fromLTWH(0, 0, 100, 100);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(24)),
        Paint()..shader = AppColors.brandGradient.createShader(rect),
      );
    }

    canvas.translate(50, 50);
    canvas.scale(glyphScale);
    canvas.translate(-50, -50);

    final white = Paint()..color = Colors.white;
    const radius = Radius.circular(5);

    // Columna vertical de la "E".
    final stemHeight = 48 * _segment(0, 0.35);
    canvas.drawRRect(
      RRect.fromLTRBR(26, 26, 37, 26 + stemHeight, radius),
      white,
    );

    // Barras horizontales (módulos), entran escalonadas.
    _bar(canvas, top: 26, maxRight: 74, t: _segment(0.25, 0.55), paint: white);
    _bar(canvas, top: 44.5, maxRight: 58, t: _segment(0.35, 0.65), paint: white);
    _bar(canvas, top: 63, maxRight: 74, t: _segment(0.45, 0.75), paint: white);

    // Nodo turquesa con halo.
    final dot = _segment(0.7, 1);
    if (dot > 0) {
      canvas.drawCircle(
        const Offset(70, 50),
        10 * dot,
        Paint()..color = AppColors.accent.withValues(alpha: 0.25),
      );
      canvas.drawCircle(
        const Offset(70, 50),
        6.5 * dot,
        Paint()..color = AppColors.accent,
      );
    }

    canvas.restore();
  }

  void _bar(
    Canvas canvas, {
    required double top,
    required double maxRight,
    required double t,
    required Paint paint,
  }) {
    if (t <= 0) return;
    final right = 26 + (maxRight - 26) * t;
    canvas.drawRRect(
      RRect.fromLTRBR(26, top, right, top + 11, const Radius.circular(5)),
      paint,
    );
  }

  /// Normaliza [progress] al tramo [start, end] con easing.
  double _segment(double start, double end) {
    final t = ((progress - start) / (end - start)).clamp(0.0, 1.0);
    return Curves.easeOutCubic.transform(t);
  }

  @override
  bool shouldRepaint(ErpLogoPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.withBackground != withBackground ||
      oldDelegate.glyphScale != glyphScale;
}
