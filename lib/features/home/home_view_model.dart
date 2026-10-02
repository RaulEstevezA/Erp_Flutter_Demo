import 'package:flutter/foundation.dart';

import '../../data/repositories/attendance_repository.dart';

/// Resultado de pulsar el botón de fichaje.
enum ClockOutcome {
  clockedIn,
  clockedOut,

  /// El servidor ya tenía el estado que se quería conseguir (se fichó desde
  /// otro dispositivo): solo se sincroniza la UI.
  syncedAlreadyWorking,
  syncedAlreadyStopped,
  failed,
}

class HomeViewModel extends ChangeNotifier {
  final AttendanceRepository _attendance;

  HomeViewModel(this._attendance);

  bool isLoadingStatus = false;
  bool isWorking = false;
  bool isClocking = false;

  /// No se pudo consultar el estado de fichaje: la app considera que no hay
  /// conexión y bloquea el resto de secciones hasta reintentar.
  bool hasConnectionError = false;

  Future<void> loadStatus() async {
    isLoadingStatus = true;
    hasConnectionError = false;
    notifyListeners();
    try {
      isWorking = await _attendance.isCurrentlyWorking();
    } catch (e) {
      debugPrint('HomeViewModel → sin estado de fichaje: $e');
      hasConnectionError = true;
    }
    isLoadingStatus = false;
    notifyListeners();
  }

  /// Ficha entrada o salida según el estado actual.
  ///
  /// Antes de fichar vuelve a preguntar al servidor: si el estado real ya no
  /// coincide con el de la pantalla, sincroniza en lugar de duplicar fichaje.
  Future<ClockOutcome> toggleClock() async {
    if (isClocking) return ClockOutcome.failed;
    isClocking = true;
    notifyListeners();

    try {
      final serverWorking = await _attendance.isCurrentlyWorking();
      if (serverWorking != isWorking) {
        isWorking = serverWorking;
        return serverWorking
            ? ClockOutcome.syncedAlreadyWorking
            : ClockOutcome.syncedAlreadyStopped;
      }

      if (isWorking) {
        await _attendance.clockOut();
      } else {
        await _attendance.clockIn();
      }
      isWorking = !isWorking;
      return isWorking ? ClockOutcome.clockedIn : ClockOutcome.clockedOut;
    } catch (e) {
      debugPrint('HomeViewModel → error al fichar: $e');
      return ClockOutcome.failed;
    } finally {
      isClocking = false;
      notifyListeners();
    }
  }
}
