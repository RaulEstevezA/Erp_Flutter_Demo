import 'package:shared_preferences/shared_preferences.dart';

import '../../data/local/local_changes_store.dart';
import '../../data/repositories/attendance_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/holiday_repository.dart';
import '../../data/repositories/user_repository.dart';
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

  AppServices._({
    required this.settings,
    required this.session,
    required this.api,
    required this.localChanges,
    required this.auth,
    required this.users,
    required this.attendance,
    required this.holidays,
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
    );
  }
}
