import 'package:erp_flutter_demo/core/di/app_services.dart';
import 'package:erp_flutter_demo/domain/clients.dart';
import 'package:erp_flutter_demo/features/visit_reports/visit_reports_screen.dart';
import 'package:erp_flutter_demo/features/visit_reports/visit_reports_view_model.dart';
import 'package:erp_flutter_demo/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<AppServices> _loggedInAs(String email) async {
  SharedPreferences.setMockInitialValues({});
  final services = await AppServices.create();
  await services.auth.login(serverUrl: 'demo', email: email, password: 'demo1234');
  return services;
}

/// Avanza el reloj simulado más allá de la latencia de la API.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 400));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('repositorio', () {
    test('solo gestión ve y crea visitas', () async {
      for (final email in ['usuario@erpflutter.dev', 'trabajador@erpflutter.dev', 'cliente@erpflutter.dev']) {
        final s = await _loggedInAs(email);
        expect(s.visits.getVisits(clientId: 1), throwsStateError, reason: email);
        expect(
          s.visits.create(clientId: 1, name: 'x', visitedAt: DateTime.now()),
          throwsStateError,
          reason: email,
        );
      }
    });

    test('lista ordenada, con técnicos y empresa, y filtra por fechas', () async {
      final s = await _loggedInAs('admin@erpflutter.dev');
      final page = await s.visits.getVisits(clientId: 1);
      expect(page.items, hasLength(10));
      for (var i = 1; i < page.items.length; i++) {
        expect(page.items[i].visitedAt.isAfter(page.items[i - 1].visitedAt), isFalse);
      }
      expect(page.items.every((v) => v.workerNames.isNotEmpty), isTrue);
      expect(page.items.first.clientName, 'Cliente Demo S.L.');

      final since = DateTime.now().subtract(const Duration(days: 30));
      final recent = await s.visits.getVisits(clientId: 1, since: since, until: DateTime.now());
      expect(recent.items.every((v) => !v.visitedAt.isBefore(since)), isTrue);
    });

    test('una visita nueva aparece la primera con sus técnicos', () async {
      final s = await _loggedInAs('superadmin@erpflutter.dev');
      await s.visits.create(
        clientId: 1,
        name: 'Visita de prueba',
        visitedAt: DateTime.now(),
        workerIds: [3, 4],
        travelDistanceKm: 12.5,
      );
      final first = (await s.visits.getVisits(clientId: 1)).items.first;
      expect(first.name, 'Visita de prueba');
      expect(first.workerNames, ['Ana López', 'Javier Torres']);
      expect(first.travelDistanceKm, 12.5);
    });
  });

  testWidgets('crear una visita desde la pantalla y verla en la lista', (tester) async {
    // Pantalla de móvil (412×892) en lugar de los 800×600 por defecto.
    tester.view.physicalSize = const Size(1236, 2676);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    late AppServices s;
    late ClientSummary client;
    await tester.runAsync(() async {
      s = await _loggedInAs('admin@erpflutter.dev');
      // Precarga de JSON: la E/S de assets no avanza con el reloj simulado.
      for (final r in ['visit_reports', 'workers', 'clients']) {
        await s.api.get(r);
      }
      client = (await s.clients.getClients(search: 'Cliente Demo')).items.single;
    });

    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'),
      home: VisitReportsScreen(
        client: client,
        viewModel: VisitReportsViewModel(s.visits, clientId: client.id),
        repository: s.visits,
        canCreate: true,
        onOpenDrawer: () {},
      ),
    ));
    await _settle(tester);
    expect(tester.takeException(), isNull);
    expect(find.byType(Card), findsWidgets);

    await tester.tap(find.text('Nueva visita'));
    await _settle(tester);
    // Sin nombre no deja guardar.
    await tester.ensureVisible(find.text('Guardar'));
    await tester.pump();
    await tester.tap(find.text('Guardar'));
    await tester.pump();
    expect(find.text('Campo obligatorio'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'Nombre de la visita'), 'Visita desde test');
    await tester.ensureVisible(find.text('Guardar'));
    await tester.pump();
    await tester.tap(find.text('Guardar'));
    await _settle(tester);
    expect(tester.takeException(), isNull);

    expect(find.text('Visita desde test'), findsOneWidget);
    await tester.tap(find.text('Visita desde test'));
    await _settle(tester);
    expect(tester.takeException(), isNull);
    expect(find.text('Sin descripción'), findsOneWidget);
    // Técnicos y desplazamiento vacíos no se muestran.
    expect(find.textContaining('Técnico'), findsNothing);
  });
}
