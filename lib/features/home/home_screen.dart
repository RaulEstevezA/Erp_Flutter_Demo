import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/roles/permissions.dart';
import '../../core/session/session_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/card_button.dart';
import '../../core/widgets/menu_leading.dart';
import '../../l10n/app_localizations.dart';
import '../messaging/messaging_view_models.dart';
import '../messaging/new_message_sheet.dart';
import '../shell/app_section.dart';
import 'home_view_model.dart';
import 'live_clock.dart';

/// Inicio: reloj, saludo, botón de fichaje y accesos a las secciones.
class HomeScreen extends StatefulWidget {
  final HomeViewModel viewModel;
  final SessionUser user;
  final ValueChanged<AppSection> onSectionSelected;
  final VoidCallback onOpenDrawer;

  final MessagingViewModel messaging;
  final VoidCallback onOpenConversations;

  const HomeScreen({
    super.key,
    required this.viewModel,
    required this.user,
    required this.onSectionSelected,
    required this.onOpenDrawer,
    required this.messaging,
    required this.onOpenConversations,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _fabOpen = false;

  void _closeFab() {
    if (_fabOpen) setState(() => _fabOpen = false);
  }

  Future<void> _newMessage() async {
    _closeFab();
    final sent = await NewMessageSheet.show(context, widget.messaging);
    if (sent && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).messagesSent)),
      );
    }
  }

  void _openConversations() {
    _closeFab();
    widget.onOpenConversations();
  }

  Future<void> _onClockTap() async {
    final l10n = AppLocalizations.of(context);
    final working = widget.viewModel.isWorking;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        actionsAlignment: MainAxisAlignment.spaceBetween,
        title: Text(
          working ? l10n.clockConfirmEndTitle : l10n.clockConfirmStartTitle,
        ),
        content: Text(
          working ? l10n.clockConfirmEndMessage : l10n.clockConfirmStartMessage,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.dialogCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.dialogAccept),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final outcome = await widget.viewModel.toggleClock();
    if (!mounted) return;

    final time = DateFormat('HH:mm').format(DateTime.now());
    final message = switch (outcome) {
      ClockOutcome.clockedIn => l10n.clockInDone(time),
      ClockOutcome.clockedOut => l10n.clockOutDone(time),
      ClockOutcome.syncedAlreadyWorking => l10n.clockSyncedStarted,
      ClockOutcome.syncedAlreadyStopped => l10n.clockSyncedEnded,
      ClockOutcome.failed => l10n.clockError,
    };
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leadingWidth: MenuLeading.compactWidth,
        leading: MenuLeading(onOpenDrawer: widget.onOpenDrawer),
        title: Text(l10n.homeTitle),
      ),
      floatingActionButton: ListenableBuilder(
        listenable: Listenable.merge([widget.viewModel, widget.messaging]),
        builder: (context, _) => _MessagesSpeedDial(
          open: _fabOpen,
          unread: widget.messaging.unreadCount,
          enabled: !widget.viewModel.hasConnectionError,
          onToggle: () => setState(() => _fabOpen = !_fabOpen),
          onNewMessage: _newMessage,
          onOpenList: _openConversations,
        ),
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          final vm = widget.viewModel;
          final blocked = vm.hasConnectionError;
          final role = widget.user.role;
          final clocks = role.can(AppPermission.clockInOut);
          // Mensajes va en el botón flotante; solo se muestra como tarjeta
          // a quien no ficha (clientes y proveedores), para quienes es la
          // única sección.
          final shortcuts = AppSection.values.where(
            (s) =>
                s != AppSection.home &&
                (s != AppSection.messages || !clocks) &&
                s.isVisibleFor(role),
          );

          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _closeFab,
            child: Column(
              children: [
                if (vm.isLoadingStatus)
                  LinearProgressIndicator(
                    minHeight: 3,
                    backgroundColor: context.brand.withValues(alpha: 0.15),
                  ),
                if (blocked) _ConnectionBanner(onRetry: vm.loadStatus),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const LiveClock(),
                            const SizedBox(height: 24),
                            Text(
                              l10n.homeWelcome(widget.user.companyName),
                              style: theme.textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.user.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (clocks) ...[
                              const SizedBox(height: 12),
                              CardButton(
                                icon: vm.isWorking
                                    ? Icons.stop_circle_outlined
                                    : Icons.play_circle_outline,
                                title: vm.isWorking
                                    ? l10n.clockEndShift
                                    : l10n.clockStartShift,
                                color: vm.isWorking
                                    ? AppColors.error
                                    : context.brand,
                                isLoading: vm.isClocking,
                                enabled: !blocked && !vm.isLoadingStatus,
                                onTap: _onClockTap,
                              ),
                            ],
                            for (final section in shortcuts) ...[
                              const SizedBox(height: 12),
                              CardButton(
                                icon: section.icon,
                                title: section.label(l10n),
                                enabled: !blocked,
                                onTap: () => widget.onSectionSelected(section),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Botón flotante de mensajes: muestra los no leídos y al pulsarlo despliega
/// "Nuevo mensaje" y "Mensajes".
class _MessagesSpeedDial extends StatelessWidget {
  final bool open;
  final int unread;
  final bool enabled;
  final VoidCallback onToggle;
  final VoidCallback onNewMessage;
  final VoidCallback onOpenList;

  const _MessagesSpeedDial({
    required this.open,
    required this.unread,
    required this.enabled,
    required this.onToggle,
    required this.onNewMessage,
    required this.onOpenList,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    Widget entry(
      String heroTag,
      IconData icon,
      String label,
      VoidCallback onTap,
      int ms,
    ) {
      return AnimatedOpacity(
        opacity: open ? 1 : 0,
        duration: Duration(milliseconds: ms),
        child: AnimatedSlide(
          offset: open ? Offset.zero : const Offset(0, 0.3),
          duration: Duration(milliseconds: ms),
          child: IgnorePointer(
            ignoring: !open,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Material(
                  color: Theme.of(context).colorScheme.surface,
                  elevation: 2,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: onTap,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: context.brand,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton.small(
                  heroTag: heroTag,
                  shape: const CircleBorder(),
                  onPressed: onTap,
                  child: Icon(icon),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          entry(
            'fab_new_message',
            Icons.edit_outlined,
            l10n.messagesNew,
            onNewMessage,
            200,
          ),
          const SizedBox(height: 12),
          entry(
            'fab_messages',
            Icons.list_alt_outlined,
            l10n.messagesList,
            onOpenList,
            150,
          ),
          const SizedBox(height: 12),
          Badge(
            isLabelVisible: unread > 0,
            label: Text('$unread'),
            backgroundColor: AppColors.accent,
            child: FloatingActionButton(
              heroTag: 'fab_main',
              tooltip: l10n.menuMessages,
              shape: const CircleBorder(),
              onPressed: enabled ? onToggle : null,
              child: AnimatedRotation(
                turns: open ? 0.125 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(open ? Icons.add : Icons.chat_bubble_outline),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Aviso fijo mientras no se pueda hablar con el servidor.
class _ConnectionBanner extends StatelessWidget {
  final VoidCallback onRetry;

  const _ConnectionBanner({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      color: AppColors.error.withValues(alpha: 0.08),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_outlined, size: 16, color: AppColors.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.homeConnectionError,
              style: const TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }
}
