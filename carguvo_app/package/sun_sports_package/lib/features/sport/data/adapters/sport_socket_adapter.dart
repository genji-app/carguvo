import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sport_socket/sport_socket.dart' as socket;
import 'package:sun_sports/core/perf/dart_stress.dart';
import 'package:sun_sports/core/perf/stall_monitor.dart';
import 'package:sun_sports/core/services/adapters/league_adapter.dart';
import 'package:sun_sports/features/sport/data/adapters/sport_api_service_impl.dart';
import 'package:sun_sports/core/services/converters/store_to_v2_converter.dart';
import 'package:sun_sports/core/services/models/api_v2/event_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/league_model_v2.dart';
import 'package:sun_sports/core/services/datasources/events_v2_remote_datasource.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/core/services/websocket/betslip_subscription_manager.dart';
import 'package:sun_sports/core/services/websocket/socket_sub_mode.dart';
import 'package:sun_sports/core/services/websocket/subscription_manager.dart';
import 'package:sun_sports/core/services/websocket/visible_league_subscription_manager.dart';
import 'package:sun_sports/features/sport/domain/repositories/sport_repository.dart';

class SportSocketAdapter {
  final socket.SportSocketClient _client;
  final StreamController<void> _leaguesController =
      StreamController<void>.broadcast();
  final StreamController<SportSocketUpdate> _updateController =
      StreamController<SportSocketUpdate>.broadcast();

  StreamSubscription<socket.DataChangeEvent>? _dataSubscription;
  StreamSubscription<socket.ConnectionStateEvent>? _connectionSubscription;

  SportApiServiceImpl? _apiService;

  bool _initialized = false;

  late final SubscriptionManager _subscriptionManager;

  late final BetslipSubscriptionManager _betslipSubscriptionManager;

  VisibleLeagueSubscriptionManager? _visibleLeagueSubscriptionManager;

  static const _tag = '[SportSocketAdapter]';

  static SportSocketAdapter? _instance;
  static SportSocketAdapter? get instance => _instance;

  static const int _maxLeagueCacheSize = 100;

  static const int _maxEventCacheSize = 500;

  final Map<int, LeagueData> _leagueCache = {};

  final Map<int, LeagueEventData> _eventCache = {};

  SportSocketAdapter({required socket.SocketConfig config})
    : _client = socket.SportSocketClient(config: config) {
    _subscriptionManager = SubscriptionManager(
      client: _client,
      useV2Protocol: config.useV2Protocol,
      language: config.v2Language,
    );
    _betslipSubscriptionManager = BetslipSubscriptionManager(
      subscriptionManager: _subscriptionManager,
      language: config.v2Language,
    );
    _client.dataStore.pruneProtection =
        (eventId) => _betslipSubscriptionManager.holdsEvent(eventId);
    _subscriptionManager.onTimeRangeCommitted = (timeRange) =>
        _client.updateTimeRange(socket.V2TimeRange.toStringValue(timeRange));
    if (SocketSubMode.current.isLeague) {
      _visibleLeagueSubscriptionManager = VisibleLeagueSubscriptionManager(
        subscriptionManager: _subscriptionManager,
      );
      _subscriptionManager.onListContextChanged =
          () => _visibleLeagueSubscriptionManager?.onContextChanged();
    }
    _setupListeners();
    _setupSubscriptionManager();
    _instance = this;
  }

  factory SportSocketAdapter.liveMode({
    required String url,
    socket.Logger? logger,
    socket.AutoRefreshConfig? autoRefreshConfig,
    bool useV2Protocol = false,
    String v2Language = 'vi',
  }) {
    return SportSocketAdapter(
      config: socket.SocketConfig.liveMode(
        url: url,
        logger: logger,
        autoRefreshConfig: autoRefreshConfig ?? socket.AutoRefreshConfig.live(),
        useV2Protocol: useV2Protocol,
        v2Language: v2Language,
      ),
    );
  }

  factory SportSocketAdapter.preMatchMode({
    required String url,
    socket.Logger? logger,
    socket.AutoRefreshConfig? autoRefreshConfig,
    bool useV2Protocol = false,
    String v2Language = 'vi',
  }) {
    return SportSocketAdapter(
      config: socket.SocketConfig.preMatchMode(
        url: url,
        logger: logger,
        autoRefreshConfig:
            autoRefreshConfig ?? socket.AutoRefreshConfig.preMatch(),
        useV2Protocol: useV2Protocol,
        v2Language: v2Language,
      ),
    );
  }

