// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Catalan Valencian (`ca`).
class AppLocalizationsCa extends AppLocalizations {
  AppLocalizationsCa([String locale = 'ca']) : super(locale);

  @override
  String get appName => 'ERP Flutter';

  @override
  String get splashTagline => 'Gestió de personal en mobilitat';

  @override
  String get dialogAccept => 'Acceptar';

  @override
  String get dialogCancel => 'Cancel·lar';

  @override
  String get retry => 'Reintentar';

  @override
  String comingSoon(String section) {
    return '$section estarà disponible properament.';
  }

  @override
  String get loginTitle => 'Inici de sessió';

  @override
  String get loginServerUrlLabel => 'URL del servidor';

  @override
  String get loginServerUrlHelper =>
      'Escriu «demo» per fer servir les dades incloses a l\'app';

  @override
  String get loginEmailLabel => 'Correu electrònic';

  @override
  String get loginPasswordLabel => 'Contrasenya';

  @override
  String get loginRememberUrl => 'Recordar URL';

  @override
  String get loginRememberUser => 'Recordar usuari';

  @override
  String get loginSubmit => 'Iniciar sessió';

  @override
  String get loginDemoAccounts => 'Comptes de demostració';

  @override
  String loginDemoAccountsHint(String password) {
    return 'Toca un compte per omplir el formulari. Contrasenya: $password';
  }

  @override
  String get loginErrorEmptyServerUrl =>
      'Has d\'introduir la URL del servidor.';

  @override
  String get loginErrorEmptyEmail =>
      'Has d\'introduir el teu correu electrònic.';

  @override
  String get loginErrorEmptyPassword => 'Has d\'introduir la contrasenya.';

  @override
  String get loginErrorInvalidCredentials =>
      'Les credencials no són correctes.';

  @override
  String get loginErrorAccessDenied =>
      'El teu usuari no té accés a l\'aplicació.';

  @override
  String get loginErrorInvalidUrl => 'La URL del servidor no és vàlida.';

  @override
  String get loginErrorServerNotFound =>
      'No s\'ha trobat cap servidor ERP en aquesta URL.';

  @override
  String get loginErrorNetwork => 'No s\'ha pogut connectar amb el servidor.';

  @override
  String get loginErrorTimeout =>
      'La connexió amb el servidor ha trigat massa.';

  @override
  String get loginErrorServer => 'S\'ha produït un error al servidor.';

  @override
  String get loginErrorUnknown => 'S\'ha produït un error inesperat.';

  @override
  String get roleSuperAdmin => 'Superadministrador';

  @override
  String get roleAdmin => 'Administrador';

  @override
  String get roleUser => 'Usuari';

  @override
  String get roleWorker => 'Treballador';

  @override
  String get roleCustomer => 'Client';

  @override
  String get roleSupplier => 'Proveïdor';

  @override
  String get roleUnknown => 'Sense rol';

  @override
  String get homeTitle => 'Inici';

  @override
  String homeWelcome(String company) {
    return 'Benvingut a $company,';
  }

  @override
  String get homeConnectionError => 'No s\'ha pogut connectar amb el servidor';

  @override
  String get homeConnectionLost => 'S\'ha perdut la connexió amb el servidor';

  @override
  String get clockStartShift => 'Iniciar / Continuar torn';

  @override
  String get clockEndShift => 'Finalitzar / Fer pausa';

  @override
  String get clockConfirmStartTitle => 'Iniciar torn?';

  @override
  String get clockConfirmStartMessage =>
      'Vols iniciar el torn / acabar la pausa?';

  @override
  String get clockConfirmEndTitle => 'Finalitzar torn?';

  @override
  String get clockConfirmEndMessage =>
      'Vols finalitzar el torn / començar una pausa?';

  @override
  String get clockSyncedStarted =>
      'El teu torn ja s\'havia iniciat des d\'un altre dispositiu. Estat actualitzat.';

  @override
  String get clockSyncedEnded =>
      'El teu torn ja s\'havia finalitzat des d\'un altre dispositiu. Estat actualitzat.';

