import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/repositories/messaging_repository.dart';
import '../../domain/app_user.dart';
import '../../domain/messaging.dart';

/// Estado global de mensajería mientras dura la sesión: contador de no
/// leídos (badge del menú y del botón flotante, cada 30 s), destinatarios
/// y envío de mensajes nuevos.
class MessagingViewModel extends ChangeNotifier {
  final MessagingRepository _repository;
  Timer? _timer;

  MessagingViewModel(this._repository);

  int unreadCount = 0;
  List<AppUser> recipients = const [];
  bool isLoadingRecipients = false;

  void start() {
    refreshUnread();
    _timer ??= Timer.periodic(const Duration(seconds: 30), (_) => refreshUnread());
  }

  Future<void> refreshUnread() async {
    try {
      final count = await _repository.unreadCount();
      if (count == unreadCount) return;
      unreadCount = count;
      notifyListeners();
    } catch (e) {
      debugPrint('MessagingViewModel → no leídos: $e');
    }
  }

  Future<void> loadRecipients() async {
    isLoadingRecipients = true;
    notifyListeners();
    try {
      recipients = await _repository.recipients();
    } catch (e) {
      debugPrint('MessagingViewModel → destinatarios: $e');
      recipients = const [];
    }
    isLoadingRecipients = false;
    notifyListeners();
  }

  Future<bool> send({required int receiverId, required String body}) async {
    try {
      await _repository.send(receiverId: receiverId, body: body);
      await refreshUnread();
      return true;
    } catch (e) {
      debugPrint('MessagingViewModel → envío: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Listado de conversaciones. Se refresca en silencio cada 10 s solo
/// mientras la pantalla está visible.
class ConversationsViewModel extends ChangeNotifier {
  final MessagingRepository _repository;
  Timer? _timer;

  ConversationsViewModel(this._repository);

  List<Conversation> conversations = const [];
  bool isLoading = false;
  bool hasError = false;

  Future<void> load() async {
    isLoading = true;
    hasError = false;
    notifyListeners();
    try {
      conversations = await _repository.conversations();
    } catch (e) {
      debugPrint('ConversationsViewModel → $e');
      hasError = true;
    }
    isLoading = false;
    notifyListeners();
  }

  void startPolling() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _silentRefresh());
  }

  void stopPolling() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _silentRefresh() async {
    try {
      conversations = await _repository.conversations();
      notifyListeners();
    } catch (_) {}
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Una conversación abierta. Vive lo que dura su pantalla.
class ChatViewModel extends ChangeNotifier {
  final MessagingRepository _repository;
  final int conversationId;
  final int receiverId;
  Timer? _timer;

  ChatViewModel(
    this._repository, {
    required this.conversationId,
    required this.receiverId,
  });

  List<Message> messages = const [];
  bool isLoading = false;
  bool isSending = false;
  bool hasError = false;

  void start() {
    load();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _poll());
  }

  Future<void> load() async {
    isLoading = true;
    hasError = false;
    notifyListeners();
    try {
      messages = await _repository.messages(conversationId);
    } catch (e) {
      debugPrint('ChatViewModel → $e');
      hasError = true;
    }
    isLoading = false;
    notifyListeners();
  }

  /// Solo repinta si hay mensajes nuevos.
  Future<void> _poll() async {
    try {
      final fresh = await _repository.messages(conversationId);
      if (fresh.length != messages.length ||
          (fresh.isNotEmpty && fresh.last.id != messages.last.id)) {
        messages = fresh;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<bool> send(String body) async {
    if (isSending) return false;
    isSending = true;
    notifyListeners();
    try {
      await _repository.send(receiverId: receiverId, body: body);
      messages = await _repository.messages(conversationId);
      return true;
    } catch (e) {
      debugPrint('ChatViewModel → envío: $e');
      return false;
    } finally {
      isSending = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
