import 'app_user.dart';

class Message {
  final int id;
  final int conversationId;
  final int senderId;
  final String? senderName;
  final String body;
  final DateTime createdAt;

  /// Enviado por el usuario de la sesión.
  final bool isMine;

  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.senderName,
    required this.body,
    required this.createdAt,
    required this.isMine,
  });
}

/// Conversación 1 a 1 vista desde el usuario de la sesión.
class Conversation {
  final int id;
  final AppUser? otherUser;
  final Message? lastMessage;
  final int unreadCount;

  const Conversation({
    required this.id,
    required this.otherUser,
    required this.lastMessage,
    required this.unreadCount,
  });
}
