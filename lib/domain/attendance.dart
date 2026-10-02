/// Tipo de un fichaje. En la API viaja como entero (0 entrada, 1 salida).
enum ClockType {
  clockIn(0),
  clockOut(1);

  final int code;

  const ClockType(this.code);

  static ClockType fromCode(int code) => code == 0 ? clockIn : clockOut;
}

/// Un registro de fichaje.
class ClockRecord {
  final int id;
  final int userId;

  /// Nombre del empleado, resuelto por el repositorio.
  final String? userName;
  final DateTime date;
  final ClockType type;
  final String? remarks;
  final double? latitude;
  final double? longitude;

  const ClockRecord({
    required this.id,
    required this.userId,
    this.userName,
    required this.date,
    required this.type,
    this.remarks,
    this.latitude,
    this.longitude,
  });

  bool get isClockIn => type == ClockType.clockIn;
  bool get hasLocation => latitude != null && longitude != null;

  ClockRecord withUserName(String? name) => ClockRecord(
        id: id,
        userId: userId,
        userName: name,
        date: date,
        type: type,
        remarks: remarks,
        latitude: latitude,
        longitude: longitude,
      );

  /// Formato con fecha absoluta, usado para los fichajes creados en local.
  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'date': date.toIso8601String(),
        'type': type.code,
        'remarks': remarks,
        'latitude': latitude,
        'longitude': longitude,
      };

  factory ClockRecord.fromJson(
    Map<String, dynamic> json, {
    required DateTime date,
  }) {
    return ClockRecord(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      date: date,
      type: ClockType.fromCode(json['type'] as int),
      remarks: json['remarks'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}

/// Estado de revisión de una incidencia.
enum IncidentStatus {
  pending(0),
  approved(1),
  rejected(2);

  final int code;

  const IncidentStatus(this.code);

  static IncidentStatus fromCode(int code) =>
      values.firstWhere((s) => s.code == code, orElse: () => pending);
}

/// Incidencia abierta por un empleado sobre uno de sus fichajes.
class ClockIncident {
  final int id;
  final int clockInRecordId;
  final int reporterUserId;
  final int targetUserId;
  final IncidentStatus status;
  final String reason;
  final DateTime? requestedDate;
  final ClockType? requestedType;
  final DateTime createdAt;

  /// Datos del fichaje afectado (resueltos por el repositorio).
  final DateTime? recordDate;
  final ClockType? recordType;
  final String? recordUserName;

  const ClockIncident({
    required this.id,
    required this.clockInRecordId,
    required this.reporterUserId,
    required this.targetUserId,
    required this.status,
    required this.reason,
    this.requestedDate,
    this.requestedType,
    required this.createdAt,
    this.recordDate,
    this.recordType,
    this.recordUserName,
  });

  ClockIncident withRecord(ClockRecord? record) => ClockIncident(
        id: id,
        clockInRecordId: clockInRecordId,
        reporterUserId: reporterUserId,
        targetUserId: targetUserId,
        status: status,
        reason: reason,
        requestedDate: requestedDate,
        requestedType: requestedType,
        createdAt: createdAt,
        recordDate: record?.date,
        recordType: record?.type,
        recordUserName: record?.userName,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'clock_in_record_id': clockInRecordId,
        'reporter_user_id': reporterUserId,
        'target_user_id': targetUserId,
        'status': status.code,
        'reason': reason,
        'requested_date': requestedDate?.toIso8601String(),
        'requested_type': requestedType?.code,
        'created_at': createdAt.toIso8601String(),
      };

  factory ClockIncident.fromJson(
    Map<String, dynamic> json, {
    required DateTime createdAt,
    DateTime? requestedDate,
  }) {
    final requestedType = json['requested_type'] as int?;
    return ClockIncident(
      id: json['id'] as int,
      clockInRecordId: json['clock_in_record_id'] as int,
      reporterUserId: json['reporter_user_id'] as int,
      targetUserId: json['target_user_id'] as int,
      status: IncidentStatus.fromCode(json['status'] as int? ?? 0),
      reason: json['reason'] as String? ?? '',
      requestedDate: requestedDate,
      requestedType:
          requestedType == null ? null : ClockType.fromCode(requestedType),
      createdAt: createdAt,
    );
  }
}

/// Página de resultados de un listado paginado.
class PageResult<T> {
  final List<T> items;
  final bool hasMore;

  const PageResult(this.items, {required this.hasMore});
}
