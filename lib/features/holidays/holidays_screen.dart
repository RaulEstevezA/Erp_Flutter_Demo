import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/state/period_list_view_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/list_parts.dart';
import '../../core/widgets/menu_leading.dart';
import '../../core/widgets/period_bars.dart';
import '../../core/widgets/period_list_scaffold.dart';
import '../../domain/holidays.dart';
import '../../l10n/app_localizations.dart';
import 'holiday_calendar.dart';
import 'holiday_detail_sheet.dart';
import 'holiday_period_tile.dart';
import 'holidays_view_model.dart';
import 'request_holidays_sheet.dart';

class HolidaysScreen extends StatelessWidget {
  final HolidaysViewModel viewModel;
  final VoidCallback onOpenDrawer;
  final VoidCallback onBack;

  const HolidaysScreen({
    super.key,
    required this.viewModel,
    required this.onOpenDrawer,
    required this.onBack,
  });

  Future<void> _request(BuildContext context) async {
    final sent = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => RequestHolidaysSheet(viewModel: viewModel),
    );
    if (sent == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).holidaysRequestSent)),
      );
    }
  }

  void _openDetail(BuildContext context, HolidayPeriod period) =>
      HolidayDetailSheet.show(context, period, viewModel);

  /// Al tocar un día del calendario: si solo hay un período se abre su
  /// detalle; si hay varios (vista de gestión) se listan primero.
  void _onDayTap(BuildContext context, DateTime day, List<HolidayPeriod> periods) {
    if (periods.length == 1) {
      _openDetail(context, periods.single);
      return;
    }
    final l10n = AppLocalizations.of(context);
    final date = DateFormat('d MMMM', Localizations.localeOf(context).toString()).format(day);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(sheetContext).size.height * 0.7,
          ),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              Text(
                l10n.holidaysOnDay(date),
                style: Theme.of(sheetContext).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              for (final period in periods)
                HolidayPeriodTile(
                  period: period,
                  showWorkerName: viewModel.canViewAll,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _openDetail(context, period);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final vm = viewModel;
        final isCalendar = vm.view == HolidaysView.calendar;
        final brand = context.brand;

        return Scaffold(
          appBar: AppBar(
            leadingWidth: MenuLeading.fullWidth,
            leading: MenuLeading(onOpenDrawer: onOpenDrawer, onBack: onBack),
            title: Text(l10n.menuHolidays),
            actions: [
              if (!isCalendar && vm.canViewAll)
                IconButton(
                  tooltip: l10n.groupByPerson,
                  icon: Icon(
                    vm.isGrouped ? Icons.group : Icons.group_outlined,
                    color: vm.isGrouped ? brand : null,
                  ),
                  onPressed: vm.toggleGrouping,
                ),
              IconButton(
                tooltip: isCalendar ? l10n.holidaysListView : l10n.holidaysCalendarView,
                icon: Icon(
                  isCalendar ? Icons.list_alt_outlined : Icons.calendar_month_outlined,
                ),
                onPressed: vm.toggleView,
              ),
            ],
          ),
          // Solo quien puede solicitar (usuario, trabajador) tiene el "+".
          floatingActionButton: vm.canRequest
              ? FloatingActionButton(
                  tooltip: l10n.holidaysRequestTitle,
                  shape: const CircleBorder(),
                  onPressed: () => _request(context),
                  child: const Icon(Icons.add),
                )
              : null,
          body: Column(
            children: [
              if (isCalendar)
                MonthNavigationBar(
                  month: vm.month,
                  // Se puede avanzar a meses futuros para ver lo planificado.
                  isCurrentMonth: false,
                  isLoading: vm.status == LoadStatus.loading,
                  onPrevious: vm.previousMonth,
                  onNext: vm.nextMonth,
                ),
              if (vm.summary != null) _SummaryBanner(summary: vm.summary!),
              Expanded(child: _body(context, l10n)),
            ],
          ),
        );
      },
    );
  }

  Widget _body(BuildContext context, AppLocalizations l10n) {
    final vm = viewModel;
    switch (vm.status) {
      case LoadStatus.initial:
      case LoadStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case LoadStatus.error:
        return LoadErrorView(message: l10n.holidaysLoadError, onRetry: vm.load);
      case LoadStatus.loaded:
        break;
    }

    if (vm.view == HolidaysView.calendar) {
      return SingleChildScrollView(
        padding: const EdgeInsets.only(top: 8, bottom: 96),
        child: HolidayCalendar(
          month: vm.month,
          periods: vm.periods,
          onDayTap: (day, periods) => _onDayTap(context, day, periods),
        ),
      );
    }

    if (vm.periods.isEmpty) {
      return EmptyView(message: l10n.holidaysEmpty, icon: Icons.beach_access_outlined);
    }

    final list = vm.isGrouped && vm.canViewAll
        ? GroupedByEmployeeList<HolidayPeriod>(
            items: vm.periods,
            groupOf: (p) => p.workerName ?? '—',
            itemBuilder: (context, period) => HolidayPeriodTile(
              period: period,
              showWorkerName: false,
              onTap: () => _openDetail(context, period),
            ),
          )
        : ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            itemCount: vm.periods.length,
            itemBuilder: (context, index) {
              final period = vm.periods[index];
              return HolidayPeriodTile(
                period: period,
                showWorkerName: vm.canViewAll,
                onTap: () => _openDetail(context, period),
              );
            },
          );

    return RefreshIndicator(onRefresh: vm.load, child: list);
  }
}

/// Resumen anual del trabajador: días usados sobre el cupo y desglose.
class _SummaryBanner extends StatelessWidget {
  final HolidaySummary summary;

  const _SummaryBanner({required this.summary});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final brand = context.brand;
    final muted = theme.colorScheme.onSurfaceVariant;
    final fraction = summary.total > 0 ? summary.usedDays / summary.total : 0.0;

    Widget part(IconData icon, String text) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: muted),
            const SizedBox(width: 3),
            Text(text, style: theme.textTheme.labelSmall?.copyWith(color: muted)),
          ],
        );

    return Container(
      width: double.infinity,
      color: brand.withValues(alpha: 0.06),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.holidaysSummary('${summary.year}', summary.usedDays, summary.total),
            style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraction.clamp(0.0, 1.0),
              minHeight: 6,
              color: brand,
              backgroundColor: brand.withValues(alpha: 0.18),
            ),
          ),
          if (summary.usedDays > 0) ...[
            const SizedBox(height: 5),
            Wrap(
              spacing: 12,
              runSpacing: 2,
              children: [
                if (summary.companyDays > 0)
                  part(Icons.business_outlined, l10n.holidaysSummaryCompany(summary.companyDays)),
                if (summary.workerDays > 0)
                  part(Icons.person_outline, l10n.holidaysSummaryWorker(summary.workerDays)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
