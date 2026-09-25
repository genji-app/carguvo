library;

class SlotHistoryChunk<T> {
  final List<T> items;
  final int count;

  const SlotHistoryChunk({required this.items, required this.count});
}

typedef SlotHistoryFetcher<T> =
    Future<SlotHistoryChunk<T>> Function({required int skip, required int limit});

class SlotHistoryPager<T> {
  static const int chunkSize = 60;

  static const int pageSize = 6;

  final SlotHistoryFetcher<T> _fetch;
  final int Function(T item) _createdTimeOf;
  final int Function(T item) _sessionIdOf;
  final void Function(String message)? _warnLog;

  SlotHistoryPager({
    required SlotHistoryFetcher<T> fetchChunk,
    required int Function(T item) createdTimeOf,
    required int Function(T item) sessionIdOf,
    void Function(String message)? warnLog,
  })  : _fetch = fetchChunk,
        _createdTimeOf = createdTimeOf,
        _sessionIdOf = sessionIdOf,
        _warnLog = warnLog;

  final List<T> _items = [];

  final Set<(int, int)> _seen = {};

  int _loadedRaw = 0;

  int _serverCount = 0;

  bool _exhausted = false;

  bool _degraded = false;

  bool get degraded => _degraded;
  int get serverCount => _serverCount;
  int get cachedCount => _items.length;

  bool get _fullyLoaded =>
      _exhausted || (_serverCount > 0 && _loadedRaw >= _serverCount);

  int get maxPages {
    if (_fullyLoaded) {
      final pages = (_items.length / pageSize).ceil();
      return pages <= 0 ? 1 : pages;
    }
    return _serverCount <= 0 ? 1 : (_serverCount / pageSize).ceil();
  }

  Future<void> _lastOp = Future<void>.value();

  Future<List<T>> page(int n) {
    final run = _lastOp.then((_) => _pageInner(n));
    _lastOp = run.then((_) {}, onError: (_) {});
    return run;
  }

  Future<List<T>> _pageInner(int n) async {
    final start = (n - 1) * pageSize;
    final end = n * pageSize;

    while (!_covers(end) && !_exhausted) {
      final progressed = await _fetchNextChunk();
      if (!progressed) break;
    }

    if (start >= _items.length) return const [];
    final safeEnd = end > _items.length ? _items.length : end;
    return _items.sublist(start, safeEnd);
  }

  bool _covers(int end) {
    if (_items.length >= end) return true;
    if (_serverCount > 0 && _loadedRaw >= _serverCount) return true;
    return false;
  }

  Future<bool> _fetchNextChunk() async {
    final skip = _loadedRaw;
    final limit = _degraded ? pageSize : chunkSize;

    SlotHistoryChunk<T> chunk;
    try {
      chunk = await _fetch(skip: skip, limit: limit);
    } catch (e) {
      if (!_degraded) {
        _degraded = true;
        _warnLog?.call(
          '[GSB-624] fetch chunk limit=$chunkSize lỗi → degrade fallback '
          'per-page limit=$pageSize (skip=$skip): $e',
        );
        chunk = await _fetch(skip: skip, limit: pageSize);
      } else {
        rethrow;
      }
    }

    _serverCount = chunk.count;

    if (chunk.items.isEmpty) {
      _exhausted = true;
      return false;
    }

    final overlap = <int>[];
    for (final item in chunk.items) {
      final key = (_sessionIdOf(item), _createdTimeOf(item));
      if (_seen.contains(key)) {
        overlap.add(_sessionIdOf(item));
        continue;
      }
      _seen.add(key);
      _items.add(item);
    }
    _loadedRaw += chunk.items.length;

    if (overlap.isNotEmpty) {
      _warnLog?.call(
        '[GSB-624] server pagination KHÔNG ổn định: chunk skip=$skip '
        'limit=$limit trả lại record đã có sessionId=${overlap.join(",")} '
        '(snapshot vẫn giữ đủ, nhưng đây là bằng chứng sort server bị xê dịch)',
      );
    }

    _sortSnapshot();
    return true;
  }

  void _sortSnapshot() {
    _items.sort((a, b) {
      final byTime = _createdTimeOf(b).compareTo(_createdTimeOf(a));
      if (byTime != 0) return byTime;
      return _sessionIdOf(b).compareTo(_sessionIdOf(a));
    });
  }
}
