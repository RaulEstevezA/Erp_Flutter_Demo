import '../../core/state/period_list_view_model.dart';
import '../../data/repositories/attendance_repository.dart';
import '../../domain/attendance.dart';

class IncidentsViewModel extends PeriodListViewModel<ClockIncident> {
  final AttendanceRepository _repository;

  IncidentsViewModel(this._repository, {required super.canViewAll});

  @override
  int get pageSize => 25;

  @override
  Future<PageResult<ClockIncident>> fetch({
    required DateTime since,
    required DateTime until,
    required int page,
    required int perPage,
  }) {
    return _repository.getIncidents(
      since: since,
      until: until,
      page: page,
      perPage: perPage,
    );
  }
}
