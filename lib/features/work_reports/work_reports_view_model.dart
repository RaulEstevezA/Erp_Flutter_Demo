import '../../core/state/searchable_paged_view_model.dart';
import '../../data/repositories/work_report_repository.dart';
import '../../domain/attendance.dart' show PageResult;
import '../../domain/work_reports.dart';

/// Listado de partes: activos o finalizados, con búsqueda, rango de fechas
/// y agrupación por empresa. Con [clientId] muestra solo los de un cliente
/// (botón "Trabajos" de la ficha) y no agrupa.
class WorkReportsViewModel extends SearchablePagedViewModel<WorkReport> {
  final WorkReportRepository _repository;
  final int? clientId;

  WorkReportsViewModel(this._repository, {this.clientId});

  WorkReportFilter _filter = WorkReportFilter.active;
  bool _isGrouped = false;

  WorkReportFilter get filter => _filter;
  bool get isGrouped => _isGrouped;
  bool get canGroup => clientId == null;

  @override
  Future<void> init() {
    _filter = WorkReportFilter.active;
    _isGrouped = false;
    return super.init();
  }

  void setFilter(WorkReportFilter filter) {
    if (filter == _filter) return;
    _filter = filter;
    load();
  }

  void toggleGrouping() {
    if (!canGroup) return;
    _isGrouped = !_isGrouped;
    load();
  }

  @override
  Future<PageResult<WorkReport>> fetch(int page) => _repository.getReports(
        filter: _filter,
        clientId: clientId,
        since: since,
        until: until,
        search: query,
        page: page,
        // Agrupado se pide todo de una vez para que los grupos estén completos.
        pageSize: _isGrouped ? 1000 : WorkReportRepository.perPage,
      );
}
