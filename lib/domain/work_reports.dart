import 'dart:ui';

/// Estados del parte en el ERP. Del 1 al 3 está activo; del 4 al 8, cerrado.
enum WorkReportStatus {
  assigned(1),
  inProgress(2),
  partiallyFinished(3),
  finished(4),
  notified(5),
  deliveryNote(6),
  invoiced(7),
  rejected(8);

  final int code;

  const WorkReportStatus(this.code);

  bool get isActive => code <= 3;

  static WorkReportStatus parse(int? code) =>
      values.where((s) => s.code == code).firstOrNull ?? assigned;
}

/// Filtro de estado del listado.
enum WorkReportFilter { active, finished }

/// Producto del catálogo que puede usarse en una línea.
class Product {
  final int id;
  final String ref;
  final String concept;

  const Product({required this.id, required this.ref, required this.concept});

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as int,
        ref: json['ref'] as String? ?? '',
        concept: json['concept'] as String? ?? '',
      );

  String get displayLabel => '$ref · $concept';
}

class WorkReportLine {
  final String? productRef;
  final String concept;
  final double units;

  /// Minutos dedicados.
  final int duration;

  const WorkReportLine({
    required this.productRef,
    required this.concept,
    required this.units,
    required this.duration,
  });
}

/// Firma del cliente como trazos en coordenadas relativas (0..1), de modo
/// que se dibuja igual en cualquier tamaño de pantalla.
typedef SignatureStrokes = List<List<Offset>>;

class WorkReport {
  final int id;
  final String code;
  final String? name;
  final int clientId;
  final String? clientName;
  final DateTime date;
  final WorkReportStatus status;
  final String? description;
  final String? remarks;
  final String? address;
  final String? city;
  final List<WorkReportLine> lines;
  final List<String> workerNames;
  final SignatureStrokes? signature;

  const WorkReport({
    required this.id,
    required this.code,
    required this.name,
    required this.clientId,
    required this.clientName,
    required this.date,
    required this.status,
    required this.description,
    required this.remarks,
    required this.address,
    required this.city,
    required this.lines,
    required this.workerNames,
    required this.signature,
  });

  /// Duración total: la suma de las líneas.
  int get duration => lines.fold(0, (sum, line) => sum + line.duration);

  bool get isSigned => signature != null && signature!.isNotEmpty;
}