  @override
  String get clockError =>
      'No s\'ha pogut registrar el fitxatge. Torna-ho a provar.';

  @override
  String clockInDone(String time) {
    return 'Entrada registrada a les $time';
  }

  @override
  String clockOutDone(String time) {
    return 'Sortida registrada a les $time';
  }

  @override
  String get menuAttendanceRecords => 'Veure fitxatges';

  @override
  String get menuIncidents => 'Incidències';

  @override
  String get menuWorkReports => 'Parts de treball';

  @override
  String get menuClients => 'Clients';

  @override
  String get menuVisitReports => 'Parts de visita';

  @override
  String get menuHolidays => 'Vacances';

  @override
  String get menuMessages => 'Missatges';

  @override
  String get menuLogout => 'Tancar sessió';

  @override
  String get settingsDarkMode => 'Mode fosc';

  @override
  String get settingsLightMode => 'Mode clar';

  @override
  String drawerVersion(String version) {
    return 'Versió $version';
  }

  @override
  String get clockTypeIn => 'Entrada';

  @override
  String get clockTypeOut => 'Sortida';

  @override
  String get recordsTitle => 'Fitxatges';

  @override
  String get recordsEmpty => 'No hi ha fitxatges en aquest període.';

  @override
  String get recordsLoadError => 'No s\'han pogut carregar els fitxatges.';

  @override
  String get recordsLocation => 'Ubicació (aprox.)';

  @override
  String get groupByEmployee => 'Agrupar per empleat';

  @override
  String get filterByDates => 'Filtrar per dates';

  @override
  String get dateFrom => 'Des de';

  @override
  String get dateTo => 'Fins a';

  @override
  String get applyFilter => 'Aplicar';

  @override
  String get clearFilter => 'Netejar filtre';

  @override
  String get incidentReport => 'Incidència';

  @override
  String get incidentDialogTitle => 'Reportar incidència';

  @override
  String get incidentReason => 'Motiu';

  @override
  String get incidentReasonHint =>
      'Descriu el motiu de la incidència (mín. 5 caràcters)';

  @override
  String get incidentReasonTooShort =>
      'El motiu ha de tenir almenys 5 caràcters.';

  @override
  String get incidentRequestDate => 'Sol·licitar canvi de data (opcional)';

  @override
  String get incidentPickDate => 'Seleccionar data i hora';

  @override
  String get incidentClearDate => 'Eliminar data';

  @override
  String get incidentRequestedType => 'Tipus sol·licitat';

  @override
  String get incidentSubmit => 'Enviar';

  @override
  String get incidentSendError =>
      'No s\'ha pogut enviar la incidència. Torna-ho a provar.';

  @override
  String get incidentSent => 'Incidència enviada correctament.';

  @override
  String get incidentPending => 'Pendent';

  @override
  String get incidentApproved => 'Aprovada';

  @override
  String get incidentRejected => 'Rebutjada';

  @override
  String get incidentsTitle => 'Incidències';

  @override
  String get incidentsEmpty => 'No hi ha incidències en aquest període.';

  @override
  String get incidentsLoadError => 'No s\'han pogut carregar les incidències.';

  @override
  String get incidentDetailTitle => 'Detall de la incidència';

  @override
  String get incidentAffectedRecord => 'Fitxatge afectat';

  @override
  String get incidentRequestedChanges => 'Canvis sol·licitats';

  @override
  String get incidentNoChanges => 'Sense canvis sol·licitats.';

  @override
  String get incidentCreatedAt => 'Creada el';

  @override
  String get incidentWorker => 'Treballador';

  @override
  String get holidaysEmpty => 'No hi ha vacances en aquest període.';

  @override
  String get holidaysLoadError => 'No s\'han pogut carregar les vacances.';

  @override
  String get holidayPending => 'Pendent';

  @override
  String get holidayApproved => 'Aprovades';

  @override
  String get holidayRejected => 'Rebutjades';

  @override
  String get holidaysCalendarView => 'Vista calendari';

  @override
  String get holidaysListView => 'Vista llista';

  @override
  String get groupByPerson => 'Agrupar per persona';

