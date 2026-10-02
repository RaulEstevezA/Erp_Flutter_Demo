import 'package:erp_flutter_demo/core/di/app_services.dart';
import 'package:erp_flutter_demo/features/clients/client_detail_screen.dart';
import 'package:erp_flutter_demo/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Avanza el reloj simulado más allá de la latencia de la API.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    await tester.pump(const Duration(milliseconds: 400));
  }
}

void main() {
  testWidgets('ficha → facturas → detalle de factura', (tester) async {
    SharedPreferences.setMockInitialValues({});
    late AppServices s;
    await tester.runAsync(() async {
      s = await AppServices.create();
      await s.auth.login(serverUrl: 'demo', email: 'admin@erpflutter.dev', password: 'demo1234');
    });
    final client = (await tester.runAsync(() async {
      // Lee los JSON una vez para que queden en la caché de la API: la carga
      // de assets es E/S real y no avanza con el reloj simulado del test.
      await s.api.get('client_documents');
      return s.clients.getClients();
    }))!.items.first;

    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'),
      home: ClientDetailScreen(client: client, repository: s.clients, onOpenDrawer: () {}),
    ));
    await _settle(tester);
    expect(tester.takeException(), isNull);
    expect(find.text('Sede principal'), findsWidgets);

    await tester.tap(find.text('Facturas'));
    await _settle(tester);
    expect(tester.takeException(), isNull);
    final firstInvoice = find.textContaining('FAC-').first;
    expect(firstInvoice, findsOneWidget);

    await tester.tap(firstInvoice);
    await _settle(tester);
    expect(tester.takeException(), isNull);
    expect(find.text('Base imponible'), findsOneWidget);
  });
}
