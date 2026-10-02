import '../../core/state/searchable_paged_view_model.dart';
import '../../data/repositories/visit_report_repository.dart';
import '../../domain/attendance.dart' show PageResult;
import '../../domain/visit_reports.dart';

/// Visitas de un cliente. Vive mientras su pantalla.
class VisitReportsViewModel extends SearchablePagedViewModel<VisitReport> {
  final VisitReportRepository _repository;
  final int clientId;

  VisitReportsViewModel(this._repository, {required this.clientId});

  @override
  Future<PageResult<VisitReport>> fetch(int page) => _repository.getVisits(
        clientId: clientId,
        page: page,
        since: since,
        until: until,
        search: query,
      );
}
