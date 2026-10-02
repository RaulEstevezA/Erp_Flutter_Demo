// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'ERP Flutter';

  @override
  String get splashTagline => 'Gestión de personal en movilidad';

  @override
  String get dialogAccept => 'Aceptar';

  @override
  String get dialogCancel => 'Cancelar';

  @override
  String get retry => 'Reintentar';

  @override
  String comingSoon(String section) {
    return '$section estará disponible próximamente.';
  }

  @override
  String get loginTitle => 'Inicio de sesión';

  @override
  String get loginServerUrlLabel => 'URL del servidor';

  @override
  String get loginServerUrlHelper =>
      'Escribe «demo» para usar los datos incluidos en la app';

  @override
  String get loginEmailLabel => 'Correo electrónico';

  @override
  String get loginPasswordLabel => 'Contraseña';

  @override
  String get loginRememberUrl => 'Recordar URL';

  @override
  String get loginRememberUser => 'Recordar usuario';

  @override
  String get loginSubmit => 'Iniciar sesión';

  @override
  String get loginDemoAccounts => 'Cuentas de demostración';

  @override
  String loginDemoAccountsHint(String password) {
    return 'Toca una cuenta para rellenar el formulario. Contraseña: $password';
  }

  @override
  String get loginErrorEmptyServerUrl =>
      'Debes introducir la URL del servidor.';

  @override
  String get loginErrorEmptyEmail => 'Debes introducir tu correo electrónico.';

  @override
  String get loginErrorEmptyPassword => 'Debes introducir la contraseña.';

  @override
  String get loginErrorInvalidCredentials =>
      'Las credenciales no son correctas.';

  @override
  String get loginErrorAccessDenied =>
      'Tu usuario no tiene acceso a la aplicación.';

  @override
  String get loginErrorInvalidUrl => 'La URL del servidor no es válida.';

  @override
  String get loginErrorServerNotFound =>
      'No se ha encontrado un servidor ERP en esa URL.';

  @override
  String get loginErrorNetwork => 'No se ha podido conectar con el servidor.';

  @override
  String get loginErrorTimeout =>
      'La conexión con el servidor ha tardado demasiado.';

  @override
  String get loginErrorServer => 'Se ha producido un error en el servidor.';

  @override
  String get loginErrorUnknown => 'Se ha producido un error inesperado.';

  @override
  String get roleSuperAdmin => 'Superadministrador';

  @override
  String get roleAdmin => 'Administrador';

  @override
  String get roleUser => 'Usuario';

  @override
  String get roleWorker => 'Trabajador';

  @override
  String get roleCustomer => 'Cliente';

  @override
  String get roleSupplier => 'Proveedor';

  @override
  String get roleUnknown => 'Sin rol';

  @override
  String get homeTitle => 'Inicio';

  @override
  String homeWelcome(String company) {
    return 'Bienvenido a $company,';
  }

  @override
  String get homeConnectionError => 'No se ha podido conectar con el servidor';

  @override
  String get homeConnectionLost => 'Se ha perdido la conexión con el servidor';

  @override
  String get clockStartShift => 'Iniciar / Continuar turno';

  @override
  String get clockEndShift => 'Finalizar / Hacer pausa';

  @override
  String get clockConfirmStartTitle => '¿Iniciar turno?';

  @override
  String get clockConfirmStartMessage =>
      '¿Quieres iniciar turno / terminar pausa?';

  @override
  String get clockConfirmEndTitle => '¿Finalizar turno?';

  @override
  String get clockConfirmEndMessage =>
      '¿Quieres finalizar turno / empezar pausa?';

  @override
  String get clockSyncedStarted =>
      'Tu turno ya había sido iniciado desde otro dispositivo. Estado actualizado.';

  @override
  String get clockSyncedEnded =>
      'Tu turno ya había sido finalizado desde otro dispositivo. Estado actualizado.';

  @override
  String get clockError =>
      'No se ha podido registrar el fichaje. Inténtalo de nuevo.';

  @override
  String clockInDone(String time) {
    return 'Entrada registrada a las $time';
  }

  @override
  String clockOutDone(String time) {
    return 'Salida registrada a las $time';
  }

  @override
  String get menuAttendanceRecords => 'Ver fichajes';

  @override
  String get menuIncidents => 'Incidencias';

  @override
  String get menuWorkReports => 'Partes de trabajo';

  @override
  String get menuClients => 'Clientes';

  @override
  String get menuVisitReports => 'Partes de visita';

  @override
  String get menuHolidays => 'Vacaciones';

  @override
  String get menuMessages => 'Mensajes';

  @override
  String get menuLogout => 'Cerrar sesión';

  @override
  String get settingsDarkMode => 'Modo oscuro';

  @override
  String get settingsLightMode => 'Modo claro';

  @override
  String drawerVersion(String version) {
    return 'Versión $version';
  }

  @override
  String get clockTypeIn => 'Entrada';

  @override
  String get clockTypeOut => 'Salida';

  @override
  String get recordsTitle => 'Fichajes';

  @override
  String get recordsEmpty => 'No hay fichajes en este período.';

  @override
  String get recordsLoadError => 'No se han podido cargar los fichajes.';

  @override
  String get recordsLocation => 'Ubicación (aprox.)';

  @override
  String get groupByEmployee => 'Agrupar por empleado';

  @override
  String get filterByDates => 'Filtrar por fechas';

  @override
  String get dateFrom => 'Desde';

  @override
  String get dateTo => 'Hasta';

  @override
  String get applyFilter => 'Aplicar';

  @override
  String get clearFilter => 'Limpiar filtro';

  @override
  String get incidentReport => 'Incidencia';

  @override
  String get incidentDialogTitle => 'Reportar incidencia';

  @override
  String get incidentReason => 'Motivo';

  @override
  String get incidentReasonHint =>
      'Describe el motivo de la incidencia (mín. 5 caracteres)';

  @override
  String get incidentReasonTooShort =>
      'El motivo debe tener al menos 5 caracteres.';

  @override
  String get incidentRequestDate => 'Solicitar cambio de fecha (opcional)';

  @override
  String get incidentPickDate => 'Seleccionar fecha y hora';

  @override
  String get incidentClearDate => 'Eliminar fecha';

  @override
  String get incidentRequestedType => 'Tipo solicitado';

  @override
  String get incidentSubmit => 'Enviar';

  @override
  String get incidentSendError =>
      'No se ha podido enviar la incidencia. Inténtalo de nuevo.';

  @override
  String get incidentSent => 'Incidencia enviada correctamente.';

  @override
  String get incidentPending => 'Pendiente';

  @override
  String get incidentApproved => 'Aprobada';

  @override
  String get incidentRejected => 'Rechazada';

  @override
  String get incidentsTitle => 'Incidencias';

  @override
  String get incidentsEmpty => 'No hay incidencias en este período.';

  @override
  String get incidentsLoadError => 'No se han podido cargar las incidencias.';

  @override
  String get incidentDetailTitle => 'Detalle de incidencia';

  @override
  String get incidentAffectedRecord => 'Fichaje afectado';

  @override
  String get incidentRequestedChanges => 'Cambios solicitados';

  @override
  String get incidentNoChanges => 'Sin cambios solicitados.';

  @override
  String get incidentCreatedAt => 'Creada el';

  @override
  String get incidentWorker => 'Trabajador';

  @override
  String get holidaysEmpty => 'No hay vacaciones en este período.';

  @override
  String get holidaysLoadError => 'No se han podido cargar las vacaciones.';

  @override
  String get holidayPending => 'Pendiente';

  @override
  String get holidayApproved => 'Aprobadas';

  @override
  String get holidayRejected => 'Rechazadas';

  @override
  String get holidaysCalendarView => 'Vista calendario';

  @override
  String get holidaysListView => 'Vista lista';

  @override
  String get groupByPerson => 'Agrupar por persona';

  @override
  String get holidaysRequestTitle => 'Solicitar vacaciones';

  @override
  String get holidaysStart => 'Fecha de inicio';

  @override
  String get holidaysEnd => 'Fecha de fin';

  @override
  String get holidaysPickDate => 'Seleccionar fecha';

  @override
  String get holidaysReason => 'Motivo (opcional)';

  @override
  String get holidaysReasonHint => 'Motivo de la solicitud...';

  @override
  String get holidaysSubmit => 'Solicitar';

  @override
  String get holidaysDatesError =>
      'Selecciona las dos fechas; la de fin no puede ser anterior a la de inicio.';

  @override
  String get holidaysRequestSent => 'Solicitud enviada correctamente.';

  @override
  String get holidaysRequestError =>
      'No se ha podido enviar la solicitud. Inténtalo de nuevo.';

  @override
  String holidaysWorkingDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días laborables',
      one: '1 día laborable',
    );
    return '$_temp0';
  }

  @override
  String holidaysNaturalDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count naturales',
      one: '1 natural',
    );
    return '$_temp0';
  }

  @override
  String get holidayDayVacation => 'Vacaciones';

  @override
  String get holidayDayNational => 'Festivo nacional';

  @override
  String get holidayDayCompany => 'Festivo de empresa';

  @override
  String get holidayDayRest => 'Descanso semanal';

  @override
  String get holidaysApprove => 'Aprobar';

  @override
  String get holidaysReject => 'Rechazar';

  @override
  String get holidaysCancelRequest => 'Cancelar solicitud';

  @override
  String get holidaysCancelTitle => 'Cancelar solicitud';

  @override
  String get holidaysCancelMessage =>
      '¿Seguro que quieres cancelar esta solicitud de vacaciones?';

  @override
  String get holidaysCancelNo => 'No';

  @override
  String get holidaysCancelYes => 'Sí, cancelar';

  @override
  String get holidaysApprovedMessage => 'Vacaciones aprobadas.';

  @override
  String get holidaysRejectedMessage => 'Vacaciones rechazadas.';

  @override
  String get holidaysCancelledMessage => 'Solicitud cancelada.';

  @override
  String get holidaysActionError =>
      'No se ha podido completar la acción. Inténtalo de nuevo.';

  @override
  String holidaysSummary(String year, int used, int total) {
    return 'Vacaciones $year: $used/$total días';
  }

  @override
  String holidaysSummaryWorker(int count) {
    return 'Trabajador: $count días';
  }

  @override
  String holidaysSummaryCompany(int count) {
    return 'Empresa: $count días';
  }

  @override
  String get holidayByWorker => 'Solicitado por trabajador';

  @override
  String get holidayByCompany => 'Asignado por empresa';

  @override
  String holidaysOnDay(String date) {
    return 'Vacaciones el $date';
  }
}
