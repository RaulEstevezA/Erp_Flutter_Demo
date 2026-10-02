import 'package:flutter/material.dart';

/// Acceso en forma de tarjeta: icono, título y chevron.
///
/// Con [color] se resalta (botón de fichaje); con [isLoading] el chevron se
/// sustituye por un indicador y deja de responder.
class CardButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;
  final bool isLoading;
  final bool enabled;

  const CardButton({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
    this.isLoading = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final highlighted = color != null;
    final card = Card(
      margin: EdgeInsets.zero,
      color: highlighted ? color!.withValues(alpha: 0.08) : null,
      shape: highlighted
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: color!.withValues(alpha: 0.45)),
            )
          : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: enabled && !isLoading ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: color,
                        fontWeight: highlighted ? FontWeight.w600 : null,
                      ),
                ),
              ),
              if (isLoading)
                SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: color),
                )
              else
                Icon(Icons.chevron_right, color: color),
            ],
          ),
        ),
      ),
    );

    return Opacity(opacity: enabled ? 1 : 0.45, child: card);
  }
}
