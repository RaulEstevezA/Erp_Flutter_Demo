import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/list_parts.dart';
import '../../domain/holidays.dart';
import '../../l10n/app_localizations.dart';
import 'holiday_style.dart';
import 'holidays_view_model.dart';

/// Resultado de la hoja de detalle, para que la pantalla muestre el aviso.
enum HolidayAction { approved, rejected, cancelled, failed }

/// Detalle de un período con el desglose día a día.
///
/// Las acciones dependen del rol y del estado:
/// * gestión, si está pendiente → Rechazar / Aprobar;
/// * el propio trabajador, si está pendiente → Cancelar solicitud;
/// * en cualquier otro caso, solo lectura.
class HolidayDetailSheet extends StatefulWidget {
  final HolidayPeriod period;
  final HolidaysViewModel viewModel;

  const HolidayDetailSheet({
    super.key,
    required this.period,
    required this.viewModel,
  });

  static Future<void> show(
    BuildContext context,
    HolidayPeriod period,
    HolidaysViewModel viewModel,
  ) async {
    final result = await showModalBottomSheet<HolidayAction>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => HolidayDetailSheet(period: period, viewModel: viewModel),
    );
    if (result == null || !context.mounted) return;

    final l10n = AppLocalizations.of(context);
    final message = switch (result) {
      HolidayAction.approved => l10n.holidaysApprovedMessage,
      HolidayAction.rejected => l10n.holidaysRejectedMessage,
      HolidayAction.cancelled => l10n.holidaysCancelledMessage,
      HolidayAction.failed => l10n.holidaysActionError,
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  State<HolidayDetailSheet> createState() => _HolidayDetailSheetState();
}

class _HolidayDetailSheetState extends State<HolidayDetailSheet> {
  bool _busy = false;

  Future<void> _run(
    Future<bool> Function(HolidayPeriod) action,
    HolidayAction success,
  ) async {
    setState(() => _busy = true);
    final ok = await action(widget.period);
    if (mounted) Navigator.of(context).pop(ok ? success : HolidayAction.failed);
  }

  Future<void> _confirmCancel() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.holidaysCancelTitle),
        content: Text(l10n.holidaysCancelMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.holidaysCancelNo),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l10n.holidaysCancelYes),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _run(widget.viewModel.cancel, HolidayAction.cancelled);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final locale = Localizations.localeOf(context).toString();
    final period = widget.period;
    final vm = widget.viewModel;
    final canReview = vm.canReview && period.isPending;
    final canCancel = vm.canCancel(period);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, scrollController) => Column(
        children: [
          Expanded(
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                formatHolidayRange(period, locale),
                                style: theme.textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            StatusPill(
                              label: period.status.label(l10n),
                              color: period.status.color,
                            ),
                          ],
                        ),
                        if (vm.canViewAll && period.workerName != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            period.workerName!,
                            style: theme.textTheme.bodySmall?.copyWith(color: muted),
                          ),
                        ],
                        if (period.reason?.isNotEmpty ?? false) ...[
                          const SizedBox(height: 4),
                          Text(
                            period.reason!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: muted,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 12,
                          runSpacing: 4,
                          children: [
                            _Info(
                              icon: Icons.work_outline,
                              label: l10n.holidaysWorkingDays(period.workingDays),
                              color: context.brand,
                            ),
                            if (period.workingDays != period.naturalDays)
                              _Info(
                                icon: Icons.calendar_today_outlined,
                                label: l10n.holidaysNaturalDays(period.naturalDays),
                                color: muted,
                              ),
                            _Info(
                              icon: period.createdBy.icon,
                              label: period.createdBy.label(l10n),
                              color: muted,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: Divider(height: 1)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  sliver: SliverList.builder(
                    itemCount: period.days.length,
                    itemBuilder: (context, i) {
                      final day = period.days[i];
                      final color = day.kind.color(context);
                      final label = DateFormat('EEEE d MMM', locale).format(day.date);
                      return ListTile(
                        dense: true,
                        leading: Icon(day.kind.icon, color: color, size: 20),
                        title: Text('${label[0].toUpperCase()}${label.substring(1)}'),
                        trailing: Text(
                          day.kind.label(l10n),
                          style: theme.textTheme.labelSmall?.copyWith(color: color),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (canReview || canCancel)
            Container(
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                12 + MediaQuery.of(context).padding.bottom,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(top: BorderSide(color: theme.dividerTheme.color ?? muted)),
              ),
              child: _busy
                  ? const Center(child: CircularProgressIndicator())
                  : Row(
                      children: [
                        if (canReview) ...[
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.error,
                                side: const BorderSide(color: AppColors.error),
                              ),
                              onPressed: () =>
                                  _run(vm.reject, HolidayAction.rejected),
                              child: Text(l10n.holidaysReject),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.success,
                              ),
                              onPressed: () =>
                                  _run(vm.approve, HolidayAction.approved),
                              child: Text(l10n.holidaysApprove),
                            ),
                          ),
                        ] else
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.error,
                                side: const BorderSide(color: AppColors.error),
                              ),
                              onPressed: _confirmCancel,
                              child: Text(l10n.holidaysCancelRequest),
                            ),
                          ),
                      ],
                    ),
            ),
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Info({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: color, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
