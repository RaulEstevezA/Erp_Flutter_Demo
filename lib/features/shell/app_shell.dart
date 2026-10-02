import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/di/app_services.dart';
import '../../core/roles/permissions.dart';
import '../../core/session/session_store.dart';
import '../../domain/clients.dart';
import '../../l10n/app_localizations.dart';
import '../attendance/records_screen.dart';
import '../attendance/records_view_model.dart';
import '../clients/clients_screen.dart';
import '../clients/clients_view_models.dart';
import '../visit_reports/visit_reports_screen.dart';
import '../work_reports/work_reports_screen.dart';
import '../work_reports/work_reports_view_model.dart';
import '../visit_reports/visit_reports_view_model.dart';
import '../holidays/holidays_screen.dart';
import '../holidays/holidays_view_model.dart';
import '../home/home_screen.dart';
import '../home/home_view_model.dart';
import '../incidents/incidents_screen.dart';
import '../incidents/incidents_view_model.dart';
import '../messaging/conversations_screen.dart';
import '../messaging/messaging_view_models.dart';
import 'app_drawer.dart';
import 'app_section.dart';

/// Contenedor de la app autenticada.
///
/// Un único Scaffold con el menú lateral; el cuerpo es la sección activa,
/// que pinta su propio AppBar. Los detalles se apilan con Navigator.push.
/// El botón atrás del sistema lleva al inicio y, desde el inicio, sale.
class AppShell extends StatefulWidget {
  final AppServices services;
  final SessionUser user;
  final VoidCallback onLogout;

  const AppShell({
    super.key,
    required this.services,
    required this.user,
    required this.onLogout,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  AppSection _section = AppSection.home;

  late final HomeViewModel _home = HomeViewModel(widget.services.attendance);
  late final RecordsViewModel _records = RecordsViewModel(
    widget.services.attendance,
    canViewAll: widget.user.role.can(AppPermission.viewAllAttendance),
  );
  late final IncidentsViewModel _incidents = IncidentsViewModel(
    widget.services.attendance,
    canViewAll: widget.user.role.can(AppPermission.viewAllAttendance),
  );
  late final MessagingViewModel _messaging =
      MessagingViewModel(widget.services.messaging);
  late final ConversationsViewModel _conversations =
      ConversationsViewModel(widget.services.messaging);
  late final ClientsViewModel _clients = ClientsViewModel(widget.services.clients);
  late final WorkReportsViewModel _workReports = WorkReportsViewModel(widget.services.workReports);
  /// Selector de empresa de la sección de partes de visita.
  late final ClientsViewModel _visitClients = ClientsViewModel(widget.services.clients);
  late final HolidaysViewModel _holidays = HolidaysViewModel(
    widget.services.holidays,
    userId: widget.user.id,
    role: widget.user.role,
  );

  @override
  void initState() {
    super.initState();
    _home.loadStatus();
    _messaging.start();
  }

  @override
  void dispose() {
    _home.dispose();
    _records.dispose();
    _incidents.dispose();
    _holidays.dispose();
    _clients.dispose();
    _visitClients.dispose();
    _workReports.dispose();
    _messaging.dispose();
    _conversations.dispose();
    super.dispose();
  }

  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();

  void _goHome() => _select(AppSection.home);

  /// Cambia de sección reiniciando su estado (mes actual, sin filtros).
  void _select(AppSection section) {
    if (!section.isImplemented) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(l10n.comingSoon(section.label(l10n)))),
        );
      return;
    }
    // Sin conexión solo se permite el inicio.
    if (section != AppSection.home && _home.hasConnectionError) return;

