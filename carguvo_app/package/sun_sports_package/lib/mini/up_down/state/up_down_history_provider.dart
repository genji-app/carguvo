import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sun_sports/core/services/config/sb_config.dart';
import 'package:sun_sports/core/services/network/sb_http_manager.dart';

class UpDownBetHistoryRecord {
  final String sessionId;

  final int bet;

  final int money;

  final DateTime betTime;

  final int card;

  final int turn;

  final int predictId;

  const UpDownBetHistoryRecord({
    required this.sessionId,
    required this.bet,
    required this.money,
    required this.betTime,
    required this.card,
    required this.turn,
    required this.predictId,
  });

  bool get isUp => predictId == 1;
  bool get isDown => predictId == -1;

  factory UpDownBetHistoryRecord.fromJson(Map<String, dynamic> j) {
    return UpDownBetHistoryRecord(
      sessionId: '${j['sessionId'] ?? ''}',
      bet: (j['betting'] as num?)?.toInt() ?? 0,
      money: (j['credit'] as num?)?.toInt() ?? 0,
      betTime: _parseTime(j['createdTime']),
      card: (j['itemId'] as num?)?.toInt() ?? 0,
      turn: (j['turn'] as num?)?.toInt() ?? 0,
      predictId: (j['predictId'] as num?)?.toInt() ?? 0,
    );
  }

  static DateTime _parseTime(dynamic v) {
    if (v is num) return DateTime.fromMillisecondsSinceEpoch(v.toInt());
    if (v is String) {
      final iso = DateTime.tryParse(v);
      if (iso != null) return iso;
      final ms = int.tryParse(v);
      if (ms != null) return DateTime.fromMillisecondsSinceEpoch(ms);
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}

typedef _Page = ({List<UpDownBetHistoryRecord> items, int count});

class UpDownHistoryRepository {
  final SbHttpManager _http;
  UpDownHistoryRepository([SbHttpManager? http])
      : _http = http ?? SbHttpManager.instance;

  static const int pageSize = 6;

  static const String _command = 'fetchUpdownBettingHistory';

  String _url(int skip) {
    final apiDomain = (SbConfig.instance.mainConfig['api_domain'] ?? '') as String;
    return '${apiDomain}sa?command=$_command&limit=$pageSize&skip=$skip';
  }

  Future<_Page> fetch(int skip) async {
    final res = await _http.send(
      _url(skip),
      authorization: true,
      token: _http.userToken,
      json: true,
    );
    return _parse(res);
  }

  _Page _parse(dynamic res) {
    final root = res is Map ? res.cast<String, dynamic>() : const <String, dynamic>{};
    final dataRaw = root['data'];
    List<dynamic> rawItems;
    int count;
    if (dataRaw is List) {
      rawItems = dataRaw;
      count = (root['count'] as num?)?.toInt() ?? -1;
    } else {
      final data = dataRaw is Map
          ? dataRaw.cast<String, dynamic>()
          : root;
      rawItems = (data['items'] as List?) ?? const [];
      count = (data['count'] as num?)?.toInt() ?? -1;
    }
    final items = rawItems
        .whereType<Map>()
        .map((e) => UpDownBetHistoryRecord.fromJson(e.cast<String, dynamic>()))
        .toList(growable: false);
    return (items: items, count: count);
  }
}

final upDownHistoryRepositoryProvider = Provider<UpDownHistoryRepository>(
  (ref) => UpDownHistoryRepository(),
);

class UpDownHistoryState {
  final List<UpDownBetHistoryRecord> items;
  final int page;
  final int totalPages;
  final bool maybeMore;
  final bool loading;
  final Object? error;

  const UpDownHistoryState({
    this.items = const [],
    this.page = 1,
    this.totalPages = 0,
    this.maybeMore = false,
    this.loading = false,
    this.error,
  });

  UpDownHistoryState copyWith({
    List<UpDownBetHistoryRecord>? items,
    int? page,
    int? totalPages,
    bool? maybeMore,
    bool? loading,
    Object? error,
    bool clearError = false,
  }) {
    return UpDownHistoryState(
      items: items ?? this.items,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      maybeMore: maybeMore ?? this.maybeMore,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  bool get hasPrev => page > 1;

  bool get hasNext => totalPages > 0 ? page < totalPages : maybeMore;

  String get pageLabel => '$page';
}

class UpDownHistoryNotifier extends StateNotifier<UpDownHistoryState> {
  final UpDownHistoryRepository _repo;

  final Map<int, _Page> _cache = {};

  UpDownHistoryNotifier(this._repo) : super(const UpDownHistoryState()) {
    loadPage(1);
  }

  Future<void> loadPage(int page) async {
    if (page < 1) return;

    final cached = _cache[page];
    if (cached != null) {
      _apply(page, cached);
      return;
    }

    final prevPage = state.page;
    final prevItems = state.items;
    state = state.copyWith(loading: true, clearError: true);
    try {
      final skip = (page - 1) * UpDownHistoryRepository.pageSize;
      final result = await _repo.fetch(skip);
      if (!mounted) return;
      _cache[page] = result;
      _apply(page, result);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        loading: false,
        error: e,
        page: prevPage,
        items: prevItems,
      );
    }
  }

  void _apply(int page, _Page result) {
    final count = result.count;
    final totalPages = count > 0
        ? (count + UpDownHistoryRepository.pageSize - 1) ~/
            UpDownHistoryRepository.pageSize
        : 0;
    state = state.copyWith(
      items: result.items,
      page: page,
      totalPages: totalPages,
      maybeMore: result.items.length >= UpDownHistoryRepository.pageSize,
      loading: false,
      clearError: true,
    );
  }

  void next() {
    if (state.hasNext) loadPage(state.page + 1);
  }

  void prev() {
    if (state.hasPrev) loadPage(state.page - 1);
  }

  Future<void> reload() {
    _cache.clear();
    return loadPage(state.page);
  }
}

final upDownHistoryProvider =
    StateNotifierProvider.autoDispose<UpDownHistoryNotifier, UpDownHistoryState>(
  (ref) => UpDownHistoryNotifier(ref.watch(upDownHistoryRepositoryProvider)),
);