  @override
  String get holidaysRequestTitle => 'Sol·licitar vacances';

  @override
  String get holidaysStart => 'Data d\'inici';

  @override
  String get holidaysEnd => 'Data de fi';

  @override
  String get holidaysPickDate => 'Seleccionar data';

  @override
  String get holidaysReason => 'Motiu (opcional)';

  @override
  String get holidaysReasonHint => 'Motiu de la sol·licitud...';

  @override
  String get holidaysSubmit => 'Sol·licitar';

  @override
  String get holidaysDatesError =>
      'Selecciona les dues dates; la de fi no pot ser anterior a la d\'inici.';

  @override
  String get holidaysRequestSent => 'Sol·licitud enviada correctament.';

  @override
  String get holidaysRequestError =>
      'No s\'ha pogut enviar la sol·licitud. Torna-ho a provar.';

  @override
  String holidaysWorkingDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dies laborables',
      one: '1 dia laborable',
    );
    return '$_temp0';
  }

  @override
  String holidaysNaturalDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count naturals',
      one: '1 natural',
    );
    return '$_temp0';
  }

  @override
  String get holidayDayVacation => 'Vacances';

  @override
  String get holidayDayNational => 'Festiu nacional';

  @override
  String get holidayDayCompany => 'Festiu d\'empresa';

  @override
  String get holidayDayRest => 'Descans setmanal';

  @override
  String get holidaysApprove => 'Aprovar';

  @override
  String get holidaysReject => 'Rebutjar';

  @override
  String get holidaysCancelRequest => 'Cancel·lar sol·licitud';

  @override
  String get holidaysCancelTitle => 'Cancel·lar sol·licitud';

  @override
  String get holidaysCancelMessage =>
      'Segur que vols cancel·lar aquesta sol·licitud de vacances?';

  @override
  String get holidaysCancelNo => 'No';

  @override
  String get holidaysCancelYes => 'Sí, cancel·la';

  @override
  String get holidaysApprovedMessage => 'Vacances aprovades.';

  @override
  String get holidaysRejectedMessage => 'Vacances rebutjades.';

  @override
  String get holidaysCancelledMessage => 'Sol·licitud cancel·lada.';

  @override
  String get holidaysActionError =>
      'No s\'ha pogut completar l\'acció. Torna-ho a provar.';

  @override
  String holidaysSummary(String year, int used, int total) {
    return 'Vacances $year: $used/$total dies';
  }

  @override
  String holidaysSummaryWorker(int count) {
    return 'Treballador: $count dies';
  }

  @override
  String holidaysSummaryCompany(int count) {
    return 'Empresa: $count dies';
  }

  @override
  String get holidayByWorker => 'Sol·licitat pel treballador';

  @override
  String get holidayByCompany => 'Assignat per l\'empresa';

  @override
  String holidaysOnDay(String date) {
    return 'Vacances el $date';
  }

  @override
  String get messagesNew => 'Nou missatge';

  @override
  String get messagesList => 'Missatges';

  @override
  String get messagesRecipientSearch => 'Cercar destinatari...';

  @override
  String get messagesRecipientRequired => 'Selecciona un destinatari';

  @override
  String get messagesNoRecipients => 'No hi ha destinataris disponibles';

  @override
  String get messagesBody => 'Missatge';

  @override
  String get messagesBodyHint => 'Escriu el teu missatge...';

  @override
  String get messagesBodyRequired => 'El missatge no pot estar buit';

  @override
  String get messagesSend => 'Enviar';

  @override
  String get messagesSent => 'Missatge enviat';

  @override
  String get messagesSendError =>
      'No s\'ha pogut enviar el missatge. Torna-ho a provar.';

  @override
  String get messagesEmpty => 'Encara no tens converses';

  @override
  String get messagesLoadError => 'No s\'han pogut carregar els missatges';

  @override
  String get messagesTypeHint => 'Escriu un missatge...';

  @override
  String get messagesChatEmpty =>
      'Encara no hi ha missatges en aquesta conversa';

  @override
  String get messagesYou => 'Tu: ';

  @override
  String get clientsSearchHint => 'Cerca nom, NIF o població…';

  @override
  String get clientsEmpty => 'No hi ha clients';

  @override
  String get clientsErrorLoad => 'No s\'han pogut carregar els clients';

  @override
  String get clientsLabelResponsible => 'Responsable';

  @override
  String get clientsLabelPaymentCondition => 'Condició de pagament';

  @override
  String get clientsLabelPaymentMethod => 'Forma de pagament';

  @override
  String get clientsLabelRemarks => 'Observacions';

  @override
  String get clientsNoRemarks => 'Sense observacions';

  @override
  String get clientsLabelAddresses => 'Adreces';

  @override
  String get clientsNoAddresses => 'Sense adreces';

  @override
  String get clientsLabelContacts => 'Contactes';

  @override
  String get clientsNoContacts => 'Sense contactes';

  @override
  String get clientsLabelBilling => 'Facturació';

  @override
  String get clientsLabelDelivering => 'Lliurament';

  @override
  String get clientsButtonWorks => 'Treballs';

  @override
  String get clientsButtonBudgets => 'Pressupostos';

  @override
  String get clientsButtonOrders => 'Comandes';

  @override
  String get clientsButtonDeliveryNotes => 'Albarans';

  @override
  String get clientsButtonInvoices => 'Factures';

  @override
  String get clientsButtonRecurrentInvoices => 'Fact. recurrents';

  @override
  String get clientsLabelPaymentData => 'Dades de pagament';

  @override
  String get clientsLabelActive => 'Client actiu';

  @override
  String get clientsLabelInactive => 'Client inactiu';

  @override
  String get clientsDocumentsEmpty => 'Sense documents';

  @override
  String get clientsDocumentsErrorLoad =>
      'No s\'han pogut carregar els documents';

  @override
  String get clientsDocumentsSearchHint => 'Cerca document...';

  @override
  String get clientsDocDetailErrorLoad => 'No s\'ha pogut carregar el document';

  @override
  String get clientsDocDetailLines => 'Línies';

  @override
  String get clientsDocDetailNoLines => 'Sense línies';

  @override
  String get clientsDocDetailBase => 'Base imposable';

  @override
  String get clientsDocDetailTax => 'IVA';

  @override
  String get clientsDocDetailTotal => 'Total';

  @override
  String get clientsDocDetailRemarks => 'Observacions';

  @override
  String get visitReportsSearchHint => 'Cerca empresa...';

  @override
  String get visitReportsVisitSearchHint => 'Cerca visita...';

  @override
  String get visitReportsEmpty => 'No hi ha visites per a aquest client';

  @override
  String get visitReportsErrorLoad => 'No s\'han pogut carregar les visites';

  @override
  String get visitReportsMonthView => 'Veure per mesos';

  @override
  String get visitReportsNewButton => 'Nova visita';

  @override
  String get visitReportsLabelWorker => 'Tècnic';

  @override
  String get visitReportsWorkersSearchHint => 'Cerca tècnic...';

  @override
  String get visitReportsLabelDescription => 'Descripció';

  @override
  String get visitReportsNoDescription => 'Sense descripció';

  @override
  String get visitReportsLabelTravelDistance => 'Distància recorreguda';

  @override
  String get visitReportsLabelTravelTime => 'Temps de desplaçament';

  @override
  String get visitReportsCreateNameLabel => 'Nom de la visita';

  @override
  String get visitReportsCreateNameHint => 'Ex. Reunió de seguiment...';

  @override
  String get visitReportsCreateDateLabel => 'Data';

  @override
  String get visitReportsCreateTimeLabel => 'Hora';

  @override
  String get visitReportsCreateDurationLabel => 'Durada (min)';

  @override
  String get visitReportsCreateTravelDistanceLabel => 'Distància (km)';

  @override
  String get visitReportsCreateTravelTimeLabel => 'Temps desplaçament (min)';

  @override
  String get visitReportsCreateDescriptionLabel => 'Descripció';

  @override
  String get visitReportsCreateDescriptionHint => 'Descriu la visita...';

  @override
  String get visitReportsCreateRequired => 'Camp obligatori';

  @override
  String get visitReportsCreateSave => 'Desa';

  @override
  String get visitReportsCreateSuccess => 'Visita creada correctament';

  @override
  String get visitReportsCreateError => 'No s\'ha pogut crear la visita';

  @override
  String get workReportsEmpty => 'No hi ha parts de treball';

  @override
  String get workReportsSearchHint => 'Cerca part...';

  @override
  String get workReportsGroupByCompany => 'Agrupa per empresa';

  @override
  String get workReportsErrorLoad =>
      'No s\'han pogut carregar els parts de treball';

  @override
  String get workReportsFilterActive => 'Actius';

  @override
  String get workReportsFilterFinished => 'Finalitzats';

  @override
  String get workReportsStatusAssigned => 'Assignat';

  @override
  String get workReportsStatusInProgress => 'En curs';

  @override
  String get workReportsStatusPartiallyFinished => 'Parcialment finalitzat';

  @override
  String get workReportsStatusFinished => 'Finalitzat';

  @override
  String get workReportsStatusNotified => 'Notificat';

  @override
  String get workReportsStatusDeliveryNote => 'Albarà generat';

  @override
  String get workReportsStatusInvoiced => 'Facturat';

  @override
  String get workReportsStatusRejected => 'Rebutjat';

  @override
  String get workReportsLabelDescription => 'Descripció';

  @override
  String get workReportsNoDescription => 'Sense descripció';

  @override
  String get workReportsLabelRemarks => 'Observacions';

  @override
  String get workReportsNoRemarks => 'Sense observacions';

  @override
  String get workReportsLabelLines => 'Línies de treball';

  @override
  String get workReportsNoLines => 'Sense línies de treball';

  @override
  String get workReportsLineUnits => 'Uts.';

  @override
  String get workReportsLineDuration => 'Durada';

  @override
  String get workReportsAddLineTitle => 'Afegeix línia';

  @override
  String get workReportsAddLineProduct => 'Producte (opcional)';

  @override
  String get workReportsAddLineProductHint => 'Cerca producte...';

  @override
  String get workReportsAddLineConcept => 'Concepte';

  @override
  String get workReportsAddLineConceptHint => 'Descripció de la tasca';

  @override
  String get workReportsAddLineConceptRequired => 'El concepte és obligatori';

  @override
  String get workReportsAddLineUnits => 'Unitats';

  @override
  String get workReportsAddLineUnitsInvalid =>
      'Introdueix un número vàlid més gran que 0';

  @override
  String get workReportsAddLineDuration => 'Durada (min)';

  @override
  String get workReportsAddLineSuccess => 'Línia afegida correctament';

  @override
  String get workReportsAddLineError => 'No s\'ha pogut afegir la línia';

  @override
  String get workReportsLabelWorkers => 'Treballadors assignats';

  @override
  String get workReportsNoWorkers => 'Sense treballadors assignats';

  @override
  String get workReportsButtonFiles => 'Fitxers';

  @override
  String get workReportsButtonSignature => 'Signatura';

  @override
  String get workReportsButtonViewSignature => 'Veure signatura';

  @override
  String get workReportsSignatureTitle => 'Signatura del client';

  @override
  String get workReportsSignatureSave => 'Desa la signatura';

  @override
  String get workReportsSignatureClear => 'Esborra';

  @override
  String get workReportsSignatureHint => 'Signa aquí';

  @override
  String get workReportsSignatureEmpty => 'Dibuixa la signatura abans de desar';

  @override
  String get workReportsSignatureSuccess => 'Signatura desada correctament';

  @override
  String get workReportsSignatureError => 'No s\'ha pogut desar la signatura';

  @override
  String get workReportsViewSignatureTitle => 'Signatura desada';

  @override
  String get workReportsButtonResign => 'Torna a signar';
}

