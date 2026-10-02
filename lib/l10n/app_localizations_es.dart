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

  @override
  String get messagesNew => 'Nuevo mensaje';

  @override
  String get messagesList => 'Mensajes';

  @override
  String get messagesRecipientSearch => 'Buscar destinatario...';

  @override
  String get messagesRecipientRequired => 'Selecciona un destinatario';

  @override
  String get messagesNoRecipients => 'No hay destinatarios disponibles';

  @override
  String get messagesBody => 'Mensaje';

  @override
  String get messagesBodyHint => 'Escribe tu mensaje...';

  @override
  String get messagesBodyRequired => 'El mensaje no puede estar vacío';

  @override
  String get messagesSend => 'Enviar';

  @override
  String get messagesSent => 'Mensaje enviado';

  @override
  String get messagesSendError =>
      'No se ha podido enviar el mensaje. Inténtalo de nuevo.';

  @override
  String get messagesEmpty => 'No tienes conversaciones todavía';

  @override
  String get messagesLoadError => 'No se han podido cargar los mensajes';

  @override
  String get messagesTypeHint => 'Escribe un mensaje...';

  @override
  String get messagesChatEmpty =>
      'Todavía no hay mensajes en esta conversación';

  @override
  String get messagesYou => 'Tú: ';

  @override
  String get clientsSearchHint => 'Buscar nombre, CIF o población…';

  @override
  String get clientsEmpty => 'No hay clientes';

  @override
  String get clientsErrorLoad => 'No se han podido cargar los clientes';

  @override
  String get clientsLabelResponsible => 'Responsable';

  @override
  String get clientsLabelPaymentCondition => 'Condición de pago';

  @override
  String get clientsLabelPaymentMethod => 'Forma de pago';

  @override
  String get clientsLabelRemarks => 'Observaciones';

  @override
  String get clientsNoRemarks => 'Sin observaciones';

  @override
  String get clientsLabelAddresses => 'Direcciones';

  @override
  String get clientsNoAddresses => 'Sin direcciones';

  @override
  String get clientsLabelContacts => 'Contactos';

  @override
  String get clientsNoContacts => 'Sin contactos';

  @override
  String get clientsLabelBilling => 'Facturación';

  @override
  String get clientsLabelDelivering => 'Entrega';

  @override
  String get clientsButtonWorks => 'Trabajos';

  @override
  String get clientsButtonBudgets => 'Presupuestos';

  @override
  String get clientsButtonOrders => 'Pedidos';

  @override
  String get clientsButtonDeliveryNotes => 'Albaranes';

  @override
  String get clientsButtonInvoices => 'Facturas';

  @override
  String get clientsButtonRecurrentInvoices => 'Fact. recurrentes';

  @override
  String get clientsLabelPaymentData => 'Datos de pago';

  @override
  String get clientsLabelActive => 'Cliente activo';

  @override
  String get clientsLabelInactive => 'Cliente inactivo';

  @override
  String get clientsDocumentsEmpty => 'Sin documentos';

  @override
  String get clientsDocumentsErrorLoad =>
      'No se han podido cargar los documentos';

  @override
  String get clientsDocumentsSearchHint => 'Buscar documento...';

  @override
  String get clientsDocDetailErrorLoad => 'No se ha podido cargar el documento';

  @override
  String get clientsDocDetailLines => 'Líneas';

  @override
  String get clientsDocDetailNoLines => 'Sin líneas';

  @override
  String get clientsDocDetailBase => 'Base imponible';

  @override
  String get clientsDocDetailTax => 'IVA';

  @override
  String get clientsDocDetailTotal => 'Total';

  @override
  String get clientsDocDetailRemarks => 'Observaciones';

  @override
  String get visitReportsSearchHint => 'Buscar empresa...';

  @override
  String get visitReportsVisitSearchHint => 'Buscar visita...';

  @override
  String get visitReportsEmpty => 'No hay visitas para este cliente';

  @override
  String get visitReportsErrorLoad => 'No se han podido cargar las visitas';

  @override
  String get visitReportsMonthView => 'Ver por meses';

  @override
  String get visitReportsNewButton => 'Nueva visita';

  @override
  String get visitReportsLabelWorker => 'Técnico';

  @override
  String get visitReportsWorkersSearchHint => 'Buscar técnico...';

  @override
  String get visitReportsLabelDescription => 'Descripción';

  @override
  String get visitReportsNoDescription => 'Sin descripción';

  @override
  String get visitReportsLabelTravelDistance => 'Distancia recorrida';

  @override
  String get visitReportsLabelTravelTime => 'Tiempo de desplazamiento';

  @override
  String get visitReportsCreateNameLabel => 'Nombre de la visita';

  @override
  String get visitReportsCreateNameHint => 'Ej. Reunión de seguimiento...';

  @override
  String get visitReportsCreateDateLabel => 'Fecha';

  @override
  String get visitReportsCreateTimeLabel => 'Hora';

  @override
  String get visitReportsCreateDurationLabel => 'Duración (min)';

  @override
  String get visitReportsCreateTravelDistanceLabel => 'Distancia (km)';

  @override
  String get visitReportsCreateTravelTimeLabel => 'Tiempo desplazamiento (min)';

  @override
  String get visitReportsCreateDescriptionLabel => 'Descripción';

  @override
  String get visitReportsCreateDescriptionHint => 'Describe la visita...';

  @override
  String get visitReportsCreateRequired => 'Campo obligatorio';

  @override
  String get visitReportsCreateSave => 'Guardar';

  @override
  String get visitReportsCreateSuccess => 'Visita creada correctamente';

  @override
  String get visitReportsCreateError => 'No se ha podido crear la visita';

  @override
  String get workReportsEmpty => 'No hay partes de trabajo';

  @override
  String get workReportsSearchHint => 'Buscar parte...';

  @override
  String get workReportsGroupByCompany => 'Agrupar por empresa';

  @override
  String get workReportsErrorLoad =>
      'No se han podido cargar los partes de trabajo';

  @override
  String get workReportsFilterActive => 'Activos';

  @override
  String get workReportsFilterFinished => 'Finalizados';

  @override
  String get workReportsStatusAssigned => 'Asignado';

  @override
  String get workReportsStatusInProgress => 'En progreso';

  @override
  String get workReportsStatusPartiallyFinished => 'Parcialmente finalizado';

  @override
  String get workReportsStatusFinished => 'Finalizado';

  @override
  String get workReportsStatusNotified => 'Notificado';

  @override
  String get workReportsStatusDeliveryNote => 'Albarán generado';

  @override
  String get workReportsStatusInvoiced => 'Facturado';

  @override
  String get workReportsStatusRejected => 'Rechazado';

  @override
  String get workReportsLabelDescription => 'Descripción';

  @override
  String get workReportsNoDescription => 'Sin descripción';

  @override
  String get workReportsLabelRemarks => 'Observaciones';

  @override
  String get workReportsNoRemarks => 'Sin observaciones';

  @override
  String get workReportsLabelLines => 'Líneas de trabajo';

  @override
  String get workReportsNoLines => 'Sin líneas de trabajo';

  @override
  String get workReportsLineUnits => 'Uds.';

  @override
  String get workReportsLineDuration => 'Duración';

  @override
  String get workReportsAddLineTitle => 'Añadir línea';

  @override
  String get workReportsAddLineProduct => 'Producto (opcional)';

  @override
  String get workReportsAddLineProductHint => 'Buscar producto...';

  @override
  String get workReportsAddLineConcept => 'Concepto';

  @override
  String get workReportsAddLineConceptHint => 'Descripción de la tarea';

  @override
  String get workReportsAddLineConceptRequired => 'El concepto es obligatorio';

  @override
  String get workReportsAddLineUnits => 'Unidades';

  @override
  String get workReportsAddLineUnitsInvalid =>
      'Introduce un número válido mayor que 0';

  @override
  String get workReportsAddLineDuration => 'Duración (min)';

  @override
  String get workReportsAddLineSuccess => 'Línea añadida correctamente';

  @override
  String get workReportsAddLineError => 'No se ha podido añadir la línea';

  @override
  String get workReportsLabelWorkers => 'Trabajadores asignados';

  @override
  String get workReportsNoWorkers => 'Sin trabajadores asignados';

  @override
  String get workReportsButtonFiles => 'Archivos';

  @override
  String get workReportsButtonSignature => 'Firma';

  @override
  String get workReportsButtonViewSignature => 'Ver firma';

  @override
  String get workReportsSignatureTitle => 'Firma del cliente';

  @override
  String get workReportsSignatureSave => 'Guardar firma';

  @override
  String get workReportsSignatureClear => 'Borrar';

  @override
  String get workReportsSignatureHint => 'Firma aquí';

  @override
  String get workReportsSignatureEmpty => 'Dibuja la firma antes de guardar';

  @override
  String get workReportsSignatureSuccess => 'Firma guardada correctamente';

  @override
  String get workReportsSignatureError => 'No se ha podido guardar la firma';

  @override
  String get workReportsViewSignatureTitle => 'Firma guardada';

  @override
  String get workReportsButtonResign => 'Volver a firmar';

  @override
  String get workReportsFilesEmpty => 'No hay archivos adjuntos';

  @override
  String get workReportsFilesErrorLoad =>
      'No se han podido cargar los archivos';

  @override
  String get workReportsFilesCamera => 'Cámara';

  @override
  String get workReportsFilesGallery => 'Galería';

  @override
  String get workReportsFilesRecordAudio => 'Grabar audio';

  @override
  String get workReportsFilesStopRecord => 'Parar';

  @override
  String get workReportsFilesRecording => 'Grabando...';

  @override
  String get workReportsFilesSaving => 'Guardando...';

  @override
  String get workReportsFilesDelete => 'Eliminar';

  @override
  String get workReportsFilesDeleteConfirmTitle => 'Eliminar archivo';

  @override
  String get workReportsFilesDeleteConfirmMessage =>
      '¿Seguro que quieres eliminar este archivo?';

  @override
  String get workReportsFilesUploadError => 'No se ha podido subir el archivo';

  @override
  String get workReportsFilesDeleteError =>
      'No se ha podido eliminar el archivo';

  @override
  String get workReportsFilesMicDenied => 'Sin permiso para usar el micrófono';

  @override
  String get workReportsFilesMaxSizeHint => 'Máx. 10 MB por archivo';

  @override
  String get workReportsFilesMaxSizeErrorTitle => 'Archivo demasiado grande';

  @override
  String get workReportsFilesMaxSizeErrorMessage =>
      'El archivo seleccionado supera el límite de 10 MB. Por favor, elige un archivo más pequeño.';

  @override
  String get workReportsAddLinePrice => 'Precio unitario (€)';

  @override
  String get workReportsAddLinePriceInvalid => 'Introduce un precio válido';

  @override
  String get workReportsLinePrice => 'Precio';

  @override
  String get workReportsLineAmount => 'Importe';

  @override
  String get workReportsLinesTotal => 'Total del parte';

  @override
  String get workReportsLineHours => 'Horas';

  @override
  String get workReportsAddLineHoursHelper =>
      'Por horas: se calcula con la duración';

  @override
  String get workReportsAddLineDurationRequired => 'Indica los minutos';

  @override
  String get workReportsEditLineTitle => 'Editar línea';

  @override
  String get workReportsEditLineSuccess => 'Línea actualizada';

  @override
  String get workReportsEditLineError => 'No se ha podido actualizar la línea';

  @override
  String get menuResetDemo => 'Restablecer datos de la demo';

  @override
  String get resetDemoTitle => 'Restablecer datos';

  @override
  String get resetDemoMessage =>
      'Se borrarán los fichajes, líneas, firmas, archivos, visitas y mensajes que hayas añadido en este dispositivo y la demo volverá a su estado inicial.';

  @override
  String get resetDemoConfirm => 'Restablecer';

  @override
  String get resetDemoDone => 'Datos de la demo restablecidos';
}
