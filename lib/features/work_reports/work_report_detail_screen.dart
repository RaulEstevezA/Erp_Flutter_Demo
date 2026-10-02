import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/list_parts.dart';
import '../../core/widgets/menu_leading.dart';
import '../../data/repositories/work_report_repository.dart';
import '../../domain/visit_reports.dart' show formatMinutes;
import '../../domain/work_reports.dart';
import '../../l10n/app_localizations.dart';
import '../clients/client_parts.dart';
import 'signature_screens.dart';
import 'work_report_style.dart';
import 'work_report_tile.dart';

/// Detalle del parte: cabecera, descripción, observaciones, líneas (se
/// pueden añadir) y técnicos. Abajo, archivos y firma del cliente.
class WorkReportDetailScreen extends StatefulWidget {
  final int reportId;
  final String code;
  final WorkReportRepository repository;
  final VoidCallback onOpenDrawer;

  const WorkReportDetailScreen({
    super.key,
    required this.reportId,
    required this.code,
    required this.repository,
    required this.onOpenDrawer,
  });

  @override
  State<WorkReportDetailScreen> createState() => _WorkReportDetailScreenState();
}

class _WorkReportDetailScreenState extends State<WorkReportDetailScreen> {
  late Future<WorkReport> _report;

  @override
  void initState() {
    super.initState();
    _report = widget.repository.getReport(widget.reportId);
  }

  void _reload() {
    final report = widget.repository.getReport(widget.reportId);
    setState(() {
      _report = report;
    });
  }

  Future<void> _addLine() async {
    final l10n = AppLocalizations.of(context);
    final added = await showDialog<bool>(
      context: context,
      builder: (_) => _AddLineDialog(repository: widget.repository, reportId: widget.reportId),
    );
    if (added != true || !mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l10n.workReportsAddLineSuccess)));
    _reload();
  }

  Future<void> _openSignature(WorkReport report) async {
    final signed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => report.isSigned
            ? ViewSignatureScreen(
                strokes: report.signature!,
                reportId: report.id,
                repository: widget.repository,
                onOpenDrawer: widget.onOpenDrawer,
              )
            : SignatureScreen(
                reportId: report.id,
                repository: widget.repository,
                onOpenDrawer: widget.onOpenDrawer,
              ),
      ),
    );
    if (signed == true && mounted) _reload();
  }

  void _openFiles() {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.comingSoon(l10n.workReportsButtonFiles))));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return FutureBuilder<WorkReport>(
      future: _report,
      builder: (context, snapshot) {
        final report = snapshot.data;
        return Scaffold(
          appBar: AppBar(
            leadingWidth: MenuLeading.fullWidth,
            leading: MenuLeading(onOpenDrawer: widget.onOpenDrawer),
            title: Text(report?.code ?? widget.code, overflow: TextOverflow.ellipsis),
          ),
          body: switch (snapshot) {
            AsyncSnapshot(hasError: true) =>
              LoadErrorView(message: l10n.workReportsErrorLoad, onRetry: _reload),
            AsyncSnapshot(hasData: false) => const Center(child: CircularProgressIndicator()),
            _ => _Body(report: report!, onAddLine: _addLine),
          },
          bottomNavigationBar: report == null
              ? null
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _openFiles,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            icon: const Icon(Icons.attach_file),
                            label: Text(l10n.workReportsButtonFiles),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => _openSignature(report),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            icon: Icon(report.isSigned ? Icons.verified_outlined : Icons.draw_outlined),
                            label: Text(
                              report.isSigned
                                  ? l10n.workReportsButtonViewSignature
                                  : l10n.workReportsButtonSignature,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class _Body extends StatelessWidget {
  final WorkReport report;
  final VoidCallback onAddLine;

  const _Body({required this.report, required this.onAddLine});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final description = report.description;
    final remarks = report.remarks;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _HeaderCard(report: report),
        const SizedBox(height: 16),
        SectionLabel(l10n.workReportsLabelDescription),
        SectionCard(children: [
          if (description != null && description.isNotEmpty)
            Text(description)
          else
            MutedText(l10n.workReportsNoDescription),
        ]),
        const SizedBox(height: 16),
        SectionLabel(l10n.workReportsLabelRemarks),
        SectionCard(children: [
          if (remarks != null && remarks.isNotEmpty) Text(remarks) else MutedText(l10n.workReportsNoRemarks),
        ]),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: SectionLabel(l10n.workReportsLabelLines)),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: IconButton(
                tooltip: l10n.workReportsAddLineTitle,
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.add_circle_outline),
                color: Theme.of(context).colorScheme.primary,
                onPressed: onAddLine,
              ),
            ),
          ],
        ),
        if (report.lines.isEmpty)
          SectionCard(children: [MutedText(l10n.workReportsNoLines)])
        else
          ...report.lines.map((line) => _LineCard(line: line)),
        const SizedBox(height: 16),
        SectionLabel(l10n.workReportsLabelWorkers),
        SectionCard(children: [
          if (report.workerNames.isEmpty) MutedText(l10n.workReportsNoWorkers),
          for (final name in report.workerNames)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Icon(Icons.person_outline, size: 16, color: muted),
                  const SizedBox(width: 8),
                  Text(name),
                ],
              ),
            ),
        ]),
      ],
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final WorkReport report;

  const _HeaderCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final place = [report.address, report.city].whereType<String>().where((s) => s.isNotEmpty).join(', ');

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
                    report.name ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
                const SizedBox(width: 8),
                WorkReportStatusBadge(
                  label: report.status.label(l10n),
                  color: report.status.color(context),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (report.clientName != null) _InfoRow(icon: Icons.business_outlined, text: report.clientName!),
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              text: DateFormat('dd/MM/yyyy').format(report.date),
            ),
            if (place.isNotEmpty) _InfoRow(icon: Icons.location_on_outlined, text: place),
            if (report.duration > 0)
              _InfoRow(icon: Icons.schedule_outlined, text: formatMinutes(report.duration)),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

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
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

