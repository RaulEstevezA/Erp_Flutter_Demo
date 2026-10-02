import 'package:flutter/material.dart';

import '../../core/state/period_list_view_model.dart' show LoadStatus;
import '../../core/theme/app_colors.dart';
import '../../core/widgets/list_parts.dart';
import '../../core/widgets/menu_leading.dart';
import '../../core/widgets/period_bars.dart';
import '../../data/repositories/client_repository.dart';
import '../../domain/clients.dart';
import '../../l10n/app_localizations.dart';
import 'client_document_detail_screen.dart';
import 'client_parts.dart';
import 'clients_view_models.dart';

/// Documentos de un tipo (presupuestos, pedidos...) de un cliente, con
/// buscador desplegable y filtro por fechas.
class ClientDocumentsScreen extends StatefulWidget {
  final String title;
  final ClientDocumentsViewModel viewModel;
  final ClientRepository repository;
  final VoidCallback onOpenDrawer;

  const ClientDocumentsScreen({
    super.key,
    required this.title,
    required this.viewModel,
    required this.repository,
    required this.onOpenDrawer,
  });

  @override
  State<ClientDocumentsScreen> createState() => _ClientDocumentsScreenState();
}

class _ClientDocumentsScreenState extends State<ClientDocumentsScreen> {
  final _search = TextEditingController();
  final _scroll = ScrollController();
  bool _searchVisible = false;

  ClientDocumentsViewModel get _vm => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      final position = _scroll.position;
      if (position.pixels >= position.maxScrollExtent - 200) _vm.loadMore();
    });
    _vm.load();
  }

  @override
  void dispose() {
    _search.dispose();
    _scroll.dispose();
    // El ViewModel es exclusivo de esta pantalla.
    _vm.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    if (_searchVisible) {
      _search.clear();
      _vm.clearSearch();
    }
    setState(() => _searchVisible = !_searchVisible);
  }

  void _open(ClientDocument doc) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ClientDocumentDetailScreen(
          title: doc.title,
          load: () => widget.repository.getDocument(_vm.clientId, _vm.type, doc.id),
          onOpenDrawer: widget.onOpenDrawer,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) {
        final brand = context.brand;
        return Scaffold(
          appBar: AppBar(
            leadingWidth: MenuLeading.fullWidth,
            leading: MenuLeading(onOpenDrawer: widget.onOpenDrawer),
            title: Text(widget.title),
            actions: [
              IconButton(
                tooltip: l10n.clientsDocumentsSearchHint,
                icon: Icon(
                  Icons.search,
                  color: _searchVisible || _vm.query.isNotEmpty ? brand : null,
                ),
                onPressed: _toggleSearch,
              ),
              IconButton(
                tooltip: _vm.hasDateRange ? l10n.clearFilter : l10n.filterByDates,
                icon: Icon(
                  Icons.date_range_outlined,
                  color: _vm.hasDateRange ? brand : null,
                ),
                onPressed: _vm.hasDateRange
                    ? _vm.clearDateRange
                    : () => DateRangeSheet.show(context, onApply: _vm.setDateRange),
              ),
            ],
          ),
          body: Column(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: _searchVisible
                    ? Padding(
                        key: const ValueKey('search'),
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                        child: TextField(
                          controller: _search,
                          autofocus: true,
                          textInputAction: TextInputAction.search,
                          onChanged: _vm.updateSearch,
                          decoration: InputDecoration(
                            hintText: l10n.clientsDocumentsSearchHint,
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: _toggleSearch,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(key: ValueKey('no-search')),
              ),
              if (_vm.hasDateRange)
                ActiveFilterBar(
                  since: _vm.since!,
                  until: _vm.until!,
                  onClear: _vm.clearDateRange,
                ),
              Expanded(child: _content(l10n)),
            ],
          ),
        );
      },
    );
  }

  Widget _content(AppLocalizations l10n) {
    return switch (_vm.status) {
      LoadStatus.initial || LoadStatus.loading =>
        const Center(child: CircularProgressIndicator()),
      LoadStatus.error =>
        LoadErrorView(message: l10n.clientsDocumentsErrorLoad, onRetry: _vm.load),
      LoadStatus.loaded when _vm.items.isEmpty =>
        EmptyView(message: l10n.clientsDocumentsEmpty, icon: Icons.description_outlined),
      LoadStatus.loaded => RefreshIndicator(
          onRefresh: _vm.load,
          child: ListView.separated(
            controller: _scroll,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: _vm.items.length + (_vm.isLoadingMore ? 1 : 0),
            separatorBuilder: (_, _) => const Divider(height: 1, indent: 16, endIndent: 16),
            itemBuilder: (context, index) {
              if (index == _vm.items.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final doc = _vm.items[index];
              return _DocumentTile(doc: doc, onTap: () => _open(doc));
            },
          ),
        ),
    };
  }
}

class _DocumentTile extends StatelessWidget {
  final ClientDocument doc;
  final VoidCallback onTap;

  const _DocumentTile({required this.doc, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final details = [
      if (doc.date != null) formatDocDate(doc.date!),
      formatMoney(context, doc.total),
    ];

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Row(
        children: [
          Expanded(
            child: Text(
              doc.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (doc.statusLabel != null) ...[
            const SizedBox(width: 8),
            DocumentStatusBadge(doc.statusLabel!, doc.statusTone),
          ],
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (doc.number != null && doc.name != null) ...[
            const SizedBox(height: 2),
            Text(doc.name!, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
          ],
          const SizedBox(height: 4),
          Text(details.join('  ·  '), style: TextStyle(color: muted, fontSize: 12)),
        ],
      ),
    );
  }
}
