import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show WidgetsBinding;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_events/sport_events.dart'
    show eventsDataOnlyThrottleLive, eventsDataOnlyThrottlePrematch;
import 'package:sport_socket/sport_socket.dart' as socket show TimeRange;

import 'package:sun_sports/features/sport/data/adapters/sport_api_service_impl.dart'
    show PopulateOutcome;
import 'package:sun_sports/features/sport/data/adapters/sport_socket_adapter.dart';
import 'package:sun_sports/features/sport/data/adapters/sport_socket_adapter_provider.dart';
import 'package:sun_sports/core/error/app_error_messages.dart';
import 'package:sun_sports/core/perf/frame_monitor.dart';
import 'package:sun_sports/core/perf/perf_flags.dart';
import 'package:sun_sports/core/utils/scroll_hold.dart';
import 'package:sun_sports/core/services/config/sb_config.dart';
import 'package:sun_sports/core/services/datasources/events_v2_remote_datasource.dart';
import 'package:sun_sports/core/services/models/api_v2/event_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/events_request_model.dart';
import 'package:sun_sports/core/services/models/api_v2/league_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/sport_constants.dart';
import 'package:sun_sports/core/services/models/api_v2/v2_to_legacy_adapter.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/core/services/repositories/events_v2_repository.dart';
import 'package:sun_sports/core/services/utils/favorite_applier.dart';
import 'package:sun_sports/providers/auth_provider.dart';
import 'events_v2_filter_provider.dart';
import 'favorite_provider.dart';
import 'package:sun_sports/core/services/providers/reconnect_aware.dart';
import 'package:sun_sports/core/services/providers/reconnect_coordinator.dart';

class EventsV2State {
  final List<LeagueModelV2> leagues;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final DateTime? lastUpdated;

  const EventsV2State({
    this.leagues = const [],
    this.isLoading = true,
    this.isRefreshing = false,
    this.error,
    this.lastUpdated,
  });

  factory EventsV2State.initial() => const EventsV2State();

  factory EventsV2State.loading() => const EventsV2State(isLoading: true);

  factory EventsV2State.loaded(List<LeagueModelV2> leagues) => EventsV2State(
    leagues: leagues,
    isLoading: false,
    lastUpdated: DateTime.now(),
  );

  factory EventsV2State.error(String message) =>
      EventsV2State(isLoading: false, error: message);

  bool get isLoaded => !isLoading && error == null && leagues.isNotEmpty;

  bool get isEmpty => !isLoading && error == null && leagues.isEmpty;

  int get totalEvents =>
      leagues.fold(0, (sum, league) => sum + league.eventCount);

  List<EventModelV2> get allEvents =>
      leagues.expand((league) => league.events).toList();

  List<EventModelV2> get allLiveEvents =>
      leagues.expand((league) => league.liveEvents).toList();

  List<EventModelV2> get allUpcomingEvents =>
      leagues.expand((league) => league.upcomingEvents).toList();

