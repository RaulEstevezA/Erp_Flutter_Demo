import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/holidays.dart';
import '../../l10n/app_localizations.dart';

extension HolidayStatusStyle on HolidayStatus {
  Color get color => switch (this) {
        HolidayStatus.approved => AppColors.success,
        HolidayStatus.pending => AppColors.pending,
        HolidayStatus.rejected => AppColors.error,
      };

  String label(AppLocalizations l10n) => switch (this) {
        HolidayStatus.approved => l10n.holidayApproved,
        HolidayStatus.pending => l10n.holidayPending,
        HolidayStatus.rejected => l10n.holidayRejected,
      };
}

extension HolidayCreatorStyle on HolidayCreator {
  IconData get icon =>
      this == HolidayCreator.company ? Icons.business_outlined : Icons.person_outline;

  String label(AppLocalizations l10n) =>
      this == HolidayCreator.company ? l10n.holidayByCompany : l10n.holidayByWorker;
}

extension HolidayDayKindStyle on HolidayDayKind {
  IconData get icon => switch (this) {
        HolidayDayKind.vacation => Icons.beach_access_outlined,
        HolidayDayKind.nationalHoliday => Icons.flag_outlined,
        HolidayDayKind.companyHoliday => Icons.business_outlined,
        HolidayDayKind.restDay => Icons.weekend_outlined,
      };

  Color color(BuildContext context) => switch (this) {
        HolidayDayKind.vacation => context.brand,
        HolidayDayKind.nationalHoliday => AppColors.error,
        HolidayDayKind.companyHoliday => AppColors.accent,
        HolidayDayKind.restDay => Theme.of(context).colorScheme.onSurfaceVariant,
      };

  String label(AppLocalizations l10n) => switch (this) {
        HolidayDayKind.vacation => l10n.holidayDayVacation,
        HolidayDayKind.nationalHoliday => l10n.holidayDayNational,
        HolidayDayKind.companyHoliday => l10n.holidayDayCompany,
        HolidayDayKind.restDay => l10n.holidayDayRest,
      };
}

/// "3 – 7 nov 2026", "28 dic 2026 – 2 ene 2027" o "5 nov 2026".
String formatHolidayRange(HolidayPeriod period, String locale) {
  final full = DateFormat('d MMM yyyy', locale);
  final short = DateFormat('d MMM', locale);
  final start = period.start;
  final end = period.end;
  if (start == end) return full.format(start);
  if (start.year != end.year) return '${full.format(start)} – ${full.format(end)}';
  return '${short.format(start)} – ${full.format(end)}';
}
