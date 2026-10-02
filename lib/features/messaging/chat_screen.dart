import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/list_parts.dart';
import '../../core/widgets/menu_leading.dart';
import '../../domain/messaging.dart';
import '../../l10n/app_localizations.dart';
import 'messaging_view_models.dart';

/// Chat de una conversación: burbujas propias a la derecha (color de marca)
/// y ajenas a la izquierda, separadores por día y barra para responder.
///
/// La pantalla es dueña de su [ChatViewModel]: lo arranca y lo destruye.
class ChatScreen extends StatefulWidget {
  final ChatViewModel viewModel;
  final String title;
  final VoidCallback onOpenDrawer;

  const ChatScreen({
    super.key,
    required this.viewModel,
    required this.title,
    required this.onOpenDrawer,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _text = TextEditingController();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_scrollToEnd);
    widget.viewModel.start();
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_scrollToEnd);
    widget.viewModel.dispose();
    _text.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send() async {
    final body = _text.text.trim();
    if (body.isEmpty) return;
    _text.clear();
    final ok = await widget.viewModel.send(body);
    if (!ok && mounted) {
      _text.text = body;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).messagesSendError),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        leadingWidth: MenuLeading.fullWidth,
        leading: MenuLeading(onOpenDrawer: widget.onOpenDrawer),
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListenableBuilder(
              listenable: widget.viewModel,
              builder: (context, _) {
                final vm = widget.viewModel;
                if (vm.isLoading && vm.messages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (vm.hasError) {
                  return LoadErrorView(message: l10n.messagesLoadError, onRetry: vm.load);
                }
                if (vm.messages.isEmpty) {
                  return EmptyView(
                    message: l10n.messagesChatEmpty,
                    icon: Icons.chat_bubble_outline,
                  );
                }
                return ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  itemCount: vm.messages.length,
                  itemBuilder: (context, index) {
                    final message = vm.messages[index];
                    final previous = index == 0 ? null : vm.messages[index - 1];
                    final newDay = previous == null ||
                        !DateUtils.isSameDay(previous.createdAt, message.createdAt);
                    return Column(
                      children: [
                        if (newDay) _DayDivider(date: message.createdAt),
                        _Bubble(message: message),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          _InputBar(
            controller: _text,
            viewModel: widget.viewModel,
            hint: l10n.messagesTypeHint,
            onSend: _send,
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final Message message;

  const _Bubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mine = message.isMine;
    final background = mine ? AppColors.primary : theme.colorScheme.surfaceContainerHighest;
    final foreground = mine ? Colors.white : theme.colorScheme.onSurface;

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(left: mine ? 60 : 0, right: mine ? 0 : 60, top: 2, bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(mine ? 18 : 4),
            bottomRight: Radius.circular(mine ? 4 : 18),
          ),
        ),
        child: Column(
          crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(message.body, style: TextStyle(color: foreground, fontSize: 15)),
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(message.createdAt),
              style: TextStyle(color: foreground.withValues(alpha: 0.65), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayDivider extends StatelessWidget {
  final DateTime date;

  const _DayDivider({required this.date});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    final label = DateFormat.yMMMMd(Localizations.localeOf(context).toString()).format(date);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(label, style: TextStyle(color: color, fontSize: 12)),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final ChatViewModel viewModel;
  final String hint;
  final VoidCallback onSend;

  const _InputBar({
    required this.controller,
    required this.viewModel,
    required this.hint,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final sending = viewModel.isSending;
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(top: BorderSide(color: theme.colorScheme.outline)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      enabled: !sending,
                      minLines: 1,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => onSend(),
                      decoration: InputDecoration(
                        hintText: hint,
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: context.brand),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  sending
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.send_rounded),
                          color: context.brand,
                          iconSize: 28,
                          onPressed: onSend,
                        ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
