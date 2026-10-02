import 'package:shared_preferences/shared_preferences.dart';

import '../../data/local/local_changes_store.dart';
import '../../data/repositories/attendance_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/client_repository.dart';
import '../../data/repositories/holiday_repository.dart';
import '../../data/repositories/messaging_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/visit_report_repository.dart';
import '../../data/repositories/work_report_repository.dart';
import '../network/api_client.dart';
import '../session/session_store.dart';
import '../settings/app_settings.dart';

/// Contenedor de dependencias de la app. Se crea una vez en `main`.
class AppServices {
  final AppSettings settings;
  final SessionStore session;
  final ApiClient api;
  final LocalChangesStore localChanges;
  final AuthRepository auth;
  final UserRepository users;
  final AttendanceRepository attendance;
  final HolidayRepository holidays;
  final MessagingRepository messaging;
  final ClientRepository clients;
  final VisitReportRepository visits;
  final WorkReportRepository workReports;

  AppServices._({
    required this.settings,
    required this.session,
    required this.api,
    required this.localChanges,
    required this.auth,
    required this.users,
    required this.attendance,
    required this.holidays,
    required this.messaging,
    required this.clients,
    required this.visits,
    required this.workReports,
  });

  static Future<AppServices> create() async {
    final prefs = await SharedPreferences.getInstance();
    final session = SessionStore(prefs);
    final api = ApiClient();
    final localChanges = LocalChangesStore(prefs);
    final users = UserRepository(api);

    return AppServices._(
      settings: AppSettings(prefs),
      session: session,
      api: api,
      localChanges: localChanges,
      auth: AuthRepository(api, session),
      users: users,
      attendance: AttendanceRepository(api, localChanges, session, users),
      holidays: HolidayRepository(api, localChanges, session, users),
      messaging: MessagingRepository(api, localChanges, session, users),
      clients: ClientRepository(api, session),
      visits: VisitReportRepository(api, localChanges, session),
      workReports: WorkReportRepository(api, localChanges, session),
    );
  }
}
