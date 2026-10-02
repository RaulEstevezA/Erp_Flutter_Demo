/// Estado de una solicitud de vacaciones.
enum HolidayStatus {
  pending,
  approved,
  rejected;

  static HolidayStatus parse(String? value) => values.firstWhere(
        (s) => s.name == value,
        orElse: () => pending,
      );
}

/// Quién originó el período: el trabajador lo solicitó o la empresa lo asignó.
enum HolidayCreator {
  worker,
  company;

  static HolidayCreator parse(String? value) =>
      value == 'company' ? company : worker;
}

/// Clasificación de cada día dentro de un período.
enum HolidayDayKind {
  /// Día laborable de vacaciones: es el único que consume cupo.
  vacation,
  nationalHoliday,
  companyHoliday,

  /// Fin de semana.
  restDay,
}

class HolidayDay {
  final DateTime date;
  final HolidayDayKind kind;

  const HolidayDay(this.date, this.kind);
}

/// Período continuo de vacaciones de un trabajador.
class HolidayPeriod {
  final int id;
  final int workerId;
  final String? workerName;
  final DateTime start;
  final DateTime end;
  final HolidayStatus status;
  final HolidayCreator createdBy;
  final String? reason;

  /// Desglose día a día, incluidos festivos y fines de semana.
  final List<HolidayDay> days;

  const HolidayPeriod({
    required this.id,
    required this.workerId,
    this.workerName,
    required this.start,
    required this.end,
    required this.status,
    required this.createdBy,
    this.reason,
    this.days = const [],
  });

  int get naturalDays => days.length;

  int get workingDays =>
      days.where((d) => d.kind == HolidayDayKind.vacation).length;

  bool get isPending => status == HolidayStatus.pending;

  bool containsDay(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    return !d.isBefore(start) && !d.isAfter(end);
  }
}

/// Resumen anual de un trabajador (solo se muestra a quien ve lo suyo).
class HolidaySummary {
  final int year;
  final int total;
  final int workerDays;
  final int companyDays;

  const HolidaySummary({
    required this.year,
    required this.total,
    required this.workerDays,
    required this.companyDays,
  });

  int get usedDays => workerDays + companyDays;
}

class HolidaysResult {
  final List<HolidayPeriod> periods;

  /// `null` para los perfiles que ven a toda la plantilla.
  final HolidaySummary? summary;

  const HolidaysResult(this.periods, this.summary);
}
