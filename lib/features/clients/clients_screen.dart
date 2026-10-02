import 'package:flutter/material.dart';

import '../../core/state/period_list_view_model.dart' show LoadStatus;
import '../../core/widgets/list_parts.dart';
import '../../core/widgets/menu_leading.dart';
import '../../data/repositories/client_repository.dart';
import '../../domain/clients.dart';
import '../../l10n/app_localizations.dart';
import 'client_detail_screen.dart';
import 'clients_view_models.dart';

/// Listado de clientes con buscador fijo bajo el AppBar.
///
/// Por defecto abre la ficha del cliente. Con [onClientTap] funciona como
/// selector (p. ej. para elegir la empresa en partes de visita).
class ClientsScreen extends StatefulWidget {
  final ClientsViewModel viewModel;
  final ClientRepository repository;
  final VoidCallback onOpenDrawer;
  final VoidCallback onBack;

  /// Abre los partes de trabajo del cliente (botón "Trabajos" de la ficha).
  final void Function(ClientSummary client)? onOpenWorks;

  /// Sustituye la apertura de la ficha.
  final void Function(ClientSummary client)? onClientTap;

  /// Título y texto del buscador; por defecto, los de clientes.
  final String? title;
  final String? searchHint;

  const ClientsScreen({
    super.key,
    required this.viewModel,
    required this.repository,
    required this.onOpenDrawer,
    required this.onBack,
    this.onOpenWorks,
    this.onClientTap,
    this.title,
    this.searchHint,
  });

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final _search = TextEditingController();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _search.text = widget.viewModel.query;
    _scroll.addListener(() {
      final position = _scroll.position;
      if (position.pixels >= position.maxScrollExtent - 200) {
        widget.viewModel.loadMore();
      }
    });
  }

  @override
  void dispose() {
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _open(ClientSummary client) {
    if (widget.onClientTap != null) {
      widget.onClientTap!(client);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ClientDetailScreen(
          client: client,
          repository: widget.repository,
          onOpenDrawer: widget.onOpenDrawer,
          onOpenWorks: widget.onOpenWorks == null ? null : () => widget.onOpenWorks!(client),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = widget.viewModel;

    return Scaffold(
      appBar: AppBar(
        leadingWidth: MenuLeading.fullWidth,
        leading: MenuLeading(onOpenDrawer: widget.onOpenDrawer, onBack: widget.onBack),
        title: Text(widget.title ?? l10n.menuClients),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: ListenableBuilder(
              listenable: _search,
              builder: (context, _) => TextField(
                controller: _search,
                onChanged: vm.updateSearch,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: widget.searchHint ?? l10n.clientsSearchHint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _search.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _search.clear();
                            vm.clearSearch();
                          },
                        ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: vm,
              builder: (context, _) => switch (vm.status) {
                LoadStatus.initial || LoadStatus.loading =>
                  const Center(child: CircularProgressIndicator()),
                LoadStatus.error =>
                  LoadErrorView(message: l10n.clientsErrorLoad, onRetry: vm.load),
                LoadStatus.loaded when vm.items.isEmpty =>
                  EmptyView(message: l10n.clientsEmpty, icon: Icons.people_outline),
                LoadStatus.loaded => RefreshIndicator(
                    onRefresh: vm.load,
                    child: ListView.separated(
                      controller: _scroll,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: vm.items.length + (vm.isLoadingMore ? 1 : 0),
                      separatorBuilder: (_, _) =>
                          const Divider(height: 1, indent: 16, endIndent: 16),
                      itemBuilder: (context, index) {
                        if (index == vm.items.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final client = vm.items[index];
                        return _ClientTile(client: client, onTap: () => _open(client));
                      },
                    ),
                  ),
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ClientTile extends StatelessWidget {
  final ClientSummary client;
  final VoidCallback onTap;

  const _ClientTile({required this.client, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final subtitle = [client.vat, client.city].whereType<String>().join(' · ');
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      title: Text(
        client.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: subtitle.isEmpty ? null : Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
