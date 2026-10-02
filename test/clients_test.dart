import 'package:erp_flutter_demo/core/di/app_services.dart';
import 'package:erp_flutter_demo/data/repositories/client_repository.dart';
import 'package:erp_flutter_demo/domain/clients.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<AppServices> _loggedInAs(String email) async {
  SharedPreferences.setMockInitialValues({});
  final services = await AppServices.create();
  await services.auth.login(serverUrl: 'demo', email: email, password: 'demo1234');
  return services;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('solo gestión puede consultar clientes', () async {
    for (final email in [
      'usuario@erpflutter.dev',
      'trabajador@erpflutter.dev',
      'cliente@erpflutter.dev',
      'proveedor@erpflutter.dev',
    ]) {
      final s = await _loggedInAs(email);
      expect(s.clients.getClients(), throwsStateError, reason: email);
    }
    final admin = await _loggedInAs('admin@erpflutter.dev');
    expect((await admin.clients.getClients()).items, isNotEmpty);
  });

  test('el listado pagina y busca sin distinguir tildes', () async {
    final s = await _loggedInAs('superadmin@erpflutter.dev');
    final first = await s.clients.getClients();
    expect(first.items, hasLength(ClientRepository.perPage));
    expect(first.hasMore, isTrue);
    final second = await s.clients.getClients(page: 2);
    expect(second.hasMore, isFalse);

    final found = await s.clients.getClients(search: 'optica');
    expect(found.items.single.name, 'Óptica Visión Clara');
  });

  test('documentos del cliente: orden, filtro de fechas y detalle', () async {
    final s = await _loggedInAs('superadmin@erpflutter.dev');
    final invoices = await s.clients.getDocuments(1, ClientDocumentType.invoices);
    expect(invoices.items, isNotEmpty);
    final dates = invoices.items.map((d) => d.date!).toList();
    for (var i = 1; i < dates.length; i++) {
      expect(dates[i].isAfter(dates[i - 1]), isFalse);
    }

    final since = DateTime.now().subtract(const Duration(days: 60));
    final recent = await s.clients.getDocuments(
      1,
      ClientDocumentType.invoices,
      since: since,
      until: DateTime.now(),
    );
    expect(recent.items.every((d) => !d.date!.isBefore(since)), isTrue);

    final doc = await s.clients.getDocument(1, ClientDocumentType.invoices, invoices.items.first.id);
    final linesTotal = doc.lines.fold<double>(0, (sum, l) => sum + l.total);
    expect(linesTotal, closeTo(doc.totalBase, 0.01));
    expect(doc.totalBase + doc.totalTax, closeTo(doc.total, 0.01));
  });
}
