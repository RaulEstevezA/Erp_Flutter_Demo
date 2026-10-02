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
import 'work_report_files_screen.dart';
import 'work_report_files_view_model.dart';
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

  Future<void> _editLine(WorkReportLine line) async {
    final l10n = AppLocalizations.of(context);
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _AddLineDialog(
        repository: widget.repository,
        reportId: widget.reportId,
        line: line,
      ),
    );
    if (saved != true || !mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l10n.workReportsEditLineSuccess)));
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
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WorkReportFilesScreen(
          viewModel: WorkReportFilesViewModel(widget.repository, reportId: widget.reportId),
          onOpenDrawer: widget.onOpenDrawer,
        ),
      ),
    );
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
            _ => _Body(report: report!, onAddLine: _addLine, onEditLine: _editLine),
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
  final ValueChanged<WorkReportLine> onEditLine;

  const _Body({required this.report, required this.onAddLine, required this.onEditLine});

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
          ...report.lines.map((line) => _LineCard(line: line, onTap: () => onEditLine(line))),
        if (report.hasPrices)
          SectionCard(children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.workReportsLinesTotal,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
                Text(
                  formatMoney(context, report.amount),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ]),
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

/// Línea de trabajo. Al tocarla se edita (precio, minutos, unidades...);
/// el precio de catálogo del producto no cambia.
class _LineCard extends StatelessWidget {
  final WorkReportLine line;
  final VoidCallback onTap;

