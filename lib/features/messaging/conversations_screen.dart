import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/roles/role_labels.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/list_parts.dart';
import '../../core/widgets/menu_leading.dart';
import '../../data/repositories/messaging_repository.dart';
import '../../domain/messaging.dart';
import '../../l10n/app_localizations.dart';
import 'chat_screen.dart';
import 'messaging_view_models.dart';
import 'new_message_sheet.dart';

/// Listado de conversaciones. Se usa como sección del menú y también
/// apilada desde el botón flotante del inicio (entonces ← cierra la ruta).
class ConversationsScreen extends StatefulWidget {
  final ConversationsViewModel viewModel;
  final MessagingViewModel messaging;
  final MessagingRepository repository;
  final VoidCallback onOpenDrawer;
  final VoidCallback? onBack;

  const ConversationsScreen({
    super.key,
    required this.viewModel,
    required this.messaging,
    required this.repository,
    required this.onOpenDrawer,
    this.onBack,
  });

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.load();
      widget.viewModel.startPolling();
    });
  }

  @override
  void dispose() {
    widget.viewModel.stopPolling();
    super.dispose();
  }

  Future<void> _refreshAll() async {
    await widget.viewModel.load();
    await widget.messaging.refreshUnread();
  }

  Future<void> _newMessage() async {
    if (await NewMessageSheet.show(context, widget.messaging) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).messagesSent)),
      );
      _refreshAll();
    }
  }

  Future<void> _open(Conversation conversation) async {
    final other = conversation.otherUser;
    if (other == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatScreen(
          viewModel: ChatViewModel(
            widget.repository,
            conversationId: conversation.id,
            receiverId: other.id,
          ),
          title: other.name,
          onOpenDrawer: widget.onOpenDrawer,
        ),
      ),
    );
    if (mounted) _refreshAll();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        leadingWidth: MenuLeading.fullWidth,
        leading: MenuLeading(onOpenDrawer: widget.onOpenDrawer, onBack: widget.onBack),
        title: Text(l10n.messagesList),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.messagesNew,
        shape: const CircleBorder(),
        onPressed: _newMessage,
        child: const Icon(Icons.add),
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          final vm = widget.viewModel;
          if (vm.isLoading && vm.conversations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.hasError) {
            return LoadErrorView(message: l10n.messagesLoadError, onRetry: vm.load);
          }
          if (vm.conversations.isEmpty) {
            return EmptyView(message: l10n.messagesEmpty, icon: Icons.forum_outlined);
          }
          return RefreshIndicator(
            onRefresh: _refreshAll,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 96),
              itemCount: vm.conversations.length,
              separatorBuilder: (_, _) => const Divider(height: 1, indent: 76, endIndent: 16),
              itemBuilder: (context, index) {
                final conversation = vm.conversations[index];
                return _ConversationTile(
                  conversation: conversation,
                  onTap: () => _open(conversation),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;

  const _ConversationTile({required this.conversation, required this.onTap});

  String _time(DateTime date) {
    final now = DateTime.now();
    return DateUtils.isSameDay(date, now)
        ? DateFormat('HH:mm').format(date)
        : DateFormat('dd/MM').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final user = conversation.otherUser;
    final last = conversation.lastMessage;
    final unread = conversation.unreadCount;
    final muted = theme.colorScheme.onSurfaceVariant;
    final brand = context.brand;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: InitialsAvatar(name: user?.name ?? '?'),
      title: Row(
        children: [
          Expanded(
            child: Text(
              user?.name ?? '—',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          if (last != null)
            Text(
              _time(last.createdAt),
              style: theme.textTheme.bodySmall?.copyWith(
                color: unread > 0 ? brand : muted,
                fontWeight: unread > 0 ? FontWeight.w600 : null,
              ),
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (user != null)
            Text(user.role.label(l10n), style: theme.textTheme.labelSmall?.copyWith(color: muted)),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${last?.isMine ?? false ? l10n.messagesYou : ''}${last?.body ?? ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: unread > 0 ? theme.colorScheme.onSurface : muted,
                    fontWeight: unread > 0 ? FontWeight.w500 : null,
                  ),
                ),
              ),
              if (unread > 0)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$unread',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
