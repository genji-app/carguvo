import 'dart:async';

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_socket/sport_socket.dart' as socket;
import 'package:sun_sports/features/sport/data/adapters/sport_socket_adapter.dart';
import 'package:sun_sports/features/sport/data/adapters/sport_socket_adapter_provider.dart';
import 'package:sun_sports/providers/infra_provider.dart';
import 'package:sun_sports/core/services/providers/reconnect_aware.dart';
import 'package:sun_sports/core/services/providers/reconnect_coordinator.dart';
import 'package:sun_sports/providers/user_provider/user_provider.dart'
    show userProvider;
import 'package:sun_sports/core/services/models/api_v2/league_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/odds_model_v2.dart';
import 'package:sun_sports/core/utils/app_logger.dart';
import 'package:sun_sports/features/home/data/datasources/hot_match_remote_datasource.dart';
import 'package:sun_sports/features/home/data/repositories/hot_match_repository_impl.dart';
import 'package:sun_sports/features/home/domain/entities/hot_match_entity.dart';
import 'package:sun_sports/features/home/domain/repositories/hot_match_repository.dart';
import 'package:sun_sports/features/home/domain/usecases/fetch_hot_match_statistics_usecase.dart';
import 'package:sun_sports/features/home/domain/usecases/fetch_hot_matches_usecase.dart';
import 'package:sun_sports/features/home/domain/usecases/stream_hot_match_statistics_usecase.dart';

final _log = AppLogger(tag: 'HotMatch');

final hotMatchRemoteDataSourceProvider = Provider<HotMatchRemoteDataSource>((
  ref,
) {
  final httpManager = ref.read(sbHttpManagerProvider);
  return HotMatchRemoteDataSourceImpl(httpManager);
});

final hotMatchRepositoryProvider = Provider<HotMatchRepository>((ref) {
  final remoteDataSource = ref.read(hotMatchRemoteDataSourceProvider);
  return HotMatchRepositoryImpl(remoteDataSource);
});

final fetchHotMatchesUseCaseProvider = Provider<FetchHotMatchesUseCase>((ref) {
  final repository = ref.read(hotMatchRepositoryProvider);
  return FetchHotMatchesUseCase(repository);
});

final streamHotMatchStatisticsUseCaseProvider =
    Provider<StreamHotMatchStatisticsUseCase>((ref) {
      final repository = ref.read(hotMatchRepositoryProvider);
      return StreamHotMatchStatisticsUseCase(repository);
    });

final fetchHotMatchStatisticsUseCaseProvider =
    Provider<FetchHotMatchStatisticsUseCase>((ref) {
      final repository = ref.read(hotMatchRepositoryProvider);
      return FetchHotMatchStatisticsUseCase(repository);
    });

class _HotSig {
  final bool isLive;
  final String score;
  final String handicap;
  final String overUnder;

  const _HotSig(this.isLive, this.score, this.handicap, this.overUnder);

  @override
  bool operator ==(Object other) =>
      other is _HotSig &&
      other.isLive == isLive &&
      other.score == score &&
      other.handicap == handicap &&
      other.overUnder == overUnder;

  @override
  int get hashCode => Object.hash(isLive, score, handicap, overUnder);
}

String _oddsSig(OddsModelV2? o) {
  if (o == null) return '';
  return '${o.points}|${o.strOfferId}|${o.isSuspended}|${o.isHidden}|'
      '${o.homeOdds?.decimal ?? ''}|${o.awayOdds?.decimal ?? ''}|'
      '${o.drawOdds?.decimal ?? ''}';
}

_HotSig _sigOf(HotMatchEventV2 m, int sportId) => _HotSig(
      m.isLive,
      m.scoreString,
      _oddsSig(m.getHandicapMarket(sportId)?.mainLineOdds),
      _oddsSig(m.getOverUnderMarket(sportId)?.mainLineOdds),
    );

