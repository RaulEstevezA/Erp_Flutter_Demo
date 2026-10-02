import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';

/// Hora (HH:mm:ss) y fecha larga del dispositivo, refrescadas cada segundo.
class LiveClock extends StatefulWidget {
  const LiveClock({super.key});

  @override
  State<LiveClock> createState() => _LiveClockState();
}

class _LiveClockState extends State<LiveClock> {
  DateTime _now = DateTime.now();
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() => _now = DateTime.now()),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final theme = Theme.of(context);
    final date = DateFormat.yMMMMEEEEd(locale).format(_now);

    return Column(
      children: [
        Text(
          DateFormat('HH:mm:ss', locale).format(_now),
          style: theme.textTheme.displayMedium?.copyWith(
            color: context.brand,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${date[0].toUpperCase()}${date.substring(1)}',
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
