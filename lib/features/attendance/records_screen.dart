import 'package:flutter/material.dart';

import '../../core/utils/maps.dart';
import '../../core/widgets/period_list_scaffold.dart';
import '../../domain/attendance.dart';
import '../../l10n/app_localizations.dart';
import 'record_tile.dart';
import 'records_view_model.dart';
import 'report_incident_dialog.dart';

/// Listado de fichajes del período, con incidencias y ubicación por fila.
class RecordsScreen extends StatefulWidget {
  final RecordsViewModel viewModel;
  final VoidCallback onOpenDrawer;
  final VoidCallback onBack;

  /// Tras crear una incidencia se navega a la sección de incidencias.
  final VoidCallback onIncidentCreated;

  const RecordsScreen({
    super.key,
    required this.viewModel,
    required this.onOpenDrawer,
    required this.onBack,
    required this.onIncidentCreated,
  });

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  /// Fila desplegada (acordeón: solo una abierta a la vez).
  Object? _expandedKey;

  void _toggle(Object key) =>
      setState(() => _expandedKey = _expandedKey == key ? null : key);

  Future<void> _reportIncident(ClockRecord record) async {
    final sent = await showDialog<bool>(
      context: context,
      builder: (_) => ReportIncidentDialog(
        record: record,
        onSubmit: (reason, requestedDate) => widget.viewModel.createIncident(
          record: record,
          reason: reason,
          requestedDate: requestedDate,
        ),
      ),
    );
    if (sent != true || !mounted) return;

    setState(() => _expandedKey = null);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).incidentSent)),
    );
    widget.onIncidentCreated();
  }

  Widget _tile(ClockRecord record, {required bool showUserName, required Object key}) {
    return RecordTile(
      record: record,
      showUserName: showUserName,
      expanded: _expandedKey == key,
      onToggle: () => _toggle(key),
      onReportIncident: () => _reportIncident(record),
      onOpenLocation: record.hasLocation
          ? () => openInMaps(record.latitude!, record.longitude!)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = widget.viewModel;

    return PeriodListScaffold<ClockRecord>(
      viewModel: vm,
      title: l10n.recordsTitle,
      emptyMessage: l10n.recordsEmpty,
      errorMessage: l10n.recordsLoadError,
      emptyIcon: Icons.history_toggle_off,
      onOpenDrawer: widget.onOpenDrawer,
      onBack: widget.onBack,
      listBuilder: (context) {
        if (vm.isGrouped) {
          return GroupedByEmployeeList<ClockRecord>(
            items: vm.items,
            groupOf: (r) => r.userName ?? '—',
            itemBuilder: (context, record) =>
                _tile(record, showUserName: false, key: record.id),
          );
        }
        return InfiniteListView(
          itemCount: vm.items.length,
          isLoadingMore: vm.isLoadingMore,
          onLoadMore: vm.loadMore,
          itemBuilder: (context, index) {
            final record = vm.items[index];
            return _tile(record, showUserName: vm.canViewAll, key: record.id);
          },
        );
      },
    );
  }
}
