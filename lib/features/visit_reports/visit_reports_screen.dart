import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/state/period_list_view_model.dart' show LoadStatus;
import '../../core/theme/app_colors.dart';
import '../../core/widgets/list_parts.dart';
import '../../core/widgets/menu_leading.dart';
import '../../core/widgets/period_bars.dart';
import '../../data/repositories/visit_report_repository.dart';
import '../../domain/clients.dart';
import '../../domain/visit_reports.dart';
import '../../l10n/app_localizations.dart';
import 'visit_report_create_screen.dart';
import 'visit_report_detail_screen.dart';
import 'visit_reports_view_model.dart';

/// Visitas de un cliente: todas por defecto, o mes a mes, por rango de
/// fechas y con buscador. Abajo, el botón para registrar una nueva.
class VisitReportsScreen extends StatefulWidget {
  final ClientSummary client;
  final VisitReportsViewModel viewModel;
  final VisitReportRepository repository;
  final bool canCreate;
  final VoidCallback onOpenDrawer;

  const VisitReportsScreen({
    super.key,
    required this.client,
    required this.viewModel,
    required this.repository,
    required this.canCreate,
    required this.onOpenDrawer,
  });

  @override
  State<VisitReportsScreen> createState() => _VisitReportsScreenState();
}

class _VisitReportsScreenState extends State<VisitReportsScreen> {
  final _search = TextEditingController();
  final _scroll = ScrollController();
  bool _searchVisible = false;

  VisitReportsViewModel get _vm => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      final position = _scroll.position;
      if (position.pixels >= position.maxScrollExtent - 200) _vm.loadMore();
    });
    _vm.load();
  }

  @override
  void dispose() {
    _search.dispose();
    _scroll.dispose();
    // El ViewModel es exclusivo de esta pantalla.
    _vm.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    if (_searchVisible) {
      _search.clear();
      _vm.clearSearch();
    }
    setState(() {
      _searchVisible = !_searchVisible;
    });
  }

  void _openDetail(VisitReport visit) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VisitReportDetailScreen(
          load: () => widget.repository.getVisit(visit.id),
          onOpenDrawer: widget.onOpenDrawer,
        ),
      ),
    );
  }

  Future<void> _openCreate() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => VisitReportCreateScreen(
          client: widget.client,
          repository: widget.repository,
          onOpenDrawer: widget.onOpenDrawer,
        ),
      ),
    );
    if (created == true) _vm.load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) {
        final brand = context.brand;
        return Scaffold(
          appBar: AppBar(
            leadingWidth: MenuLeading.fullWidth,
            leading: MenuLeading(onOpenDrawer: widget.onOpenDrawer),
            title: Text(widget.client.name, overflow: TextOverflow.ellipsis),
            actions: [
              IconButton(
                tooltip: l10n.visitReportsMonthView,
                icon: Icon(
                  Icons.calendar_month_rounded,
                  color: _vm.isMonthMode ? brand : null,
                ),
                onPressed: _vm.toggleMonthMode,
              ),
              IconButton(
                tooltip: l10n.visitReportsVisitSearchHint,
                icon: Icon(
                  Icons.search,
                  color: _searchVisible || _vm.query.isNotEmpty ? brand : null,
                ),
                onPressed: _toggleSearch,
              ),
              IconButton(
                tooltip: _vm.hasDateRange ? l10n.clearFilter : l10n.filterByDates,
                icon: Icon(
                  Icons.date_range_outlined,
                  color: _vm.hasDateRange ? brand : null,
                ),
                onPressed: _vm.hasDateRange
                    ? _vm.clearDateRange
                    : () => DateRangeSheet.show(context, onApply: _vm.setDateRange),
              ),
            ],
          ),
          body: Column(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: _searchVisible
                    ? Padding(
                        key: const ValueKey('search'),
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                        child: TextField(
                          controller: _search,
                          autofocus: true,
                          textInputAction: TextInputAction.search,
                          onChanged: _vm.updateSearch,
                          decoration: InputDecoration(
                            hintText: l10n.visitReportsVisitSearchHint,
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: _toggleSearch,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(key: ValueKey('no-search')),
              ),
              if (_vm.hasDateRange)
                ActiveFilterBar(
                  since: _vm.since!,
                  until: _vm.until!,
                  onClear: _vm.clearDateRange,
                )
              else if (_vm.isMonthMode)
                MonthNavigationBar(
                  month: _vm.since!,
                  isCurrentMonth: _vm.isCurrentMonth,
                  isLoading: _vm.status == LoadStatus.loading,
                  onPrevious: _vm.previousMonth,
                  onNext: _vm.nextMonth,
                ),
              Expanded(child: _content(l10n)),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: FilledButton.icon(
                onPressed: widget.canCreate ? _openCreate : null,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.add),
                label: Text(l10n.visitReportsNewButton),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _content(AppLocalizations l10n) {
    return switch (_vm.status) {
      LoadStatus.initial || LoadStatus.loading =>
        const Center(child: CircularProgressIndicator()),
      LoadStatus.error => LoadErrorView(message: l10n.visitReportsErrorLoad, onRetry: _vm.load),
      LoadStatus.loaded when _vm.items.isEmpty =>
        EmptyView(message: l10n.visitReportsEmpty, icon: Icons.event_busy_outlined),
      LoadStatus.loaded => RefreshIndicator(
          onRefresh: _vm.load,
          child: ListView.separated(
            controller: _scroll,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            itemCount: _vm.items.length + (_vm.isLoadingMore ? 1 : 0),
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              if (index == _vm.items.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final visit = _vm.items[index];
              return _VisitCard(visit: visit, onTap: () => _openDetail(visit));
            },
          ),
        ),
    };
  }
}

class _VisitCard extends StatelessWidget {
  final VisitReport visit;
  final VoidCallback onTap;

  const _VisitCard({required this.visit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final duration = visit.durationMinutes ?? 0;
    final description = visit.description;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      visit.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          DateFormat('dd/MM/yyyy').format(visit.visitedAt),
                          style: TextStyle(color: muted, fontSize: 12),
                        ),
                        const Spacer(),
                        if (duration > 0)
                          Text(
                            formatMinutes(duration),
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                    if (visit.workerNames.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        visit.workerNames.join(', '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: muted, fontSize: 12),
                      ),
                    ],
                    if (description != null && description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: muted.withValues(alpha: 0.75), fontSize: 11),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: muted, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
