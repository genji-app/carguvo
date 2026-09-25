import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sun_sports/core/services/config/sb_config.dart';
import 'package:sun_sports/core/services/network/sb_http_manager.dart';

class DiamondHistoryRecord {
  final int sessionId;
  final int bet;
  final int money;
  final int totalBet;
  final int numLines;
  final bool isJackpot;
  final DateTime betTime;
  final List<int> symbols;
  final List<int> winLineIds;

  const DiamondHistoryRecord({
    required this.sessionId,
    required this.bet,
    required this.money,
    required this.totalBet,
    required this.numLines,
    required this.isJackpot,
    required this.betTime,
    required this.symbols,
    required this.winLineIds,
  });

  int get winLineCount => winLineIds.length;

  factory DiamondHistoryRecord.fromJson(Map<String, dynamic> j) {
    final symbols = ((j['symbols'] as List?) ?? const [])
        .map((e) => e is int ? e : (e as num).toInt())
        .toList(growable: false);
    final wins = <int>[];
    for (final p in (j['payoutLines'] as List?) ?? const []) {
      if (p is Map) {
        final id = (p['id'] as num?)?.toInt();
        if (id != null) wins.add(id);
      }
    }
    return DiamondHistoryRecord(
      sessionId: (j['sessionId'] as num?)?.toInt() ?? 0,
      bet: (j['betting'] as num?)?.toInt() ?? 0,
      money: (j['money'] as num?)?.toInt() ?? 0,
      totalBet: (j['totalBet'] as num?)?.toInt() ?? 0,
      numLines: (j['numLines'] as num?)?.toInt() ?? 0,
      isJackpot: (j['isJackpot'] as bool?) ?? false,
      betTime: _parseTime(j['createdTime']),
      symbols: symbols,
      winLineIds: wins,
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

typedef _Page = ({List<DiamondHistoryRecord> items, int count});

class DiamondHistoryRepository {
  final SbHttpManager _http;
  DiamondHistoryRepository([SbHttpManager? http])
      : _http = http ?? SbHttpManager.instance;

  static const int pageSize = 6;
  static const int gameId = 202;
  static const int assetId = 1;

  String _url(int skip) {
    final apiDomain =
        (SbConfig.instance.mainConfig['api_domain'] ?? '') as String;
    return '${apiDomain}sa?command=fetchSlotMachineHistory'
        '&assetId=$assetId&gameId=$gameId&limit=$pageSize&skip=$skip';
  }

  Future<({List<DiamondHistoryRecord> items, int count})> fetch(
      int skip) async {
    final res = await _http.send(
      _url(skip),
      authorization: true,
      token: _http.userToken,
      json: true,
    );
    return _parse(res);
  }

  _Page _parse(dynamic res) {
    final root =
        res is Map ? res.cast<String, dynamic>() : const <String, dynamic>{};
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
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => DiamondHistoryRecord.fromJson(e.cast<String, dynamic>()))
        .toList(growable: false);
    return (items: items, count: count);
  }
}

final diamondHistoryRepositoryProvider = Provider<DiamondHistoryRepository>(
  (ref) => DiamondHistoryRepository(),
);

class DiamondHistoryState {
  final List<DiamondHistoryRecord> items;
  final int page;
  final int totalPages;
  final bool maybeMore;
  final bool loading;
  final Object? error;

  const DiamondHistoryState({
    this.items = const [],
    this.page = 1,
    this.totalPages = 0,
    this.maybeMore = false,
    this.loading = false,
    this.error,
  });

  DiamondHistoryState copyWith({
    List<DiamondHistoryRecord>? items,
    int? page,
    int? totalPages,
    bool? maybeMore,
    bool? loading,
    Object? error,
    bool clearError = false,
  }) {
    return DiamondHistoryState(
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

class DiamondHistoryNotifier extends StateNotifier<DiamondHistoryState> {
  final DiamondHistoryRepository _repo;
  final Map<int, _Page> _cache = {};

  DiamondHistoryNotifier(this._repo) : super(const DiamondHistoryState()) {
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
      final skip = (page - 1) * DiamondHistoryRepository.pageSize;
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
        ? (count + DiamondHistoryRepository.pageSize - 1) ~/
            DiamondHistoryRepository.pageSize
        : 0;
    state = state.copyWith(
      items: result.items,
      page: page,
      totalPages: totalPages,
      maybeMore: result.items.length >= DiamondHistoryRepository.pageSize,
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
}

final diamondHistoryProvider = StateNotifierProvider.autoDispose<
    DiamondHistoryNotifier, DiamondHistoryState>(
  (ref) => DiamondHistoryNotifier(ref.watch(diamondHistoryRepositoryProvider)),
);