  Future<void> initialize({
    required SportRepository repository,
    required EventsV2RemoteDataSource v2DataSource,
    int sportId = 1,
    bool fetchHot = false,
    bool fetchInitialData = true,
  }) async {
    debugPrint('$_tag 🚀 Initializing with V2 API integration...');

    _apiService = SportApiServiceImpl(
      repository: repository,
      v2DataSource: v2DataSource,
    );

    await _client.initialize(
      apiService: _apiService!,
      sportId: sportId,
      fetchHot: fetchHot,
      fetchInitialData: fetchInitialData,
    );

    _initialized = true;
    debugPrint('$_tag ✅ Initialization complete - sportId: $sportId');
  }

  Future<void> changeSport(int sportId) async {
    if (!_initialized) {
      throw StateError('Adapter not initialized. Call initialize() first.');
    }

    _subscriptionManager.setActiveSport(sportId);

    _clearCaches();

    debugPrint('$_tag 🔄 Changing sport to $sportId...');
    await _client.changeSport(sportId);
    debugPrint('$_tag ✅ Changed to sport $sportId');
  }

  int get currentSportId => _client.currentSportId;

  bool get isInitialized => _initialized;

  SubscriptionManager get subscriptionManager => _subscriptionManager;

  socket.AutoRefreshManager? get autoRefreshManager =>
      _client.autoRefreshManager;

  Future<socket.AutoRefreshResult?> triggerManualRefresh() async {
    return await _client.autoRefreshManager?.triggerRefresh(
      socket.AutoRefreshTrigger.manual,
    );
  }

  void updateTimeRange(String timeRange) {
    debugPrint('$_tag updateTimeRange: $timeRange');

    _client.updateTimeRange(timeRange);

    _subscriptionManager.setTimeRangeFromString(timeRange);
  }

  String get currentTimeRange => _client.currentTimeRange;

  Future<void> fetchLiveAndPopulate({bool background = false}) async {
    if (_apiService == null) {
      debugPrint('$_tag ⚠️ fetchLiveAndPopulate: No API service');
      return;
    }

    final sportId = _client.currentSportId;
    debugPrint('$_tag 📡 fetchLiveAndPopulate - sportId: $sportId (diff-sync)');

    await _apiService!.fetchLiveAndPopulate(
      sportId: sportId,
      store: _client.dataStore,
      background: background,
    );
  }

  Future<void> fetchTodayAndPopulate({bool background = false}) async {
    if (_apiService == null) {
      debugPrint('$_tag ⚠️ fetchTodayAndPopulate: No API service');
      return;
    }

    final sportId = _client.currentSportId;
    debugPrint('$_tag 📡 fetchTodayAndPopulate - sportId: $sportId (diff-sync)');

    await _apiService!.fetchTodayAndPopulate(
      sportId: sportId,
      store: _client.dataStore,
      background: background,
    );
  }

  Future<void> fetchEarlyAndPopulate({bool background = false}) async {
    if (_apiService == null) {
      debugPrint('$_tag ⚠️ fetchEarlyAndPopulate: No API service');
      return;
    }

    final sportId = _client.currentSportId;
    debugPrint('$_tag 📡 fetchEarlyAndPopulate - sportId: $sportId (diff-sync)');

    await _apiService!.fetchEarlyAndPopulate(
      sportId: sportId,
      store: _client.dataStore,
      background: background,
    );
  }

  Future<void> fetchTodayEarlyAndPopulate({bool background = false}) async {
    if (_apiService == null) {
      debugPrint('$_tag ⚠️ fetchTodayEarlyAndPopulate: No API service');
      return;
    }

    final sportId = _client.currentSportId;
    debugPrint(
      '$_tag 📡 fetchTodayEarlyAndPopulate - sportId: $sportId (diff-sync)',
    );

    await _apiService!.fetchTodayEarlyAndPopulate(
      sportId: sportId,
      store: _client.dataStore,
      background: background,
    );
  }

  Future<void> fetchLeaguesAndMerge({
    required List<int> leagueIds,
    required String timeRange,
  }) async {
    if (_apiService == null) {
      debugPrint('$_tag ⚠️ fetchLeaguesAndMerge: No API service');
      return;
    }

    await _apiService!.fetchLeaguesAndMerge(
      sportId: _client.currentSportId,
      leagueIds: leagueIds,
      timeRange: timeRange,
      store: _client.dataStore,
    );
  }

