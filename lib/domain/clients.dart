/// Cliente tal y como aparece en el listado.
class ClientSummary {
  final int id;
  final int? code;
  final String name;
  final String? vat;
  final bool active;
  final String? city;

  const ClientSummary({
    required this.id,
    required this.code,
    required this.name,
    required this.vat,
    required this.active,
    required this.city,
  });

  factory ClientSummary.fromJson(Map<String, dynamic> json) => ClientSummary(
        id: json['id'] as int,
        code: json['code'] as int?,
        name: json['name'] as String? ?? '',
        vat: json['vat'] as String?,
        active: json['active'] as bool? ?? true,
        city: json['city'] as String?,
      );
}

/// Ficha completa de un cliente.
class ClientDetail {
  final int id;
  final int? code;
  final String name;
  final String? vat;
  final bool active;
  final String? remarks;
  final String? responsible;
  final String? paymentCondition;
  final String? paymentMethod;
  final List<ClientAddress> addresses;
  final List<ClientContact> contacts;

  const ClientDetail({
    required this.id,
    required this.code,
    required this.name,
    required this.vat,
    required this.active,
    required this.remarks,
    required this.responsible,
    required this.paymentCondition,
    required this.paymentMethod,
    required this.addresses,
    required this.contacts,
  });

  factory ClientDetail.fromJson(Map<String, dynamic> json) => ClientDetail(
        id: json['id'] as int,
        code: json['code'] as int?,
        name: json['name'] as String? ?? '',
        vat: json['vat'] as String?,
        active: json['active'] as bool? ?? true,
        remarks: json['remarks'] as String?,
        responsible: json['responsible'] as String?,
        paymentCondition: json['payment_condition'] as String?,
        paymentMethod: json['payment_method'] as String?,
        addresses: (json['addresses'] as List? ?? const [])
            .cast<Map<String, dynamic>>()
            .map(ClientAddress.fromJson)
            .toList(),
        contacts: (json['contacts'] as List? ?? const [])
            .cast<Map<String, dynamic>>()
            .map(ClientContact.fromJson)
            .toList(),
      );
}

class ClientAddress {
  final String? alias;
  final String? address;
  final String? city;
  final String? postcode;
  final String? phone;
  final String? email;
  final bool billing;
  final bool delivering;

  const ClientAddress({
    required this.alias,
    required this.address,
    required this.city,
    required this.postcode,
    required this.phone,
    required this.email,
    required this.billing,
    required this.delivering,
  });

  factory ClientAddress.fromJson(Map<String, dynamic> json) => ClientAddress(
        alias: json['alias'] as String?,
        address: json['address'] as String?,
        city: json['city'] as String?,
        postcode: json['postcode'] as String?,
        phone: json['phone'] as String?,
        email: json['email'] as String?,
        billing: json['billing'] as bool? ?? false,
        delivering: json['delivering'] as bool? ?? false,
      );
}

class ClientContact {
  final String? name;
  final String? phone;
  final String? email;

  const ClientContact({required this.name, required this.phone, required this.email});

  factory ClientContact.fromJson(Map<String, dynamic> json) => ClientContact(
        name: json['name'] as String?,
        phone: json['phone'] as String?,
        email: json['email'] as String?,
      );
}

/// Tipos de documento comercial accesibles desde la ficha del cliente.
/// El nombre coincide con la clave en `client_documents.json`.
enum ClientDocumentType { budgets, orders, deliveryNotes, invoices, recurrentInvoices }

/// Tono del estado de un documento; la app lo traduce a un color.
enum DocumentStatusTone {
  success,
  pending,
  error,
  info,
  neutral;

  static DocumentStatusTone parse(String? value) =>
      values.where((t) => t.name == value).firstOrNull ?? neutral;
}

/// Documento comercial (presupuesto, pedido, albarán, factura...).
class ClientDocument {
  final int id;
  final String? number;
  final String? name;
  final DateTime? date;
  final String? statusLabel;
  final DocumentStatusTone statusTone;
  final String? description;
  final double totalBase;
  final double totalTax;
  final double total;
  final List<ClientDocumentLine> lines;

  const ClientDocument({
    required this.id,
    required this.number,
    required this.name,
    required this.date,
    required this.statusLabel,
    required this.statusTone,
    required this.description,
    required this.totalBase,
    required this.totalTax,
    required this.total,
    required this.lines,
  });

  /// Número o, si no tiene, el nombre.
  String get title => number ?? name ?? '—';
}

class ClientDocumentLine {
  final String? concept;
  final double units;
  final double unitPrice;
  final double total;

  const ClientDocumentLine({
    required this.concept,
    required this.units,
    required this.unitPrice,
    required this.total,
  });

  factory ClientDocumentLine.fromJson(Map<String, dynamic> json) => ClientDocumentLine(
        concept: json['concept'] as String?,
        units: (json['units'] as num?)?.toDouble() ?? 1,
        unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0,
        total: (json['total'] as num?)?.toDouble() ?? 0,
      );
}
