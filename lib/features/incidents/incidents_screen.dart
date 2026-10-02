import 'package:flutter/material.dart';

import '../../core/widgets/period_list_scaffold.dart';
import '../../domain/attendance.dart';
import '../../l10n/app_localizations.dart';
import 'incident_detail_screen.dart';
import 'incident_tile.dart';
import 'incidents_view_model.dart';

class IncidentsScreen extends StatelessWidget {
  final IncidentsViewModel viewModel;
  final VoidCallback onOpenDrawer;
  final VoidCallback onBack;

  const IncidentsScreen({
    super.key,
    required this.viewModel,
    required this.onOpenDrawer,
    required this.onBack,
  });

  void _openDetail(BuildContext context, ClockIncident incident) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => IncidentDetailScreen(
          incident: incident,
          showUserName: viewModel.canViewAll,
          onOpenDrawer: onOpenDrawer,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = viewModel;

    return PeriodListScaffold<ClockIncident>(
      viewModel: vm,
      title: l10n.incidentsTitle,
      emptyMessage: l10n.incidentsEmpty,
      errorMessage: l10n.incidentsLoadError,
      emptyIcon: Icons.outlined_flag,
      onOpenDrawer: onOpenDrawer,
      onBack: onBack,
      listBuilder: (context) {
        if (vm.isGrouped) {
          return GroupedByEmployeeList<ClockIncident>(
            items: vm.items,
            groupOf: (i) => i.recordUserName ?? '—',
            itemBuilder: (context, incident) => IncidentTile(
              incident: incident,
              showUserName: false,
              onTap: () => _openDetail(context, incident),
            ),
          );
        }
        return InfiniteListView(
          itemCount: vm.items.length,
          isLoadingMore: vm.isLoadingMore,
          onLoadMore: vm.loadMore,
          itemBuilder: (context, index) {
            final incident = vm.items[index];
            return IncidentTile(
              incident: incident,
              showUserName: vm.canViewAll,
              onTap: () => _openDetail(context, incident),
            );
          },
        );
      },
    );
  }
}
