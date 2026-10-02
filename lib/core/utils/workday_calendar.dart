/// Convierte las fechas relativas del backend estático en fechas reales.
///
/// El backend guarda `workday_offset` (0 = hoy, 1 = día laborable anterior...)
/// y una hora `HH:mm`. Así los datos de la demo siempre parecen recientes.
abstract final class WorkdayCalendar {
  static DateTime resolve(int workdayOffset, String time, {DateTime? today}) {
    final now = today ?? DateTime.now();
    var day = DateTime(now.year, now.month, now.day);
    var remaining = workdayOffset;
    while (remaining > 0) {
      day = day.subtract(const Duration(days: 1));
      if (day.weekday != DateTime.saturday && day.weekday != DateTime.sunday) {
        remaining--;
      }
    }
    final parts = time.split(':');
    return DateTime(
      day.year,
      day.month,
      day.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }
}

extension DateOnly on DateTime {
  DateTime get startOfDay => DateTime(year, month, day);
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);
}