/// The translations for Catalan Valencian, as used in Spain (`ca_ES`).
class AppLocalizationsCaEs extends AppLocalizationsCa {
  AppLocalizationsCaEs() : super('ca_ES');

  @override
  String get loginServerUrlHelper =>
      'Escriu «demo» per a usar les dades incloses en l\'app';

  @override
  String loginDemoAccountsHint(String password) {
    return 'Toca un compte per a omplir el formulari. Contrasenya: $password';
  }

  @override
  String get clockError =>
      'No s\'ha pogut registrar el fitxatge. Torna a intentar-ho.';

  @override
  String clockOutDone(String time) {
    return 'Eixida registrada a les $time';
  }

  @override
  String get menuAttendanceRecords => 'Vore fitxatges';

  @override
  String get menuHolidays => 'Vacacions';

  @override
  String get clockTypeOut => 'Eixida';

  @override
  String get recordsEmpty => 'No hi ha fitxatges en este període.';

  @override
  String get incidentSendError =>
      'No s\'ha pogut enviar la incidència. Torna a intentar-ho.';

  @override
  String get incidentsEmpty => 'No hi ha incidències en este període.';

  @override
  String get holidaysEmpty => 'No hi ha vacacions en este període.';

  @override
  String get holidaysLoadError => 'No s\'han pogut carregar les vacacions.';