  Future<void> connect() async {
    await _client.connect();
  }

  Future<void> disconnect() async {
    await _client.disconnect();
  }

  Future<void> ensureConnectionAlive() => _client.ensureConnectionAlive();

  void subscribeSport(int sportId) {
    _client.subscribeSport(sportId);
  }

  void unsubscribeSport(int sportId) {
    _client.unsubscribeSport(sportId);
  }

  Set<int> get subscribedSports => _client.subscribedSports;

  bool get isConnected => _client.isConnected;

  socket.ConnectionState get connectionState => _client.connectionState;

  List<LeagueModelV2> buildV2Leagues(int sportId) => DartStress.timed(
        'convert',
        () => StoreToV2Converter.buildLeagues(_client.dataStore, sportId),
      );

  void subscribeHot(
    int sportId, {
    int? timeRange,
    String source = 'hot_match',
  }) {
    _subscriptionManager.registry.subscribe(
      socket.HotMatchKey(sportId, timeRange: timeRange),
      source: source,
    );
  }

  void unsubscribeHot(
    int sportId, {
    int? timeRange,
    String source = 'hot_match',
  }) {
    _subscriptionManager.registry.unsubscribe(
      socket.HotMatchKey(sportId, timeRange: timeRange),
      source: source,
    );
  }

  List<LeagueModelV2> buildHotLeagues(int sportId) =>
      StoreToV2Converter.buildHotLeagues(_client.dataStore, sportId);

  List<int> hotEventOrder(int sportId) =>
      _client.dataStore.getHotOrderBySport(sportId);

  Set<int> hotEventIds(int sportId) => _client.dataStore
      .getHotEventsBySport(sportId)
      .map((e) => e.eventId)
      .toSet();

  String? get lastPopulateTimeRange => _client.dataStore.lastPopulateTimeRange;
  int? get lastPopulateSportId => _client.dataStore.lastPopulateSportId;

  int get lastPopulateStamp => _client.dataStore.populateGeneration;

  PopulateOutcome? lastPopulateOutcome(int sportId, String timeRange) =>
      _apiService?.lastOutcome(sportId, timeRange);

  bool get populateInFlight => _apiService?.populateInFlight ?? false;

  Future<void> get populateIdle =>
      _apiService?.inFlightDone ?? Future<void>.value();

  Stream<void> get onLeaguesChanged => _leaguesController.stream;

  Stream<SportSocketUpdate> get onUpdate => _updateController.stream;

  Stream<socket.DataChangeEvent> get onStoreChanged => _client.onDataChanged;

  void resubscribeDetail(int eventId) =>
      _subscriptionManager.resubscribeDetail(eventId);

  void setBatchFlushPaused(bool paused) {
    if (paused) {
      _client.setBatchFlushPaused(true);
      return;
    }
    final active = _subscriptionManager.subscribedChannels;
    _client.setBatchFlushPaused(
      false,
      flushFirst: (payload) => active.contains(payload.channel),
    );
  }

  Stream<socket.ConnectionStateEvent> get onConnectionChanged =>
      _client.onConnectionChanged;

  Stream<socket.ProcessorMetrics> get onMetrics => _client.onMetrics;

  Stream<socket.ScoreUpdateData> get onScoreUpdate => _client.onScoreUpdate;

  Stream<socket.EventStatusData> get onEventStatusUpdate =>
      _client.onEventStatusUpdate;

  Stream<socket.BalanceUpdateData> get onBalanceUpdate =>
      _client.onBalanceUpdate;

  Stream<socket.MarketStatusData> get onMarketStatusChange =>
      _client.onMarketStatusChange;

  Stream<socket.OddsChangeData> get onOddsChange => _client.onOddsChange;

  Stream<socket.OddsUpdateData> get onOddsUpdate => _client.onOddsUpdate;

  void requestBalance(String custLogin) => _client.requestBalance(custLogin);

  void setSortMode(socket.SortMode mode) {
    _client.dataStore.sortMode = mode;
    _eventCache.clear();
  }

  socket.SortMode get sortMode => _client.dataStore.sortMode;

  bool leagueHasEvents(int leagueId) =>
      _client.dataStore.getEventsByLeague(leagueId).isNotEmpty;

