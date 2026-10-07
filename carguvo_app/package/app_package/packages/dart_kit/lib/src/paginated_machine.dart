library;

import 'request_lock.dart';

enum PaginatedStatus {
  initial,
  loading,
  data,
  noData,
  refreshing,
  loadingMore,
  error,
}

class PaginatedPage<T> {
  const PaginatedPage({required this.items, this.nextCursor});

  final List<T> items;
  final int? nextCursor;
}

class PaginatedMachine<T> with RequestLock {
  PaginatedMachine({
    required Future<PaginatedPage<T>> Function([int? cursor]) request,
    required void Function() onChanged,
    bool Function()? isDisposed,
  }) : _request = request,
       _onChanged = onChanged,
       _isDisposed = isDisposed;

  final Future<PaginatedPage<T>> Function([int? cursor]) _request;
  final void Function() _onChanged;
  final bool Function()? _isDisposed;

  PaginatedStatus _status = PaginatedStatus.initial;
  List<T>? _data;
  int? _cursor;

  PaginatedStatus get status => _status;

  List<T>? get data => _data;

  int? get cursor => _cursor;

  bool get _disposed => _isDisposed?.call() ?? false;

  bool get canLoadMore =>
      _status == PaginatedStatus.data && _cursor != null && _cursor != 0;

  bool get isInitialized => _status != PaginatedStatus.initial;

  Future<void> loadInitial() async {
    if (_disposed || lock()) return;
    _data = null;
    _cursor = null;
    _emit(PaginatedStatus.loading);
    try {
      final page = await _request();
      if (_disposed) return;
      _applyFirstPage(page);
    } catch (_) {
      if (_disposed) return;
      _data = null;
      _cursor = null;
      _emit(PaginatedStatus.error);
    } finally {
      unlock();
    }
  }

  Future<void> refresh([bool clear = true]) async {
    if (_disposed || lock()) return;
    try {
      if (clear) _data = null;
      _emit(PaginatedStatus.refreshing);
      final page = await _request();
      if (_disposed) return;
      _applyFirstPage(page);
    } catch (_) {
      if (_disposed) return;
      _data = null;
      _cursor = null;
      _emit(PaginatedStatus.error);
    } finally {
      unlock();
    }
  }

  Future<void> loadMore() async {
    if (_disposed || !canLoadMore || lock()) return;
    try {
      final previous = _data ?? <T>[];
      final from = _cursor;
      _emit(PaginatedStatus.loadingMore);
      final page = await _request(from);
      if (_disposed) return;
      _data = [...previous, ...page.items];
      _cursor = page.nextCursor;
      _emit(PaginatedStatus.data);
    } catch (_) {
      if (_disposed) return;
      _emit(PaginatedStatus.error);
    } finally {
      unlock();
    }
  }

  void reset() {
    if (_disposed) return;
    _data = null;
    _cursor = null;
    _emit(PaginatedStatus.initial);
  }

  void _applyFirstPage(PaginatedPage<T> page) {
    if (page.items.isEmpty) {
      _data = null;
      _cursor = null;
      _emit(PaginatedStatus.noData);
      return;
    }
    _data = page.items;
    _cursor = page.nextCursor;
    _emit(PaginatedStatus.data);
  }

  void _emit(PaginatedStatus status) {
    _status = status;
    _onChanged();
  }
}
