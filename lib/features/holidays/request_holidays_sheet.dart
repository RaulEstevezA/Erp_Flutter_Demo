import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/period_bars.dart';
import '../../l10n/app_localizations.dart';
import 'holidays_view_model.dart';

/// Hoja para solicitar vacaciones: inicio, fin y motivo opcional.
/// Devuelve `true` si la solicitud se envió.
class RequestHolidaysSheet extends StatefulWidget {
  final HolidaysViewModel viewModel;

  const RequestHolidaysSheet({super.key, required this.viewModel});

  @override
  State<RequestHolidaysSheet> createState() => _RequestHolidaysSheetState();
}

class _RequestHolidaysSheetState extends State<RequestHolidaysSheet> {
  final _reason = TextEditingController();
  DateTime? _start;
  DateTime? _end;
  bool _sending = false;
  bool _showDateError = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _pick({required bool start}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: (start ? _start : _end ?? _start) ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2, 12, 31),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (start) {
        _start = picked;
        if (_end != null && _end!.isBefore(picked)) _end = null;
      } else {
        _end = picked;
      }
      _showDateError = false;
    });
  }

  Future<void> _submit() async {
    if (_start == null || _end == null || _end!.isBefore(_start!)) {
      setState(() => _showDateError = true);
      return;
    }
    setState(() => _sending = true);
    final reason = _reason.text.trim();
    final ok = await widget.viewModel.request(
      _start!,
      _end!,
      reason.isEmpty ? null : reason,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).holidaysRequestError),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final format = DateFormat('d MMM yyyy', Localizations.localeOf(context).toString());
    final media = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        0,
        24,
        24 + media.viewInsets.bottom + media.padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.beach_access_outlined, color: context.brand),
              const SizedBox(width: 8),
              Text(l10n.holidaysRequestTitle, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 20),
          DateField(
            label: l10n.holidaysStart,
            value: _start == null ? l10n.holidaysPickDate : format.format(_start!),
            onTap: _sending ? () {} : () => _pick(start: true),
          ),
          const SizedBox(height: 12),
          DateField(
            label: l10n.holidaysEnd,
            value: _end == null ? l10n.holidaysPickDate : format.format(_end!),
            onTap: _sending ? () {} : () => _pick(start: false),
          ),
          if (_showDateError) ...[
            const SizedBox(height: 6),
            Text(
              l10n.holidaysDatesError,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.error),
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: _reason,
            enabled: !_sending,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: l10n.holidaysReason,
              hintText: l10n.holidaysReasonHint,
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _sending ? null : () => Navigator.of(context).pop(false),
                child: Text(l10n.dialogCancel),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: _sending ? null : _submit,
                icon: _sending
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.send_outlined),
                label: Text(l10n.holidaysSubmit),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
