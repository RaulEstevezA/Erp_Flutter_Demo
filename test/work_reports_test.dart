import 'package:erp_flutter_demo/core/di/app_services.dart';
import 'package:erp_flutter_demo/domain/work_reports.dart';
import 'package:erp_flutter_demo/features/work_reports/work_reports_screen.dart';
import 'package:erp_flutter_demo/features/work_reports/work_reports_view_model.dart';
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

Future<List<WorkReport>> _all(AppServices s) async => [
      for (final filter in WorkReportFilter.values)
        ...(await s.workReports.getReports(filter: filter, pageSize: 1000)).items,
    ];

/// Avanza el reloj simulado más allá de la latencia de la API.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 400));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('roles', () {
    test('gestión ve todos los partes', () async {
      final s = await _loggedInAs('admin@erpflutter.dev');
      expect(await _all(s), hasLength(117));
    });

    test('un trabajador solo ve los partes en los que está asignado', () async {
      final s = await _loggedInAs('trabajador@erpflutter.dev');
      final mine = await _all(s);
      expect(mine, isNotEmpty);
      expect(mine.length, lessThan(117));
      expect(mine.every((r) => r.workerNames.contains('Javier Torres')), isTrue);

      // Un parte ajeno no se puede abrir ni modificar.
      final admin = await _loggedInAs('admin@erpflutter.dev');
      final other = (await _all(admin)).firstWhere((r) => !r.workerNames.contains('Javier Torres'));
      final worker = await _loggedInAs('trabajador@erpflutter.dev');
      expect(worker.workReports.getReport(other.id), throwsStateError);
      expect(worker.workReports.addLine(other.id, concept: 'x', units: 1), throwsStateError);
    });

    test('clientes y proveedores no tienen partes', () async {
      for (final email in ['cliente@erpflutter.dev', 'proveedor@erpflutter.dev']) {
        final s = await _loggedInAs(email);
        expect(s.workReports.getReports(filter: WorkReportFilter.active), throwsStateError);
      }
    });
  });

  test('filtros: activos y finalizados no se mezclan', () async {
    final s = await _loggedInAs('superadmin@erpflutter.dev');
    final active = (await s.workReports.getReports(filter: WorkReportFilter.active, pageSize: 1000)).items;
    final finished = (await s.workReports.getReports(filter: WorkReportFilter.finished, pageSize: 1000)).items;
    expect(active.every((r) => r.status.isActive), isTrue);
    expect(finished.every((r) => !r.status.isActive), isTrue);

    final client1 = await s.workReports.getReports(filter: WorkReportFilter.finished, clientId: 1, pageSize: 1000);
    expect(client1.items.every((r) => r.clientName == 'Cliente Demo S.L.'), isTrue);
  });

  test('añadir línea y firmar se guardan en el parte', () async {
    final s = await _loggedInAs('trabajador@erpflutter.dev');
    final report = (await s.workReports.getReports(filter: WorkReportFilter.active)).items.first;
    final products = await s.workReports.searchProducts('cat6');
    expect(products.single.ref, 'CAB-C6');

    await s.workReports.addLine(report.id,
        concept: products.single.concept, units: 30, duration: 45, productId: products.single.id);
    await s.workReports.saveSignature(report.id, [
      [const Offset(0.1, 0.5), const Offset(0.5, 0.4), const Offset(0.9, 0.6)],
    ]);

    final updated = await s.workReports.getReport(report.id);
    expect(updated.lines.last.productRef, 'CAB-C6');
    expect(updated.lines.last.units, 30);
    expect(updated.duration, report.duration + 45);
    expect(updated.isSigned, isTrue);

    expect(s.workReports.addLine(report.id, concept: 'x', units: 0), throwsArgumentError);
    expect(s.workReports.saveSignature(report.id, [[]]), throwsArgumentError);
  });

  testWidgets('listado → detalle → firmar', (tester) async {
    tester.view.physicalSize = const Size(1236, 2676);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    late AppServices s;
    await tester.runAsync(() async {
      s = await _loggedInAs('trabajador@erpflutter.dev');
      // Precarga de JSON: la E/S de assets no avanza con el reloj simulado.
      for (final r in ['work_reports', 'workers', 'clients', 'products', 'users']) {
        await s.api.get(r);
      }
    });

    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'),
      home: WorkReportsScreen(
        viewModel: WorkReportsViewModel(s.workReports),
        repository: s.workReports,
        ownsViewModel: true,
        onOpenDrawer: () {},
      ),
    ));
    await _settle(tester);
    expect(tester.takeException(), isNull);
    expect(find.textContaining('PT-'), findsWidgets);

    // Finalizados → los estados son de cierre.
    await tester.tap(find.text('Finalizados'));
    await _settle(tester);
    expect(find.text('Asignado'), findsNothing);

    await tester.tap(find.text('Activos'));
    await _settle(tester);
    await tester.tap(find.textContaining('PT-').first);
    await _settle(tester);
    expect(tester.takeException(), isNull);
    expect(find.text('LÍNEAS DE TRABAJO'), findsOneWidget);

    // Firmar dibujando un trazo.
    await tester.tap(find.text('Firma'));
    await _settle(tester);
    await tester.drag(find.byKey(const ValueKey('signature-pad')), const Offset(150, 40));
    await tester.tap(find.text('Guardar firma'));
    await _settle(tester);
    expect(tester.takeException(), isNull);
    expect(find.text('Ver firma'), findsOneWidget);
  });
}
