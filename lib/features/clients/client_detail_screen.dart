import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/list_parts.dart';
import '../../core/widgets/menu_leading.dart';
import '../../data/repositories/client_repository.dart';
import '../../domain/clients.dart';
import '../../l10n/app_localizations.dart';
import 'client_documents_screen.dart';
import 'client_parts.dart';
import 'clients_view_models.dart';

/// Ficha del cliente: cabecera fija con el CIF y los accesos a sus
/// documentos, y debajo observaciones, direcciones, contactos y pago.
class ClientDetailScreen extends StatefulWidget {
  final ClientSummary client;
  final ClientRepository repository;
  final VoidCallback onOpenDrawer;

  /// Botón "Trabajos". Sin él se avisa de que llegará próximamente.
  final VoidCallback? onOpenWorks;

  const ClientDetailScreen({
    super.key,
    required this.client,
    required this.repository,
    required this.onOpenDrawer,
    this.onOpenWorks,
  });

  @override
  State<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen> {
  late Future<ClientDetail> _detail;

  @override
  void initState() {
    super.initState();
    _detail = widget.repository.getClient(widget.client.id);
  }

  void _load() {
    final detail = widget.repository.getClient(widget.client.id);
    setState(() {
      _detail = detail;
    });
  }

  void _openDocuments(ClientDocumentType type, String title) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ClientDocumentsScreen(
          title: title,
          viewModel: ClientDocumentsViewModel(
            widget.repository,
            clientId: widget.client.id,
            type: type,
          ),
          repository: widget.repository,
          onOpenDrawer: widget.onOpenDrawer,
        ),
      ),
    );
  }

  void _openWorks() {
    if (widget.onOpenWorks != null) {
      widget.onOpenWorks!();
      return;
    }
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.comingSoon(l10n.menuWorkReports))));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        leadingWidth: MenuLeading.fullWidth,
        leading: MenuLeading(onOpenDrawer: widget.onOpenDrawer),
        title: Text(widget.client.name, overflow: TextOverflow.ellipsis),
      ),
      body: Column(
        children: [
          _Header(
            vat: widget.client.vat,
            buttons: [
              _DocButton(l10n.clientsButtonWorks, Icons.build_outlined, _openWorks),
              for (final (type, label, icon) in [
                (ClientDocumentType.budgets, l10n.clientsButtonBudgets, Icons.description_outlined),
                (ClientDocumentType.orders, l10n.clientsButtonOrders, Icons.shopping_cart_outlined),
                (ClientDocumentType.deliveryNotes, l10n.clientsButtonDeliveryNotes,
                    Icons.local_shipping_outlined),
                (ClientDocumentType.invoices, l10n.clientsButtonInvoices, Icons.receipt_outlined),
                (ClientDocumentType.recurrentInvoices, l10n.clientsButtonRecurrentInvoices,
                    Icons.repeat_outlined),
              ])
                _DocButton(label, icon, () => _openDocuments(type, label)),
            ],
          ),
          Expanded(
            child: FutureBuilder<ClientDetail>(
              future: _detail,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return LoadErrorView(message: l10n.clientsErrorLoad, onRetry: _load);
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return _Body(detail: snapshot.data!);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String? vat;
  final List<_DocButton> buttons;

  const _Header({required this.vat, required this.buttons});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget row(Iterable<_DocButton> items) => Row(
          children: [
            for (final (i, button) in items.indexed) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(child: button),
            ],
          ],
        );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (vat != null) ...[
            Text(
              vat!,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
          ],
          row(buttons.take(3)),
          const SizedBox(height: 8),
          row(buttons.skip(3)),
        ],
      ),
    );
  }
}

class _DocButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _DocButton(this.label, this.icon, this.onPressed);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(fontSize: 10),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final ClientDetail detail;

  const _Body({required this.detail});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final remarks = detail.remarks;
    final payment = [
      (l10n.clientsLabelResponsible, detail.responsible),
      (l10n.clientsLabelPaymentMethod, detail.paymentMethod),
      (l10n.clientsLabelPaymentCondition, detail.paymentCondition),
    ].where((row) => row.$2 != null).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionLabel(l10n.clientsLabelRemarks),
        SectionCard(
          children: [
            if (remarks != null && remarks.isNotEmpty)
              Text(remarks)
            else
              MutedText(l10n.clientsNoRemarks),
          ],
        ),
        const SizedBox(height: 20),
        SectionLabel(l10n.clientsLabelAddresses),
        if (detail.addresses.isEmpty)
          SectionCard(children: [MutedText(l10n.clientsNoAddresses)])
        else
          ...detail.addresses.map((a) => _AddressCard(address: a)),
        const SizedBox(height: 20),
        SectionLabel(l10n.clientsLabelContacts),
        if (detail.contacts.isEmpty)
          SectionCard(children: [MutedText(l10n.clientsNoContacts)])
        else
          ...detail.contacts.map((c) => _ContactCard(contact: c)),
        const SizedBox(height: 20),
        SectionLabel(l10n.clientsLabelPaymentData),
        SectionCard(
          children: [
            if (payment.isEmpty) const MutedText('—'),
            for (final (label, value) in payment) _InfoRow(label: label, value: value!),
          ],
        ),
        const SizedBox(height: 24),
        _ActiveBadge(active: detail.active),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final ClientAddress address;

  const _AddressCard({required this.address});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final lines = [
      ?address.address,
      if (address.city != null || address.postcode != null)
        [address.postcode, address.city].whereType<String>().join(' '),
      ?address.phone,
      ?address.email,
    ];

    return SectionCard(
      margin: const EdgeInsets.only(bottom: 8),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                address.alias ?? '',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Wrap(
              spacing: 4,
              children: [
                if (address.billing)
                  StatusPill(label: l10n.clientsLabelBilling, color: AppColors.pending),
                if (address.delivering)
                  StatusPill(label: l10n.clientsLabelDelivering, color: AppColors.accent),
              ],
            ),
          ],
        ),
        if (lines.isNotEmpty) ...[
          const SizedBox(height: 6),
          for (final line in lines) Text(line, style: TextStyle(color: muted)),
        ],
      ],
    );
  }
}

class _ContactCard extends StatelessWidget {
  final ClientContact contact;

  const _ContactCard({required this.contact});

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return SectionCard(
      margin: const EdgeInsets.only(bottom: 8),
      children: [
        if (contact.name != null)
          Text(contact.name!, style: const TextStyle(fontWeight: FontWeight.w600)),
        if (contact.phone != null) ...[
          const SizedBox(height: 4),
          Text(contact.phone!, style: TextStyle(color: muted)),
        ],
        if (contact.email != null) ...[
          const SizedBox(height: 2),
          Text(contact.email!, style: TextStyle(color: muted)),
        ],
      ],
    );
  }
}

class _ActiveBadge extends StatelessWidget {
  final bool active;

  const _ActiveBadge({required this.active});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = active ? AppColors.success : AppColors.error;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(active ? Icons.check_circle_outline : Icons.cancel_outlined, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          active ? l10n.clientsLabelActive : l10n.clientsLabelInactive,
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
