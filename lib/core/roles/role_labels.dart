import '../../l10n/app_localizations.dart';
import 'app_role.dart';

extension AppRoleLabel on AppRole {
  String label(AppLocalizations l10n) => switch (this) {
        AppRole.superAdmin => l10n.roleSuperAdmin,
        AppRole.admin => l10n.roleAdmin,
        AppRole.user => l10n.roleUser,
        AppRole.worker => l10n.roleWorker,
        AppRole.customer => l10n.roleCustomer,
        AppRole.supplier => l10n.roleSupplier,
        AppRole.unknown => l10n.roleUnknown,
      };
}
