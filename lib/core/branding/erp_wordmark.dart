import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Nombre de la app con "Flutter" resaltado en el color de acento.
class ErpWordmark extends StatelessWidget {
  final Color color;
  final double fontSize;

  const ErpWordmark({super.key, required this.color, this.fontSize = 28});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          letterSpacing: -0.5,
        ),
        children: const [
          TextSpan(text: 'ERP ', style: TextStyle(fontWeight: FontWeight.w800)),
          TextSpan(
            text: 'Flutter',
            style: TextStyle(
              fontWeight: FontWeight.w400,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}