    switch (section) {
      case AppSection.home:
        _home.loadStatus();
        _messaging.refreshUnread();
      case AppSection.attendanceRecords:
        _records.init();
      case AppSection.incidents:
        _incidents.init();
      case AppSection.holidays:
        _holidays.init();
      case AppSection.clients:
        _clients.init();
      case AppSection.visitReports:
        _visitClients.init();
      case AppSection.workReports:
        _workReports.init();
      default:
        break;
    }
    setState(() => _section = section);
  }

  Future<void> _resetDemo() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetDemoTitle),
        content: Text(l10n.resetDemoMessage),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.dialogCancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.resetDemoConfirm)),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await widget.services.resetDemoData();
    if (!mounted) return;
    _select(AppSection.home);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.resetDemoDone)));
  }

  /// Desde el botón flotante del inicio el listado se apila sobre el shell.
  Future<void> _pushConversations() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ConversationsScreen(
          viewModel: _conversations,
          messaging: _messaging,
          repository: widget.services.messaging,
          onOpenDrawer: _openDrawer,
        ),
      ),
    );
    _messaging.refreshUnread();
  }

  /// Botón "Trabajos" de la ficha: partes de ese cliente.
  void _pushClientWorkReports(ClientSummary client) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WorkReportsScreen(
          viewModel: WorkReportsViewModel(widget.services.workReports, clientId: client.id),
          repository: widget.services.workReports,
          title: client.name,
          ownsViewModel: true,
          onOpenDrawer: _openDrawer,
        ),
      ),
    );
  }

  void _pushVisits(ClientSummary client) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VisitReportsScreen(
          client: client,
          viewModel: VisitReportsViewModel(widget.services.visits, clientId: client.id),
          repository: widget.services.visits,
          canCreate: widget.user.role.can(AppPermission.createVisitReports),
          onOpenDrawer: _openDrawer,
        ),
      ),
    );
  }

  Widget _body() {
    return switch (_section) {
      AppSection.attendanceRecords => RecordsScreen(
          viewModel: _records,
          onOpenDrawer: _openDrawer,
          onBack: _goHome,
          onIncidentCreated: () => _select(AppSection.incidents),
        ),
      AppSection.incidents => IncidentsScreen(
          viewModel: _incidents,
          onOpenDrawer: _openDrawer,
          onBack: _goHome,
        ),
      AppSection.messages => ConversationsScreen(
          viewModel: _conversations,
          messaging: _messaging,
          repository: widget.services.messaging,
          onOpenDrawer: _openDrawer,
          onBack: _goHome,
        ),
      AppSection.workReports => WorkReportsScreen(
          viewModel: _workReports,
          repository: widget.services.workReports,
          onOpenDrawer: _openDrawer,
          onBack: _goHome,
        ),
      AppSection.clients => ClientsScreen(
          viewModel: _clients,
          repository: widget.services.clients,
          onOpenWorks: _pushClientWorkReports,
          onOpenDrawer: _openDrawer,
          onBack: _goHome,
        ),
      AppSection.visitReports => ClientsScreen(
          viewModel: _visitClients,
          repository: widget.services.clients,
          title: AppLocalizations.of(context).menuVisitReports,
          searchHint: AppLocalizations.of(context).visitReportsSearchHint,
          onClientTap: _pushVisits,
          onOpenDrawer: _openDrawer,
          onBack: _goHome,
        ),
      AppSection.holidays => HolidaysScreen(
          viewModel: _holidays,
          onOpenDrawer: _openDrawer,
          onBack: _goHome,
        ),
      _ => HomeScreen(
          viewModel: _home,
          user: widget.user,
          onSectionSelected: _select,
          onOpenDrawer: _openDrawer,
          messaging: _messaging,
          onOpenConversations: _pushConversations,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final settings = widget.services.settings;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_section != AppSection.home) {
          _goHome();
        } else {
          SystemNavigator.pop();
        }
      },
      child: ListenableBuilder(
        listenable: Listenable.merge([_home, settings, _messaging]),
        builder: (context, _) {
          return Scaffold(
            key: _scaffoldKey,
            drawerEdgeDragWidth: 40,
            drawer: AppDrawer(
              user: widget.user,
              current: _section,
              isDark: settings.isDark,
              offline: _home.hasConnectionError,
              onSelect: _select,
              onToggleTheme: settings.toggleTheme,
              onLogout: widget.onLogout,
              onResetDemo: _resetDemo,
              unreadMessages: _messaging.unreadCount,
            ),
            body: Stack(
              children: [
                // La sección cambia con un fundido suave.
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: KeyedSubtree(key: ValueKey(_section), child: _body()),
                ),
                // Los Scaffold de cada sección se quedan los gestos
                // horizontales; esta franja del borde izquierdo los recoge
                // para abrir el menú arrastrando.
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 20,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onHorizontalDragEnd: (details) {
                      if ((details.primaryVelocity ?? 0) > 300) _openDrawer();
                    },
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
