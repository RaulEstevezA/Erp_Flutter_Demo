import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/clients.dart';

/// Importe en euros con el formato del idioma activo.
String formatMoney(BuildContext context, double value) {
  final locale = Localizations.localeOf(context).toString();
  return NumberFormat.currency(locale: locale, symbol: '€').format(value);
}

/// Unidades sin decimales cuando son enteras ("3", "2,5").
String formatUnits(BuildContext context, double value) {
  final locale = Localizations.localeOf(context).toString();
  return NumberFormat.decimalPattern(locale).format(value);
}

String formatDocDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);

/// Rótulo de sección en versalitas y color secundario.
class SectionLabel extends StatelessWidget {
  final String title;

  const SectionLabel(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}

/// Tarjeta con el contenido de una sección de la ficha.
class SectionCard extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry margin;

  const SectionCard({super.key, required this.children, this.margin = EdgeInsets.zero});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

/// Texto atenuado para secciones vacías ("Sin contactos"...).
class MutedText extends StatelessWidget {
  final String text;

  const MutedText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant));
  }
}

/// Estado de un documento con el color de su tono.
class DocumentStatusBadge extends StatelessWidget {
  final String label;
  final DocumentStatusTone tone;

  const DocumentStatusBadge(this.label, this.tone, {super.key});

  @override
  Widget build(BuildContext context) {
    final color = switch (tone) {
      DocumentStatusTone.success => AppColors.success,
      DocumentStatusTone.pending => AppColors.pending,
      DocumentStatusTone.error => AppColors.error,
      DocumentStatusTone.info => context.brand,
      DocumentStatusTone.neutral => Theme.of(context).colorScheme.onSurfaceVariant,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
