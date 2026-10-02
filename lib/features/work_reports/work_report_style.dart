import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/work_reports.dart';
import '../../l10n/app_localizations.dart';

extension WorkReportStatusStyle on WorkReportStatus {
  String label(AppLocalizations l10n) => switch (this) {
        WorkReportStatus.assigned => l10n.workReportsStatusAssigned,
        WorkReportStatus.inProgress => l10n.workReportsStatusInProgress,
        WorkReportStatus.partiallyFinished => l10n.workReportsStatusPartiallyFinished,
        WorkReportStatus.finished => l10n.workReportsStatusFinished,
        WorkReportStatus.notified => l10n.workReportsStatusNotified,
        WorkReportStatus.deliveryNote => l10n.workReportsStatusDeliveryNote,
        WorkReportStatus.invoiced => l10n.workReportsStatusInvoiced,
        WorkReportStatus.rejected => l10n.workReportsStatusRejected,
      };

  Color color(BuildContext context) => switch (this) {
        WorkReportStatus.assigned => context.brand,
        WorkReportStatus.inProgress => AppColors.pending,
        WorkReportStatus.partiallyFinished => const Color(0xFFEA580C),
        WorkReportStatus.finished => AppColors.success,
        WorkReportStatus.notified => AppColors.accent,
        WorkReportStatus.deliveryNote => AppColors.violet,
        WorkReportStatus.invoiced => const Color(0xFF0891B2),
        WorkReportStatus.rejected => AppColors.error,
      };
}
