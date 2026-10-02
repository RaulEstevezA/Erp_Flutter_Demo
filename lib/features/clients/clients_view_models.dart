import '../../core/state/searchable_paged_view_model.dart';
import '../../data/repositories/client_repository.dart';
import '../../domain/attendance.dart' show PageResult;
import '../../domain/clients.dart';

class ClientsViewModel extends SearchablePagedViewModel<ClientSummary> {
  final ClientRepository _repository;

  ClientsViewModel(this._repository);

  @override
  Future<PageResult<ClientSummary>> fetch(int page) =>
      _repository.getClients(search: query, page: page);
}

/// Documentos de un tipo para un cliente. Vive mientras su pantalla.
class ClientDocumentsViewModel extends SearchablePagedViewModel<ClientDocument> {
  final ClientRepository _repository;
  final int clientId;
  final ClientDocumentType type;

  ClientDocumentsViewModel(this._repository, {required this.clientId, required this.type});

  @override
  Future<PageResult<ClientDocument>> fetch(int page) => _repository.getDocuments(
        clientId,
        type,
        page: page,
        since: since,
        until: until,
        search: query,
      );
}
