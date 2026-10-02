import 'dart:math';

import '../../core/network/api_client.dart';
import '../../core/roles/permissions.dart';
import '../../core/session/session_store.dart';
import '../../domain/attendance.dart' show PageResult;
import '../../domain/clients.dart';

/// Clientes y sus documentos comerciales. Solo para roles con
/// [AppPermission.viewClients] (gestión).
///
/// El ERP filtra y pagina en el servidor; aquí se hace sobre el JSON
/// estático con el mismo contrato (páginas de [perPage] y `hasMore`).
class ClientRepository {
  static const perPage = 20;

  final ApiClient _api;
  final SessionStore _session;

  const ClientRepository(this._api, this._session);

  void _checkAccess() {
    final user = _session.user;
    if (user == null || !user.role.can(AppPermission.viewClients)) {
      throw StateError('Sin permiso para ver clientes.');
    }
  }

  Future<List<Map<String, dynamic>>> _clients() async {
    _checkAccess();
    final data = await _api.get('clients') as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }

  /// Clientes ordenados por nombre. [search] busca en nombre, CIF y ciudad.
  Future<PageResult<ClientSummary>> getClients({String? search, int page = 1}) async {
    final query = _normalize(search ?? '');
    final matches = (await _clients())
        .where((c) =>
            query.isEmpty ||
            [c['name'], c['vat'], c['city']]
                .whereType<String>()
                .any((field) => _normalize(field).contains(query)))
        .map(ClientSummary.fromJson)
        .toList()
      ..sort((a, b) => _normalize(a.name).compareTo(_normalize(b.name)));
    return _paginate(matches, page);
  }

  Future<ClientDetail> getClient(int clientId) async {
    final json = (await _clients()).where((c) => c['id'] == clientId).firstOrNull;
    if (json == null) throw StateError('Cliente no encontrado.');
    return ClientDetail.fromJson(json);
  }

  /// Documentos del cliente, del más reciente al más antiguo.
  Future<PageResult<ClientDocument>> getDocuments(
    int clientId,
    ClientDocumentType type, {
    int page = 1,
    DateTime? since,
    DateTime? until,
    String? search,
  }) async {
    final query = _normalize(search ?? '');
    final docs = (await _documents(clientId, type))
        .where((d) =>
            (since == null || (d.date != null && !d.date!.isBefore(since))) &&
            (until == null || (d.date != null && !d.date!.isAfter(until))) &&
            (query.isEmpty ||
                [d.number, d.name, d.statusLabel]
                    .whereType<String>()
                    .any((field) => _normalize(field).contains(query))))
        .toList()
      ..sort((a, b) => b.date!.compareTo(a.date!));
    return _paginate(docs, page);
  }

  Future<ClientDocument> getDocument(int clientId, ClientDocumentType type, int id) async {
    final doc = (await _documents(clientId, type)).where((d) => d.id == id).firstOrNull;
    if (doc == null) throw StateError('Documento no encontrado.');
    return doc;
  }

  Future<List<ClientDocument>> _documents(int clientId, ClientDocumentType type) async {
    _checkAccess();
    final data = await _api.get('client_documents') as Map<String, dynamic>;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return (data[_key(type)] as List? ?? const [])
        .cast<Map<String, dynamic>>()
        .where((d) => d['client_id'] == clientId)
        .map(
          (d) => ClientDocument(
            id: d['id'] as int,
            number: d['number'] as String?,
            name: d['name'] as String?,
            date: today.subtract(Duration(days: d['days_ago'] as int)),
            statusLabel: d['status_label'] as String?,
            statusTone: DocumentStatusTone.parse(d['status_tone'] as String?),
            description: d['description'] as String?,
            totalBase: (d['total_base'] as num?)?.toDouble() ?? 0,
            totalTax: (d['total_tax'] as num?)?.toDouble() ?? 0,
            total: (d['total'] as num?)?.toDouble() ?? 0,
            lines: (d['lines'] as List? ?? const [])
                .cast<Map<String, dynamic>>()
                .map(ClientDocumentLine.fromJson)
                .toList(),
          ),
        )
        .toList();
  }

  static String _key(ClientDocumentType type) => switch (type) {
        ClientDocumentType.budgets => 'budgets',
        ClientDocumentType.orders => 'orders',
        ClientDocumentType.deliveryNotes => 'delivery_notes',
        ClientDocumentType.invoices => 'invoices',
        ClientDocumentType.recurrentInvoices => 'recurrent_invoices',
      };

  /// Minúsculas y sin tildes, para que "lopez" encuentre "López".
  static String _normalize(String text) {
    const from = 'áàäâéèëêíìïîóòöôúùüûñç';
    const to = 'aaaaeeeeiiiioooouuuunc';
    final lower = text.toLowerCase().trim();
    final buffer = StringBuffer();
    for (final char in lower.split('')) {
      final i = from.indexOf(char);
      buffer.write(i == -1 ? char : to[i]);
    }
    return buffer.toString();
  }

  static PageResult<T> _paginate<T>(List<T> items, int page) {
    final start = (page - 1) * perPage;
    if (start >= items.length) return PageResult(<T>[], hasMore: false);
    final end = min(start + perPage, items.length);
    return PageResult(items.sublist(start, end), hasMore: end < items.length);
  }
}
