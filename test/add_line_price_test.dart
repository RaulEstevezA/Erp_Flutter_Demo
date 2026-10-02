import 'package:erp_flutter_demo/core/di/app_services.dart';
import 'package:erp_flutter_demo/domain/work_reports.dart';
import 'package:erp_flutter_demo/features/work_reports/work_report_detail_screen.dart';
import 'package:erp_flutter_demo/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 400));
  }
}

void main() {
  for (final (label, typedPrice, expected) in [
    ('precio por defecto', null, 32.0),
    ('precio 0', '0', 0.0),
    ('precio mayor', '50', 50.0),
  ]) {
    testWidgets('mano de obra técnico 30 min, $label', (tester) async {
      tester.view.physicalSize = const Size(1236, 2676);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      late AppServices s;
      late WorkReport report;
      await tester.runAsync(() async {
        SharedPreferences.setMockInitialValues({});
        s = await AppServices.create();
        await s.auth.login(serverUrl: 'demo', email: 'trabajador@erpflutter.dev', password: 'demo1234');
        report = (await s.workReports.getReports(filter: WorkReportFilter.active)).items.first;
      });

      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('es'),
        home: WorkReportDetailScreen(
          reportId: report.id,
          code: report.code,
          repository: s.workReports,
          onOpenDrawer: () {},
        ),
      ));
      await _settle(tester);

      await tester.tap(find.byTooltip('Añadir línea'));
      await _settle(tester);
      // Selector de productos: buscar y tocar el técnico.
      await tester.tap(find.byKey(const ValueKey('product-field')));
      await _settle(tester);
      await tester.enterText(find.widgetWithText(TextField, 'Buscar producto...'), 'mano');
      await tester.pump();
      expect(find.text('28,00\u00a0€/h'), findsOneWidget);
      await tester.tap(find.text('Mano de obra técnico (h)'));
      await _settle(tester);
      // El elegido se ve en el diálogo con su precio de catálogo.
      expect(find.textContaining('MO-TEC · 32,00'), findsOneWidget);
      await tester.enterText(find.widgetWithText(TextFormField, 'Duración (min)'), '30');
      await tester.pump();
      if (typedPrice != null) {
        await tester.enterText(find.widgetWithText(TextFormField, 'Precio unitario (€)'), typedPrice);
        await tester.pump();
      }
      await tester.tap(find.text('Aceptar'));
      await _settle(tester);

      final line = (await tester.runAsync(() => s.workReports.getReport(report.id)))!.lines.last;
      expect(line.concept, 'Mano de obra técnico (h)');
      expect(line.price, expected);
      expect(line.total, expected / 2);
    });
  }

  testWidgets('editar el precio de una línea añadida: el doble y luego 0', (tester) async {
    tester.view.physicalSize = const Size(1236, 2676);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    late AppServices s;
    late WorkReport report;
    await tester.runAsync(() async {
      SharedPreferences.setMockInitialValues({});
      s = await AppServices.create();
      await s.auth.login(serverUrl: 'demo', email: 'trabajador@erpflutter.dev', password: 'demo1234');
      report = (await s.workReports.getReports(filter: WorkReportFilter.active)).items.first;
      final official = (await s.workReports.searchProducts('MO-OFI')).single;
      await s.workReports.addLine(report.id,
          concept: official.concept, units: 1, duration: 60, productId: official.id, price: 28);
    });

    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'),
      home: WorkReportDetailScreen(
        reportId: report.id,
        code: report.code,
        repository: s.workReports,
        onOpenDrawer: () {},
      ),
    ));
    await _settle(tester);

    for (final (typed, expected) in [('56', 56.0), ('0', 0.0)]) {
      final card = find.text('Mano de obra oficial (h)').last;
      await tester.scrollUntilVisible(card, 200, scrollable: find.byType(Scrollable).first);
      await tester.tap(card);
      await _settle(tester);
      expect(find.text('Editar línea'), findsOneWidget);
      await tester.enterText(find.widgetWithText(TextFormField, 'Precio unitario (€)'), typed);
      await tester.tap(find.text('Aceptar'));
      await _settle(tester);
      expect(tester.takeException(), isNull);

      final line = (await tester.runAsync(() => s.workReports.getReport(report.id)))!.lines.last;
      expect(line.price, expected);
      expect(line.total, expected);
      expect(line.duration, 60);
    }
  });
}
