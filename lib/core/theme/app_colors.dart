import 'package:flutter/material.dart';

/// Paleta de ERP Flutter.
///
/// Marca: índigo como color principal, violeta para degradados y turquesa
/// como acento. Los colores semánticos (éxito, error, pendiente) se usan en
/// estados de fichajes e incidencias.
abstract final class AppColors {
  // Marca
  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryDark = Color(0xFF3730A3);
  static const Color violet = Color(0xFF7C3AED);
  static const Color accent = Color(0xFF14B8A6);

  /// Variante más clara del primario, legible sobre fondos oscuros.
  static const Color primaryOnDark = Color(0xFF818CF8);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, violet],
  );

  // Semánticos
  static const Color success = Color(0xFF16A34A);
  static const Color error = Color(0xFFDC2626);
  static const Color pending = Color(0xFFF59E0B);

  // Modo claro
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);

  // Modo oscuro
  static const Color darkBackground = Color(0xFF0B1020);
  static const Color darkSurface = Color(0xFF161B2E);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkBorder = Color(0xFF283048);
}

/// Acceso al color de marca adaptado al brillo del tema actual.
extension BrandColors on BuildContext {
  Color get brand => Theme.of(this).brightness == Brightness.dark
      ? AppColors.primaryOnDark
      : AppColors.primary;
}
