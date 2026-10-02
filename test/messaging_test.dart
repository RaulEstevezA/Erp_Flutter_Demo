import 'package:erp_flutter_demo/core/di/app_services.dart';
import 'package:erp_flutter_demo/core/roles/app_role.dart';
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

  test('el chat es libre: cualquier rol escribe a cualquier otro', () async {
    for (final email in [
      'trabajador@erpflutter.dev',
      'cliente@erpflutter.dev',
      'proveedor@erpflutter.dev',
    ]) {
      final s = await _loggedInAs(email);
      final me = s.session.user!.id;
      final recipients = await s.messaging.recipients();
      // Los 7 usuarios de la demo menos uno mismo.
      expect(recipients, hasLength(6), reason: email);
      expect(recipients.map((u) => u.id), isNot(contains(me)));
    }
  });

  test('un trabajador tiene sus conversaciones', () async {
    final s = await _loggedInAs('trabajador@erpflutter.dev');
    expect(await s.messaging.conversations(), isNotEmpty);
    expect(
      (await s.messaging.recipients()).map((u) => u.role),
      contains(AppRole.customer),
    );
  });

  test('abrir una conversación la marca como leída', () async {
    final s = await _loggedInAs('admin@erpflutter.dev');
    final before = await s.messaging.unreadCount();
    expect(before, greaterThan(0));

    final unreadConv = (await s.messaging.conversations()).firstWhere((c) => c.unreadCount > 0);
    await s.messaging.messages(unreadConv.id);

    expect(await s.messaging.unreadCount(), before - unreadConv.unreadCount);
  });

  test('un mensaje nuevo crea conversación y llega respuesta automática', () async {
    final s = await _loggedInAs('usuario@erpflutter.dev');
    // Ana López (3) aún no tiene conversación con el proveedor (7).
    final before = await s.messaging.conversations();
    expect(before.any((c) => c.otherUser?.id == 7), isFalse);

    final convId = await s.messaging.send(receiverId: 7, body: '¿Tenéis stock?');
    var messages = await s.messaging.messages(convId);
    expect(messages.single.isMine, isTrue);

    // La respuesta se programa a 4-8 s.
    await Future<void>.delayed(const Duration(seconds: 9));
    messages = await s.messaging.messages(convId);
    expect(messages, hasLength(2));
    expect(messages.last.isMine, isFalse);
    expect(messages.last.senderId, 7);
  }, timeout: const Timeout(Duration(seconds: 30)));
}