  @override
  String get holidaysRequestTitle => 'Sol·licitar vacacions';

  @override
  String get holidaysRequestError =>
      'No s\'ha pogut enviar la sol·licitud. Torna a intentar-ho.';

  @override
  String get holidayDayVacation => 'Vacacions';

  @override
  String get holidaysCancelMessage =>
      'Segur que vols cancel·lar esta sol·licitud de vacacions?';

  @override
  String get holidaysApprovedMessage => 'Vacacions aprovades.';

  @override
  String get holidaysRejectedMessage => 'Vacacions rebutjades.';

  @override
  String get holidaysActionError =>
      'No s\'ha pogut completar l\'acció. Torna a intentar-ho.';

  @override
  String holidaysSummary(String year, int used, int total) {
    return 'Vacacions $year: $used/$total dies';
  }

  @override
  String holidaysOnDay(String date) {
    return 'Vacacions el $date';
  }

  @override
  String get messagesRecipientSearch => 'Buscar destinatari...';

  @override
  String get messagesSendError =>
      'No s\'ha pogut enviar el missatge. Torna a intentar-ho.';

  @override
  String get messagesChatEmpty => 'Encara no hi ha missatges en esta conversa';

  @override
  String get clientsSearchHint => 'Busca nom, NIF o població…';

