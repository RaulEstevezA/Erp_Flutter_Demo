import 'dart:typed_data';

import 'package:erp_flutter_demo/core/di/app_services.dart';
import 'package:erp_flutter_demo/data/local/attachments/attachment_storage.dart';
import 'package:erp_flutter_demo/data/repositories/work_report_repository.dart';
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

  group('archivos', filesTests);

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

    expect(products.single.price, 0.85);
    await s.workReports.addLine(report.id,
        concept: products.single.concept,
        units: 30,
        duration: 45,
        productId: products.single.id,
        price: 1.2);
    await s.workReports.saveSignature(report.id, [
      [const Offset(0.1, 0.5), const Offset(0.5, 0.4), const Offset(0.9, 0.6)],
    ]);

    final updated = await s.workReports.getReport(report.id);
    expect(updated.lines.last.productRef, 'CAB-C6');
    expect(updated.lines.last.units, 30);
    expect(updated.duration, report.duration + 45);
    expect(updated.lines.last.total, closeTo(36, 0.001));
    expect(updated.amount, closeTo(report.amount + 36, 0.001));
    expect(updated.isSigned, isTrue);

    expect(s.workReports.addLine(report.id, concept: 'x', units: 0), throwsArgumentError);
    expect(s.workReports.addLine(report.id, concept: 'x', units: 1, price: -1), throwsArgumentError);
    expect(s.workReports.saveSignature(report.id, [[]]), throwsArgumentError);
  });

  test('se pueden añadir varias líneas seguidas (también con líneas antiguas sin id)', () async {
    final s = await _loggedInAs('trabajador@erpflutter.dev');
    final report = (await s.workReports.getReports(filter: WorkReportFilter.active)).items.first;
    // Línea guardada por una versión anterior de la app, sin id.
    await s.localChanges.add('work_report_lines', {
      'report_id': report.id,
      'concept': 'Línea antigua',
      'units': 1,
      'duration': 0,
    });
    await s.workReports.addLine(report.id, concept: 'Primera', units: 1);
    await s.workReports.addLine(report.id, concept: 'Segunda', units: 2);
    final lines = (await s.workReports.getReport(report.id)).lines;
    expect(lines.map((l) => l.concept), containsAllInOrder(['Línea antigua', 'Primera', 'Segunda']));
    expect(lines.map((l) => l.id).toSet(), hasLength(lines.length));
  });

  test('la mano de obra se cobra por horas según la duración', () async {
    final s = await _loggedInAs('trabajador@erpflutter.dev');
    final report = (await s.workReports.getReports(filter: WorkReportFilter.active)).items.first;
    final tech = (await s.workReports.searchProducts('MO-TEC')).single;
    expect(tech.hourly, isTrue);

    // Aunque llegaran otras unidades, mandan los minutos: 30 min = 0,5 h.
    await s.workReports.addLine(report.id,
        concept: tech.concept, units: 5, duration: 30, productId: tech.id, price: tech.price);
    final line = (await s.workReports.getReport(report.id)).lines.last;
    expect(line.hourly, isTrue);
    expect(line.units, 0.5);
    expect(line.total, 16);

    expect(
      s.workReports.addLine(report.id, concept: tech.concept, units: 1, productId: tech.id),
      throwsArgumentError,
    );
  });

  test('el precio de una línea propia se puede cambiar; las del servidor no', () async {
    final s = await _loggedInAs('trabajador@erpflutter.dev');
    final report = (await s.workReports.getReports(filter: WorkReportFilter.active))
        .items
        .firstWhere((r) => r.lines.isNotEmpty);
    final official = (await s.workReports.searchProducts('MO-OFI')).single;

    await s.workReports.addLine(report.id,
        concept: official.concept, units: 1, duration: 60, productId: official.id, price: official.price);
    var mine = (await s.workReports.getReport(report.id)).lines.last;
    expect(mine.editable, isTrue);
    expect(mine.total, 28);

    // Cliente muy irritante: el doble.
    await s.workReports.updateLine(report.id, mine.id,
        concept: mine.concept, units: mine.units, duration: 60, price: 56);
    mine = (await s.workReports.getReport(report.id)).lines.last;
    expect(mine.price, 56);
    expect(mine.total, 56);

    // No se le cobra, pero consta.
    await s.workReports.updateLine(report.id, mine.id,
        concept: mine.concept, units: mine.units, duration: 60, price: 0);
    mine = (await s.workReports.getReport(report.id)).lines.last;
    expect(mine.concept, official.concept);
    expect(mine.duration, 60);
    expect(mine.total, 0);

    final server = (await s.workReports.getReport(report.id)).lines.first;
    expect(server.editable, isFalse);
    expect(
      s.workReports.updateLine(report.id, server.id,
          concept: server.concept, units: server.units, duration: server.duration, price: 0),
      throwsStateError,
    );
  });

  test('en los datos de ejemplo, la mano de obra cuadra con sus minutos', () async {
    final s = await _loggedInAs('admin@erpflutter.dev');
    final labour = [
      for (final r in await _all(s))
        for (final l in r.lines)
          if (l.hourly) l,
    ];
    expect(labour, isNotEmpty);
    for (final l in labour) {
      expect(l.units, closeTo(l.duration / 60, 0.001));
      expect(l.total, closeTo(l.price! * l.duration / 60, 0.001));
    }
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

    // Añadir línea: el producto propone su precio, que se puede cambiar.
    await tester.tap(find.byTooltip('Añadir línea'));
    await _settle(tester);
    await tester.tap(find.byKey(const ValueKey('product-field')));
    await _settle(tester);
    await tester.enterText(find.widgetWithText(TextField, 'Buscar producto...'), 'cat6');
    await tester.pump();
    await tester.tap(find.text('Cable de red Cat6 (m)'));
    await _settle(tester);
    final price = find.widgetWithText(TextFormField, 'Precio unitario (€)');
    expect(find.descendant(of: price, matching: find.text('0,85')), findsOneWidget);
    await tester.enterText(price, '1,20');
    await tester.enterText(find.widgetWithText(TextFormField, 'Unidades'), '10');
    await tester.tap(find.text('Aceptar'));
    await _settle(tester);
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(find.text('Total del parte'), 200, scrollable: find.byType(Scrollable).last);
    expect(find.textContaining('12,00'), findsWidgets);
    expect(find.textContaining('1,20'), findsOneWidget);
    expect(find.text('Total del parte'), findsOneWidget);

    // Mano de obra: las horas salen de los minutos (30 min a 32 €/h = 16 €).
    await tester.tap(find.byTooltip('Añadir línea'));
    await _settle(tester);
    await tester.tap(find.byKey(const ValueKey('product-field')));
    await _settle(tester);
    await tester.enterText(find.widgetWithText(TextField, 'Buscar producto...'), 'MO-TEC');
    await tester.pump();
    await tester.tap(find.text('Mano de obra técnico (h)'));
    await _settle(tester);
    await tester.enterText(find.widgetWithText(TextFormField, 'Duración (min)'), '30');
    await tester.pump();
    expect(
      find.descendant(of: find.widgetWithText(TextFormField, 'Horas'), matching: find.text('0,5')),
      findsOneWidget,
    );
    await tester.tap(find.text('Aceptar'));
    await _settle(tester);
    expect(tester.takeException(), isNull);
    final saved = (await tester.runAsync(() async {
      final reports = await s.workReports.getReports(filter: WorkReportFilter.active);
      final opened = reports.items.firstWhere((r) => r.lines.any((l) => l.productRef == 'CAB-C6'));
      return opened.lines.last;
    }))!;
    expect(saved.productRef, 'MO-TEC');
    expect(saved.units, 0.5);
    expect(saved.total, 16);

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

/// Almacenamiento en memoria para no depender de path_provider en tests.
class _MemoryStorage implements AttachmentStorage {
  final files = <String, Uint8List>{};

  @override
  Future<String> save(String name, Uint8List bytes) async {
    final key = '${files.length}_$name';
    files[key] = bytes;
    return key;
  }

  @override
  Future<Uint8List?> read(String key) async => files[key];

  @override
  Future<void> delete(String key) async => files.remove(key);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void filesTests() {
  Future<(AppServices, _MemoryStorage)> loggedIn(String email) async {
    SharedPreferences.setMockInitialValues({});
    final storage = _MemoryStorage();
    final services = await AppServices.create(attachments: storage);
    await services.auth.login(serverUrl: 'demo', email: email, password: 'demo1234');
    return (services, storage);
  }

  test('archivos de ejemplo: se ven y se pueden ocultar', () async {
    final (s, _) = await loggedIn('admin@erpflutter.dev');
    final report = (await _all(s)).firstWhere((r) => r.code == 'PT-00011');
    final files = await s.workReports.getFiles(report.id);
    expect(files.map((f) => f.type), containsAll(WorkReportFileType.values));

    final image = files.firstWhere((f) => f.isImage);
    final bytes = await s.workReports.fileBytes(image);
    expect(bytes!.length, image.size);

    await s.workReports.deleteFile(report.id, image);
    expect((await s.workReports.getFiles(report.id)).any((f) => f.id == image.id), isFalse);
  });

  test('adjuntar y borrar un archivo propio; límite de 10 MB', () async {
    final (s, storage) = await loggedIn('trabajador@erpflutter.dev');
    final report = (await s.workReports.getReports(filter: WorkReportFilter.active)).items.first;
    final before = (await s.workReports.getFiles(report.id)).length;

    await s.workReports.addFile(report.id,
        name: 'foto.jpg', bytes: Uint8List.fromList([1, 2, 3]), type: WorkReportFileType.image);
    final files = await s.workReports.getFiles(report.id);
    expect(files, hasLength(before + 1));
    final mine = files.last;
    expect(mine.name, 'foto.jpg');
    expect(await s.workReports.fileBytes(mine), [1, 2, 3]);

    await s.workReports.deleteFile(report.id, mine);
    expect(storage.files, isEmpty);
    expect(await s.workReports.getFiles(report.id), hasLength(before));

    expect(
      s.workReports.addFile(report.id,
          name: 'enorme.jpg',
          bytes: Uint8List(WorkReportRepository.maxFileBytes + 1),
          type: WorkReportFileType.image),
      throwsA(isA<FileTooLargeException>()),
    );
  });
}
