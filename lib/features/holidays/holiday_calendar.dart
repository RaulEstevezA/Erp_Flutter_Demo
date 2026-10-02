import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/holidays.dart';
import '../../l10n/app_localizations.dart';
import 'holiday_style.dart';

/// Cuadrícula mensual (lunes a domingo). Cada día con vacaciones se tiñe
/// según su estado, con prioridad aprobada > pendiente > rechazada.
class HolidayCalendar extends StatelessWidget {
  final DateTime month;
  final List<HolidayPeriod> periods;

  /// Se llama al tocar un día que tiene vacaciones.
  final void Function(DateTime day, List<HolidayPeriod> periods) onDayTap;

  const HolidayCalendar({
    super.key,
    required this.month,
    required this.periods,
    required this.onDayTap,
  });

  static const _priority = [
    HolidayStatus.approved,
    HolidayStatus.pending,
    HolidayStatus.rejected,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leading = DateTime(month.year, month.month).weekday - 1;
    final now = DateTime.now();

    // 2024-01-01 fue lunes.
    final weekdays = [
      for (var i = 0; i < 7; i++)
        DateFormat.E(locale).format(DateTime(2024, 1, 1 + i)).substring(0, 1).toUpperCase(),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              for (final label in weekdays)
                Expanded(
                  child: Center(
                    child: Text(
                      label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: leading + daysInMonth,
            itemBuilder: (context, index) {
              if (index < leading) return const SizedBox.shrink();
              final date = DateTime(month.year, month.month, index - leading + 1);
              final onDay = periods.where((p) => p.containsDay(date)).toList();
              final status = _priority.where((s) => onDay.any((p) => p.status == s)).firstOrNull;
              final isToday = date.year == now.year &&
                  date.month == now.month &&
                  date.day == now.day;
              final weekend = date.weekday >= DateTime.saturday;
              final color = status?.color;

              return InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: onDay.isEmpty ? null : () => onDayTap(date, onDay),
                child: Container(
                  decoration: BoxDecoration(
                    color: color?.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                    border: isToday
                        ? Border.all(color: theme.colorScheme.primary, width: 1.5)
                        : null,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '${date.day}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: color != null || isToday ? FontWeight.w700 : null,
                          color: color ??
                              (weekend ? theme.colorScheme.onSurfaceVariant : null),
                        ),
                      ),
                      // Varias personas ese día (vista de gestión).
                      if (onDay.length > 1)
                        Positioned(
                          bottom: 3,
                          child: Text(
                            '${onDay.length}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 9,
                              color: color,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              for (final status in _priority)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: status.color.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(status.label(l10n), style: theme.textTheme.labelSmall),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
