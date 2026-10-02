import 'package:flutter/foundation.dart';

import '../../domain/attendance.dart';
import '../utils/workday_calendar.dart';

enum LoadStatus { initial, loading, loaded, error }

/// Base de los listados filtrados por período (fichajes, incidencias...).
///
/// Gestiona:
/// * navegación mes a mes (sin pasar del mes en curso),
/// * rango de fechas a medida,
/// * agrupación por empleado (pide todo el período de una vez),
/// * scroll infinito con descarte de respuestas obsoletas.
abstract class PeriodListViewModel<T> extends ChangeNotifier {
  /// `true` si el usuario puede ver a toda la plantilla (y por tanto agrupar).
  final bool canViewAll;

  PeriodListViewModel({required this.canViewAll}) {
    _resetToCurrentMonth();
  }

  /// Tamaño de página del modo lista.
  int get pageSize;

  Future<PageResult<T>> fetch({
    required DateTime since,
    required DateTime until,
    required int page,
    required int perPage,
  });

  LoadStatus _status = LoadStatus.initial;
  List<T> _items = const [];
  late DateTime _since;
  late DateTime _until;
  bool _isCustomRange = false;
  bool _isGrouped = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _page = 0;

  /// Se incrementa en cada carga completa: las respuestas de cargas
  /// anteriores que lleguen tarde se ignoran.
  int _generation = 0;

  LoadStatus get status => _status;
  List<T> get items => _items;
  DateTime get since => _since;
  DateTime get until => _until;
  bool get isCustomRange => _isCustomRange;
  bool get isGrouped => _isGrouped;
  bool get isLoadingMore => _isLoadingMore;

  bool get isCurrentMonth {
    final now = DateTime.now();
    return _since.year == now.year && _since.month == now.month;
  }

  int get _effectivePageSize => _isGrouped ? 1000 : pageSize;

  /// Estado limpio al entrar en la sección: mes actual, sin agrupar.
  Future<void> init() {
    _resetToCurrentMonth();
    _isCustomRange = false;
    _isGrouped = false;
    return load();
  }

  Future<void> load() async {
    final generation = ++_generation;
    _status = LoadStatus.loading;
    _items = const [];
    _page = 0;
    _hasMore = true;
    _isLoadingMore = false;
    notifyListeners();

    try {
      final result = await fetch(
        since: _since,
        until: _until,
        page: 1,
        perPage: _effectivePageSize,
      );
      if (generation != _generation) return;
      _items = result.items;
      _hasMore = result.hasMore;
      _page = 1;
      _status = LoadStatus.loaded;
    } catch (e) {
      if (generation != _generation) return;
      debugPrint('$runtimeType → error de carga: $e');
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore || _status != LoadStatus.loaded) return;
    final generation = _generation;
    _isLoadingMore = true;
    notifyListeners();

    try {
      final result = await fetch(
        since: _since,
        until: _until,
        page: _page + 1,
        perPage: _effectivePageSize,
      );
      if (generation != _generation) return;
      _items = [..._items, ...result.items];
      _hasMore = result.hasMore;
      _page++;
    } catch (_) {
      if (generation != _generation) return;
    }
    _isLoadingMore = false;
    notifyListeners();
  }

  void previousMonth() {
    final start = DateTime(_since.year, _since.month - 1);
    _since = start;
    _until = DateTime(start.year, start.month + 1, 0).endOfDay;
    load();
  }

  void nextMonth() {
    if (isCurrentMonth) return;
    final start = DateTime(_since.year, _since.month + 1);
    final now = DateTime.now();
    if (start.year == now.year && start.month == now.month) {
      _resetToCurrentMonth();
    } else {
      _since = start;
      _until = DateTime(start.year, start.month + 1, 0).endOfDay;
    }
    load();
  }

  void setCustomRange(DateTime since, DateTime until) {
    _since = since.startOfDay;
    _until = until.endOfDay;
    _isCustomRange = true;
    load();
  }

  void clearCustomRange() {
    _resetToCurrentMonth();
    _isCustomRange = false;
    load();
  }

  void toggleGrouping() {
    if (!canViewAll) return;
    _isGrouped = !_isGrouped;
    load();
  }

  void _resetToCurrentMonth() {
    final now = DateTime.now();
    _since = DateTime(now.year, now.month);
    _until = now.endOfDay;
  }
}