  const _LineCard({required this.line, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _content(context, l10n, muted),
          ),
        ),
      ),
    );
  }

  List<Widget> _content(BuildContext context, AppLocalizations l10n, Color muted) {
    return [
        Row(
          children: [
            Expanded(
              child: Text(
                line.productRef ?? '',
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Icon(Icons.edit_outlined, size: 16, color: muted),
          ],
        ),
        Text(line.concept, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Wrap(
                spacing: 16,
                runSpacing: 4,
                children: [
                  _LineDetail(
                    label: line.hourly ? l10n.workReportsLineHours : l10n.workReportsLineUnits,
                    value: formatUnits(context, line.units),
                  ),
                  if (line.price != null)
                    _LineDetail(label: l10n.workReportsLinePrice, value: formatMoney(context, line.price!)),
                  if (line.duration > 0)
                    _LineDetail(label: l10n.workReportsLineDuration, value: formatMinutes(line.duration)),
                ],
              ),
            ),
            if (line.total != null) ...[
              const SizedBox(width: 12),
              Text(
                formatMoney(context, line.total!),
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ],
          ],
        ),
    ];
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

/// Diálogo "Añadir línea": producto opcional (rellena concepto y precio),
/// concepto, unidades, duración y precio. Con [line] edita esa línea: el
/// producto queda fijo y el resto, incluido el precio, se puede cambiar.
class _AddLineDialog extends StatefulWidget {
  final WorkReportRepository repository;
  final int reportId;
  final WorkReportLine? line;

  const _AddLineDialog({required this.repository, required this.reportId, this.line});

  @override
  State<_AddLineDialog> createState() => _AddLineDialogState();
}

class _AddLineDialogState extends State<_AddLineDialog> {
  final _formKey = GlobalKey<FormState>();
  final _concept = TextEditingController();
  final _units = TextEditingController();
  final _duration = TextEditingController();
  final _price = TextEditingController();
  Product? _product;

  /// Producto por horas: las unidades se calculan con la duración.
  bool get _hourly => _product?.hourly ?? false;

  bool get _editing => widget.line != null;

  @override
  void initState() {
    super.initState();
    _duration.addListener(_syncHours);
    final line = widget.line;
    if (line != null) {
      _concept.text = line.concept;
      _duration.text = line.duration > 0 ? '${line.duration}' : '';
      if (line.productId != null) _loadProduct(line.productId!);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Los números se escriben con el separador decimal del idioma.
    final line = widget.line;
    if (line != null && _units.text.isEmpty) {
      _units.text = _decimal(line.units, fixed: false);
      _price.text = line.price == null ? '' : _decimal(line.price!, fixed: true);
    }
  }

  String _decimal(double value, {required bool fixed}) {
    var text = fixed
        ? value.toStringAsFixed(2)
        : (value == value.roundToDouble() ? value.toInt().toString() : '$value');
    if (Localizations.localeOf(context).languageCode != 'en') text = text.replaceAll('.', ',');
    return text;
  }

  Future<void> _loadProduct(int productId) async {
    final product = (await widget.repository.products()).where((p) => p.id == productId).firstOrNull;
    if (!mounted || product == null) return;
    setState(() {
      _product = product;
    });
  }

  void _syncHours() {
    if (!_hourly) return;
    final minutes = int.tryParse(_duration.text) ?? 0;
    final hours = minutes / 60;
    final english = Localizations.localeOf(context).languageCode == 'en';
    final text = hours == hours.roundToDouble()
        ? hours.toInt().toString()
        : hours.toStringAsFixed(2).replaceAll(RegExp(r'0$'), '');
    _units.text = minutes == 0 ? '' : (english ? text : text.replaceAll('.', ','));
  }
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _concept.dispose();
    _units.dispose();
    _duration.dispose();
    _price.dispose();
    super.dispose();
  }

  /// Precio escrito por el usuario; vacío = línea sin importe.
  double? get _parsedPrice {
    final text = _price.text.trim();
    return text.isEmpty ? null : double.tryParse(text.replaceAll(',', '.'));
  }

  /// Elegir producto rellena concepto y precio de catálogo. Después ambos
  /// se pueden cambiar; el precio no se vuelve a tocar salvo que se elija
  /// otro producto.
  Future<void> _pickProduct() async {
    final product = await showModalBottomSheet<Product>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _ProductPickerSheet(repository: widget.repository),
    );
    if (product == null || !mounted) return;
    final fixed = product.price.toStringAsFixed(2);
    final english = Localizations.localeOf(context).languageCode == 'en';
    setState(() {
      _product = product;
      _concept.text = product.concept;
      _price.text = english ? fixed : fixed.replaceAll('.', ',');
    });
    _syncHours();
  }

  void _clearProduct() {
    setState(() {
      _product = null;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _saving = true;
      _error = null;
    });
    final units = double.tryParse(_units.text.replaceAll(',', '.')) ?? 0;
    final duration = int.tryParse(_duration.text) ?? 0;
    try {
      if (_editing) {
        await widget.repository.updateLine(
          widget.reportId,
          widget.line!.id,
          concept: _concept.text,
          units: units,
          duration: duration,
          price: _parsedPrice,
        );
      } else {
        await widget.repository.addLine(
          widget.reportId,
          concept: _concept.text,
          units: units,
          duration: duration,
          productId: _product?.id,
          price: _parsedPrice,
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = _editing ? l10n.workReportsEditLineError : l10n.workReportsAddLineError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(_editing ? l10n.workReportsEditLineTitle : l10n.workReportsAddLineTitle),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Al editar, el producto de la línea no cambia.
              if (!_editing || _product != null)
                _ProductField(
                  product: _product,
                  onTap: _editing ? null : _pickProduct,
                  onClear: _editing ? null : _clearProduct,
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
                      readOnly: _hourly,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                      decoration: InputDecoration(
                        labelText: _hourly ? l10n.workReportsLineHours : l10n.workReportsAddLineUnits,
                        helperText: _hourly ? l10n.workReportsAddLineHoursHelper : null,
                        helperMaxLines: 2,
                        filled: _hourly,
                      ),
                      validator: (v) {
                        if (_hourly) return null; // Lo valida la duración.
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
                      validator: (v) => _hourly && (int.tryParse(v ?? '') ?? 0) <= 0
                          ? l10n.workReportsAddLineDurationRequired
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _price,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                decoration: InputDecoration(
                  labelText: l10n.workReportsAddLinePrice,
                  prefixIcon: const Icon(Icons.euro, size: 18),
                ),
                validator: (v) {
                  if ((v ?? '').trim().isEmpty) return null;
                  final n = double.tryParse(v!.replaceAll(',', '.'));
                  return (n == null || n < 0) ? l10n.workReportsAddLinePriceInvalid : null;
                },
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

/// Campo del producto elegido: concepto, referencia y precio de catálogo.
class _ProductField extends StatelessWidget {
  final Product? product;
  final VoidCallback? onTap;
  final VoidCallback? onClear;

  const _ProductField({required this.product, required this.onTap, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = product;
    return InkWell(
      key: const ValueKey('product-field'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        isEmpty: p == null,
        decoration: InputDecoration(
          labelText: l10n.workReportsAddLineProduct,
          hintText: l10n.workReportsAddLineProductHint,
          suffixIcon: p == null
              ? const Icon(Icons.search, size: 18)
              : onClear == null
                  ? null
                  : IconButton(
                  tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: onClear,
                ),
        ),
        child: p == null
            ? null
            : Text(
                '${p.concept}\n${p.ref} · ${_priceLabel(context, p)}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
      ),
    );
  }
}

String _priceLabel(BuildContext context, Product p) =>
    '${formatMoney(context, p.price)}${p.hourly ? '/h' : ''}';

/// Hoja con el catálogo y un buscador. Devuelve el producto tocado.
class _ProductPickerSheet extends StatefulWidget {
  final WorkReportRepository repository;

  const _ProductPickerSheet({required this.repository});

  @override
  State<_ProductPickerSheet> createState() => _ProductPickerSheetState();
}

class _ProductPickerSheetState extends State<_ProductPickerSheet> {
  late final Future<List<Product>> _all = widget.repository.products();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final media = MediaQuery.of(context);
    final q = _query.trim().toLowerCase();

    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: SizedBox(
        height: media.size.height * 0.6,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                autofocus: false,
                onChanged: (v) => setState(() {
                  _query = v;
                }),
                decoration: InputDecoration(
                  hintText: l10n.workReportsAddLineProductHint,
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Product>>(
                future: _all,
                builder: (context, snapshot) {
                  final products = (snapshot.data ?? const <Product>[])
                      .where((p) => q.isEmpty ||
                          p.ref.toLowerCase().contains(q) ||
                          p.concept.toLowerCase().contains(q))
                      .toList();
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  return ListView.separated(
                    itemCount: products.length,
                    separatorBuilder: (_, _) => const Divider(height: 1, indent: 16, endIndent: 16),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ListTile(
                        title: Text(product.concept),
                        subtitle: Text(product.ref),
                        trailing: Text(
                          _priceLabel(context, product),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        onTap: () => Navigator.of(context).pop(product),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
