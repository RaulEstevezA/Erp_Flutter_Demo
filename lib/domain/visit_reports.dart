/// Técnico o comercial asignable a visitas y trabajos.
class Worker {
  final int id;
  final String name;

  const Worker({required this.id, required this.name});

  factory Worker.fromJson(Map<String, dynamic> json) =>
      Worker(id: json['id'] as int, name: json['name'] as String? ?? '');
}

/// Parte de visita comercial a un cliente.
class VisitReport {
  final int id;
  final int clientId;
  final String? clientName;
  final String name;
  final DateTime visitedAt;
  final int? durationMinutes;
  final List<String> workerNames;
  final String? description;
  final double? travelDistanceKm;
  final int? travelTimeMinutes;

  const VisitReport({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.name,
    required this.visitedAt,
    required this.durationMinutes,
    required this.workerNames,
    required this.description,
    required this.travelDistanceKm,
    required this.travelTimeMinutes,
  });
}

/// "45 min", "2h", "1h 30min".
String formatMinutes(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return '$m min';
  if (m == 0) return '${h}h';
  return '${h}h ${m}min';
}
