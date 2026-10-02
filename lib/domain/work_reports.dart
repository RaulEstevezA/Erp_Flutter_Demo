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

  /// Precio unitario de catálogo; se propone al añadir la línea.
  final double price;

  /// Se cobra por horas (mano de obra): las unidades son la duración en horas.
  final bool hourly;

  const Product({
    required this.id,
    required this.ref,
    required this.concept,
    required this.price,
    this.hourly = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as int,
        ref: json['ref'] as String? ?? '',
        concept: json['concept'] as String? ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0,
        hourly: json['hourly'] as bool? ?? false,
      );

  String get displayLabel => '$ref · $concept';
}

class WorkReportLine {
  /// Identificador estable de la línea (para editarla).
  final String id;
  final int? productId;
  final String? productRef;
  final String concept;
  final double units;

  /// Minutos dedicados.
  final int duration;

  /// Precio unitario (`null` si la línea no tiene importe).
  final double? price;

  /// Línea de mano de obra: [units] son horas.
  final bool hourly;

  /// Añadida en el dispositivo. Las del servidor (base de datos del ERP)
  /// no se modifican desde la app.
  final bool editable;

  const WorkReportLine({
    required this.id,
    this.productId,
    required this.productRef,
    required this.concept,
    required this.units,
    required this.duration,
    this.price,
    this.hourly = false,
    this.editable = false,
  });

  double? get total => price == null ? null : units * price!;
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

  /// Importe de las líneas con precio.
  double get amount => lines.fold(0, (sum, line) => sum + (line.total ?? 0));

  bool get hasPrices => lines.any((line) => line.price != null);
}

enum WorkReportFileType { image, audio }

/// Archivo adjunto a un parte. Los de la demo vienen empaquetados en la app
/// ([asset]); los que añade el usuario están en el dispositivo ([storageKey]).
class WorkReportFile {
  final int id;
  final String name;
  final WorkReportFileType type;
  final int size;
  final String? asset;
  final String? storageKey;

  const WorkReportFile({
    required this.id,
    required this.name,
    required this.type,
    required this.size,
    this.asset,
    this.storageKey,
  });

  bool get isImage => type == WorkReportFileType.image;
}

/// "850 B", "56,2 KB", "1,3 MB".
String formatFileSize(int bytes, String locale) {
  if (bytes < 1024) return '$bytes B';
  final kb = bytes / 1024;
  String fmt(double v) => v.toStringAsFixed(1).replaceAll('.', locale.startsWith('en') ? '.' : ',');
  if (kb < 1024) return '${fmt(kb)} KB';
  return '${fmt(kb / 1024)} MB';
}