  @override
  String get clientsLabelDelivering => 'Entrega';

  @override
  String get clientsButtonOrders => 'Comandes';

  @override
  String get clientsDocumentsSearchHint => 'Busca document...';

  @override
  String get visitReportsSearchHint => 'Busca empresa...';

  @override
  String get visitReportsVisitSearchHint => 'Busca visita...';

  @override
  String get visitReportsEmpty => 'No hi ha visites per a este client';

  @override
  String get visitReportsWorkersSearchHint => 'Busca tècnic...';

  @override
  String get visitReportsCreateSave => 'Guarda';

  @override
  String get workReportsSearchHint => 'Busca part...';

  @override
  String get workReportsAddLineTitle => 'Afig línia';

  @override
  String get workReportsAddLineProductHint => 'Busca producte...';

  @override
  String get workReportsAddLineUnitsInvalid =>
      'Introduïx un número vàlid major que 0';

  @override
  String get workReportsButtonSignature => 'Firma';

  @override
  String get workReportsButtonViewSignature => 'Vore firma';

  @override
  String get workReportsSignatureTitle => 'Firma del client';

  @override
  String get workReportsSignatureSave => 'Guarda la firma';

  @override
  String get workReportsSignatureClear => 'Esborra';

  @override
  String get workReportsSignatureHint => 'Firma ací';

  @override
  String get workReportsSignatureEmpty => 'Dibuixa la firma abans de guardar';

  @override
  String get workReportsSignatureSuccess => 'Firma guardada correctament';

  @override
  String get workReportsSignatureError => 'No s\'ha pogut guardar la firma';

  @override
  String get workReportsViewSignatureTitle => 'Firma guardada';

  @override
  String get workReportsButtonResign => 'Torna a firmar';
}
