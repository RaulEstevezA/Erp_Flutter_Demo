import 'package:flutter/material.dart';

import '../../core/widgets/list_parts.dart';
import '../../domain/holidays.dart';
import '../../l10n/app_localizations.dart';
import 'holiday_style.dart';

/// Tarjeta de un período: franja de color por estado, fechas, persona (si
/// se ve a toda la plantilla), motivo, días y origen.
class HolidayPeriodTile extends StatelessWidget {
  final HolidayPeriod period;
  final bool showWorkerName;
  final VoidCallback onTap;

  const HolidayPeriodTile({
    super.key,
    required this.period,
    required this.showWorkerName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final locale = Localizations.localeOf(context).toString();
    final status = period.status;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 5, color: status.color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              formatHolidayRange(period, locale),
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            if (showWorkerName && period.workerName != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                period.workerName!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(color: muted),
                              ),
                            ],
                            if (period.reason?.isNotEmpty ?? false) ...[
                              const SizedBox(height: 2),
                              Text(
                                period.reason!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: muted,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.holidaysWorkingDays(period.workingDays),
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          if (period.workingDays != period.naturalDays)
                            Text(
                              '(${l10n.holidaysNaturalDays(period.naturalDays)})',
                              style: theme.textTheme.labelSmall?.copyWith(color: muted),
                            ),
                          const SizedBox(height: 4),
                          StatusPill(label: status.label(l10n), color: status.color),
                          const SizedBox(height: 3),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(period.createdBy.icon, size: 11, color: muted),
                              const SizedBox(width: 3),
                              Text(
                                period.createdBy.label(l10n),
                                style: theme.textTheme.labelSmall
                                    ?.copyWith(color: muted, fontSize: 10),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