class HotMatchNotifier extends StateNotifier<HotMatchState>
    implements ReconnectAware {
  final SportSocketAdapter _adapter;
  final FetchHotMatchesUseCase _fetchHotMatchesUseCase;
  final StreamHotMatchStatisticsUseCase _streamStatsUseCase;
  final FetchHotMatchStatisticsUseCase _fetchStatsUseCase;

  int _sportId;

  static const String _source = 'hot_match';

  static const int? _hotTimeRange = null;

  StreamSubscription<socket.DataChangeEvent>? _storeSub;
  bool _frameScheduled = false;

  bool _socketTookOver = false;

  StreamSubscription<MapEntry<int, HotMatchEventStatistics>>? _coldStatsSub;
  bool _hasColdStarted = false;

  final Map<int, _HotSig> _lastKnownSnapshot = {};

  Map<int, HotMatchEventV2> _currentMatches = const {};

  final Set<int> _pendingStatChangedIds = {};
  Timer? _statDebounceTimer;
  static const Duration _statDebounceWindow = Duration(milliseconds: 800);

  final Map<int, HotMatchEventStatistics> _pendingStatisticsBatch = {};
  Timer? _statisticsBatchTimer;
  static const Duration _statisticsBatchWindow = Duration(milliseconds: 100);

  static const int _replaceChunkSize = 3;

  List<HotMatchEventV2> _displayedMatches = const [];

  List<HotMatchEventV2> _targetMatches = const [];

  bool _staging = false;

  int _stagingEpoch = 0;

  static const Duration _chunkStatsTimeout = Duration(seconds: 2);

  HotMatchNotifier(
    this._adapter,
    this._fetchHotMatchesUseCase,
    this._streamStatsUseCase,
    this._fetchStatsUseCase, {
    int sportId = 1,
  })  : _sportId = sportId,
        super(const HotMatchState(isLoading: true)) {
    _subscribe();
    _rebuildFromStore();
    _storeSub = _adapter.onStoreChanged.listen(_onStoreChanged);
    _loadRestSkeleton();
  }

  Future<void> _loadRestSkeleton() async {
    final result = await _fetchHotMatchesUseCase();
    if (!mounted || _socketTookOver) return;

    result.fold(
      (failure) {
        _log.w('hot skeleton REST error: ${failure.message}');
        if (state.isLoading) state = state.copyWith(isLoading: false);
      },
      (leagues) {
        if (_socketTookOver) return;
        final matches = flattenLeaguesToHotMatches(leagues);
        _currentMatches = {for (final m in matches) m.eventId: m};
        _displayedMatches = matches;

        if (matches.isNotEmpty && !_hasColdStarted) {
          _coldStart(matches);
        }
        _lastKnownSnapshot
          ..clear()
          ..addEntries(
            matches.map((m) => MapEntry(m.eventId, _sigOf(m, _sportId))),
          );

        state = state.copyWith(
          leagues: leagues,
          hotOrder: [for (final m in matches) m.eventId],
          isLoading: false,
          lastUpdated: DateTime.now(),
        );
      },
    );
  }

  void _subscribe() => _adapter.subscribeHot(
        _sportId,
        timeRange: _hotTimeRange,
        source: _source,
      );
  void _unsubscribe() => _adapter.unsubscribeHot(
        _sportId,
        timeRange: _hotTimeRange,
        source: _source,
      );

  void _onStoreChanged(socket.DataChangeEvent e) {
    final relevant = <int>{
      ..._currentMatches.keys,
      ..._adapter.hotEventIds(_sportId),
    };
    final touched = e.updatedEventIds.any(relevant.contains) ||
        e.addedEventIds.any(relevant.contains) ||
        e.removedEventIds.any(relevant.contains);
    if (!touched) return;

    if (_frameScheduled) return;
    _frameScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _frameScheduled = false;
      if (mounted) _rebuildFromStore();
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  void _rebuildFromStore() {
    final storeLeagues = _adapter.buildHotLeagues(_sportId);
    final storeOrder = _adapter.hotEventOrder(_sportId);

    if (storeLeagues.isEmpty) {
      if (_socketTookOver) {
        _targetMatches = const [];
        if (_staging) return;
        if (state.leagues.isNotEmpty) {
          state = state.copyWith(
            leagues: const [],
            hotOrder: const [],
            lastUpdated: DateTime.now(),
          );
        }
        _displayedMatches = const [];
        _currentMatches = const {};
        _lastKnownSnapshot.clear();
      }
      return;
    }

    _socketTookOver = true;
    final wasColdStart = !_hasColdStarted;
    final matches = flattenLeaguesToHotMatches(storeLeagues);
    _currentMatches = {for (final m in matches) m.eventId: m};
    _targetMatches = matches;

    final newSigs = <int, _HotSig>{
      for (final m in matches) m.eventId: _sigOf(m, _sportId),
    };

    if (wasColdStart) {
      _coldStart(matches);
      _lastKnownSnapshot
        ..clear()
        ..addAll(newSigs);
      _displayedMatches = matches;
      state = state.copyWith(
        leagues: storeLeagues,
        hotOrder: storeOrder,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
      return;
    }

    final changed = <int>{};
    for (final entry in newSigs.entries) {
      final old = _lastKnownSnapshot[entry.key];
      if (old != null && old != entry.value) changed.add(entry.key);
    }

    final targetIds = {for (final m in matches) m.eventId};
    final displayedIds = {for (final m in _displayedMatches) m.eventId};
    final membershipChanged = !_setEquals(targetIds, displayedIds);

    _lastKnownSnapshot
      ..clear()
      ..addAll(newSigs);

    final orderChanged = !listEquals(state.hotOrder, storeOrder);

    if (membershipChanged && _displayedMatches.isNotEmpty) {
      final keptChanged = changed.intersection(displayedIds);
      if (keptChanged.isNotEmpty) _scheduleStatFetch(keptChanged);
      if (orderChanged) state = state.copyWith(hotOrder: storeOrder);
      _runStagedReplace();
      return;
    }

    if (changed.isNotEmpty) _scheduleStatFetch(changed);

    _displayedMatches = matches;

    if (changed.isEmpty && !orderChanged) return;

    state = state.copyWith(
      leagues: storeLeagues,
      hotOrder: storeOrder,
      isLoading: false,
      lastUpdated: DateTime.now(),
    );
  }

  Future<void> _runStagedReplace() async {
    if (_staging) return;
    _staging = true;
    final epoch = _stagingEpoch;
    try {
      while (mounted && epoch == _stagingEpoch) {
        final target = _targetMatches;
        final targetById = {for (final m in target) m.eventId: m};
        final displayedIds = {for (final m in _displayedMatches) m.eventId};

        final toAdd = [
          for (final m in target)
            if (!displayedIds.contains(m.eventId)) m.eventId,
        ];
        final toRemove = [
          for (final m in _displayedMatches)
            if (!targetById.containsKey(m.eventId)) m.eventId,
        ];

        if (toAdd.isEmpty && toRemove.isEmpty) {
          _displayedMatches = [
            for (final m in _displayedMatches) targetById[m.eventId] ?? m,
          ];
          _commitDisplayed();
          break;
        }

        final addBatch = toAdd.take(_replaceChunkSize).toSet();
        final removeBatch = toRemove.take(_replaceChunkSize).toSet();

        _displayedMatches = [
          for (final m in _displayedMatches)
            if (!removeBatch.contains(m.eventId)) targetById[m.eventId] ?? m,
          for (final id in addBatch)
            if (targetById[id] != null) targetById[id]!,
        ];
        _commitDisplayed();

        if (addBatch.isNotEmpty) {
          await _fetchStatsForChunk(addBatch);
        }
        if (!mounted || epoch != _stagingEpoch) break;
      }
    } finally {
      _staging = false;
    }
  }

  void _commitDisplayed() {
    if (!mounted) return;
    state = state.copyWith(
      leagues: _groupMatchesToLeagues(_displayedMatches),
      hotOrder: _adapter.hotEventOrder(_sportId),
      isLoading: false,
      lastUpdated: DateTime.now(),
    );
  }

  List<LeagueModelV2> _groupMatchesToLeagues(List<HotMatchEventV2> matches) {
    final byLeague = <int, List<HotMatchEventV2>>{};
    final order = <int>[];
    for (final m in matches) {
      byLeague.putIfAbsent(m.leagueId, () {
        order.add(m.leagueId);
        return <HotMatchEventV2>[];
      }).add(m);
    }
    return [
      for (final lid in order)
        LeagueModelV2(
          leagueId: lid,
          sportId: _sportId,
          leagueName: byLeague[lid]!.first.leagueName,
          leagueNameEn: byLeague[lid]!.first.leagueName,
          leagueLogo: byLeague[lid]!.first.leagueLogo,
          events: [for (final m in byLeague[lid]!) m.event],
        ),
    ];
  }

  Future<void> _fetchStatsForChunk(Set<int> ids) async {
    final matches = [
      for (final m in _displayedMatches)
        if (ids.contains(m.eventId)) m,
    ];
    if (matches.isEmpty) return;

    state = state.copyWith(
      pendingStatisticsIds: {...state.pendingStatisticsIds, ...ids},
    );

    Map<int, HotMatchEventStatistics> result = const {};
    try {
      result = await _fetchStatsUseCase(matches, _sportId)
          .timeout(_chunkStatsTimeout);
    } catch (e, s) {
      _log.w('staged-replace chunk statistics error', e, s);
    }
    if (!mounted) return;

    state = state.copyWith(
      eventStatistics: {...state.eventStatistics, ...result},
      pendingStatisticsIds: {...state.pendingStatisticsIds}..removeAll(ids),
    );
  }

  static bool _setEquals(Set<int> a, Set<int> b) =>
      a.length == b.length && a.containsAll(b);

  void _coldStart(List<HotMatchEventV2> matches) {
    _hasColdStarted = true;
    _coldStatsSub?.cancel();

    final ids = matches.map((m) => m.eventId).toSet();
    state = state.copyWith(pendingStatisticsIds: ids);

    _coldStatsSub = _streamStatsUseCase(matches, _sportId).listen(
      (entry) {
        if (!mounted) return;
        _pendingStatisticsBatch[entry.key] = entry.value;
        _scheduleStatisticsBatchFlush();
      },
      onError: (Object e, StackTrace s) =>
          _log.w('cold-start statistics error', e, s),
      cancelOnError: false,
      onDone: _flushStatisticsBatch,
    );
  }

  void _scheduleStatFetch(Set<int> ids) {
    _pendingStatChangedIds.addAll(ids);
    _statDebounceTimer?.cancel();
    _statDebounceTimer = Timer(_statDebounceWindow, _flushStatChangedFetch);
  }

  Future<void> _flushStatChangedFetch() async {
    if (_pendingStatChangedIds.isEmpty || !mounted) return;
    final ids = _pendingStatChangedIds.toSet();
    _pendingStatChangedIds.clear();

    final matches = [
      for (final id in ids)
        if (_currentMatches[id] != null) _currentMatches[id]!,
    ];
    if (matches.isEmpty) return;

    state = state.copyWith(
      pendingStatisticsIds: {...state.pendingStatisticsIds, ...ids},
    );

    Map<int, HotMatchEventStatistics> result;
    try {
      result = await _fetchStatsUseCase(matches, _sportId);
    } catch (e, s) {
      _log.w('on-update statistics error', e, s);
      result = const {};
    }
    if (!mounted) return;

    final updatedStats = {...state.eventStatistics, ...result};
    final updatedPending = {...state.pendingStatisticsIds}..removeAll(ids);
    state = state.copyWith(
      eventStatistics: updatedStats,
      pendingStatisticsIds: updatedPending,
    );
  }

  void _scheduleStatisticsBatchFlush() {
    _statisticsBatchTimer?.cancel();
    _statisticsBatchTimer =
        Timer(_statisticsBatchWindow, _flushStatisticsBatch);
  }

  void _flushStatisticsBatch() {
    _statisticsBatchTimer?.cancel();
    _statisticsBatchTimer = null;
    if (_pendingStatisticsBatch.isEmpty || !mounted) return;

    final updatedStats = {...state.eventStatistics, ..._pendingStatisticsBatch};
    final updatedPending = {...state.pendingStatisticsIds}
      ..removeAll(_pendingStatisticsBatch.keys);
    _pendingStatisticsBatch.clear();

    state = state.copyWith(
      eventStatistics: updatedStats,
      pendingStatisticsIds: updatedPending,
    );
  }

  Future<void> fetchHotMatches({
    int? sportId,
    bool forceRefresh = false,
  }) async {
    if (sportId != null && sportId != _sportId) {
      _unsubscribe();
      _sportId = sportId;
      _resetForReColdStart();
      _subscribe();
      _rebuildFromStore();
      await _loadRestSkeleton();
    } else if (forceRefresh) {
      _resetForReColdStart();
      _rebuildFromStore();
      await _loadRestSkeleton();
    } else {
      _rebuildFromStore();
    }
  }

  DateTime? _lastEventRefreshAt;
  static const Duration _eventRefreshCooldown = Duration(seconds: 2);

  void refreshEvent(int eventId) {
    final last = _lastEventRefreshAt;
    if (last != null &&
        DateTime.now().difference(last) < _eventRefreshCooldown) {
      return;
    }
    _lastEventRefreshAt = DateTime.now();

    _rebuildFromStore();
    if (_currentMatches.containsKey(eventId)) {
      _scheduleStatFetch({eventId});
    }
  }

  void refreshStatistics() {
    final matches = _currentMatches.values.toList();
    if (matches.isEmpty) return;
    _coldStart(matches);
  }

  void _resetForReColdStart() {
    _hasColdStarted = false;
    _socketTookOver = false;
    _lastKnownSnapshot.clear();
    _coldStatsSub?.cancel();
    _coldStatsSub = null;
    _displayedMatches = const [];
    _targetMatches = const [];
    _stagingEpoch++;
  }

  void setPageIndex(int index) {
    state = state.copyWith(currentPageIndex: index);
  }

  void setRightSidebarPageIndex(int index) {
    state = state.copyWith(rightSidebarPageIndex: index);
  }

  Future<void> changeSport(int sportId) => fetchHotMatches(sportId: sportId);

  @override
  void refreshOnReconnect() {
    _resetForReColdStart();
    _rebuildFromStore();
    _loadRestSkeleton();
  }

  @override
  void dispose() {
    _storeSub?.cancel();
    _coldStatsSub?.cancel();
    _statDebounceTimer?.cancel();
    _statisticsBatchTimer?.cancel();
    _pendingStatisticsBatch.clear();
    _pendingStatChangedIds.clear();
    _unsubscribe();
    super.dispose();
  }
}

final StateNotifierProvider<HotMatchNotifier, HotMatchState> hotMatchProvider =
    StateNotifierProvider<HotMatchNotifier, HotMatchState>((ref) {
      final adapter = ref.read(sportSocketAdapterProvider);
      final fetchHot = ref.read(fetchHotMatchesUseCaseProvider);
      final streamStats = ref.read(streamHotMatchStatisticsUseCaseProvider);
      final fetchStats = ref.read(fetchHotMatchStatisticsUseCaseProvider);

      final notifier = HotMatchNotifier(
        adapter,
        fetchHot,
        streamStats,
        fetchStats,
      );

      ref.listen<bool>(
        userProvider.select((s) => s.isLoggedIn),
        (prev, next) {
          if (prev != true && next) notifier.refreshStatistics();
        },
      );

      final coordinator = ref.read(reconnectCoordinatorProvider);
      reconnectCb() =>
          ref.read(hotMatchProvider.notifier).refreshOnReconnect();
      coordinator.register(reconnectCb);

      ref.onDispose(() {
        coordinator.unregister(reconnectCb);
        _log.d('HotMatchNotifier disposed');
      });

      return notifier;
    });

final hotMatchesProvider = Provider<List<HotMatchEventV2>>((ref) {
  final leagues = ref.watch(hotMatchProvider.select((s) => s.leagues));
  final hotOrder = ref.watch(hotMatchProvider.select((s) => s.hotOrder));
  final eventStatistics = ref.watch(
    hotMatchProvider.select((s) => s.eventStatistics),
  );

  final list = flattenLeaguesToHotMatches(
    leagues,
    eventStatistics: eventStatistics,
  );

  final rankOf = <int, int>{
    for (var i = 0; i < hotOrder.length; i++) hotOrder[i]: i,
  };
  final indexed = list.asMap().entries.toList()
    ..sort((a, b) {
      final ra = rankOf[a.value.eventId] ?? hotOrder.length + a.key;
      final rb = rankOf[b.value.eventId] ?? hotOrder.length + b.key;
      return ra.compareTo(rb);
    });

  return [for (final e in indexed) e.value];
});

final hotMatchLoadingProvider = Provider<bool>((ref) {
  return ref.watch(hotMatchProvider).isLoading;
});

final hotMatchErrorProvider = Provider<String?>((ref) {
  return ref.watch(hotMatchProvider).error;
});

final hotMatchHasDataProvider = Provider<bool>((ref) {
  return ref.watch(hotMatchProvider).hasData;
});

final hotMatchPageIndexProvider = Provider<int>((ref) {
  return ref.watch(hotMatchProvider).currentPageIndex;
});
