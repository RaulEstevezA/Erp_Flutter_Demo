import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ca.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ca'),
    Locale('ca', 'ES'),
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appName.
  ///
  /// In es, this message translates to:
  /// **'ERP Flutter'**
  String get appName;

  /// No description provided for @splashTagline.
  ///
  /// In es, this message translates to:
  /// **'Gestión de personal en movilidad'**
  String get splashTagline;

  /// No description provided for @dialogAccept.
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get dialogAccept;

  /// No description provided for @dialogCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get dialogCancel;

  /// No description provided for @retry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// No description provided for @comingSoon.
  ///
  /// In es, this message translates to:
  /// **'{section} estará disponible próximamente.'**
  String comingSoon(String section);

  /// No description provided for @loginTitle.
  ///
  /// In es, this message translates to:
  /// **'Inicio de sesión'**
  String get loginTitle;

  /// No description provided for @loginServerUrlLabel.
  ///
  /// In es, this message translates to:
  /// **'URL del servidor'**
  String get loginServerUrlLabel;

  /// No description provided for @loginServerUrlHelper.
  ///
  /// In es, this message translates to:
  /// **'Escribe «demo» para usar los datos incluidos en la app'**
  String get loginServerUrlHelper;

  /// No description provided for @loginEmailLabel.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get loginEmailLabel;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get loginPasswordLabel;

  /// No description provided for @loginRememberUrl.
  ///
  /// In es, this message translates to:
  /// **'Recordar URL'**
  String get loginRememberUrl;

  /// No description provided for @loginRememberUser.
  ///
  /// In es, this message translates to:
  /// **'Recordar usuario'**
  String get loginRememberUser;

  /// No description provided for @loginSubmit.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get loginSubmit;

  /// No description provided for @loginDemoAccounts.
  ///
  /// In es, this message translates to:
  /// **'Cuentas de demostración'**
  String get loginDemoAccounts;

  /// No description provided for @loginDemoAccountsHint.
  ///
  /// In es, this message translates to:
  /// **'Toca una cuenta para rellenar el formulario. Contraseña: {password}'**
  String loginDemoAccountsHint(String password);

  /// No description provided for @loginErrorEmptyServerUrl.
  ///
  /// In es, this message translates to:
  /// **'Debes introducir la URL del servidor.'**
  String get loginErrorEmptyServerUrl;

  /// No description provided for @loginErrorEmptyEmail.
  ///
  /// In es, this message translates to:
  /// **'Debes introducir tu correo electrónico.'**
  String get loginErrorEmptyEmail;

  /// No description provided for @loginErrorEmptyPassword.
  ///
  /// In es, this message translates to:
  /// **'Debes introducir la contraseña.'**
  String get loginErrorEmptyPassword;

  /// No description provided for @loginErrorInvalidCredentials.
  ///
  /// In es, this message translates to:
  /// **'Las credenciales no son correctas.'**
  String get loginErrorInvalidCredentials;

  /// No description provided for @loginErrorAccessDenied.
  ///
  /// In es, this message translates to:
  /// **'Tu usuario no tiene acceso a la aplicación.'**
  String get loginErrorAccessDenied;

  /// No description provided for @loginErrorInvalidUrl.
  ///
  /// In es, this message translates to:
  /// **'La URL del servidor no es válida.'**
  String get loginErrorInvalidUrl;

  /// No description provided for @loginErrorServerNotFound.
  ///
  /// In es, this message translates to:
  /// **'No se ha encontrado un servidor ERP en esa URL.'**
  String get loginErrorServerNotFound;

  /// No description provided for @loginErrorNetwork.
  ///
  /// In es, this message translates to:
  /// **'No se ha podido conectar con el servidor.'**
  String get loginErrorNetwork;

  /// No description provided for @loginErrorTimeout.
  ///
  /// In es, this message translates to:
  /// **'La conexión con el servidor ha tardado demasiado.'**
  String get loginErrorTimeout;

  /// No description provided for @loginErrorServer.
  ///
  /// In es, this message translates to:
  /// **'Se ha producido un error en el servidor.'**
  String get loginErrorServer;

  /// No description provided for @loginErrorUnknown.
  ///
  /// In es, this message translates to:
  /// **'Se ha producido un error inesperado.'**
  String get loginErrorUnknown;

  /// No description provided for @roleSuperAdmin.
  ///
  /// In es, this message translates to:
  /// **'Superadministrador'**
  String get roleSuperAdmin;

  /// No description provided for @roleAdmin.
  ///
  /// In es, this message translates to:
  /// **'Administrador'**
  String get roleAdmin;

  /// No description provided for @roleUser.
  ///
  /// In es, this message translates to:
  /// **'Usuario'**
  String get roleUser;

  /// No description provided for @roleWorker.
  ///
  /// In es, this message translates to:
  /// **'Trabajador'**
  String get roleWorker;

  /// No description provided for @roleCustomer.
  ///
  /// In es, this message translates to:
  /// **'Cliente'**
  String get roleCustomer;

  /// No description provided for @roleSupplier.
  ///
  /// In es, this message translates to:
  /// **'Proveedor'**
  String get roleSupplier;

  /// No description provided for @roleUnknown.
  ///
  /// In es, this message translates to:
  /// **'Sin rol'**
  String get roleUnknown;

  /// No description provided for @homeTitle.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get homeTitle;

  /// No description provided for @homeWelcome.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido a {company},'**
  String homeWelcome(String company);

  /// No description provided for @homeConnectionError.
  ///
  /// In es, this message translates to:
  /// **'No se ha podido conectar con el servidor'**
  String get homeConnectionError;

  /// No description provided for @homeConnectionLost.
  ///
  /// In es, this message translates to:
  /// **'Se ha perdido la conexión con el servidor'**
  String get homeConnectionLost;

  /// No description provided for @clockStartShift.
  ///
  /// In es, this message translates to:
  /// **'Iniciar / Continuar turno'**
  String get clockStartShift;

  /// No description provided for @clockEndShift.
  ///
  /// In es, this message translates to:
  /// **'Finalizar / Hacer pausa'**
  String get clockEndShift;

  /// No description provided for @clockConfirmStartTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Iniciar turno?'**
  String get clockConfirmStartTitle;

  /// No description provided for @clockConfirmStartMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Quieres iniciar turno / terminar pausa?'**
  String get clockConfirmStartMessage;

  /// No description provided for @clockConfirmEndTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Finalizar turno?'**
  String get clockConfirmEndTitle;

  /// No description provided for @clockConfirmEndMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Quieres finalizar turno / empezar pausa?'**
  String get clockConfirmEndMessage;

  /// No description provided for @clockSyncedStarted.
  ///
  /// In es, this message translates to:
  /// **'Tu turno ya había sido iniciado desde otro dispositivo. Estado actualizado.'**
  String get clockSyncedStarted;

  /// No description provided for @clockSyncedEnded.
  ///
  /// In es, this message translates to:
  /// **'Tu turno ya había sido finalizado desde otro dispositivo. Estado actualizado.'**
  String get clockSyncedEnded;

  /// No description provided for @clockError.
  ///
  /// In es, this message translates to:
  /// **'No se ha podido registrar el fichaje. Inténtalo de nuevo.'**
  String get clockError;

  /// No description provided for @clockInDone.
  ///
  /// In es, this message translates to:
  /// **'Entrada registrada a las {time}'**
  String clockInDone(String time);

  /// No description provided for @clockOutDone.
  ///
  /// In es, this message translates to:
  /// **'Salida registrada a las {time}'**
  String clockOutDone(String time);

  /// No description provided for @menuAttendanceRecords.
  ///
  /// In es, this message translates to:
  /// **'Ver fichajes'**
  String get menuAttendanceRecords;

  /// No description provided for @menuIncidents.
  ///
  /// In es, this message translates to:
  /// **'Incidencias'**
  String get menuIncidents;

  /// No description provided for @menuWorkReports.
  ///
  /// In es, this message translates to:
  /// **'Partes de trabajo'**
  String get menuWorkReports;

  /// No description provided for @menuClients.
  ///
  /// In es, this message translates to:
  /// **'Clientes'**
  String get menuClients;

  /// No description provided for @menuVisitReports.
  ///
  /// In es, this message translates to:
  /// **'Partes de visita'**
  String get menuVisitReports;

  /// No description provided for @menuHolidays.
  ///
  /// In es, this message translates to:
  /// **'Vacaciones'**
  String get menuHolidays;

  /// No description provided for @menuMessages.
  ///
  /// In es, this message translates to:
  /// **'Mensajes'**
  String get menuMessages;

  /// No description provided for @menuLogout.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get menuLogout;

  /// No description provided for @settingsDarkMode.
  ///
  /// In es, this message translates to:
  /// **'Modo oscuro'**
  String get settingsDarkMode;

  /// No description provided for @settingsLightMode.
  ///
  /// In es, this message translates to:
  /// **'Modo claro'**
  String get settingsLightMode;

  /// No description provided for @drawerVersion.
  ///
  /// In es, this message translates to:
  /// **'Versión {version}'**
  String drawerVersion(String version);

  /// No description provided for @clockTypeIn.
  ///
  /// In es, this message translates to:
  /// **'Entrada'**
  String get clockTypeIn;

  /// No description provided for @clockTypeOut.
  ///
  /// In es, this message translates to:
  /// **'Salida'**
  String get clockTypeOut;

  /// No description provided for @recordsTitle.
  ///
  /// In es, this message translates to:
  /// **'Fichajes'**
  String get recordsTitle;

  /// No description provided for @recordsEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay fichajes en este período.'**
  String get recordsEmpty;

  /// No description provided for @recordsLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se han podido cargar los fichajes.'**
  String get recordsLoadError;

  /// No description provided for @recordsLocation.
  ///
  /// In es, this message translates to:
  /// **'Ubicación (aprox.)'**
  String get recordsLocation;

  /// No description provided for @groupByEmployee.
  ///
  /// In es, this message translates to:
  /// **'Agrupar por empleado'**
  String get groupByEmployee;

  /// No description provided for @filterByDates.
  ///
  /// In es, this message translates to:
  /// **'Filtrar por fechas'**
  String get filterByDates;

  /// No description provided for @dateFrom.
  ///
  /// In es, this message translates to:
  /// **'Desde'**
  String get dateFrom;

  /// No description provided for @dateTo.
  ///
  /// In es, this message translates to:
  /// **'Hasta'**
  String get dateTo;

  /// No description provided for @applyFilter.
  ///
  /// In es, this message translates to:
  /// **'Aplicar'**
  String get applyFilter;

  /// No description provided for @clearFilter.
  ///
  /// In es, this message translates to:
  /// **'Limpiar filtro'**
  String get clearFilter;

  /// No description provided for @incidentReport.
  ///
  /// In es, this message translates to:
  /// **'Incidencia'**
  String get incidentReport;

  /// No description provided for @incidentDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Reportar incidencia'**
  String get incidentDialogTitle;

  /// No description provided for @incidentReason.
  ///
  /// In es, this message translates to:
  /// **'Motivo'**
  String get incidentReason;

  /// No description provided for @incidentReasonHint.
  ///
  /// In es, this message translates to:
  /// **'Describe el motivo de la incidencia (mín. 5 caracteres)'**
  String get incidentReasonHint;

  /// No description provided for @incidentReasonTooShort.
  ///
  /// In es, this message translates to:
  /// **'El motivo debe tener al menos 5 caracteres.'**
  String get incidentReasonTooShort;

  /// No description provided for @incidentRequestDate.
  ///
  /// In es, this message translates to:
  /// **'Solicitar cambio de fecha (opcional)'**
  String get incidentRequestDate;

  /// No description provided for @incidentPickDate.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar fecha y hora'**
  String get incidentPickDate;

  /// No description provided for @incidentClearDate.
  ///
  /// In es, this message translates to:
  /// **'Eliminar fecha'**
  String get incidentClearDate;

  /// No description provided for @incidentRequestedType.
  ///
  /// In es, this message translates to:
  /// **'Tipo solicitado'**
  String get incidentRequestedType;

  /// No description provided for @incidentSubmit.
  ///
  /// In es, this message translates to:
  /// **'Enviar'**
  String get incidentSubmit;

  /// No description provided for @incidentSendError.
  ///
  /// In es, this message translates to:
  /// **'No se ha podido enviar la incidencia. Inténtalo de nuevo.'**
  String get incidentSendError;

  /// No description provided for @incidentSent.
  ///
  /// In es, this message translates to:
  /// **'Incidencia enviada correctamente.'**
  String get incidentSent;

  /// No description provided for @incidentPending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get incidentPending;

  /// No description provided for @incidentApproved.
  ///
  /// In es, this message translates to:
  /// **'Aprobada'**
  String get incidentApproved;

  /// No description provided for @incidentRejected.
  ///
  /// In es, this message translates to:
  /// **'Rechazada'**
  String get incidentRejected;

  /// No description provided for @incidentsTitle.
  ///
  /// In es, this message translates to:
  /// **'Incidencias'**
  String get incidentsTitle;

  /// No description provided for @incidentsEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay incidencias en este período.'**
  String get incidentsEmpty;

  /// No description provided for @incidentsLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se han podido cargar las incidencias.'**
  String get incidentsLoadError;

  /// No description provided for @incidentDetailTitle.
  ///
  /// In es, this message translates to:
  /// **'Detalle de incidencia'**
  String get incidentDetailTitle;

  /// No description provided for @incidentAffectedRecord.
  ///
  /// In es, this message translates to:
  /// **'Fichaje afectado'**
  String get incidentAffectedRecord;

  /// No description provided for @incidentRequestedChanges.
  ///
  /// In es, this message translates to:
  /// **'Cambios solicitados'**
  String get incidentRequestedChanges;

  /// No description provided for @incidentNoChanges.
  ///
  /// In es, this message translates to:
  /// **'Sin cambios solicitados.'**
  String get incidentNoChanges;

  /// No description provided for @incidentCreatedAt.
  ///
  /// In es, this message translates to:
  /// **'Creada el'**
  String get incidentCreatedAt;

  /// No description provided for @incidentWorker.
  ///
  /// In es, this message translates to:
  /// **'Trabajador'**
  String get incidentWorker;

  /// No description provided for @holidaysEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay vacaciones en este período.'**
  String get holidaysEmpty;

  /// No description provided for @holidaysLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se han podido cargar las vacaciones.'**
  String get holidaysLoadError;

  /// No description provided for @holidayPending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get holidayPending;

  /// No description provided for @holidayApproved.
  ///
  /// In es, this message translates to:
  /// **'Aprobadas'**
  String get holidayApproved;

  /// No description provided for @holidayRejected.
  ///
  /// In es, this message translates to:
  /// **'Rechazadas'**
  String get holidayRejected;

  /// No description provided for @holidaysCalendarView.
  ///
  /// In es, this message translates to:
  /// **'Vista calendario'**
  String get holidaysCalendarView;

  /// No description provided for @holidaysListView.
  ///
  /// In es, this message translates to:
  /// **'Vista lista'**
  String get holidaysListView;

  /// No description provided for @groupByPerson.
  ///
  /// In es, this message translates to:
  /// **'Agrupar por persona'**
  String get groupByPerson;

  /// No description provided for @holidaysRequestTitle.
  ///
  /// In es, this message translates to:
  /// **'Solicitar vacaciones'**
  String get holidaysRequestTitle;

  /// No description provided for @holidaysStart.
  ///
  /// In es, this message translates to:
  /// **'Fecha de inicio'**
  String get holidaysStart;

  /// No description provided for @holidaysEnd.
  ///
  /// In es, this message translates to:
  /// **'Fecha de fin'**
  String get holidaysEnd;

  /// No description provided for @holidaysPickDate.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar fecha'**
  String get holidaysPickDate;

  /// No description provided for @holidaysReason.
  ///
  /// In es, this message translates to:
  /// **'Motivo (opcional)'**
  String get holidaysReason;

  /// No description provided for @holidaysReasonHint.
  ///
  /// In es, this message translates to:
  /// **'Motivo de la solicitud...'**
  String get holidaysReasonHint;

  /// No description provided for @holidaysSubmit.
  ///
  /// In es, this message translates to:
  /// **'Solicitar'**
  String get holidaysSubmit;

  /// No description provided for @holidaysDatesError.
  ///
  /// In es, this message translates to:
  /// **'Selecciona las dos fechas; la de fin no puede ser anterior a la de inicio.'**
  String get holidaysDatesError;

  /// No description provided for @holidaysRequestSent.
  ///
  /// In es, this message translates to:
  /// **'Solicitud enviada correctamente.'**
  String get holidaysRequestSent;

  /// No description provided for @holidaysRequestError.
  ///
  /// In es, this message translates to:
  /// **'No se ha podido enviar la solicitud. Inténtalo de nuevo.'**
  String get holidaysRequestError;

  /// No description provided for @holidaysWorkingDays.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 día laborable} other{{count} días laborables}}'**
  String holidaysWorkingDays(int count);

  /// No description provided for @holidaysNaturalDays.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 natural} other{{count} naturales}}'**
  String holidaysNaturalDays(int count);

  /// No description provided for @holidayDayVacation.
  ///
  /// In es, this message translates to:
  /// **'Vacaciones'**
  String get holidayDayVacation;

  /// No description provided for @holidayDayNational.
  ///
  /// In es, this message translates to:
  /// **'Festivo nacional'**
  String get holidayDayNational;

  /// No description provided for @holidayDayCompany.
  ///
  /// In es, this message translates to:
  /// **'Festivo de empresa'**
  String get holidayDayCompany;

  /// No description provided for @holidayDayRest.
  ///
  /// In es, this message translates to:
  /// **'Descanso semanal'**
  String get holidayDayRest;

  /// No description provided for @holidaysApprove.
  ///
  /// In es, this message translates to:
  /// **'Aprobar'**
  String get holidaysApprove;

  /// No description provided for @holidaysReject.
  ///
  /// In es, this message translates to:
  /// **'Rechazar'**
  String get holidaysReject;

  /// No description provided for @holidaysCancelRequest.
  ///
  /// In es, this message translates to:
  /// **'Cancelar solicitud'**
  String get holidaysCancelRequest;

  /// No description provided for @holidaysCancelTitle.
  ///
  /// In es, this message translates to:
  /// **'Cancelar solicitud'**
  String get holidaysCancelTitle;

  /// No description provided for @holidaysCancelMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Seguro que quieres cancelar esta solicitud de vacaciones?'**
  String get holidaysCancelMessage;

  /// No description provided for @holidaysCancelNo.
  ///
  /// In es, this message translates to:
  /// **'No'**
  String get holidaysCancelNo;

  /// No description provided for @holidaysCancelYes.
  ///
  /// In es, this message translates to:
  /// **'Sí, cancelar'**
  String get holidaysCancelYes;

  /// No description provided for @holidaysApprovedMessage.
  ///
  /// In es, this message translates to:
  /// **'Vacaciones aprobadas.'**
  String get holidaysApprovedMessage;

  /// No description provided for @holidaysRejectedMessage.
  ///
  /// In es, this message translates to:
  /// **'Vacaciones rechazadas.'**
  String get holidaysRejectedMessage;

  /// No description provided for @holidaysCancelledMessage.
  ///
  /// In es, this message translates to:
  /// **'Solicitud cancelada.'**
  String get holidaysCancelledMessage;

  /// No description provided for @holidaysActionError.
  ///
  /// In es, this message translates to:
  /// **'No se ha podido completar la acción. Inténtalo de nuevo.'**
  String get holidaysActionError;

  /// No description provided for @holidaysSummary.
  ///
  /// In es, this message translates to:
  /// **'Vacaciones {year}: {used}/{total} días'**
  String holidaysSummary(String year, int used, int total);

  /// No description provided for @holidaysSummaryWorker.
  ///
  /// In es, this message translates to:
  /// **'Trabajador: {count} días'**
  String holidaysSummaryWorker(int count);

  /// No description provided for @holidaysSummaryCompany.
  ///
  /// In es, this message translates to:
  /// **'Empresa: {count} días'**
  String holidaysSummaryCompany(int count);

  /// No description provided for @holidayByWorker.
  ///
  /// In es, this message translates to:
  /// **'Solicitado por trabajador'**
  String get holidayByWorker;

  /// No description provided for @holidayByCompany.
  ///
  /// In es, this message translates to:
  /// **'Asignado por empresa'**
  String get holidayByCompany;

  /// No description provided for @holidaysOnDay.
  ///
  /// In es, this message translates to:
  /// **'Vacaciones el {date}'**
  String holidaysOnDay(String date);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ca', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'ca':
      {
        switch (locale.countryCode) {
          case 'ES':
            return AppLocalizationsCaEs();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ca':
      return AppLocalizationsCa();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
