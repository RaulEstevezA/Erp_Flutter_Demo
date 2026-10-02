import 'package:flutter/material.dart';

import '../../core/widgets/list_parts.dart';
import '../../core/widgets/menu_leading.dart';
import '../../domain/clients.dart';
import '../../l10n/app_localizations.dart';
import 'client_parts.dart';

/// Detalle de un documento: cabecera, observaciones, líneas y totales.
class ClientDocumentDetailScreen extends StatefulWidget {
  final String title;
  final Future<ClientDocument> Function() load;
  final VoidCallback onOpenDrawer;

  const ClientDocumentDetailScreen({
    super.key,
    required this.title,
    required this.load,
    required this.onOpenDrawer,
  });

  @override
  State<ClientDocumentDetailScreen> createState() => _ClientDocumentDetailScreenState();
}

class _ClientDocumentDetailScreenState extends State<ClientDocumentDetailScreen> {
  late Future<ClientDocument> _doc;

  @override
  void initState() {
    super.initState();
    _doc = widget.load();
  }

  void _reload() {
    final doc = widget.load();
    setState(() {
      _doc = doc;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        leadingWidth: MenuLeading.fullWidth,
        leading: MenuLeading(onOpenDrawer: widget.onOpenDrawer),
        title: Text(widget.title, overflow: TextOverflow.ellipsis),
      ),
      body: FutureBuilder<ClientDocument>(
        future: _doc,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return LoadErrorView(message: l10n.clientsDocDetailErrorLoad, onRetry: _reload);
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final doc = snapshot.data!;
          final description = doc.description;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _HeaderCard(doc: doc),
              if (description != null && description.isNotEmpty) ...[
                const SizedBox(height: 20),
                SectionLabel(l10n.clientsDocDetailRemarks),
                SectionCard(children: [Text(description)]),
              ],
              const SizedBox(height: 20),
              SectionLabel(l10n.clientsDocDetailLines),
              if (doc.lines.isEmpty)
                SectionCard(children: [MutedText(l10n.clientsDocDetailNoLines)])
              else
                ...doc.lines.map((line) => _LineCard(line: line)),
              const SizedBox(height: 20),
              SectionCard(
                children: [
                  _TotalRow(label: l10n.clientsDocDetailBase, value: doc.totalBase),
                  const SizedBox(height: 4),
                  _TotalRow(label: l10n.clientsDocDetailTax, value: doc.totalTax),
                  const Divider(height: 16),
                  _TotalRow(label: l10n.clientsDocDetailTotal, value: doc.total, highlighted: true),
                ],
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final ClientDocument doc;

  const _HeaderCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final subtitle = doc.number != null ? doc.name : null;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    doc.title,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                if (doc.statusLabel != null) ...[
                  const SizedBox(width: 8),
                  DocumentStatusBadge(doc.statusLabel!, doc.statusTone),
                ],
              ],
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: muted, fontSize: 13)),
            ],
            if (doc.date != null) ...[
              const SizedBox(height: 6),
              Text(formatDocDate(doc.date!), style: TextStyle(color: muted, fontSize: 13)),
            ],
          ],
        ),
      ),
    );
  }
}

class _LineCard extends StatelessWidget {
  final ClientDocumentLine line;

  const _LineCard({required this.line});

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(line.concept ?? '—', style: const TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 3),
                  Text(
                    '${formatUnits(context, line.units)} × ${formatMoney(context, line.unitPrice)}',
                    style: TextStyle(color: muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              formatMoney(context, line.total),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final double value;
  final bool highlighted;

  const _TotalRow({required this.label, required this.value, this.highlighted = false});

  @override
  Widget build(BuildContext context) {
    final style = highlighted
        ? const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)
        : TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(formatMoney(context, value), style: style),
      ],
    );
  }
}
