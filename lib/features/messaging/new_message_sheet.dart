import 'package:flutter/material.dart';

import '../../core/roles/role_labels.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/app_user.dart';
import '../../l10n/app_localizations.dart';
import 'messaging_view_models.dart';

/// Hoja para escribir un mensaje nuevo: buscador de destinatario con lista
/// filtrable, cuerpo y enviar. Devuelve `true` si se envió.
class NewMessageSheet extends StatefulWidget {
  final MessagingViewModel viewModel;

  const NewMessageSheet({super.key, required this.viewModel});

  static Future<bool> show(BuildContext context, MessagingViewModel viewModel) async {
    final sent = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => NewMessageSheet(viewModel: viewModel),
    );
    return sent ?? false;
  }

  @override
  State<NewMessageSheet> createState() => _NewMessageSheetState();
}

class _NewMessageSheetState extends State<NewMessageSheet> {
  final _search = TextEditingController();
  final _body = TextEditingController();
  AppUser? _selected;
  bool _recipientError = false;
  bool _bodyError = false;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _search.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.viewModel.loadRecipients());
  }

  @override
  void dispose() {
    _search.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final body = _body.text.trim();
    setState(() {
      _recipientError = _selected == null;
      _bodyError = body.isEmpty;
    });
    if (_recipientError || _bodyError) return;

    setState(() => _sending = true);
    final ok = await widget.viewModel.send(receiverId: _selected!.id, body: body);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _sending = false);
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
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);
    final brand = context.brand;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + media.viewInsets.bottom + media.padding.bottom),
      child: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          final vm = widget.viewModel;
          final query = _search.text.trim().toLowerCase();
          final filtered = vm.recipients
              .where((u) => '${u.name} ${u.email}'.toLowerCase().contains(query))
              .toList();

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.edit_outlined, color: brand),
                  const SizedBox(width: 8),
                  Text(l10n.messagesNew, style: theme.textTheme.titleMedium),
                ],
              ),
              const SizedBox(height: 20),
              if (vm.isLoadingRecipients)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                )
              else ...[
                TextField(
                  controller: _search,
                  enabled: !_sending,
                  autocorrect: false,
                  decoration: InputDecoration(
                    hintText: l10n.messagesRecipientSearch,
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    suffixIcon: _search.text.isEmpty
                        ? null
                        : IconButton(icon: const Icon(Icons.clear), onPressed: _search.clear),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    border: Border.all(color: theme.colorScheme.outline),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: filtered.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              l10n.messagesNoRecipients,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: filtered.length,
                            separatorBuilder: (_, _) =>
                                const Divider(height: 1, indent: 12, endIndent: 12),
                            itemBuilder: (context, index) {
                              final user = filtered[index];
                              final selected = _selected?.id == user.id;
                              return ListTile(
                                dense: true,
                                enabled: !_sending,
                                title: Text(
                                  user.name,
                                  style: TextStyle(
                                    color: selected ? brand : null,
                                    fontWeight: selected ? FontWeight.w600 : null,
                                  ),
                                ),
                                subtitle: Text('${user.role.label(l10n)} · ${user.email}'),
                                trailing: selected
                                    ? Icon(Icons.check_circle, color: brand, size: 20)
                                    : null,
                                onTap: () => setState(() {
                                  _selected = user;
                                  _recipientError = false;
                                }),
                              );
                            },
                          ),
                  ),
                ),
                if (_recipientError)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 12),
                    child: Text(
                      l10n.messagesRecipientRequired,
                      style: theme.textTheme.bodySmall?.copyWith(color: AppColors.error),
                    ),
                  ),
              ],
              const SizedBox(height: 16),
              TextField(
                controller: _body,
                enabled: !_sending,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (_) {
                  if (_bodyError) setState(() => _bodyError = false);
                },
                decoration: InputDecoration(
                  labelText: l10n.messagesBody,
                  hintText: l10n.messagesBodyHint,
                  alignLabelWithHint: true,
                  errorText: _bodyError ? l10n.messagesBodyRequired : null,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _sending ? null : () => Navigator.of(context).pop(false),
                    child: Text(l10n.dialogCancel),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _sending ? null : _send,
                    icon: _sending
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.send_outlined),
                    label: Text(l10n.messagesSend),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