  LeagueData? getLeague(int leagueId) {
    final cached = _leagueCache[leagueId];
    if (cached != null) return cached;

    final store = _client.dataStore;
    final league = store.getLeague(leagueId);
    if (league == null) return null;

    final allEvents = store.getEventsByLeague(leagueId);
    final events = allEvents.toList()
      ..sort(socket.EventData.compareByStartThenId);

    final marketsPerEvent = <int, List<socket.MarketData>>{};
    final oddsPerMarket = <String, List<socket.OddsData>>{};

    for (final event in events) {
      final markets = store.getMarketsByEvent(event.eventId);
      marketsPerEvent[event.eventId] = markets;

      for (final market in markets) {
        final marketKey = '${event.eventId}_${market.marketId}';
        oddsPerMarket[marketKey] = store.getOddsByMarket(
          event.eventId,
          market.marketId,
        );
      }
    }

    final result = LeagueAdapter.toFreezedWithEvents(
      league,
      events,
      marketsPerEvent,
      oddsPerMarket,
    );

    _addToLeagueCache(leagueId, result);
    return result;
  }

  socket.EventData? getEventData(int eventId) {
    return _client.dataStore.getEvent(eventId);
  }

  int marketCountOf(int eventId) =>
      _client.dataStore.getMarketsByEvent(eventId).length;

  EventModelV2? buildDetailEventV2(int eventId) =>
      StoreToV2Converter.buildDetailEvent(_client.dataStore, eventId);

  socket.OddsData? getOdds(int eventId, int marketId, String offerId) {
    return _client.dataStore.getOdds(eventId, marketId, offerId);
  }

  LeagueEventData? getEvent(int eventId) {
    final cached = _eventCache[eventId];
    if (cached != null) return cached;

    final store = _client.dataStore;
    final event = store.getEvent(eventId);
    if (event == null) return null;

    final markets = store.getMarketsByEvent(eventId);
    final oddsPerMarket = <String, List<socket.OddsData>>{};

    for (final market in markets) {
      final marketKey = '${eventId}_${market.marketId}';
      oddsPerMarket[marketKey] = store.getOddsByMarket(
        eventId,
        market.marketId,
      );
    }

    final result = EventAdapter.toFreezedWithMarkets(
      event,
      markets,
      oddsPerMarket,
    );

    _addToEventCache(eventId, result);
    return result;
  }

  socket.ReconciliationResult reconcile(List<socket.LeagueData> apiData) {
    return _client.reconcile(apiData);
  }

  socket.ReconciliationResult reconcileSport({
    required int sportId,
    required List<socket.LeagueData> apiLeagues,
  }) {
    return _client.reconcileSport(sportId: sportId, apiLeagues: apiLeagues);
  }

  socket.ReconciliationResult fullSync({
    required int sportId,
    required List<socket.LeagueData> apiLeagues,
  }) {
    return _client.fullSync(sportId: sportId, apiLeagues: apiLeagues);
  }

  socket.ProcessorMetrics getMetrics() => _client.getMetrics();

  void resetStats() => _client.resetStats();

  void _setupListeners() {
    _dataSubscription = _client.onDataChanged.listen(_handleDataChange);
    _connectionSubscription = _client.onConnectionChanged.listen(
      _handleConnectionChange,
    );
  }

  void _setupSubscriptionManager() {
    _client.onConnectionChanged.listen((event) {
      switch (event.currentState) {
        case socket.ConnectionState.connected:
          if (!_subscriptionManager.isInitialized) {
            _subscriptionManager.init();
          } else {
            _subscriptionManager.onReconnected();
            _betslipSubscriptionManager.onReconnected();
          }
          break;
        case socket.ConnectionState.disconnected:
          _subscriptionManager.onDisconnected();
          break;
        default:
          break;
      }
    });
  }

  void _handleDataChange(socket.DataChangeEvent event) =>
      PerfWork.time('fan.data', () => _fanOutDataChange(event));

  void _fanOutDataChange(socket.DataChangeEvent event) {
    if (event.isEmpty) return;

    _invalidateCaches(event);

    _updateController.add(
      SportSocketUpdate(
        updatedLeagueIds: event.updatedLeagueIds,
        updatedEventIds: event.updatedEventIds,
        updatedMarketKeys: event.updatedMarketKeys,
        updatedOddsKeys: event.updatedOddsKeys,
        addedLeagueIds: event.addedLeagueIds,
        addedEventIds: event.addedEventIds,
        removedLeagueIds: event.removedLeagueIds,
        removedEventIds: event.removedEventIds,
        timestamp: event.timestamp,
      ),
    );

    final hasStructuralChanges =
        event.addedLeagueIds.isNotEmpty ||
        event.addedEventIds.isNotEmpty ||
        event.removedLeagueIds.isNotEmpty ||
        event.removedEventIds.isNotEmpty;

    if (hasStructuralChanges) {
      if (kDebugMode) {
        debugPrint(
          '$_tag Structural changes - '
          'added: ${event.addedLeagueIds.length} leagues, ${event.addedEventIds.length} events | '
          'removed: ${event.removedLeagueIds.length} leagues, ${event.removedEventIds.length} events',
        );
      }
      _leaguesController.add(null);
    }
  }

