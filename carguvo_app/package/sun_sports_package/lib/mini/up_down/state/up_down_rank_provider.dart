import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sun_sports/core/services/config/sb_config.dart';
import 'package:sun_sports/core/services/network/sb_http_manager.dart';

class UpDownRankRecord {
  final String displayName;

  final int bet;

  final int money;

  final String type;

  final DateTime betTime;

  const UpDownRankRecord({
    required this.displayName,
    required this.bet,
    required this.money,
    required this.type,
    required this.betTime,
  });

  String get typeLabel {
    final d = type.toLowerCase();
    if (d.contains('hũ') || d.contains('jackpot') || d.contains('nổ')) {
      return 'Nổ hũ';
    }
    return 'Thắng lớn';
  }

  factory UpDownRankRecord.fromJson(Map<String, dynamic> j) {
    return UpDownRankRecord(
      displayName: '${j['displayName'] ?? ''}',
      bet: (j['betting'] as num?)?.toInt() ?? 0,
      money: (j['credit'] as num?)?.toInt() ?? 0,
      type: '${j['description'] ?? ''}',
      betTime: _parseTime(j['createdTime']),
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

typedef _Page = ({List<UpDownRankRecord> items, int count});

class UpDownRankRepository {
  final SbHttpManager _http;
  UpDownRankRepository([SbHttpManager? http])
      : _http = http ?? SbHttpManager.instance;

  static const int pageSize = 6;

  static const String _command = 'fetchSpinBoard';

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
      final data = dataRaw is Map ? dataRaw.cast<String, dynamic>() : root;
      rawItems = (data['items'] as List?) ?? const [];
      count = (data['count'] as num?)?.toInt() ?? -1;
    }
    final items = rawItems
        .whereType<Map>()
        .map((e) => UpDownRankRecord.fromJson(e.cast<String, dynamic>()))
        .toList(growable: false);
    return (items: items, count: count);
  }
}

final upDownRankRepositoryProvider = Provider<UpDownRankRepository>(
  (ref) => UpDownRankRepository(),
);

class UpDownRankState {
  final List<UpDownRankRecord> items;
  final int page;
  final int totalPages;
  final bool maybeMore;
  final bool loading;
  final Object? error;

  const UpDownRankState({
    this.items = const [],
    this.page = 1,
    this.totalPages = 0,
    this.maybeMore = false,
    this.loading = false,
    this.error,
  });

  UpDownRankState copyWith({
    List<UpDownRankRecord>? items,
    int? page,
    int? totalPages,
    bool? maybeMore,
    bool? loading,
    Object? error,
    bool clearError = false,
  }) {
    return UpDownRankState(
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

class UpDownRankNotifier extends StateNotifier<UpDownRankState> {
  final UpDownRankRepository _repo;
  final Map<int, _Page> _cache = {};

  UpDownRankNotifier(this._repo) : super(const UpDownRankState()) {
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
      final skip = (page - 1) * UpDownRankRepository.pageSize;
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
        ? (count + UpDownRankRepository.pageSize - 1) ~/
            UpDownRankRepository.pageSize
        : 0;
    state = state.copyWith(
      items: result.items,
      page: page,
      totalPages: totalPages,
      maybeMore: result.items.length >= UpDownRankRepository.pageSize,
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

final upDownRankProvider =
    StateNotifierProvider.autoDispose<UpDownRankNotifier, UpDownRankState>(
  (ref) => UpDownRankNotifier(ref.watch(upDownRankRepositoryProvider)),
);
