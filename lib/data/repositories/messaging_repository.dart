import 'dart:math';

import '../../core/network/api_client.dart';
import '../../core/session/session_store.dart';
import '../../domain/app_user.dart';
import '../../domain/messaging.dart';
import '../local/local_changes_store.dart';
import 'user_repository.dart';

/// Mensajería 1 a 1: un chat abierto en el que cualquier usuario puede
/// escribir a cualquier otro, sea cual sea su rol.
///
/// Como el backend es estático, cuando se envía un mensaje el destinatario
/// "contesta" pasados unos segundos con una respuesta de `auto_replies`. Esa
/// respuesta se guarda con fecha futura y aparece cuando llega su hora, de
/// modo que el sondeo periódico de las pantallas la recoge como haría con
/// un mensaje real.
class MessagingRepository {
  static const _resource = 'messages';
  static const _localConversations = 'conversations';
  static const _localMessages = 'messages';
  static const _reads = 'message_reads';

  final ApiClient _api;
  final LocalChangesStore _local;
  final SessionStore _session;
  final UserRepository _users;
  final Random _random;

  /// Instante de referencia para los `minutes_ago` del backend. Se fija una
  /// vez para que los mensajes estáticos no "se muevan" durante la sesión.
  final DateTime _anchor = DateTime.now();

  MessagingRepository(
    this._api,
    this._local,
    this._session,
    this._users, {
    Random? random,
  }) : _random = random ?? Random();

  SessionUser get _me {
    final user = _session.user;
    if (user == null) throw StateError('No hay sesión activa.');
    return user;
  }

