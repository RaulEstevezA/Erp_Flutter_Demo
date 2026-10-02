import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/widgets/list_parts.dart';
import '../../core/widgets/menu_leading.dart';
import '../../domain/visit_reports.dart';
import '../../l10n/app_localizations.dart';
import '../clients/client_parts.dart';

/// Detalle de una visita: empresa, fecha, técnicos, tiempos y descripción.
class VisitReportDetailScreen extends StatefulWidget {
  final Future<VisitReport> Function() load;
  final VoidCallback onOpenDrawer;

  const VisitReportDetailScreen({super.key, required this.load, required this.onOpenDrawer});

  @override
  State<VisitReportDetailScreen> createState() => _VisitReportDetailScreenState();
}

class _VisitReportDetailScreenState extends State<VisitReportDetailScreen> {
  late Future<VisitReport> _visit;

  @override
  void initState() {
    super.initState();
    _visit = widget.load();
  }

  void _reload() {
    final visit = widget.load();
    setState(() {
      _visit = visit;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return FutureBuilder<VisitReport>(
      future: _visit,
      builder: (context, snapshot) {
        final visit = snapshot.data;
        return Scaffold(
          appBar: AppBar(
            leadingWidth: MenuLeading.fullWidth,
            leading: MenuLeading(onOpenDrawer: widget.onOpenDrawer),
            title: Text(
              visit != null && visit.name.isNotEmpty ? visit.name : '—',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          body: switch (snapshot) {
            AsyncSnapshot(hasError: true) =>
              LoadErrorView(message: l10n.visitReportsErrorLoad, onRetry: _reload),
            AsyncSnapshot(hasData: false) => const Center(child: CircularProgressIndicator()),
            _ => _Body(visit: visit!),
          },
        );
      },
    );
  }
}

class _Body extends StatelessWidget {
  final VisitReport visit;

  const _Body({required this.visit});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final description = visit.description;
    final duration = visit.durationMinutes ?? 0;
    final distance = visit.travelDistanceKm ?? 0;
    final travelTime = visit.travelTimeMinutes ?? 0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (visit.clientName != null) ...[
                  Text(
                    visit.clientName!,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                ],
                _InfoRow(
                  icon: Icons.calendar_today_outlined,
                  text: DateFormat('dd/MM/yyyy · HH:mm', locale).format(visit.visitedAt),
                ),
                if (visit.workerNames.isNotEmpty)
                  _InfoRow(
                    icon: Icons.people_outline,
                    label: l10n.visitReportsLabelWorker,
                    text: visit.workerNames.join(', '),
                  ),
                if (duration > 0)
                  _InfoRow(icon: Icons.schedule_outlined, text: formatMinutes(duration)),
                if (distance > 0)
                  _InfoRow(
                    icon: Icons.route_outlined,
                    label: l10n.visitReportsLabelTravelDistance,
                    text: '${NumberFormat('#,##0.##', locale).format(distance)} km',
                  ),
                if (travelTime > 0)
                  _InfoRow(
                    icon: Icons.directions_car_outlined,
                    label: l10n.visitReportsLabelTravelTime,
                    text: formatMinutes(travelTime),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SectionLabel(l10n.visitReportsLabelDescription),
        SectionCard(
          children: [
            if (description != null && description.isNotEmpty)
              Text(description)
            else
              MutedText(l10n.visitReportsNoDescription),
          ],
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? label;

  const _InfoRow({required this.icon, required this.text, this.label});

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: muted),
          const SizedBox(width: 8),
          if (label != null) Text('$label: ', style: TextStyle(color: muted, fontSize: 13)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
