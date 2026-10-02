import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/attendance.dart';
import '../../l10n/app_localizations.dart';
import 'clock_type_style.dart';

/// Diálogo para reportar una incidencia sobre [record].
///
/// Pide un motivo (mínimo 5 caracteres) y, opcionalmente, la fecha y hora
/// correctas. Devuelve `true` al cerrarse si la incidencia se envió.
class ReportIncidentDialog extends StatefulWidget {
  final ClockRecord record;
  final Future<void> Function(String reason, DateTime? requestedDate) onSubmit;

  const ReportIncidentDialog({
    super.key,
    required this.record,
    required this.onSubmit,
  });

  @override
  State<ReportIncidentDialog> createState() => _ReportIncidentDialogState();
}

class _ReportIncidentDialogState extends State<ReportIncidentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reason = TextEditingController();
  DateTime? _requestedDate;
  bool _sending = false;
  bool _failed = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final base = _requestedDate ?? widget.record.date;
    final date = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
    );
    if (time == null) return;

    setState(() {
      _requestedDate =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _sending = true;
      _failed = false;
    });
    try {
      await widget.onSubmit(_reason.text.trim(), _requestedDate);
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        setState(() {
          _sending = false;
          _failed = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final format =
        DateFormat('d MMM yyyy  HH:mm', Localizations.localeOf(context).toString());
    final type = widget.record.type;

    return AlertDialog(
      title: Text(l10n.incidentDialogTitle),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(type.icon, color: type.color, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${format.format(widget.record.date)}  ·  ${type.label(l10n)}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reason,
                maxLines: 3,
                enabled: !_sending,
                decoration: InputDecoration(
                  labelText: l10n.incidentReason,
                  hintText: l10n.incidentReasonHint,
                  hintMaxLines: 2,
                ),
                validator: (value) => (value?.trim().length ?? 0) < 5
                    ? l10n.incidentReasonTooShort
                    : null,
              ),
              const SizedBox(height: 16),
              Text(l10n.incidentRequestDate, style: theme.textTheme.labelMedium),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today_outlined, size: 16),
                      label: Text(
                        _requestedDate == null
                            ? l10n.incidentPickDate
                            : format.format(_requestedDate!),
                        overflow: TextOverflow.ellipsis,
                      ),
                      onPressed: _sending ? null : _pickDateTime,
                    ),
                  ),
                  if (_requestedDate != null)
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      tooltip: l10n.incidentClearDate,
                      onPressed: () => setState(() => _requestedDate = null),
                    ),
                ],
              ),
              if (_failed) ...[
                const SizedBox(height: 12),
                Text(
                  l10n.incidentSendError,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: AppColors.error),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _sending ? null : () => Navigator.of(context).pop(false),
          child: Text(l10n.dialogCancel),
        ),
        FilledButton(
          onPressed: _sending ? null : _submit,
          child: _sending
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(l10n.incidentSubmit),
        ),
      ],
    );
  }
}