  /// Todos los usuarios salvo el de la sesión.
  Future<List<AppUser>> recipients() async {
    final me = _me;
    final all = await _users.all();
    return all
        .where((u) => u.id != me.id)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<List<Conversation>> conversations() async {
    final me = _me;
    final data = await _load();
    final users = await _users.byId();

    final result = <Conversation>[];
    for (final conv in data.conversations) {
      final participants = conv.participants;
      if (!participants.contains(me.id)) continue;
      final otherId = participants.firstWhere((id) => id != me.id, orElse: () => me.id);
      final messages = data.messages.where((m) => m.conversationId == conv.id).toList();
      if (messages.isEmpty) continue;
      result.add(
        Conversation(
          id: conv.id,
          otherUser: users[otherId],
          lastMessage: _toMessage(messages.last, me.id, users),
          unreadCount: messages.where((m) => !_isReadBy(m, me.id)).length,
        ),
      );
    }
    result.sort(
      (a, b) => b.lastMessage!.createdAt.compareTo(a.lastMessage!.createdAt),
    );
    return result;
  }

  /// Total de mensajes sin leer, acotado a 99 como en el ERP.
  Future<int> unreadCount() async {
    final total = (await conversations())
        .fold<int>(0, (sum, c) => sum + c.unreadCount);
    return min(total, 99);
  }

  /// Mensajes de la conversación (del más antiguo al más reciente).
  /// Abrirla la marca como leída.
  Future<List<Message>> messages(int conversationId) async {
    final me = _me;
    final data = await _load();
    final conv = data.conversations.where((c) => c.id == conversationId).firstOrNull;
    if (conv == null || !conv.participants.contains(me.id)) {
      throw StateError('Conversación no disponible.');
    }
    final users = await _users.byId();
    final raw = data.messages.where((m) => m.conversationId == conversationId).toList();
    if (raw.isNotEmpty) {
      await _local.putInMap(_reads, '$conversationId:${me.id}', raw.last.id);
    }
    return raw.map((m) => _toMessage(m, me.id, users)).toList();
  }

  /// Envía un mensaje y devuelve el id de la conversación (nueva o existente).
  Future<int> send({required int receiverId, required String body}) async {
    final me = _me;
    final allowed = await recipients();
    if (!allowed.any((u) => u.id == receiverId)) {
      throw StateError('No puedes escribir a este usuario.');
    }

    final data = await _load();
    final existing = data.conversations
        .where((c) => c.participants.contains(me.id) && c.participants.contains(receiverId))
        .firstOrNull;
    final conversationId = existing?.id ?? _local.nextId(_localConversations);
    if (existing == null) {
      await _local.add(_localConversations, {
        'id': conversationId,
        'participants': [me.id, receiverId],
      });
    }

    final now = DateTime.now();
    final sentId = _local.nextId(_localMessages);
    await _local.add(_localMessages, {
      'id': sentId,
      'conversation_id': conversationId,
      'sender_id': me.id,
      'body': body,
      'created_at': now.toIso8601String(),
    });
    // Lo propio cuenta como leído.
    await _local.putInMap(_reads, '$conversationId:${me.id}', sentId);

    final replies = data.autoReplies;
    if (replies.isNotEmpty) {
      await _local.add(_localMessages, {
        'id': _local.nextId(_localMessages),
        'conversation_id': conversationId,
        'sender_id': receiverId,
        'body': replies[_random.nextInt(replies.length)],
        'created_at': now.add(Duration(seconds: 4 + _random.nextInt(5))).toIso8601String(),
      });
    }
    return conversationId;
  }

  // ── Datos ──────────────────────────────────────────────────────────────

  Future<_MessagingData> _load() async {
    final data = await _api.get(_resource) as Map<String, dynamic>;
    final now = DateTime.now();

    final conversations = [
      ...(data['conversations'] as List).cast<Map<String, dynamic>>(),
      ..._local.read(_localConversations),
    ]
        .map(
          (c) => _Conv(
            c['id'] as int,
            (c['participants'] as List).cast<int>(),
          ),
        )
        .toList();

    final messages = [
      ...(data['messages'] as List).cast<Map<String, dynamic>>().map(
            (m) => _RawMessage(
              id: m['id'] as int,
              conversationId: m['conversation_id'] as int,
              senderId: m['sender_id'] as int,
              body: m['body'] as String,
              createdAt: _anchor.subtract(Duration(minutes: m['minutes_ago'] as int)),
              readOnServer: m['read'] as bool? ?? true,
            ),
          ),
      ..._local.read(_localMessages).map(
            (m) => _RawMessage(
              id: m['id'] as int,
              conversationId: m['conversation_id'] as int,
              senderId: m['sender_id'] as int,
              body: m['body'] as String,
              createdAt: DateTime.parse(m['created_at'] as String),
              readOnServer: false,
            ),
          ),
    ]
        // Las respuestas automáticas "llegan" cuando pasa su hora.
        .where((m) => !m.createdAt.isAfter(now))
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return _MessagingData(
      conversations,
      messages,
      (data['auto_replies'] as List? ?? const []).cast<String>(),
    );
  }

  bool _isReadBy(_RawMessage message, int userId) {
    if (message.senderId == userId || message.readOnServer) return true;
    final marker = _local.readMap(_reads)['${message.conversationId}:$userId'] as int?;
    return marker != null && message.id <= marker;
  }

  static Message _toMessage(_RawMessage m, int me, Map<int, AppUser> users) => Message(
        id: m.id,
        conversationId: m.conversationId,
        senderId: m.senderId,
        senderName: users[m.senderId]?.name,
        body: m.body,
        createdAt: m.createdAt,
        isMine: m.senderId == me,
      );
}

class _Conv {
  final int id;
  final List<int> participants;

  const _Conv(this.id, this.participants);
}

class _RawMessage {
  final int id;
  final int conversationId;
  final int senderId;
  final String body;
  final DateTime createdAt;
  final bool readOnServer;

  const _RawMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.body,
    required this.createdAt,
    required this.readOnServer,
  });
}

class _MessagingData {
  final List<_Conv> conversations;
  final List<_RawMessage> messages;
  final List<String> autoReplies;

  const _MessagingData(this.conversations, this.messages, this.autoReplies);
}
