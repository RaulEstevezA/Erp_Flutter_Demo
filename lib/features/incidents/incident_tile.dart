import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/widgets/list_parts.dart';
import '../../domain/attendance.dart';
import '../../l10n/app_localizations.dart';
import '../attendance/clock_type_style.dart';

/// Resumen de una incidencia: fecha y tipo del fichaje, empleado (si se ve
/// a toda la plantilla), motivo en una línea y estado.
class IncidentTile extends StatelessWidget {
  final ClockIncident incident;
  final bool showUserName;
  final VoidCallback onTap;

  const IncidentTile({
    super.key,
    required this.incident,
    required this.showUserName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final type = incident.recordType ?? ClockType.clockIn;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TintedIcon(icon: type.icon, color: type.color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          DateFormat('d MMM yyyy  HH:mm', locale)
                              .format(incident.createdAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        StatusPill(label: type.label(l10n), color: type.color),
                      ],
                    ),
                    if (showUserName && incident.recordUserName != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        incident.recordUserName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      incident.reason,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusPill(
                label: incident.status.label(l10n),
                color: incident.status.color,
                outlined: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
