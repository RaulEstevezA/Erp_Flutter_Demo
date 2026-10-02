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

  /// No description provided for @messagesNew.
  ///
  /// In es, this message translates to:
  /// **'Nuevo mensaje'**
  String get messagesNew;

  /// No description provided for @messagesList.
  ///
  /// In es, this message translates to:
  /// **'Mensajes'**
  String get messagesList;

  /// No description provided for @messagesRecipientSearch.
  ///
  /// In es, this message translates to:
  /// **'Buscar destinatario...'**
  String get messagesRecipientSearch;

  /// No description provided for @messagesRecipientRequired.
  ///
  /// In es, this message translates to:
  /// **'Selecciona un destinatario'**
  String get messagesRecipientRequired;

  /// No description provided for @messagesNoRecipients.
  ///
  /// In es, this message translates to:
  /// **'No hay destinatarios disponibles'**
  String get messagesNoRecipients;

  /// No description provided for @messagesBody.
  ///
  /// In es, this message translates to:
  /// **'Mensaje'**
  String get messagesBody;

  /// No description provided for @messagesBodyHint.
  ///
  /// In es, this message translates to:
  /// **'Escribe tu mensaje...'**
  String get messagesBodyHint;

  /// No description provided for @messagesBodyRequired.
  ///
  /// In es, this message translates to:
  /// **'El mensaje no puede estar vacío'**
  String get messagesBodyRequired;

  /// No description provided for @messagesSend.
  ///
  /// In es, this message translates to:
  /// **'Enviar'**
  String get messagesSend;

  /// No description provided for @messagesSent.
  ///
  /// In es, this message translates to:
  /// **'Mensaje enviado'**
  String get messagesSent;

  /// No description provided for @messagesSendError.
  ///
  /// In es, this message translates to:
  /// **'No se ha podido enviar el mensaje. Inténtalo de nuevo.'**
  String get messagesSendError;

  /// No description provided for @messagesEmpty.
  ///
  /// In es, this message translates to:
  /// **'No tienes conversaciones todavía'**
  String get messagesEmpty;

  /// No description provided for @messagesLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se han podido cargar los mensajes'**
  String get messagesLoadError;

  /// No description provided for @messagesTypeHint.
  ///
  /// In es, this message translates to:
  /// **'Escribe un mensaje...'**
  String get messagesTypeHint;

  /// No description provided for @messagesChatEmpty.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay mensajes en esta conversación'**
  String get messagesChatEmpty;

  /// No description provided for @messagesYou.
  ///
  /// In es, this message translates to:
  /// **'Tú: '**
  String get messagesYou;

  /// No description provided for @clientsSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar nombre, CIF o población…'**
  String get clientsSearchHint;

  /// No description provided for @clientsEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay clientes'**
  String get clientsEmpty;

  /// No description provided for @clientsErrorLoad.
  ///
  /// In es, this message translates to:
  /// **'No se han podido cargar los clientes'**
  String get clientsErrorLoad;

  /// No description provided for @clientsLabelResponsible.
  ///
  /// In es, this message translates to:
  /// **'Responsable'**
  String get clientsLabelResponsible;

  /// No description provided for @clientsLabelPaymentCondition.
  ///
  /// In es, this message translates to:
  /// **'Condición de pago'**
  String get clientsLabelPaymentCondition;

  /// No description provided for @clientsLabelPaymentMethod.
  ///
  /// In es, this message translates to:
  /// **'Forma de pago'**
  String get clientsLabelPaymentMethod;

  /// No description provided for @clientsLabelRemarks.
  ///
  /// In es, this message translates to:
  /// **'Observaciones'**
  String get clientsLabelRemarks;

  /// No description provided for @clientsNoRemarks.
  ///
  /// In es, this message translates to:
  /// **'Sin observaciones'**
  String get clientsNoRemarks;

  /// No description provided for @clientsLabelAddresses.
  ///
  /// In es, this message translates to:
  /// **'Direcciones'**
  String get clientsLabelAddresses;

  /// No description provided for @clientsNoAddresses.
  ///
  /// In es, this message translates to:
  /// **'Sin direcciones'**
  String get clientsNoAddresses;

  /// No description provided for @clientsLabelContacts.
  ///
  /// In es, this message translates to:
  /// **'Contactos'**
  String get clientsLabelContacts;

  /// No description provided for @clientsNoContacts.
  ///
  /// In es, this message translates to:
  /// **'Sin contactos'**
  String get clientsNoContacts;

  /// No description provided for @clientsLabelBilling.
  ///
  /// In es, this message translates to:
  /// **'Facturación'**
  String get clientsLabelBilling;

  /// No description provided for @clientsLabelDelivering.
  ///
  /// In es, this message translates to:
  /// **'Entrega'**
  String get clientsLabelDelivering;

  /// No description provided for @clientsButtonWorks.
  ///
  /// In es, this message translates to:
  /// **'Trabajos'**
  String get clientsButtonWorks;

  /// No description provided for @clientsButtonBudgets.
  ///
  /// In es, this message translates to:
  /// **'Presupuestos'**
  String get clientsButtonBudgets;

  /// No description provided for @clientsButtonOrders.
  ///
  /// In es, this message translates to:
  /// **'Pedidos'**
  String get clientsButtonOrders;

  /// No description provided for @clientsButtonDeliveryNotes.
  ///
  /// In es, this message translates to:
  /// **'Albaranes'**
  String get clientsButtonDeliveryNotes;

  /// No description provided for @clientsButtonInvoices.
  ///
  /// In es, this message translates to:
  /// **'Facturas'**
  String get clientsButtonInvoices;

  /// No description provided for @clientsButtonRecurrentInvoices.
  ///
  /// In es, this message translates to:
  /// **'Fact. recurrentes'**
  String get clientsButtonRecurrentInvoices;

  /// No description provided for @clientsLabelPaymentData.
  ///
  /// In es, this message translates to:
  /// **'Datos de pago'**
  String get clientsLabelPaymentData;

  /// No description provided for @clientsLabelActive.
  ///
  /// In es, this message translates to:
  /// **'Cliente activo'**
  String get clientsLabelActive;

  /// No description provided for @clientsLabelInactive.
  ///
  /// In es, this message translates to:
  /// **'Cliente inactivo'**
  String get clientsLabelInactive;

  /// No description provided for @clientsDocumentsEmpty.
  ///
  /// In es, this message translates to:
  /// **'Sin documentos'**
  String get clientsDocumentsEmpty;

  /// No description provided for @clientsDocumentsErrorLoad.
  ///
  /// In es, this message translates to:
  /// **'No se han podido cargar los documentos'**
  String get clientsDocumentsErrorLoad;

  /// No description provided for @clientsDocumentsSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar documento...'**
  String get clientsDocumentsSearchHint;

  /// No description provided for @clientsDocDetailErrorLoad.
  ///
  /// In es, this message translates to:
  /// **'No se ha podido cargar el documento'**
  String get clientsDocDetailErrorLoad;

  /// No description provided for @clientsDocDetailLines.
  ///
  /// In es, this message translates to:
  /// **'Líneas'**
  String get clientsDocDetailLines;

  /// No description provided for @clientsDocDetailNoLines.
  ///
  /// In es, this message translates to:
  /// **'Sin líneas'**
  String get clientsDocDetailNoLines;

  /// No description provided for @clientsDocDetailBase.
  ///
  /// In es, this message translates to:
  /// **'Base imponible'**
  String get clientsDocDetailBase;

  /// No description provided for @clientsDocDetailTax.
  ///
  /// In es, this message translates to:
  /// **'IVA'**
  String get clientsDocDetailTax;

  /// No description provided for @clientsDocDetailTotal.
  ///
  /// In es, this message translates to:
  /// **'Total'**
  String get clientsDocDetailTotal;

  /// No description provided for @clientsDocDetailRemarks.
  ///
  /// In es, this message translates to:
  /// **'Observaciones'**
  String get clientsDocDetailRemarks;

  /// No description provided for @visitReportsSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar empresa...'**
  String get visitReportsSearchHint;

  /// No description provided for @visitReportsVisitSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar visita...'**
  String get visitReportsVisitSearchHint;

  /// No description provided for @visitReportsEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay visitas para este cliente'**
  String get visitReportsEmpty;

  /// No description provided for @visitReportsErrorLoad.
  ///
  /// In es, this message translates to:
  /// **'No se han podido cargar las visitas'**
  String get visitReportsErrorLoad;

  /// No description provided for @visitReportsMonthView.
  ///
  /// In es, this message translates to:
  /// **'Ver por meses'**
  String get visitReportsMonthView;

  /// No description provided for @visitReportsNewButton.
  ///
  /// In es, this message translates to:
  /// **'Nueva visita'**
  String get visitReportsNewButton;

  /// No description provided for @visitReportsLabelWorker.
  ///
  /// In es, this message translates to:
  /// **'Técnico'**
  String get visitReportsLabelWorker;

  /// No description provided for @visitReportsWorkersSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar técnico...'**
  String get visitReportsWorkersSearchHint;

  /// No description provided for @visitReportsLabelDescription.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get visitReportsLabelDescription;

  /// No description provided for @visitReportsNoDescription.
  ///
  /// In es, this message translates to:
  /// **'Sin descripción'**
  String get visitReportsNoDescription;

  /// No description provided for @visitReportsLabelTravelDistance.
  ///
  /// In es, this message translates to:
  /// **'Distancia recorrida'**
  String get visitReportsLabelTravelDistance;

  /// No description provided for @visitReportsLabelTravelTime.
  ///
  /// In es, this message translates to:
  /// **'Tiempo de desplazamiento'**
  String get visitReportsLabelTravelTime;

  /// No description provided for @visitReportsCreateNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la visita'**
  String get visitReportsCreateNameLabel;

  /// No description provided for @visitReportsCreateNameHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Reunión de seguimiento...'**
  String get visitReportsCreateNameHint;

  /// No description provided for @visitReportsCreateDateLabel.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get visitReportsCreateDateLabel;

  /// No description provided for @visitReportsCreateTimeLabel.
  ///
  /// In es, this message translates to:
  /// **'Hora'**
  String get visitReportsCreateTimeLabel;

  /// No description provided for @visitReportsCreateDurationLabel.
  ///
  /// In es, this message translates to:
  /// **'Duración (min)'**
  String get visitReportsCreateDurationLabel;

  /// No description provided for @visitReportsCreateTravelDistanceLabel.
  ///
  /// In es, this message translates to:
  /// **'Distancia (km)'**
  String get visitReportsCreateTravelDistanceLabel;

  /// No description provided for @visitReportsCreateTravelTimeLabel.
  ///
  /// In es, this message translates to:
  /// **'Tiempo desplazamiento (min)'**
  String get visitReportsCreateTravelTimeLabel;

  /// No description provided for @visitReportsCreateDescriptionLabel.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get visitReportsCreateDescriptionLabel;

  /// No description provided for @visitReportsCreateDescriptionHint.
  ///
  /// In es, this message translates to:
  /// **'Describe la visita...'**
  String get visitReportsCreateDescriptionHint;

  /// No description provided for @visitReportsCreateRequired.
  ///
  /// In es, this message translates to:
  /// **'Campo obligatorio'**
  String get visitReportsCreateRequired;

  /// No description provided for @visitReportsCreateSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get visitReportsCreateSave;

  /// No description provided for @visitReportsCreateSuccess.
  ///
  /// In es, this message translates to:
  /// **'Visita creada correctamente'**
  String get visitReportsCreateSuccess;

  /// No description provided for @visitReportsCreateError.
  ///
  /// In es, this message translates to:
  /// **'No se ha podido crear la visita'**
  String get visitReportsCreateError;

  /// No description provided for @workReportsEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay partes de trabajo'**
  String get workReportsEmpty;

  /// No description provided for @workReportsSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar parte...'**
  String get workReportsSearchHint;

  /// No description provided for @workReportsGroupByCompany.
  ///
  /// In es, this message translates to:
  /// **'Agrupar por empresa'**
  String get workReportsGroupByCompany;

  /// No description provided for @workReportsErrorLoad.
  ///
  /// In es, this message translates to:
  /// **'No se han podido cargar los partes de trabajo'**
  String get workReportsErrorLoad;

  /// No description provided for @workReportsFilterActive.
  ///
  /// In es, this message translates to:
  /// **'Activos'**
  String get workReportsFilterActive;

  /// No description provided for @workReportsFilterFinished.
  ///
  /// In es, this message translates to:
  /// **'Finalizados'**
  String get workReportsFilterFinished;

  /// No description provided for @workReportsStatusAssigned.
  ///
  /// In es, this message translates to:
  /// **'Asignado'**
  String get workReportsStatusAssigned;

  /// No description provided for @workReportsStatusInProgress.
  ///
  /// In es, this message translates to:
  /// **'En progreso'**
  String get workReportsStatusInProgress;

  /// No description provided for @workReportsStatusPartiallyFinished.
  ///
  /// In es, this message translates to:
  /// **'Parcialmente finalizado'**
  String get workReportsStatusPartiallyFinished;

  /// No description provided for @workReportsStatusFinished.
  ///
  /// In es, this message translates to:
  /// **'Finalizado'**
  String get workReportsStatusFinished;

  /// No description provided for @workReportsStatusNotified.
  ///
  /// In es, this message translates to:
  /// **'Notificado'**
  String get workReportsStatusNotified;

  /// No description provided for @workReportsStatusDeliveryNote.
  ///
  /// In es, this message translates to:
  /// **'Albarán generado'**
  String get workReportsStatusDeliveryNote;

  /// No description provided for @workReportsStatusInvoiced.
  ///
  /// In es, this message translates to:
  /// **'Facturado'**
  String get workReportsStatusInvoiced;

  /// No description provided for @workReportsStatusRejected.
  ///
  /// In es, this message translates to:
  /// **'Rechazado'**
  String get workReportsStatusRejected;

  /// No description provided for @workReportsLabelDescription.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get workReportsLabelDescription;

  /// No description provided for @workReportsNoDescription.
  ///
  /// In es, this message translates to:
  /// **'Sin descripción'**
  String get workReportsNoDescription;

  /// No description provided for @workReportsLabelRemarks.
  ///
  /// In es, this message translates to:
  /// **'Observaciones'**
  String get workReportsLabelRemarks;

  /// No description provided for @workReportsNoRemarks.
  ///
  /// In es, this message translates to:
  /// **'Sin observaciones'**
  String get workReportsNoRemarks;

  /// No description provided for @workReportsLabelLines.
  ///
  /// In es, this message translates to:
  /// **'Líneas de trabajo'**
  String get workReportsLabelLines;

  /// No description provided for @workReportsNoLines.
  ///
  /// In es, this message translates to:
  /// **'Sin líneas de trabajo'**
  String get workReportsNoLines;

  /// No description provided for @workReportsLineUnits.
  ///
  /// In es, this message translates to:
  /// **'Uds.'**
  String get workReportsLineUnits;

  /// No description provided for @workReportsLineDuration.
  ///
  /// In es, this message translates to:
  /// **'Duración'**
  String get workReportsLineDuration;

  /// No description provided for @workReportsAddLineTitle.
  ///
  /// In es, this message translates to:
  /// **'Añadir línea'**
  String get workReportsAddLineTitle;

  /// No description provided for @workReportsAddLineProduct.
  ///
  /// In es, this message translates to:
  /// **'Producto (opcional)'**
  String get workReportsAddLineProduct;

  /// No description provided for @workReportsAddLineProductHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar producto...'**
  String get workReportsAddLineProductHint;

  /// No description provided for @workReportsAddLineConcept.
  ///
  /// In es, this message translates to:
  /// **'Concepto'**
  String get workReportsAddLineConcept;

  /// No description provided for @workReportsAddLineConceptHint.
  ///
  /// In es, this message translates to:
  /// **'Descripción de la tarea'**
  String get workReportsAddLineConceptHint;

  /// No description provided for @workReportsAddLineConceptRequired.
  ///
  /// In es, this message translates to:
  /// **'El concepto es obligatorio'**
  String get workReportsAddLineConceptRequired;

  /// No description provided for @workReportsAddLineUnits.
  ///
  /// In es, this message translates to:
  /// **'Unidades'**
  String get workReportsAddLineUnits;

  /// No description provided for @workReportsAddLineUnitsInvalid.
  ///
  /// In es, this message translates to:
  /// **'Introduce un número válido mayor que 0'**
  String get workReportsAddLineUnitsInvalid;

  /// No description provided for @workReportsAddLineDuration.
  ///
  /// In es, this message translates to:
  /// **'Duración (min)'**
  String get workReportsAddLineDuration;

  /// No description provided for @workReportsAddLineSuccess.
  ///
  /// In es, this message translates to:
  /// **'Línea añadida correctamente'**
  String get workReportsAddLineSuccess;

  /// No description provided for @workReportsAddLineError.
  ///
  /// In es, this message translates to:
  /// **'No se ha podido añadir la línea'**
  String get workReportsAddLineError;

  /// No description provided for @workReportsLabelWorkers.
  ///
  /// In es, this message translates to:
  /// **'Trabajadores asignados'**
  String get workReportsLabelWorkers;

  /// No description provided for @workReportsNoWorkers.
  ///
  /// In es, this message translates to:
  /// **'Sin trabajadores asignados'**
  String get workReportsNoWorkers;

  /// No description provided for @workReportsButtonFiles.
  ///
  /// In es, this message translates to:
  /// **'Archivos'**
  String get workReportsButtonFiles;

  /// No description provided for @workReportsButtonSignature.
  ///
  /// In es, this message translates to:
  /// **'Firma'**
  String get workReportsButtonSignature;

  /// No description provided for @workReportsButtonViewSignature.
  ///
  /// In es, this message translates to:
  /// **'Ver firma'**
  String get workReportsButtonViewSignature;

  /// No description provided for @workReportsSignatureTitle.
  ///
  /// In es, this message translates to:
  /// **'Firma del cliente'**
  String get workReportsSignatureTitle;

  /// No description provided for @workReportsSignatureSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar firma'**
  String get workReportsSignatureSave;

  /// No description provided for @workReportsSignatureClear.
  ///
  /// In es, this message translates to:
  /// **'Borrar'**
  String get workReportsSignatureClear;

  /// No description provided for @workReportsSignatureHint.
  ///
  /// In es, this message translates to:
  /// **'Firma aquí'**
  String get workReportsSignatureHint;

  /// No description provided for @workReportsSignatureEmpty.
  ///
  /// In es, this message translates to:
  /// **'Dibuja la firma antes de guardar'**
  String get workReportsSignatureEmpty;

  /// No description provided for @workReportsSignatureSuccess.
  ///
  /// In es, this message translates to:
  /// **'Firma guardada correctamente'**
  String get workReportsSignatureSuccess;

  /// No description provided for @workReportsSignatureError.
  ///
  /// In es, this message translates to:
  /// **'No se ha podido guardar la firma'**
  String get workReportsSignatureError;

  /// No description provided for @workReportsViewSignatureTitle.
  ///
  /// In es, this message translates to:
  /// **'Firma guardada'**
  String get workReportsViewSignatureTitle;

  /// No description provided for @workReportsButtonResign.
  ///
  /// In es, this message translates to:
  /// **'Volver a firmar'**
  String get workReportsButtonResign;

  /// No description provided for @workReportsFilesEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay archivos adjuntos'**
  String get workReportsFilesEmpty;

  /// No description provided for @workReportsFilesErrorLoad.
  ///
  /// In es, this message translates to:
  /// **'No se han podido cargar los archivos'**
  String get workReportsFilesErrorLoad;

  /// No description provided for @workReportsFilesCamera.
  ///
  /// In es, this message translates to:
  /// **'Cámara'**
  String get workReportsFilesCamera;

  /// No description provided for @workReportsFilesGallery.
  ///
  /// In es, this message translates to:
  /// **'Galería'**
  String get workReportsFilesGallery;

  /// No description provided for @workReportsFilesRecordAudio.
  ///
  /// In es, this message translates to:
  /// **'Grabar audio'**
  String get workReportsFilesRecordAudio;

  /// No description provided for @workReportsFilesStopRecord.
  ///
  /// In es, this message translates to:
  /// **'Parar'**
  String get workReportsFilesStopRecord;

  /// No description provided for @workReportsFilesRecording.
  ///
  /// In es, this message translates to:
  /// **'Grabando...'**
  String get workReportsFilesRecording;

  /// No description provided for @workReportsFilesSaving.
  ///
  /// In es, this message translates to:
  /// **'Guardando...'**
  String get workReportsFilesSaving;

  /// No description provided for @workReportsFilesDelete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get workReportsFilesDelete;

  /// No description provided for @workReportsFilesDeleteConfirmTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar archivo'**
  String get workReportsFilesDeleteConfirmTitle;

  /// No description provided for @workReportsFilesDeleteConfirmMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Seguro que quieres eliminar este archivo?'**
  String get workReportsFilesDeleteConfirmMessage;

  /// No description provided for @workReportsFilesUploadError.
  ///
  /// In es, this message translates to:
  /// **'No se ha podido subir el archivo'**
  String get workReportsFilesUploadError;

  /// No description provided for @workReportsFilesDeleteError.
  ///
  /// In es, this message translates to:
  /// **'No se ha podido eliminar el archivo'**
  String get workReportsFilesDeleteError;

  /// No description provided for @workReportsFilesMicDenied.
  ///
  /// In es, this message translates to:
  /// **'Sin permiso para usar el micrófono'**
  String get workReportsFilesMicDenied;

  /// No description provided for @workReportsFilesMaxSizeHint.
  ///
  /// In es, this message translates to:
  /// **'Máx. 10 MB por archivo'**
  String get workReportsFilesMaxSizeHint;

  /// No description provided for @workReportsFilesMaxSizeErrorTitle.
  ///
  /// In es, this message translates to:
  /// **'Archivo demasiado grande'**
  String get workReportsFilesMaxSizeErrorTitle;

  /// No description provided for @workReportsFilesMaxSizeErrorMessage.
  ///
  /// In es, this message translates to:
  /// **'El archivo seleccionado supera el límite de 10 MB. Por favor, elige un archivo más pequeño.'**
  String get workReportsFilesMaxSizeErrorMessage;

  /// No description provided for @workReportsAddLinePrice.
  ///
  /// In es, this message translates to:
  /// **'Precio unitario (€)'**
  String get workReportsAddLinePrice;

  /// No description provided for @workReportsAddLinePriceInvalid.
  ///
  /// In es, this message translates to:
  /// **'Introduce un precio válido'**
  String get workReportsAddLinePriceInvalid;

  /// No description provided for @workReportsLinePrice.
  ///
  /// In es, this message translates to:
  /// **'Precio'**
  String get workReportsLinePrice;

  /// No description provided for @workReportsLineAmount.
  ///
  /// In es, this message translates to:
  /// **'Importe'**
  String get workReportsLineAmount;

  /// No description provided for @workReportsLinesTotal.
  ///
  /// In es, this message translates to:
  /// **'Total del parte'**
  String get workReportsLinesTotal;

  /// No description provided for @workReportsLineHours.
  ///
  /// In es, this message translates to:
  /// **'Horas'**
  String get workReportsLineHours;

  /// No description provided for @workReportsAddLineHoursHelper.
  ///
  /// In es, this message translates to:
  /// **'Por horas: se calcula con la duración'**
  String get workReportsAddLineHoursHelper;

  /// No description provided for @workReportsAddLineDurationRequired.
  ///
  /// In es, this message translates to:
  /// **'Indica los minutos'**
  String get workReportsAddLineDurationRequired;

  /// No description provided for @workReportsEditLineTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar línea'**
  String get workReportsEditLineTitle;

  /// No description provided for @workReportsEditLineSuccess.
  ///
  /// In es, this message translates to:
  /// **'Línea actualizada'**
  String get workReportsEditLineSuccess;

  /// No description provided for @workReportsEditLineError.
  ///
  /// In es, this message translates to:
  /// **'No se ha podido actualizar la línea'**
  String get workReportsEditLineError;
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
