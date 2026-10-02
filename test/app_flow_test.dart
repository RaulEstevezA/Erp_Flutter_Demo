import 'package:erp_flutter_demo/app.dart';
import 'package:erp_flutter_demo/core/di/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(initializeDateFormatting);

  Future<AppServices> pumpApp(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final services = await tester.runAsync(AppServices.create);
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ErpFlutterApp(services: services!));
    // Splash.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    return services;
  }

  /// Avanza el reloj real para que terminen las cargas con latencia simulada.
  Future<void> settle(WidgetTester tester) async {
    await tester.runAsync(() => Future<void>.delayed(const Duration(seconds: 1)));
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('login como trabajador → inicio sin módulos de gestión',
      (tester) async {
    await pumpApp(tester);
    expect(find.text('Inicio de sesión'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Correo electrónico'),
      'trabajador@erpflutter.dev',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Contraseña'),
      'demo1234',
    );
    await tester.tap(find.text('Iniciar sesión'));
    await settle(tester);
    await settle(tester);

    expect(find.text('Bienvenido a ERP Flutter Demo,'), findsOneWidget);
    expect(find.text('Javier Torres'), findsOneWidget);
    expect(find.text('Ver fichajes'), findsOneWidget);
    expect(find.text('Vacaciones'), findsOneWidget);
    expect(find.text('Clientes'), findsNothing);
    expect(find.text('Partes de visita'), findsNothing);
  });

  testWidgets('errores de validación del login', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pump();
    expect(find.text('Debes introducir tu correo electrónico.'), findsOneWidget);
  });
}