  EventsV2State copyWith({
    List<LeagueModelV2>? leagues,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    bool clearError = false,
    DateTime? lastUpdated,
  }) {
    return EventsV2State(
      leagues: leagues ?? this.leagues,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: clearError ? null : (error ?? this.error),
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  String toString() =>
      'EventsV2State(leagues: ${leagues.length}, isLoading: $isLoading, error: $error)';
}

abstract class EventsV2NotifierBase extends StateNotifier<EventsV2State>
    implements ReconnectAware {
  EventsV2NotifierBase(super.state);
  Future<void> refresh();

  Future<void> refreshOnStaleOffer({int? leagueId});

  static const staleOfferRefreshCooldown = Duration(seconds: 2);
}

List<LeagueModelV2> liveOnlyLeagues(List<LeagueModelV2> leagues) {
  return leagues
      .map((l) => l.copyWith(events: l.events.where((e) => e.isLive).toList()))
      .where((l) => l.events.isNotEmpty)
      .toList();
}

class EventsV2Notifier extends EventsV2NotifierBase {
  final EventsV2Repository _repository;
  final EventFilterV2 _filter;

  CancelToken? _cancelToken;
  Timer? _refreshTimer;

  static const _liveRefreshInterval = Duration(seconds: 10);
  static const _todayRefreshInterval = Duration(seconds: 30);
  static const _earlyRefreshInterval = Duration(seconds: 60);

  DateTime? _lastStaleOfferRefreshAt;
  static const _staleOfferRefreshCooldown =
      EventsV2NotifierBase.staleOfferRefreshCooldown;

  EventsV2Notifier(this._repository, this._filter)
    : super(EventsV2State.initial()) {
    fetchEvents();
  }

  @override
  void refreshOnReconnect() {
    fetchEvents();
  }

  @override
  void dispose() {
    _cancelToken?.cancel('Disposed');
    _refreshTimer?.cancel();
    super.dispose();
  }

  Duration get _refreshInterval {
    switch (_filter.timeRange) {
      case EventTimeRange.live:
        return _liveRefreshInterval;
      case EventTimeRange.today:
        return _todayRefreshInterval;
      case EventTimeRange.early:
      case EventTimeRange.todayAndEarly:
        return _earlyRefreshInterval;
    }
  }

  Future<void> fetchEvents() async {
    _cancelToken?.cancel('New request');
    _cancelToken = CancelToken();

    _refreshTimer?.cancel();

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final request = EventsRequestModel(
        sportId: _filter.sportId,
        timeRange: _filter.timeRangeValue,
        sportTypeId: _filter.sportTypeId,
        sortByTime: _filter.timeRange == EventTimeRange.todayAndEarly,
      );

      final leagues = await _repository.getEventsWithCancel(
        request,
        _cancelToken!,
      );

      if (mounted) {
        final merged = leagues.mergeDuplicateLeagues();
        state = EventsV2State.loaded(
          _filter.timeRange == EventTimeRange.live
              ? liveOnlyLeagues(merged)
              : merged,
        );
        _startAutoRefresh();
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        return;
      }
      if (mounted) {
        state = EventsV2State.error('Failed to load events: ${e.message}');
      }
    } on CancelledException {
      return;
    } catch (e) {
      if (mounted) {
        state = EventsV2State.error('An error occurred: $e');
      }
    }
  }

  Future<void> refresh() async {
    if (state.isRefreshing) return;

    state = state.copyWith(isRefreshing: true);

    try {
      await fetchEvents();
    } finally {
      if (mounted) {
        state = state.copyWith(isRefreshing: false);
      }
    }
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();

    _refreshTimer = Timer.periodic(_refreshInterval, (_) {
      if (mounted) {
        _silentRefresh();
      }
    });

    if (kDebugMode) {
      debugPrint(
        '[EventsV2] Auto-refresh started: ${_refreshInterval.inSeconds}s interval',
      );
    }
  }

  @override
  Future<void> refreshOnStaleOffer({int? leagueId}) async {
    final last = _lastStaleOfferRefreshAt;
    if (last != null &&
        DateTime.now().difference(last) < _staleOfferRefreshCooldown) {
      return;
    }
    _lastStaleOfferRefreshAt = DateTime.now();
    await _silentRefresh();
  }

  Future<void> _silentRefresh() async {
    try {
      final request = EventsRequestModel(
        sportId: _filter.sportId,
        timeRange: _filter.timeRangeValue,
        sportTypeId: _filter.sportTypeId,
        sortByTime: _filter.timeRange == EventTimeRange.todayAndEarly,
      );

      final leagues = await _repository.getEvents(request);

      if (mounted) {
        final merged = leagues.mergeDuplicateLeagues();
        state = EventsV2State.loaded(
          _filter.timeRange == EventTimeRange.live
              ? liveOnlyLeagues(merged)
              : merged,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[EventsV2] Silent refresh failed: $e');
      }
    }
  }

  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  void resumeAutoRefresh() {
    if (_refreshTimer == null && state.isLoaded) {
      _startAutoRefresh();
    }
  }
}

final useSocketStoreProvider = StateProvider<bool>((ref) {
  final Object? raw = SbConfig.instance.mainConfig['use_socket_store'];
  if (raw is bool) return raw;
  return true;
});

final staleOfferHealBusProvider =
    StateProvider<({int seq, int? leagueId})>((ref) => (seq: 0, leagueId: null));

class StoreBackedEventsV2Notifier extends EventsV2NotifierBase {
  final SportSocketAdapter _adapter;
  final int _sportId;
  final EventTimeRange _timeRange;

  StreamSubscription<dynamic>? _sub;
  StreamSubscription<dynamic>? _updateSub;
  Timer? _reconcileTimer;
  bool _frameScheduled = false;

  bool _holdDirty = false;

  StoreBackedEventsV2Notifier(this._adapter, this._sportId, this._timeRange)
      : super(EventsV2State.initial()) {
    _rebuild();
    _sub = _adapter.onLeaguesChanged.listen((_) => _schedule());
    _updateSub = _adapter.onUpdate.listen((update) {
      _scheduleDataOnly();
      _healEmptyInsertedLeagues(update.addedLeagueIds);
    });
    _triggerPopulate();
    _reconcileTimer = Timer.periodic(
      _reconcileInterval,
      (_) => _triggerPopulate(background: true),
    );
  }

  static const _liveInterval = Duration(seconds: 300);
  static const _todayInterval = Duration(seconds: 600);
  static const _earlyInterval = Duration(seconds: 600);
  Duration get _reconcileInterval {
    switch (_timeRange) {
      case EventTimeRange.live:
        return _liveInterval;
      case EventTimeRange.today:
        return _todayInterval;
      case EventTimeRange.early:
      case EventTimeRange.todayAndEarly:
        return _earlyInterval;
    }
  }

  void _triggerPopulate({bool background = false}) {
    final Future<void> populate;
    switch (_timeRange) {
      case EventTimeRange.live:
        populate = _adapter.fetchLiveAndPopulate(background: background);
        break;
      case EventTimeRange.today:
        populate = _adapter.fetchTodayAndPopulate(background: background);
        break;
      case EventTimeRange.early:
        populate = _adapter.fetchEarlyAndPopulate(background: background);
        break;
      case EventTimeRange.todayAndEarly:
        populate = _adapter.fetchTodayEarlyAndPopulate(
          background: background,
        );
        break;
    }
    _populatingCount++;
    unawaited(populate.whenComplete(() {
      _populatingCount--;
      if (!mounted) return;
      _rebuild();
      _healColdTab();
    }));
  }

  int _autoRetries = 0;
  static const _maxAutoRetries = 2;

  void _healColdTab() {
    if (_populatingCount > 0 || !state.isLoading) return;
    final outcome = _adapter.lastPopulateOutcome(_sportId, _socketTimeRange);
    switch (outcome) {
      case PopulateOutcome.superseded:
      case PopulateOutcome.skipped:
        if (_autoRetries >= _maxAutoRetries) {
          debugPrint(
            '[EventsV2] cold $_socketTimeRange: $outcome after '
            '$_autoRetries retries → error',
          );
          state = EventsV2State.error(_populateErrorMessage);
          return;
        }
        _autoRetries++;
        debugPrint(
          '[EventsV2] cold $_socketTimeRange: $outcome → retry '
          '$_autoRetries/$_maxAutoRetries once idle',
        );
        unawaited(_retryOnceIdle());
      case PopulateOutcome.failed:
        state = EventsV2State.error(_populateErrorMessage);
      case PopulateOutcome.applied:
      case null:
        break;
    }
  }

  Future<void> _retryOnceIdle() async {
    for (var round = 0; round < 3; round++) {
      await _adapter.populateIdle;
      if (!mounted || !state.isLoading || _populatingCount > 0) return;
      if (!_adapter.populateInFlight) {
        _triggerPopulate();
        return;
      }
    }
  }

  String get _populateErrorMessage =>
      localizedOrGenericError('populate:$_socketTimeRange', null);

  int _populatingCount = 0;

  String get _socketTimeRange {
    switch (_timeRange) {
      case EventTimeRange.live:
        return socket.TimeRange.live;
      case EventTimeRange.today:
        return socket.TimeRange.today;
      case EventTimeRange.early:
        return socket.TimeRange.early;
      case EventTimeRange.todayAndEarly:
        return socket.TimeRange.todayEarly;
    }
  }

  static final Map<int, DateTime> _leagueInsertHealAt = {};
  static const _leagueInsertHealCooldown = Duration(seconds: 60);

  @visibleForTesting
  static void debugResetLeagueInsertHealCooldown() =>
      _leagueInsertHealAt.clear();

  void _healEmptyInsertedLeagues(List<int> addedLeagueIds) {
    if (addedLeagueIds.isEmpty) return;
    final now = DateTime.now();
    final targets = <int>[];
    for (final id in addedLeagueIds) {
      if (id <= 0) continue;
      final last = _leagueInsertHealAt[id];
      if (last != null && now.difference(last) < _leagueInsertHealCooldown) {
        continue;
      }
      if (_adapter.leagueHasEvents(id)) continue;
      targets.add(id);
    }
    if (targets.isEmpty) return;
    for (final id in targets) {
      _leagueInsertHealAt[id] = now;
    }
    unawaited(
      _adapter
          .fetchLeaguesAndMerge(leagueIds: targets, timeRange: _socketTimeRange)
          .whenComplete(() {
        if (mounted) _rebuild();
      }),
    );
  }

  static const _liveDataOnlyConvertInterval = eventsDataOnlyThrottleLive;
  static const _prematchDataOnlyConvertInterval = eventsDataOnlyThrottlePrematch;
  Duration get _dataOnlyConvertInterval => _timeRange == EventTimeRange.live
      ? _liveDataOnlyConvertInterval
      : _prematchDataOnlyConvertInterval;
  DateTime? _lastDataOnlyConvertAt;
  Timer? _dataOnlyConvertTimer;

  void _scheduleDataOnly() {
    if (_dataOnlyConvertTimer != null) return;
    final last = _lastDataOnlyConvertAt;
    final wait = last == null
        ? Duration.zero
        : _dataOnlyConvertInterval - DateTime.now().difference(last);
    _dataOnlyConvertTimer = Timer(wait.isNegative ? Duration.zero : wait, () {
      _dataOnlyConvertTimer = null;
      _lastDataOnlyConvertAt = DateTime.now();
      _schedule();
    });
  }

  void _schedule() {
    if (ScrollHold.instance.active) {
      if (PerfFlags.trace) PerfCounters.hit('hold.tick');
      if (!_holdDirty) {
        _holdDirty = true;
        ScrollHold.instance.onRelease(_releaseHold, late: true);
      }
      return;
    }
    if (_frameScheduled) return;
    _frameScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _frameScheduled = false;
      if (!mounted) return;
      _rebuild();
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  void _releaseHold() {
    if (!_holdDirty) return;
    _holdDirty = false;
    if (!mounted) return;
    if (PerfFlags.trace) PerfCounters.hit('hold.flush');
    _rebuild();
  }

  void _rebuild() {
    if (_populatingCount > 0) return;

    final storeRange = _adapter.lastPopulateTimeRange;
    final synced = storeRange == _socketTimeRange &&
        _adapter.lastPopulateSportId == _sportId;
    if (storeRange != null && !synced) return;

    var leagues = _adapter.buildV2Leagues(_sportId);
    if (_timeRange == EventTimeRange.live) {
      leagues = liveOnlyLeagues(leagues);
    }
    if (leagues.isEmpty && !synced) {
      if (state.error != null) return;
      state = EventsV2State.loading();
      return;
    }
    state = EventsV2State.loaded(leagues);
  }

  DateTime? _lastStaleOfferRefreshAt;

  @override
  Future<void> refreshOnStaleOffer({int? leagueId}) async {
    final last = _lastStaleOfferRefreshAt;
    if (last != null &&
        DateTime.now().difference(last) <
            EventsV2NotifierBase.staleOfferRefreshCooldown) {
      return;
    }
    _lastStaleOfferRefreshAt = DateTime.now();

    if (leagueId != null && leagueId > 0) {
      unawaited(
        _adapter
            .fetchLeaguesAndMerge(
              leagueIds: [leagueId],
              timeRange: _socketTimeRange,
            )
            .whenComplete(() {
          if (mounted) _rebuild();
        }),
      );
      return;
    }
    _triggerPopulate();
  }

  @override
  void refreshOnReconnect() => _triggerPopulate();

  @override
  Future<void> refresh() async {
    _autoRetries = 0;
    if (state.error != null) state = EventsV2State.loading();
    _triggerPopulate();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _updateSub?.cancel();
    _dataOnlyConvertTimer?.cancel();
    _reconcileTimer?.cancel();
    _holdDirty = false;
    ScrollHold.instance.cancel(_releaseHold);
    super.dispose();
  }
}

final AutoDisposeStateNotifierProvider<EventsV2NotifierBase, EventsV2State>
eventsV2Provider = StateNotifierProvider.autoDispose<
    EventsV2NotifierBase, EventsV2State>((ref) {
  final coordinator = ref.read(reconnectCoordinatorProvider);

  if (ref.watch(useSocketStoreProvider)) {
    final adapter = ref.watch(sportSocketAdapterProvider);
    final filter = ref.watch(eventFilterV2Provider);
    final notifier =
        StoreBackedEventsV2Notifier(adapter, filter.sportId, filter.timeRange);

    void reconnectCb() => notifier.refreshOnReconnect();
    coordinator.register(reconnectCb);
    ref.onDispose(() => coordinator.unregister(reconnectCb));
    ref.listen(staleOfferHealBusProvider, (prev, next) {
      notifier.refreshOnStaleOffer(leagueId: next.leagueId);
    });
    return notifier;
  }

  final repository = ref.watch(eventsV2RepositoryProvider);
  final filter = ref.watch(eventFilterV2Provider);
  final notifier = EventsV2Notifier(repository, filter);

  void reconnectCb() => notifier.refreshOnReconnect();
  coordinator.register(reconnectCb);
  ref.onDispose(() {
    coordinator.unregister(reconnectCb);
    notifier.stopAutoRefresh();
  });
  ref.listen(staleOfferHealBusProvider, (prev, next) {
    notifier.refreshOnStaleOffer(leagueId: next.leagueId);
  });
  return notifier;
});

class TabEventsV2Notifier extends EventsV2NotifierBase {
  final EventsV2Repository _repository;
  final int sportId;
  final EventTimeRange timeRange;
  final int? sportTypeId;
  final Duration refreshInterval;

  CancelToken? _cancelToken;
  Timer? _refreshTimer;

  TabEventsV2Notifier({
    required EventsV2Repository repository,
    required this.sportId,
    required this.timeRange,
    required this.refreshInterval,
    this.sportTypeId,
  }) : _repository = repository,
       super(EventsV2State.initial()) {
    fetchEvents();
  }

  @override
  void dispose() {
    _cancelToken?.cancel('Disposed');
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchEvents() async {
    _cancelToken?.cancel('New request');
    _cancelToken = CancelToken();
    _refreshTimer?.cancel();

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final request = EventsRequestModel(
        sportId: sportId,
        timeRange: timeRange.value,
        sportTypeId: sportTypeId,
        sortByTime: false,
      );

      final leagues = await _repository.getEventsWithCancel(
        request,
        _cancelToken!,
      );

      if (mounted) {
        state = EventsV2State.loaded(
          timeRange == EventTimeRange.live ? liveOnlyLeagues(leagues) : leagues,
        );
        _startAutoRefresh();
      }
    } on DioException catch (e) {
      if (e.type != DioExceptionType.cancel && mounted) {
        state = EventsV2State.error('Failed to load: ${e.message}');
      }
    } on CancelledException {
    } catch (e) {
      if (mounted) {
        state = EventsV2State.error('Error: $e');
      }
    }
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(refreshInterval, (_) {
      if (mounted) _silentRefresh();
    });
  }

  Future<void> _silentRefresh() async {
    try {
      final request = EventsRequestModel(
        sportId: sportId,
        timeRange: timeRange.value,
        sportTypeId: sportTypeId,
        sortByTime: false,
      );

      final leagues = await _repository.getEvents(request);
      if (mounted) {
        state = EventsV2State.loaded(
          timeRange == EventTimeRange.live ? liveOnlyLeagues(leagues) : leagues,
        );
      }
    } catch (_) {}
  }

  @override
  Future<void> refresh() => fetchEvents();

  @override
  void refreshOnReconnect() {
    fetchEvents();
  }

  DateTime? _lastStaleOfferRefreshAt;

  @override
  Future<void> refreshOnStaleOffer({int? leagueId}) async {
    final last = _lastStaleOfferRefreshAt;
    if (last != null &&
        DateTime.now().difference(last) <
            EventsV2NotifierBase.staleOfferRefreshCooldown) {
      return;
    }
    _lastStaleOfferRefreshAt = DateTime.now();
    await _silentRefresh();
  }
}

final liveEventsV2Provider =
    StateNotifierProvider.autoDispose<EventsV2NotifierBase, EventsV2State>((
      ref,
    ) {
      final sport = ref.watch(selectedSportV2Provider);
      final boxingType = ref.watch(selectedBoxingTypeV2Provider);
      final sportTypeId = sport == SportType.boxing ? boxingType?.id : null;

      final EventsV2NotifierBase notifier;
      if (ref.watch(useSocketStoreProvider) && sportTypeId == null) {
        final adapter = ref.watch(sportSocketAdapterProvider);
        notifier = StoreBackedEventsV2Notifier(
          adapter,
          sport.id,
          EventTimeRange.live,
        );
        final coordinator = ref.read(reconnectCoordinatorProvider);
        void reconnectCb() => notifier.refreshOnReconnect();
        coordinator.register(reconnectCb);
        ref.onDispose(() => coordinator.unregister(reconnectCb));
      } else {
        final repository = ref.watch(eventsV2RepositoryProvider);
        notifier = TabEventsV2Notifier(
          repository: repository,
          sportId: sport.id,
          timeRange: EventTimeRange.live,
          sportTypeId: sportTypeId,
          refreshInterval: const Duration(seconds: 10),
        );
      }
      ref.listen(staleOfferHealBusProvider, (prev, next) {
        notifier.refreshOnStaleOffer(leagueId: next.leagueId);
      });
      return notifier;
    });

final liveEventCountV2Provider = Provider.autoDispose<int>((ref) {
  final events = ref.watch(eventsV2Provider);
  return events.allLiveEvents.length;
});

final leaguesV2Provider = Provider.autoDispose<List<LeagueModelV2>>((ref) {
  final leagues = ref.watch(eventsV2Provider.select((s) => s.leagues));

  final sportId = ref.watch(selectedSportV2Provider.select((s) => s.id));
  final favoriteData = ref.watch(
    favoriteProvider.select((s) => s.getFavoriteData(sportId)),
  );

  if (favoriteData == null && ref.read(isAuthenticatedProvider)) {
    final favNotifier = ref.read(favoriteProvider.notifier);
    Future.microtask(() => favNotifier.fetchFavorites(sportId));
  }

  return FavoriteApplier.applyFavorites(leagues, favoriteData);
});

final totalEventsCountV2Provider = Provider.autoDispose<int>((ref) {
  final events = ref.watch(eventsV2Provider);
  return events.totalEvents;
});

final eventsV2LoadingProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(eventsV2Provider).isLoading;
});

final eventsV2ErrorProvider = Provider.autoDispose<String?>((ref) {
  return ref.watch(eventsV2Provider).error;
});

final leaguesLegacyProvider = Provider.autoDispose<List<LeagueData>>((ref) {
  final leagues = ref.watch(leaguesV2Provider);
  return leagues.toLegacy();
});
