import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/branding/erp_logo.dart';
import '../../core/roles/role_labels.dart';
import '../../core/session/session_store.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import 'app_section.dart';

/// Menú lateral: secciones visibles para el rol, tema, cierre de sesión y
/// versión de la app.
class AppDrawer extends StatelessWidget {
  final SessionUser user;
  final AppSection current;
  final bool isDark;
  final bool offline;
  final int unreadMessages;
  final ValueChanged<AppSection> onSelect;
  final VoidCallback onToggleTheme;
  final VoidCallback onLogout;
  final VoidCallback onResetDemo;

  const AppDrawer({
    super.key,
    required this.user,
    required this.current,
    required this.isDark,
    required this.offline,
    required this.onSelect,
    required this.onToggleTheme,
    required this.onLogout,
    required this.onResetDemo,
    this.unreadMessages = 0,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sections = AppSection.values.where((s) => s.isVisibleFor(user.role));

    return Drawer(
      child: Column(
        children: [
          _Header(user: user),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                for (final section in sections)
                  _NavTile(
                    section: section,
                    selected: section == current,
                    enabled: section == AppSection.home || !offline,
                    badge: section == AppSection.messages && unreadMessages > 0
                        ? '$unreadMessages'
                        : null,
                    onTap: () {
                      Navigator.of(context).pop();
                      onSelect(section);
                    },
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          SafeArea(
            top: false,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  ),
                  title: Text(isDark ? l10n.settingsLightMode : l10n.settingsDarkMode),
                  onTap: onToggleTheme,
                ),
                ListTile(
                  leading: const Icon(Icons.restart_alt),
                  title: Text(l10n.menuResetDemo),
                  onTap: () {
                    Navigator.of(context).pop();
                    onResetDemo();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: Text(l10n.menuLogout),
                  onTap: () {
                    Navigator.of(context).pop();
                    onLogout();
                  },
                ),
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    final version = snapshot.data?.version;
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          version == null ? '' : l10n.drawerVersion(version),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final SessionUser user;

  const _Header({required this.user});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: AppColors.brandGradient),
      padding: EdgeInsets.fromLTRB(
        16,
        24 + MediaQuery.of(context).padding.top,
        16,
        16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: const ErpLogo(size: 56, withBackground: false, glyphScale: 0.72),
          ),
          const SizedBox(height: 12),
          Text(
            user.companyName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${user.name} · ${user.role.label(l10n)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final AppSection section;
  final bool selected;
  final bool enabled;
  final String? badge;
  final VoidCallback onTap;

  const _NavTile({
    required this.section,
    required this.selected,
    required this.enabled,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: ListTile(
          selected: selected,
          selectedTileColor: brand.withValues(alpha: 0.12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          leading: Badge(
            isLabelVisible: badge != null,
            label: badge == null ? null : Text(badge!),
            child: Icon(section.icon, color: selected ? brand : null),
          ),
          title: Text(
            section.label(AppLocalizations.of(context)),
            style: TextStyle(
              color: selected ? brand : Theme.of(context).colorScheme.onSurface,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          onTap: enabled ? onTap : null,
        ),
      ),
    );
  }
}
