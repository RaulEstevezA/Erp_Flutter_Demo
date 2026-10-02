import '../../core/state/period_list_view_model.dart';
import '../../data/repositories/attendance_repository.dart';
import '../../domain/attendance.dart';

class RecordsViewModel extends PeriodListViewModel<ClockRecord> {
  final AttendanceRepository _repository;

  RecordsViewModel(this._repository, {required super.canViewAll});

  @override
  int get pageSize => 50;

  @override
  Future<PageResult<ClockRecord>> fetch({
    required DateTime since,
    required DateTime until,
    required int page,
    required int perPage,
  }) {
    return _repository.getRecords(
      since: since,
      until: until,
      page: page,
      perPage: perPage,
    );
  }

  /// Lanza excepción si falla: el diálogo es quien muestra el error.
  Future<void> createIncident({
    required ClockRecord record,
    required String reason,
    DateTime? requestedDate,
  }) {
    return _repository.createIncident(
      record: record,
      reason: reason,
      requestedDate: requestedDate,
      requestedType: requestedDate == null ? null : record.type,
    );
  }
}
