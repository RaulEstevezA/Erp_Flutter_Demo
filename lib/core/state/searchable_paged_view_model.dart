import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/attendance.dart' show PageResult;
import '../utils/workday_calendar.dart';
import 'period_list_view_model.dart' show LoadStatus;

/// Listado paginado con búsqueda (debounce de 350 ms) y, opcionalmente,
/// rango de fechas o vista por meses. Base de los listados de clientes,
/// documentos y visitas.
abstract class SearchablePagedViewModel<T> extends ChangeNotifier {
  static const _debounceDelay = Duration(milliseconds: 350);

  Future<PageResult<T>> fetch(int page);

  LoadStatus _status = LoadStatus.initial;
  List<T> _items = const [];
  String _query = '';
  DateTime? _since;
  DateTime? _until;
  bool _isMonthMode = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _page = 0;
  int _generation = 0;
  Timer? _debounce;

  LoadStatus get status => _status;
  List<T> get items => _items;
  String get query => _query;
  DateTime? get since => _since;
  DateTime? get until => _until;

  /// Rango a medida (no la vista por meses).
  bool get hasDateRange => _since != null && !_isMonthMode;
  bool get isMonthMode => _isMonthMode;

  bool get isCurrentMonth {
    final now = DateTime.now();
    return !_isMonthMode || (_since!.year == now.year && _since!.month == now.month);
  }

  bool get isLoadingMore => _isLoadingMore;

  /// Estado limpio: sin búsqueda ni fechas.
  Future<void> init() {
    _debounce?.cancel();
    _query = '';
    _since = null;
    _until = null;
    _isMonthMode = false;
    return load();
  }

  Future<void> load() async {
    _debounce?.cancel();
    final generation = ++_generation;
    _status = LoadStatus.loading;
    _items = const [];
    _page = 0;
    _hasMore = true;
    _isLoadingMore = false;
    notifyListeners();

    try {
      final result = await fetch(1);
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
      final result = await fetch(_page + 1);
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

  void updateSearch(String query) {
    if (query == _query) return;
    _query = query;
    notifyListeners();
    _debounce?.cancel();
    _debounce = Timer(_debounceDelay, load);
  }

  void clearSearch() {
    if (_query.isEmpty) return;
    _query = '';
    load();
  }

  void setDateRange(DateTime since, DateTime until) {
    _isMonthMode = false;
    _since = since.startOfDay;
    _until = until.endOfDay;
    load();
  }

  void clearDateRange() {
    _isMonthMode = false;
    _since = null;
    _until = null;
    load();
  }

  /// Alterna entre ver todo y ver mes a mes (empezando por el actual).
  void toggleMonthMode() {
    if (_isMonthMode) {
      clearDateRange();
      return;
    }
    _isMonthMode = true;
    _showMonth(DateTime.now());
  }

  void previousMonth() {
    if (!_isMonthMode) return;
    _showMonth(DateTime(_since!.year, _since!.month - 1));
  }

  void nextMonth() {
    if (!_isMonthMode || isCurrentMonth) return;
    _showMonth(DateTime(_since!.year, _since!.month + 1));
  }

  /// El mes en curso acaba hoy; los anteriores, en su último día.
  void _showMonth(DateTime month) {
    final now = DateTime.now();
    _since = DateTime(month.year, month.month);
    _until = month.year == now.year && month.month == now.month
        ? now.endOfDay
        : DateTime(month.year, month.month + 1, 0).endOfDay;
    load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
