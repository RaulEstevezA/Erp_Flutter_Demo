import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/widgets/menu_leading.dart';
import '../../domain/attendance.dart';
import '../../l10n/app_localizations.dart';
import '../attendance/clock_type_style.dart';

/// Detalle de una incidencia: estado, fichaje afectado, motivo, cambios
/// solicitados y fecha de creación.
class IncidentDetailScreen extends StatelessWidget {
  final ClockIncident incident;
  final bool showUserName;
  final VoidCallback onOpenDrawer;

  const IncidentDetailScreen({
    super.key,
    required this.incident,
    required this.showUserName,
    required this.onOpenDrawer,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final format =
        DateFormat('d MMM yyyy  HH:mm', Localizations.localeOf(context).toString());
    final type = incident.recordType ?? ClockType.clockIn;
    final status = incident.status;

    return Scaffold(
      appBar: AppBar(
        leadingWidth: MenuLeading.fullWidth,
        leading: MenuLeading(onOpenDrawer: onOpenDrawer),
        title: Text(l10n.incidentDetailTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: status.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: status.color.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(status.icon, color: status.color, size: 22),
                const SizedBox(width: 10),
                Text(
                  status.label(l10n),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: status.color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Section(
            title: l10n.incidentAffectedRecord,
            children: [
              if (showUserName && incident.recordUserName != null)
                _Row(label: l10n.incidentWorker, value: incident.recordUserName!),
              _Row(
                label: type.label(l10n),
                value: incident.recordDate == null
                    ? '—'
                    : format.format(incident.recordDate!),
                icon: type.icon,
                color: type.color,
              ),
            ],
          ),
          _Section(
            title: l10n.incidentReason,
            children: [Text(incident.reason)],
          ),
          _Section(
            title: l10n.incidentRequestedChanges,
            children: [
              if (incident.requestedDate == null && incident.requestedType == null)
                Text(
                  l10n.incidentNoChanges,
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                )
              else ...[
                if (incident.requestedDate != null)
                  _Row(
                    label: l10n.incidentRequestDate,
                    value: format.format(incident.requestedDate!),
                  ),
                if (incident.requestedType != null)
                  _Row(
                    label: l10n.incidentRequestedType,
                    value: incident.requestedType!.label(l10n),
                  ),
              ],
            ],
          ),
          _Section(
            title: l10n.incidentCreatedAt,
            children: [Text(format.format(incident.createdAt))],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.toUpperCase(),
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? color;

  const _Row({required this.label, required this.value, this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
          ],
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: value, style: TextStyle(color: color)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
