import 'package:flutter/material.dart';

import '../../core/roles/app_role.dart';
import '../../core/roles/permissions.dart';
import '../../l10n/app_localizations.dart';

/// Secciones de primer nivel. El inicio y el menú lateral se construyen a
/// partir de esta lista, filtrada por los permisos del rol.
enum AppSection {
  home(Icons.home_outlined, null),
  attendanceRecords(Icons.history_outlined, null),
  incidents(Icons.flag_outlined, null),
  workReports(Icons.assignment_outlined, AppPermission.viewWorkReports),
  clients(Icons.people_outline, AppPermission.viewClients),
  visitReports(Icons.badge_outlined, AppPermission.viewVisitReports),
  holidays(Icons.beach_access_outlined, AppPermission.viewHolidays),
  messages(Icons.chat_bubble_outline, AppPermission.viewMessages);

  final IconData icon;

  /// Permiso necesario para ver la sección (`null` = todos los roles).
  final AppPermission? permission;

  const AppSection(this.icon, this.permission);

  /// Secciones ya construidas en la demo. El resto muestra "próximamente".
  static const implemented = {home, attendanceRecords, incidents, holidays};

  bool get isImplemented => implemented.contains(this);

  bool isVisibleFor(AppRole role) => permission == null || role.can(permission!);

  String label(AppLocalizations l10n) => switch (this) {
        home => l10n.homeTitle,
        attendanceRecords => l10n.menuAttendanceRecords,
        incidents => l10n.menuIncidents,
        workReports => l10n.menuWorkReports,
        clients => l10n.menuClients,
        visitReports => l10n.menuVisitReports,
        holidays => l10n.menuHolidays,
        messages => l10n.menuMessages,
      };
}
