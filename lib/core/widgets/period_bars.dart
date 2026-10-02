import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';

/// Barra "‹ octubre 2026 ›" para moverse entre meses.
///
/// No deja avanzar más allá del mes en curso.
class MonthNavigationBar extends StatelessWidget {
  final DateTime month;
  final bool isCurrentMonth;
  final bool isLoading;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const MonthNavigationBar({
    super.key,
    required this.month,
    required this.isCurrentMonth,
    required this.isLoading,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final label = DateFormat('MMMM yyyy', locale).format(month);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: isLoading ? null : onPrevious,
          ),
          Expanded(
            child: Text(
              '${label[0].toUpperCase()}${label.substring(1)}',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: isLoading || isCurrentMonth ? null : onNext,
          ),
        ],
      ),
    );
  }
}

/// Sustituye a [MonthNavigationBar] cuando hay un rango de fechas a medida.
class ActiveFilterBar extends StatelessWidget {
  final DateTime since;
  final DateTime until;
  final VoidCallback onClear;

  const ActiveFilterBar({
    super.key,
    required this.since,
    required this.until,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final brand = context.brand;
    final label = '${DateFormat('d MMM', locale).format(since)} – '
        '${DateFormat('d MMM yyyy', locale).format(until)}';

    return Container(
      color: brand.withValues(alpha: 0.08),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Icon(Icons.date_range_outlined, size: 18, color: brand),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: brand,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          IconButton(
            tooltip: AppLocalizations.of(context).clearFilter,
            icon: const Icon(Icons.close, size: 18),
            visualDensity: VisualDensity.compact,
            onPressed: onClear,
          ),
        ],
      ),
    );
  }
}

/// Hoja inferior con los selectores "Desde" y "Hasta".
class DateRangeSheet extends StatefulWidget {
  final void Function(DateTime since, DateTime until) onApply;

  const DateRangeSheet({super.key, required this.onApply});

  static Future<void> show(
    BuildContext context, {
    required void Function(DateTime since, DateTime until) onApply,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => DateRangeSheet(onApply: onApply),
    );
  }

  @override
  State<DateRangeSheet> createState() => _DateRangeSheetState();
}

class _DateRangeSheetState extends State<DateRangeSheet> {
  DateTime? _since;
  DateTime? _until;

  Future<void> _pick({required bool since}) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final current = since ? _since : _until;
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? (since ? DateTime(now.year, now.month) : today),
      firstDate: DateTime(2020),
      lastDate: today,
    );
    if (picked == null) return;

    setState(() {
      if (since) {
        _since = picked;
        if (_until != null && _until!.isBefore(picked)) _until = picked;
      } else {
        _until = picked;
        if (_since != null && _since!.isAfter(picked)) _since = picked;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final format =
        DateFormat('d MMM yyyy', Localizations.localeOf(context).toString());
    final media = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        0,
        24,
        20 + media.viewInsets.bottom + media.padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.filterByDates,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          DateField(
            label: l10n.dateFrom,
            value: _since == null ? null : format.format(_since!),
            onTap: () => _pick(since: true),
          ),
          const SizedBox(height: 12),
          DateField(
            label: l10n.dateTo,
            value: _until == null ? null : format.format(_until!),
            onTap: () => _pick(since: false),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _since == null || _until == null
                ? null
                : () {
                    Navigator.of(context).pop();
                    widget.onApply(_since!, _until!);
                  },
            child: Text(l10n.applyFilter),
          ),
        ],
      ),
    );
  }
}

/// Campo de fecha de solo lectura que abre un selector al pulsarlo.
class DateField extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback onTap;

  const DateField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
        ),
        child: Text(value ?? '—'),
      ),
    );
  }
}
