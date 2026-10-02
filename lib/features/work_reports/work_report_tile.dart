import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/visit_reports.dart' show formatMinutes;
import '../../domain/work_reports.dart';
import '../../l10n/app_localizations.dart';
import 'work_report_style.dart';

/// Fila de un parte: código y estado, nombre, empresa, fecha y duración.
class WorkReportTile extends StatelessWidget {
  final WorkReport report;
  final VoidCallback onTap;

  const WorkReportTile({super.key, required this.report, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final details = [
      DateFormat('dd/MM/yyyy').format(report.date),
      if (report.duration > 0) formatMinutes(report.duration),
    ].join('  ·  ');

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Row(
        children: [
          Expanded(
            child: Text(
              report.code,
              style: const TextStyle(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          WorkReportStatusBadge(label: report.status.label(l10n), color: report.status.color(context)),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (report.name != null) ...[
            const SizedBox(height: 2),
            Text(report.name!, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
          ],
          if (report.clientName != null) ...[
            const SizedBox(height: 2),
            Text(
              report.clientName!,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: muted, fontSize: 12),
            ),
          ],
          const SizedBox(height: 4),
          Text(details, style: TextStyle(color: muted, fontSize: 12)),
        ],
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}

class WorkReportStatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const WorkReportStatusBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
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