  void _handleConnectionChange(socket.ConnectionStateEvent event) {
    if (event.currentState == socket.ConnectionState.disconnected) {
      _clearCaches();
    }
  }

  void _addToLeagueCache(int leagueId, LeagueData league) {
    if (_leagueCache.length >= _maxLeagueCacheSize) {
      _leagueCache.remove(_leagueCache.keys.first);
    }
    _leagueCache[leagueId] = league;
  }

  void _addToEventCache(int eventId, LeagueEventData event) {
    if (_eventCache.length >= _maxEventCacheSize) {
      _eventCache.remove(_eventCache.keys.first);
    }
    _eventCache[eventId] = event;
  }

  void _invalidateCaches(socket.DataChangeEvent event) {
    for (final leagueId in event.updatedLeagueIds) {
      _leagueCache.remove(leagueId);
    }
    for (final eventId in event.updatedEventIds) {
      _eventCache.remove(eventId);
    }
    for (final marketKey in event.updatedMarketKeys) {
      final eventId = int.tryParse(marketKey.split('_').first);
      if (eventId != null) _eventCache.remove(eventId);
    }
    for (final oddsKey in event.updatedOddsKeys) {
      final parts = oddsKey.split('_');
      if (parts.isNotEmpty) {
        final eventId = int.tryParse(parts.first);
        if (eventId != null) _eventCache.remove(eventId);
      }
    }
    for (final leagueId in event.removedLeagueIds) {
      _leagueCache.remove(leagueId);
    }
    for (final eventId in event.removedEventIds) {
      _eventCache.remove(eventId);
    }
  }

  void _clearCaches() {
    _leagueCache.clear();
    _eventCache.clear();
  }

  Future<void> dispose() async {
    if (_instance == this) {
      _instance = null;
    }
    await _dataSubscription?.cancel();
    await _connectionSubscription?.cancel();
    await _leaguesController.close();
    await _updateController.close();
    _visibleLeagueSubscriptionManager?.dispose();
    _betslipSubscriptionManager.dispose();
    _subscriptionManager.dispose();
    await _client.dispose();
  }
}

class SportSocketUpdate {
  final Set<int> updatedLeagueIds;

  final Set<int> updatedEventIds;

  final Set<String> updatedMarketKeys;

  final Set<String> updatedOddsKeys;

  final List<int> addedLeagueIds;

  final List<int> addedEventIds;

  final List<int> removedLeagueIds;

  final List<int> removedEventIds;

  final DateTime timestamp;

  const SportSocketUpdate({
    required this.updatedLeagueIds,
    required this.updatedEventIds,
    required this.updatedMarketKeys,
    required this.updatedOddsKeys,
    required this.addedLeagueIds,
    required this.addedEventIds,
    required this.removedLeagueIds,
    required this.removedEventIds,
    required this.timestamp,
  });

  bool affectsEvent(int eventId) =>
      updatedEventIds.contains(eventId) ||
      addedEventIds.contains(eventId) ||
      removedEventIds.contains(eventId);

  bool affectsLeague(int leagueId) =>
      updatedLeagueIds.contains(leagueId) ||
      addedLeagueIds.contains(leagueId) ||
      removedLeagueIds.contains(leagueId);

  bool affectsMarket(int eventId, int marketId) {
    final key = '${eventId}_$marketId';
    return updatedMarketKeys.contains(key);
  }

  bool get isOddsOnlyUpdate =>
      updatedOddsKeys.isNotEmpty &&
      addedLeagueIds.isEmpty &&
      addedEventIds.isEmpty &&
      removedLeagueIds.isEmpty &&
      removedEventIds.isEmpty &&
      updatedLeagueIds.isEmpty;

  bool get hasStructuralChanges =>
      addedLeagueIds.isNotEmpty ||
      addedEventIds.isNotEmpty ||
      removedLeagueIds.isNotEmpty ||
      removedEventIds.isNotEmpty;
}
