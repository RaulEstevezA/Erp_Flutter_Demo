import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/list_parts.dart';
import '../../domain/attendance.dart';
import '../../l10n/app_localizations.dart';
import 'clock_type_style.dart';

/// Fila de un fichaje. Al pulsarla se despliega un panel con "Ubicación"
/// (si hay coordenadas) y "Incidencia".
///
/// Con [showUserName] (perfiles de gestión en lista plana) la fecha va
/// acompañada del nombre del empleado.
class RecordTile extends StatelessWidget {
  final ClockRecord record;
  final bool showUserName;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onReportIncident;
  final VoidCallback? onOpenLocation;

  const RecordTile({
    super.key,
    required this.record,
    required this.showUserName,
    required this.expanded,
    required this.onToggle,
    required this.onReportIncident,
    this.onOpenLocation,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final type = record.type;
    final date = DateFormat('EEE d MMM yyyy', locale).format(record.date);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  TintedIcon(icon: type.icon, color: type.color),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          date,
                          style: (showUserName
                                  ? theme.textTheme.bodyMedium
                                  : theme.textTheme.bodyLarge)
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        if (showUserName && record.userName != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            record.userName!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        DateFormat('HH:mm', locale).format(record.date),
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (record.hasLocation) ...[
                            Icon(
                              Icons.location_on,
                              size: 12,
                              color: context.brand.withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 4),
                          ],
                          StatusPill(label: type.label(l10n), color: type.color),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    expanded ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: expanded
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
                  child: Row(
                    children: [
                      if (onOpenLocation != null) ...[
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.map_outlined, size: 16),
                            label: Text(
                              l10n.recordsLocation,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            style: OutlinedButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                            ),
                            onPressed: onOpenLocation,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: FilledButton.icon(
                          icon: const Icon(Icons.flag_outlined, size: 16),
                          label: Text(l10n.incidentReport),
                          style: FilledButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                          ),
                          onPressed: onReportIncident,
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
