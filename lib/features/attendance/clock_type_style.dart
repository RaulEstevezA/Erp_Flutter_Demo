import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/attendance.dart';
import '../../l10n/app_localizations.dart';

/// Color, icono y texto con los que se pinta cada tipo de fichaje.
extension ClockTypeStyle on ClockType {
  Color get color => this == ClockType.clockIn ? AppColors.success : AppColors.error;

  IconData get icon =>
      this == ClockType.clockIn ? Icons.login_rounded : Icons.logout_rounded;

  String label(AppLocalizations l10n) =>
      this == ClockType.clockIn ? l10n.clockTypeIn : l10n.clockTypeOut;
}

extension IncidentStatusStyle on IncidentStatus {
  Color get color => switch (this) {
        IncidentStatus.pending => AppColors.pending,
        IncidentStatus.approved => AppColors.success,
        IncidentStatus.rejected => AppColors.error,
      };

  IconData get icon => switch (this) {
        IncidentStatus.pending => Icons.hourglass_empty_rounded,
        IncidentStatus.approved => Icons.check_circle_outline_rounded,
        IncidentStatus.rejected => Icons.cancel_outlined,
      };

  String label(AppLocalizations l10n) => switch (this) {
        IncidentStatus.pending => l10n.incidentPending,
        IncidentStatus.approved => l10n.incidentApproved,
        IncidentStatus.rejected => l10n.incidentRejected,
      };
}
