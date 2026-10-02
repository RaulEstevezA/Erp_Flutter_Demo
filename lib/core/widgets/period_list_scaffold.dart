import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../state/period_list_view_model.dart';
import '../theme/app_colors.dart';
import 'list_parts.dart';
import 'menu_leading.dart';
import 'period_bars.dart';

/// Esqueleto de una sección con listado por período.
///
/// AppBar con ☰ / ←, filtro de fechas y (si procede) agrupar por empleado;
/// debajo la barra de mes o de rango activo y el contenido según el estado.
class PeriodListScaffold<T> extends StatelessWidget {
  final PeriodListViewModel<T> viewModel;
  final String title;
  final String emptyMessage;
  final String errorMessage;
  final IconData emptyIcon;
  final VoidCallback onOpenDrawer;
  final VoidCallback onBack;

  /// Contenido cuando hay elementos cargados.
  final WidgetBuilder listBuilder;

  const PeriodListScaffold({
    super.key,
    required this.viewModel,
    required this.title,
    required this.emptyMessage,
    required this.errorMessage,
    required this.onOpenDrawer,
    required this.onBack,
    required this.listBuilder,
    this.emptyIcon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final vm = viewModel;
        final brand = context.brand;

        return Scaffold(
          appBar: AppBar(
            leadingWidth: MenuLeading.fullWidth,
            leading: MenuLeading(onOpenDrawer: onOpenDrawer, onBack: onBack),
            title: Text(title),
            actions: [
              IconButton(
                tooltip: vm.isCustomRange ? l10n.clearFilter : l10n.filterByDates,
                icon: Icon(
                  Icons.date_range_outlined,
                  color: vm.isCustomRange ? brand : null,
                ),
                onPressed: vm.isCustomRange
                    ? vm.clearCustomRange
                    : () => DateRangeSheet.show(
                          context,
                          onApply: vm.setCustomRange,
                        ),
              ),
              if (vm.canViewAll)
                IconButton(
                  tooltip: l10n.groupByEmployee,
                  icon: Icon(
                    vm.isGrouped ? Icons.group : Icons.group_outlined,
                    color: vm.isGrouped ? brand : null,
                  ),
                  onPressed: vm.toggleGrouping,
                ),
            ],
          ),
          body: Column(
            children: [
              if (vm.isCustomRange)
                ActiveFilterBar(
                  since: vm.since,
                  until: vm.until,
                  onClear: vm.clearCustomRange,
                )
              else
                MonthNavigationBar(
                  month: vm.since,
                  isCurrentMonth: vm.isCurrentMonth,
                  isLoading: vm.status == LoadStatus.loading,
                  onPrevious: vm.previousMonth,
                  onNext: vm.nextMonth,
                ),
              Expanded(
                child: switch (vm.status) {
                  LoadStatus.initial || LoadStatus.loading =>
                    const Center(child: CircularProgressIndicator()),
                  LoadStatus.error =>
                    LoadErrorView(message: errorMessage, onRetry: vm.load),
                  LoadStatus.loaded when vm.items.isEmpty =>
                    EmptyView(message: emptyMessage, icon: emptyIcon),
                  LoadStatus.loaded => RefreshIndicator(
                      onRefresh: vm.load,
                      child: listBuilder(context),
                    ),
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

/// ListView que pide la siguiente página al acercarse al final.
class InfiniteListView extends StatefulWidget {
  final int itemCount;
  final bool isLoadingMore;
  final VoidCallback onLoadMore;
  final IndexedWidgetBuilder itemBuilder;

  const InfiniteListView({
    super.key,
    required this.itemCount,
    required this.isLoadingMore,
    required this.onLoadMore,
    required this.itemBuilder,
  });

  @override
  State<InfiniteListView> createState() => _InfiniteListViewState();
}

class _InfiniteListViewState extends State<InfiniteListView> {
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final position = _controller.position;
      if (position.pixels >= position.maxScrollExtent - 200) {
        widget.onLoadMore();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _controller,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: widget.itemCount + (widget.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == widget.itemCount) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return widget.itemBuilder(context, index);
      },
    );
  }
}

/// Elementos agrupados por empleado en secciones plegables (cerradas al
/// empezar, como en el ERP).
class GroupedByEmployeeList<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T item) groupOf;

  final Widget Function(BuildContext context, T item) itemBuilder;

  /// Icono de la cabecera de cada grupo (persona, empresa...).
  final IconData icon;

  const GroupedByEmployeeList({
    super.key,
    required this.items,
    required this.groupOf,
    required this.itemBuilder,
    this.icon = Icons.person_outline,
  });

  @override
  State<GroupedByEmployeeList<T>> createState() =>
      _GroupedByEmployeeListState<T>();
}

class _GroupedByEmployeeListState<T> extends State<GroupedByEmployeeList<T>> {
  final Set<String> _expanded = {};

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<T>>{};
    for (final item in widget.items) {
      groups.putIfAbsent(widget.groupOf(item), () => []).add(item);
    }
    final names = groups.keys.toList()..sort();

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: names.length,
      itemBuilder: (context, index) {
        final name = names[index];
        final items = groups[name]!;
        final expanded = _expanded.contains(name);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CollapsibleHeader(
              title: name,
              count: items.length,
              expanded: expanded,
              icon: widget.icon,
              onToggle: () => setState(
                () => expanded ? _expanded.remove(name) : _expanded.add(name),
              ),
            ),
            if (expanded)
              for (final item in items) widget.itemBuilder(context, item),
            const Divider(height: 1),
          ],
        );
      },
    );
  }
}
