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

  @override
  String get messagesNew => 'New message';

  @override
  String get messagesList => 'Messages';

  @override
  String get messagesRecipientSearch => 'Search recipient...';

  @override
  String get messagesRecipientRequired => 'Select a recipient';

  @override
  String get messagesNoRecipients => 'No recipients available';

  @override
  String get messagesBody => 'Message';

  @override
  String get messagesBodyHint => 'Write your message...';

  @override
  String get messagesBodyRequired => 'The message cannot be empty';

  @override
  String get messagesSend => 'Send';

  @override
  String get messagesSent => 'Message sent';

  @override
  String get messagesSendError =>
      'Could not send the message. Please try again.';

  @override
  String get messagesEmpty => 'You have no conversations yet';

  @override
  String get messagesLoadError => 'Could not load messages';

  @override
  String get messagesTypeHint => 'Type a message...';

  @override
  String get messagesChatEmpty => 'No messages in this conversation yet';

  @override
  String get messagesYou => 'You: ';

  @override
  String get clientsSearchHint => 'Search name, VAT or town…';

  @override
  String get clientsEmpty => 'No clients found';

  @override
  String get clientsErrorLoad => 'Could not load clients';

  @override
  String get clientsLabelResponsible => 'Account manager';

  @override
  String get clientsLabelPaymentCondition => 'Payment terms';

  @override
  String get clientsLabelPaymentMethod => 'Payment method';

  @override
  String get clientsLabelRemarks => 'Remarks';

  @override
  String get clientsNoRemarks => 'No remarks';

  @override
  String get clientsLabelAddresses => 'Addresses';

  @override
  String get clientsNoAddresses => 'No addresses';

  @override
  String get clientsLabelContacts => 'Contacts';

  @override
  String get clientsNoContacts => 'No contacts';

  @override
  String get clientsLabelBilling => 'Billing';

  @override
  String get clientsLabelDelivering => 'Delivery';

  @override
  String get clientsButtonWorks => 'Works';

  @override
  String get clientsButtonBudgets => 'Budgets';

  @override
  String get clientsButtonOrders => 'Orders';

  @override
  String get clientsButtonDeliveryNotes => 'Delivery notes';

  @override
  String get clientsButtonInvoices => 'Invoices';

  @override
  String get clientsButtonRecurrentInvoices => 'Recur. invoices';

  @override
  String get clientsLabelPaymentData => 'Payment data';

  @override
  String get clientsLabelActive => 'Active client';

  @override
  String get clientsLabelInactive => 'Inactive client';

  @override
  String get clientsDocumentsEmpty => 'No documents';

  @override
  String get clientsDocumentsErrorLoad => 'Could not load documents';

  @override
  String get clientsDocumentsSearchHint => 'Search document...';

  @override
  String get clientsDocDetailErrorLoad => 'Could not load the document';

  @override
  String get clientsDocDetailLines => 'Lines';

  @override
  String get clientsDocDetailNoLines => 'No lines';

  @override
  String get clientsDocDetailBase => 'Taxable base';

  @override
  String get clientsDocDetailTax => 'VAT';

  @override
  String get clientsDocDetailTotal => 'Total';

  @override
  String get clientsDocDetailRemarks => 'Remarks';

  @override
  String get visitReportsSearchHint => 'Search company...';

  @override
  String get visitReportsVisitSearchHint => 'Search visit...';

  @override
  String get visitReportsEmpty => 'No visits for this client';

  @override
  String get visitReportsErrorLoad => 'Could not load visits';

  @override
  String get visitReportsMonthView => 'View by month';

  @override
  String get visitReportsNewButton => 'New visit';

  @override
  String get visitReportsLabelWorker => 'Technician';

  @override
  String get visitReportsWorkersSearchHint => 'Search technician...';

  @override
  String get visitReportsLabelDescription => 'Description';

  @override
  String get visitReportsNoDescription => 'No description';

  @override
  String get visitReportsLabelTravelDistance => 'Distance travelled';

  @override
  String get visitReportsLabelTravelTime => 'Travel time';

  @override
  String get visitReportsCreateNameLabel => 'Visit name';

  @override
  String get visitReportsCreateNameHint => 'E.g. Follow-up meeting...';

  @override
  String get visitReportsCreateDateLabel => 'Date';

  @override
  String get visitReportsCreateTimeLabel => 'Time';

  @override
  String get visitReportsCreateDurationLabel => 'Duration (min)';

  @override
  String get visitReportsCreateTravelDistanceLabel => 'Distance (km)';

  @override
  String get visitReportsCreateTravelTimeLabel => 'Travel time (min)';

  @override
  String get visitReportsCreateDescriptionLabel => 'Description';

  @override
  String get visitReportsCreateDescriptionHint => 'Describe the visit...';

  @override
  String get visitReportsCreateRequired => 'Required field';

  @override
  String get visitReportsCreateSave => 'Save';

  @override
  String get visitReportsCreateSuccess => 'Visit created';

  @override
  String get visitReportsCreateError => 'Could not create the visit';

  @override
  String get workReportsEmpty => 'No work reports';

  @override
  String get workReportsSearchHint => 'Search report...';

  @override
  String get workReportsGroupByCompany => 'Group by company';

  @override
  String get workReportsErrorLoad => 'Could not load work reports';

  @override
  String get workReportsFilterActive => 'Active';

  @override
  String get workReportsFilterFinished => 'Finished';

  @override
  String get workReportsStatusAssigned => 'Assigned';

  @override
  String get workReportsStatusInProgress => 'In progress';

  @override
  String get workReportsStatusPartiallyFinished => 'Partially finished';

  @override
  String get workReportsStatusFinished => 'Finished';

  @override
  String get workReportsStatusNotified => 'Notified';

  @override
  String get workReportsStatusDeliveryNote => 'Delivery note issued';

  @override
  String get workReportsStatusInvoiced => 'Invoiced';

  @override
  String get workReportsStatusRejected => 'Rejected';

  @override
  String get workReportsLabelDescription => 'Description';

  @override
  String get workReportsNoDescription => 'No description';

  @override
  String get workReportsLabelRemarks => 'Remarks';

  @override
  String get workReportsNoRemarks => 'No remarks';

  @override
  String get workReportsLabelLines => 'Work lines';

  @override
  String get workReportsNoLines => 'No work lines';

  @override
  String get workReportsLineUnits => 'Units';

  @override
  String get workReportsLineDuration => 'Duration';

  @override
  String get workReportsAddLineTitle => 'Add line';

  @override
  String get workReportsAddLineProduct => 'Product (optional)';

  @override
  String get workReportsAddLineProductHint => 'Search product...';

  @override
  String get workReportsAddLineConcept => 'Concept';

  @override
  String get workReportsAddLineConceptHint => 'Task description';

  @override
  String get workReportsAddLineConceptRequired => 'The concept is required';

  @override
  String get workReportsAddLineUnits => 'Units';

  @override
  String get workReportsAddLineUnitsInvalid =>
      'Enter a valid number greater than 0';

  @override
  String get workReportsAddLineDuration => 'Duration (min)';

  @override
  String get workReportsAddLineSuccess => 'Line added';

  @override
  String get workReportsAddLineError => 'Could not add the line';

  @override
  String get workReportsLabelWorkers => 'Assigned workers';

  @override
  String get workReportsNoWorkers => 'No assigned workers';

  @override
  String get workReportsButtonFiles => 'Files';

  @override
  String get workReportsButtonSignature => 'Signature';

  @override
  String get workReportsButtonViewSignature => 'View signature';

  @override
  String get workReportsSignatureTitle => 'Client signature';

  @override
  String get workReportsSignatureSave => 'Save signature';

  @override
  String get workReportsSignatureClear => 'Clear';

  @override
  String get workReportsSignatureHint => 'Sign here';

  @override
  String get workReportsSignatureEmpty => 'Draw the signature before saving';

  @override
  String get workReportsSignatureSuccess => 'Signature saved';

  @override
  String get workReportsSignatureError => 'Could not save the signature';

  @override
  String get workReportsViewSignatureTitle => 'Saved signature';

  @override
  String get workReportsButtonResign => 'Sign again';
}
