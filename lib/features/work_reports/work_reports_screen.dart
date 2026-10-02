import 'package:flutter/material.dart';

import '../../core/state/period_list_view_model.dart' show LoadStatus;
import '../../core/theme/app_colors.dart';
import '../../core/widgets/list_parts.dart';
import '../../core/widgets/menu_leading.dart';
import '../../core/widgets/period_bars.dart';
import '../../core/widgets/period_list_scaffold.dart';
import '../../data/repositories/work_report_repository.dart';
import '../../domain/work_reports.dart';
import '../../l10n/app_localizations.dart';
import 'work_report_detail_screen.dart';
import 'work_report_tile.dart';
import 'work_reports_view_model.dart';

/// Listado de partes de trabajo con filtro Activos / Finalizados, buscador,
/// rango de fechas y agrupación por empresa.
///
/// Se usa como sección del menú (con [onBack]) y apilado desde la ficha de
/// un cliente; en ese caso el ViewModel es de la pantalla ([ownsViewModel]).
class WorkReportsScreen extends StatefulWidget {
  final WorkReportsViewModel viewModel;
  final WorkReportRepository repository;
  final VoidCallback onOpenDrawer;
  final VoidCallback? onBack;
  final String? title;
  final bool ownsViewModel;

  const WorkReportsScreen({
    super.key,
    required this.viewModel,
    required this.repository,
    required this.onOpenDrawer,
    this.onBack,
    this.title,
    this.ownsViewModel = false,
  });

  @override
  State<WorkReportsScreen> createState() => _WorkReportsScreenState();
}

class _WorkReportsScreenState extends State<WorkReportsScreen> {
  final _search = TextEditingController();
  bool _searchVisible = false;

  WorkReportsViewModel get _vm => widget.viewModel;

  @override
  void initState() {
    super.initState();
    // Como sección, el shell ya la ha iniciado al seleccionarla.
    if (_vm.status == LoadStatus.initial) _vm.load();
  }

  @override
  void dispose() {
    _search.dispose();
    if (widget.ownsViewModel) _vm.dispose();
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

  Future<void> _openDetail(WorkReport report) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WorkReportDetailScreen(
          reportId: report.id,
          code: report.code,
          repository: widget.repository,
          onOpenDrawer: widget.onOpenDrawer,
        ),
      ),
    );
    // Puede haber nuevas líneas o firma.
    _vm.load();
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
            leading: MenuLeading(onOpenDrawer: widget.onOpenDrawer, onBack: widget.onBack),
            title: Text(widget.title ?? l10n.menuWorkReports, overflow: TextOverflow.ellipsis),
            actions: [
              IconButton(
                tooltip: l10n.workReportsSearchHint,
                icon: Icon(
                  Icons.search,
                  color: _searchVisible || _vm.query.isNotEmpty ? brand : null,
                ),
                onPressed: _toggleSearch,
              ),
              IconButton(
                tooltip: _vm.hasDateRange ? l10n.clearFilter : l10n.filterByDates,
                icon: Icon(Icons.date_range_outlined, color: _vm.hasDateRange ? brand : null),
                onPressed: _vm.hasDateRange
                    ? _vm.clearDateRange
                    : () => DateRangeSheet.show(context, onApply: _vm.setDateRange),
              ),
              if (_vm.canGroup)
                IconButton(
                  tooltip: l10n.workReportsGroupByCompany,
                  icon: Icon(
                    _vm.isGrouped ? Icons.business : Icons.business_outlined,
                    color: _vm.isGrouped ? brand : null,
                  ),
                  onPressed: _vm.toggleGrouping,
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
                            hintText: l10n.workReportsSearchHint,
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
                ),
              _FilterBar(selected: _vm.filter, onChanged: _vm.setFilter),
              Expanded(child: _content(l10n)),
            ],
          ),
        );
      },
    );
  }

  Widget _content(AppLocalizations l10n) {
    return switch (_vm.status) {
      LoadStatus.initial || LoadStatus.loading =>
        const Center(child: CircularProgressIndicator()),
      LoadStatus.error => LoadErrorView(message: l10n.workReportsErrorLoad, onRetry: _vm.load),
      LoadStatus.loaded when _vm.items.isEmpty =>
        EmptyView(message: l10n.workReportsEmpty, icon: Icons.assignment_outlined),
      LoadStatus.loaded => RefreshIndicator(
          onRefresh: _vm.load,
          child: _vm.isGrouped
              ? GroupedByEmployeeList<WorkReport>(
                  items: _vm.items,
                  groupOf: (r) => r.clientName ?? '—',
                  icon: Icons.business_outlined,
                  itemBuilder: (context, report) =>
                      WorkReportTile(report: report, onTap: () => _openDetail(report)),
                )
              : _FlatList(vm: _vm, onTap: _openDetail),
        ),
    };
  }
}

class _FlatList extends StatefulWidget {
  final WorkReportsViewModel vm;
  final ValueChanged<WorkReport> onTap;

  const _FlatList({required this.vm, required this.onTap});

  @override
  State<_FlatList> createState() => _FlatListState();
}

class _FlatListState extends State<_FlatList> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      final position = _scroll.position;
      if (position.pixels >= position.maxScrollExtent - 200) widget.vm.loadMore();
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.vm.items;
    return ListView.separated(
      controller: _scroll,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: items.length + (widget.vm.isLoadingMore ? 1 : 0),
      separatorBuilder: (_, _) => const Divider(height: 1, indent: 16, endIndent: 16),
      itemBuilder: (context, index) {
        if (index == items.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final report = items[index];
        return WorkReportTile(report: report, onTap: () => widget.onTap(report));
      },
    );
  }
}

/// Píldoras "Activos" / "Finalizados".
class _FilterBar extends StatelessWidget {
  final WorkReportFilter selected;
  final ValueChanged<WorkReportFilter> onChanged;

  const _FilterBar({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          for (final (filter, label) in [
            (WorkReportFilter.active, l10n.workReportsFilterActive),
            (WorkReportFilter.finished, l10n.workReportsFilterFinished),
          ]) ...[
            ChoiceChip(
              label: Text(label),
              selected: selected == filter,
              showCheckmark: false,
              selectedColor: context.brand,
              labelStyle: TextStyle(
                color: selected == filter ? Colors.white : null,
                fontWeight: selected == filter ? FontWeight.w600 : FontWeight.normal,
              ),
              shape: const StadiumBorder(),
              onSelected: (_) => onChanged(filter),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
