import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../core/widgets/menu_leading.dart';
import '../../data/repositories/visit_report_repository.dart';
import '../../domain/clients.dart';
import '../../domain/visit_reports.dart';
import '../../l10n/app_localizations.dart';

/// Formulario de nueva visita para el cliente elegido.
/// Devuelve `true` al cerrarse si se ha guardado.
class VisitReportCreateScreen extends StatefulWidget {
  final ClientSummary client;
  final VisitReportRepository repository;
  final VoidCallback onOpenDrawer;

  const VisitReportCreateScreen({
    super.key,
    required this.client,
    required this.repository,
    required this.onOpenDrawer,
  });

  @override
  State<VisitReportCreateScreen> createState() => _VisitReportCreateScreenState();
}

class _VisitReportCreateScreenState extends State<VisitReportCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _duration = TextEditingController(text: '0');
  final _distance = TextEditingController();
  final _travelTime = TextEditingController();
  final _description = TextEditingController();

  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  final List<Worker> _workers = [];
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _duration.dispose();
    _distance.dispose();
    _travelTime.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      setState(() {
        _date = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null && mounted) {
      setState(() {
        _time = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await widget.repository.create(
        clientId: widget.client.id,
        name: _name.text,
        visitedAt: DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute),
        durationMinutes: int.tryParse(_duration.text),
        description: _description.text,
        workerIds: _workers.map((w) => w.id).toList(),
        travelDistanceKm: double.tryParse(_distance.text.replaceAll(',', '.')),
        travelTimeMinutes: int.tryParse(_travelTime.text),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.visitReportsCreateSuccess)));
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = l10n.visitReportsCreateError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Scaffold(
      appBar: AppBar(
        leadingWidth: MenuLeading.fullWidth,
        leading: MenuLeading(onOpenDrawer: widget.onOpenDrawer),
        title: Text(l10n.visitReportsNewButton),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Icon(Icons.business_outlined, color: muted, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.client.name,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l10n.visitReportsCreateNameLabel,
                  hintText: l10n.visitReportsCreateNameHint,
                  prefixIcon: const Icon(Icons.title_outlined),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.visitReportsCreateRequired : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _PickerField(
                      label: l10n.visitReportsCreateDateLabel,
                      icon: Icons.calendar_today_outlined,
                      value: DateFormat('dd/MM/yyyy').format(_date),
                      onTap: _pickDate,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: _PickerField(
                      label: l10n.visitReportsCreateTimeLabel,
                      icon: Icons.access_time_outlined,
                      value: _time.format(context),
                      onTap: _pickTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _duration,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: l10n.visitReportsCreateDurationLabel,
                  prefixIcon: const Icon(Icons.schedule_outlined),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _distance,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                      decoration: InputDecoration(
                        labelText: l10n.visitReportsCreateTravelDistanceLabel,
                        prefixIcon: const Icon(Icons.route_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _travelTime,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: l10n.visitReportsCreateTravelTimeLabel,
                        prefixIcon: const Icon(Icons.directions_car_outlined),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _WorkerSelector(
                repository: widget.repository,
                selected: _workers,
                onAdd: (worker) {
                  if (_workers.any((w) => w.id == worker.id)) return;
                  setState(() {
                    _workers.add(worker);
                  });
                },
                onRemove: (worker) {
                  setState(() {
                    _workers.removeWhere((w) => w.id == worker.id);
                  });
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _description,
                textCapitalization: TextCapitalization.sentences,
                minLines: 3,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: l10n.visitReportsCreateDescriptionLabel,
                  hintText: l10n.visitReportsCreateDescriptionHint,
                  alignLabelWithHint: true,
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 13),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _saving ? null : _submit,
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(l10n.visitReportsCreateSave),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final VoidCallback onTap;

  const _PickerField({
    required this.label,
    required this.icon,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        child: Text(value),
      ),
    );
  }
}

/// Autocompletado de técnicos con los elegidos como chips debajo.
class _WorkerSelector extends StatelessWidget {
  final VisitReportRepository repository;
  final List<Worker> selected;
  final ValueChanged<Worker> onAdd;
  final ValueChanged<Worker> onRemove;

  const _WorkerSelector({
    required this.repository,
    required this.selected,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Autocomplete<Worker>(
          displayStringForOption: (w) => w.name,
          optionsBuilder: (value) async {
            try {
              final found = await repository.searchWorkers(value.text);
              return found.where((w) => !selected.any((s) => s.id == w.id));
            } catch (_) {
              return const [];
            }
          },
          onSelected: onAdd,
          fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: l10n.visitReportsLabelWorker,
                hintText: l10n.visitReportsWorkersSearchHint,
                prefixIcon: const Icon(Icons.person_search_outlined),
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200, maxWidth: 360),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (_, index) {
                      final worker = options.elementAt(index);
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.person_outline, size: 18),
                        title: Text(worker.name, style: const TextStyle(fontSize: 14)),
                        onTap: () => onSelected(worker),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
        if (selected.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              for (final worker in selected)
                Chip(
                  label: Text(worker.name, style: const TextStyle(fontSize: 13)),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () => onRemove(worker),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ],
      ],
    );
  }
}