class _LineCard extends StatelessWidget {
  final WorkReportLine line;

  const _LineCard({required this.line});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SectionCard(
      margin: const EdgeInsets.only(bottom: 8),
      children: [
        if (line.productRef != null)
          Text(
            line.productRef!,
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        Text(line.concept, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        const SizedBox(height: 6),
        Row(
          children: [
            _LineDetail(label: l10n.workReportsLineUnits, value: formatUnits(context, line.units)),
            if (line.duration > 0) ...[
              const SizedBox(width: 16),
              _LineDetail(label: l10n.workReportsLineDuration, value: formatMinutes(line.duration)),
            ],
          ],
        ),
      ],
    );
  }
}

class _LineDetail extends StatelessWidget {
  final String label;
  final String value;

  const _LineDetail({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '$label ', style: TextStyle(color: muted, fontSize: 12)),
          TextSpan(text: value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// Diálogo "Añadir línea": producto opcional (rellena el concepto),
/// concepto, unidades y duración.
class _AddLineDialog extends StatefulWidget {
  final WorkReportRepository repository;
  final int reportId;

  const _AddLineDialog({required this.repository, required this.reportId});

  @override
  State<_AddLineDialog> createState() => _AddLineDialogState();
}

class _AddLineDialogState extends State<_AddLineDialog> {
  final _formKey = GlobalKey<FormState>();
  final _concept = TextEditingController();
  final _units = TextEditingController();
  final _duration = TextEditingController();
  int? _productId;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _concept.dispose();
    _units.dispose();
    _duration.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.repository.addLine(
        widget.reportId,
        concept: _concept.text,
        units: double.parse(_units.text.replaceAll(',', '.')),
        duration: int.tryParse(_duration.text) ?? 0,
        productId: _productId,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = l10n.workReportsAddLineError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.workReportsAddLineTitle),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Autocomplete<Product>(
                displayStringForOption: (p) => p.displayLabel,
                optionsBuilder: (value) async {
                  if (value.text.trim().length < 2) return const [];
                  try {
                    return await widget.repository.searchProducts(value.text);
                  } catch (_) {
                    return const [];
                  }
                },
                onSelected: (product) {
                  _productId = product.id;
                  _concept.text = product.concept;
                },
                fieldViewBuilder: (context, controller, focusNode, onSubmitted) => TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  onChanged: (_) => _productId = null,
                  decoration: InputDecoration(
                    labelText: l10n.workReportsAddLineProduct,
                    hintText: l10n.workReportsAddLineProductHint,
                    suffixIcon: const Icon(Icons.search, size: 18),
                  ),
                ),
                optionsViewBuilder: (context, onSelected, options) => Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(12),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 220, maxWidth: 280),
                      child: ListView(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        children: [
                          for (final product in options)
                            ListTile(
                              dense: true,
                              title: Text(product.concept),
                              subtitle: Text(product.ref),
                              onTap: () => onSelected(product),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _concept,
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l10n.workReportsAddLineConcept,
                  hintText: l10n.workReportsAddLineConceptHint,
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.workReportsAddLineConceptRequired : null,
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _units,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                      decoration: InputDecoration(labelText: l10n.workReportsAddLineUnits),
                      validator: (v) {
                        final n = double.tryParse((v ?? '').replaceAll(',', '.'));
                        return (n == null || n <= 0) ? l10n.workReportsAddLineUnitsInvalid : null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _duration,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(labelText: l10n.workReportsAddLineDuration),
                    ),
                  ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 13)),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: Text(l10n.dialogCancel),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(l10n.dialogAccept),
        ),
      ],
    );
  }
}
