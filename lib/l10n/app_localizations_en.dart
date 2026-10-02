// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'ERP Flutter';

  @override
  String get splashTagline => 'Mobile workforce management';

  @override
  String get dialogAccept => 'OK';

  @override
  String get dialogCancel => 'Cancel';

  @override
  String get retry => 'Retry';

  @override
  String comingSoon(String section) {
    return '$section will be available soon.';
  }

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginServerUrlLabel => 'Server URL';

  @override
  String get loginServerUrlHelper =>
      'Type “demo” to use the data bundled with the app';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginRememberUrl => 'Remember URL';

  @override
  String get loginRememberUser => 'Remember user';

  @override
  String get loginSubmit => 'Sign in';

  @override
  String get loginDemoAccounts => 'Demo accounts';

  @override
  String loginDemoAccountsHint(String password) {
    return 'Tap an account to fill in the form. Password: $password';
  }

  @override
  String get loginErrorEmptyServerUrl => 'Please enter the server URL.';

  @override
  String get loginErrorEmptyEmail => 'Please enter your email.';

  @override
  String get loginErrorEmptyPassword => 'Please enter your password.';

  @override
  String get loginErrorInvalidCredentials => 'Incorrect credentials.';

  @override
  String get loginErrorAccessDenied => 'Your user has no access to the app.';

  @override
  String get loginErrorInvalidUrl => 'The server URL is not valid.';

  @override
  String get loginErrorServerNotFound => 'No ERP server was found at that URL.';

  @override
  String get loginErrorNetwork => 'Could not connect to the server.';

  @override
  String get loginErrorTimeout => 'The server took too long to respond.';

  @override
  String get loginErrorServer => 'The server returned an error.';

  @override
  String get loginErrorUnknown => 'An unexpected error occurred.';

  @override
  String get roleSuperAdmin => 'Super administrator';

  @override
  String get roleAdmin => 'Administrator';

  @override
  String get roleUser => 'User';

  @override
  String get roleWorker => 'Worker';

  @override
  String get roleCustomer => 'Customer';

  @override
  String get roleSupplier => 'Supplier';

  @override
  String get roleUnknown => 'No role';

  @override
  String get homeTitle => 'Home';

  @override
  String homeWelcome(String company) {
    return 'Welcome to $company,';
  }

  @override
  String get homeConnectionError => 'Could not connect to the server';

  @override
  String get homeConnectionLost => 'Connection to the server was lost';

  @override
  String get clockStartShift => 'Start / Resume shift';

  @override
  String get clockEndShift => 'End shift / Take a break';

  @override
  String get clockConfirmStartTitle => 'Start shift?';

  @override
  String get clockConfirmStartMessage =>
      'Do you want to start your shift / end your break?';

  @override
  String get clockConfirmEndTitle => 'End shift?';

  @override
  String get clockConfirmEndMessage =>
      'Do you want to end your shift / start a break?';

  @override
  String get clockSyncedStarted =>
      'Your shift had already been started from another device. Status updated.';

  @override
  String get clockSyncedEnded =>
      'Your shift had already been ended from another device. Status updated.';

  @override
  String get clockError =>
      'Could not register the clock entry. Please try again.';

  @override
  String clockInDone(String time) {
    return 'Clock-in registered at $time';
  }

  @override
  String clockOutDone(String time) {
    return 'Clock-out registered at $time';
  }

  @override
  String get menuAttendanceRecords => 'Clock records';

  @override
  String get menuIncidents => 'Incidents';

  @override
  String get menuWorkReports => 'Work reports';

  @override
  String get menuClients => 'Clients';

  @override
  String get menuVisitReports => 'Visit reports';

  @override
  String get menuHolidays => 'Holidays';

  @override
  String get menuMessages => 'Messages';

  @override
  String get menuLogout => 'Sign out';

  @override
  String get settingsDarkMode => 'Dark mode';

  @override
  String get settingsLightMode => 'Light mode';

  @override
  String drawerVersion(String version) {
    return 'Version $version';
  }

  @override
  String get clockTypeIn => 'In';

  @override
  String get clockTypeOut => 'Out';

  @override
  String get recordsTitle => 'Clock records';

  @override
  String get recordsEmpty => 'No clock records in this period.';

  @override
  String get recordsLoadError => 'Could not load clock records.';

  @override
  String get recordsLocation => 'Location (approx.)';

  @override
  String get groupByEmployee => 'Group by employee';

  @override
  String get filterByDates => 'Filter by dates';

  @override
  String get dateFrom => 'From';

  @override
  String get dateTo => 'To';

  @override
  String get applyFilter => 'Apply';

  @override
  String get clearFilter => 'Clear filter';

  @override
  String get incidentReport => 'Incident';

  @override
  String get incidentDialogTitle => 'Report incident';

  @override
  String get incidentReason => 'Reason';

  @override
  String get incidentReasonHint =>
      'Describe the reason for the incident (min. 5 characters)';

  @override
  String get incidentReasonTooShort =>
      'The reason must be at least 5 characters long.';

  @override
  String get incidentRequestDate => 'Request a date change (optional)';

  @override
  String get incidentPickDate => 'Select date and time';

  @override
  String get incidentClearDate => 'Remove date';

  @override
  String get incidentRequestedType => 'Requested type';

  @override
  String get incidentSubmit => 'Send';

  @override
  String get incidentSendError =>
      'Could not send the incident. Please try again.';

  @override
  String get incidentSent => 'Incident sent successfully.';

  @override
  String get incidentPending => 'Pending';

  @override
  String get incidentApproved => 'Approved';

  @override
  String get incidentRejected => 'Rejected';

  @override
  String get incidentsTitle => 'Incidents';

  @override
  String get incidentsEmpty => 'No incidents in this period.';

  @override
  String get incidentsLoadError => 'Could not load incidents.';

  @override
  String get incidentDetailTitle => 'Incident details';

  @override
  String get incidentAffectedRecord => 'Affected clock record';

  @override
  String get incidentRequestedChanges => 'Requested changes';

  @override
  String get incidentNoChanges => 'No changes requested.';

  @override
  String get incidentCreatedAt => 'Created on';

  @override
  String get incidentWorker => 'Worker';

  @override
  String get holidaysEmpty => 'No holidays in this period.';

  @override
  String get holidaysLoadError => 'Could not load holidays.';

  @override
  String get holidayPending => 'Pending';

  @override
  String get holidayApproved => 'Approved';

  @override
  String get holidayRejected => 'Rejected';

  @override
  String get holidaysCalendarView => 'Calendar view';

  @override
  String get holidaysListView => 'List view';

  @override
  String get groupByPerson => 'Group by person';

  @override
  String get holidaysRequestTitle => 'Request holidays';

  @override
  String get holidaysStart => 'Start date';

  @override
  String get holidaysEnd => 'End date';

  @override
  String get holidaysPickDate => 'Select date';

  @override
  String get holidaysReason => 'Reason (optional)';

  @override
  String get holidaysReasonHint => 'Reason for the request...';

  @override
  String get holidaysSubmit => 'Request';

  @override
  String get holidaysDatesError =>
      'Select both dates; the end date cannot be before the start date.';

  @override
  String get holidaysRequestSent => 'Request sent successfully.';

  @override
  String get holidaysRequestError =>
      'Could not send the request. Please try again.';

  @override
  String holidaysWorkingDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count working days',
      one: '1 working day',
    );
    return '$_temp0';
  }

  @override
  String holidaysNaturalDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count calendar days',
      one: '1 calendar day',
    );
    return '$_temp0';
  }

  @override
  String get holidayDayVacation => 'Holiday';

  @override
  String get holidayDayNational => 'Public holiday';

  @override
  String get holidayDayCompany => 'Company holiday';

  @override
  String get holidayDayRest => 'Weekly rest';

  @override
  String get holidaysApprove => 'Approve';

  @override
  String get holidaysReject => 'Reject';

  @override
  String get holidaysCancelRequest => 'Cancel request';

  @override
  String get holidaysCancelTitle => 'Cancel request';

  @override
  String get holidaysCancelMessage =>
      'Are you sure you want to cancel this holiday request?';

  @override
  String get holidaysCancelNo => 'No';

  @override
  String get holidaysCancelYes => 'Yes, cancel';

  @override
  String get holidaysApprovedMessage => 'Holidays approved.';

  @override
  String get holidaysRejectedMessage => 'Holidays rejected.';

  @override
  String get holidaysCancelledMessage => 'Request cancelled.';

  @override
  String get holidaysActionError =>
      'The action could not be completed. Please try again.';

  @override
  String holidaysSummary(String year, int used, int total) {
    return 'Holidays $year: $used/$total days';
  }

  @override
  String holidaysSummaryWorker(int count) {
    return 'Worker: $count days';
  }

  @override
  String holidaysSummaryCompany(int count) {
    return 'Company: $count days';
  }

  @override
  String get holidayByWorker => 'Requested by worker';

  @override
  String get holidayByCompany => 'Assigned by company';

  @override
  String holidaysOnDay(String date) {
    return 'Holidays on $date';
  }
}
