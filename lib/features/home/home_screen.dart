import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/session/session_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/card_button.dart';
import '../../core/widgets/menu_leading.dart';
import '../../l10n/app_localizations.dart';
import '../shell/app_section.dart';
import 'home_view_model.dart';
import 'live_clock.dart';

/// Inicio: reloj, saludo, botón de fichaje y accesos a las secciones.
class HomeScreen extends StatefulWidget {
  final HomeViewModel viewModel;
  final SessionUser user;
  final ValueChanged<AppSection> onSectionSelected;
  final VoidCallback onOpenDrawer;

  const HomeScreen({
    super.key,
    required this.viewModel,
    required this.user,
    required this.onSectionSelected,
    required this.onOpenDrawer,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          final vm = widget.viewModel;
          final blocked = vm.hasConnectionError;
          final shortcuts = AppSection.values.where(
            (s) => s != AppSection.home &&
                s != AppSection.messages &&
                s.isVisibleFor(widget.user.role),
          );

          return Column(
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
                          const SizedBox(height: 24),
                          CardButton(
                            icon: vm.isWorking
                                ? Icons.stop_circle_outlined
                                : Icons.play_circle_outline,
                            title: vm.isWorking
                                ? l10n.clockEndShift
                                : l10n.clockStartShift,
                            color:
                                vm.isWorking ? AppColors.error : context.brand,
                            isLoading: vm.isClocking,
                            enabled: !blocked && !vm.isLoadingStatus,
                            onTap: _onClockTap,
                          ),
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
          );
        },
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
