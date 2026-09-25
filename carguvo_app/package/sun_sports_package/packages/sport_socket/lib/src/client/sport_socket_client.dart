import 'dart:async';
import 'dart:typed_data';

import 'socket_config.dart';
import 'connection_handler.dart';
import 'reconciliation_service.dart';
import '../api/i_sport_api_service.dart';
import '../api/auto_refresh_manager.dart';
import '../processor/message_processor.dart';
import '../processor/light_batch_processor.dart';
import '../processor/payload_router.dart';
import '../parser/proto_parser.dart';
import '../proto/proto.dart' show Payload;
import '../data/sport_data_store.dart';
import '../data/models/league_data.dart';
import '../data/models/score_update_data.dart';
import '../data/models/event_status_data.dart';
import '../data/models/balance_update_data.dart';
import '../data/models/market_status_data.dart';
import '../data/models/odds_change_data.dart';
import '../data/models/odds_update_data.dart';
import '../events/connection_state.dart';
import '../events/data_change_event.dart';
import '../events/processor_metrics.dart';
import '../utils/logger.dart';
import '../utils/perf_hooks.dart';

class SportSocketClient {
  final SocketConfig _config;
  final Logger _logger;

  late final ConnectionHandler _connectionHandler;

  late final MessageProcessor _messageProcessor;

  late final SportDataStore _dataStore;

  late final ReconciliationService _reconciliationService;

  ProtoParser? _protoParser;

  LightBatchProcessor? _batchProcessor;

  PayloadRouter? _payloadRouter;

  StreamSubscription<Uint8List>? _binaryMessageSubscription;

  StreamSubscription<void>? _v2ReconnectedSubscription;

  ISportApiService? _apiService;

  AutoRefreshManager? _autoRefreshManager;

  int _currentSportId = 1;

  int _primarySportId = 1;

  bool _wasConnectedBefore = false;

  StreamSubscription<String>? _messageSubscription;

  StreamSubscription<ConnectionStateEvent>? _connectionStateSubscription;

  bool _disposed = false;

  final StreamController<ScoreUpdateData> _scoreController =
      StreamController<ScoreUpdateData>.broadcast();

  final StreamController<EventStatusData> _eventStatusController =
      StreamController<EventStatusData>.broadcast();

  final StreamController<BalanceUpdateData> _balanceController =
      StreamController<BalanceUpdateData>.broadcast();

  final StreamController<MarketStatusData> _marketStatusController =
      StreamController<MarketStatusData>.broadcast();

  final StreamController<OddsChangeData> _oddsChangeController =
      StreamController<OddsChangeData>.broadcast();

  final StreamController<OddsUpdateData> _oddsUpdateController =
      StreamController<OddsUpdateData>.broadcast();

  SportSocketClient({
    required SocketConfig config,
  })  : _config = config,
        _logger = config.logger {
    _dataStore = SportDataStore();

    _messageProcessor = MessageProcessor(
      sampleInterval: config.sampleInterval,
      maxParsePerSample: config.maxParsePerSample,
      maxPendingQueueSize: config.maxPendingQueueSize,
      pendingExpiration: config.pendingExpiration,
      logger: config.logger,
    );

    _connectionHandler = ConnectionHandler(config: config);

    _reconciliationService = ReconciliationService(
      store: _dataStore,
      logger: config.logger,
    );

    if (config.useV2Protocol) {
      _initializeV2Components();
    }
  }

  void _initializeV2Components() {
    _logger.info('[SportSocket] 🆕 Initializing V2 Protocol components...');

    _protoParser = ProtoParser();

    _batchProcessor = LightBatchProcessor(
      batchInterval: _config.v2BatchInterval,
      maxBatchSize: _config.v2MaxBatchSize,
    );

    _payloadRouter = PayloadRouter(logger: _logger);

    _batchProcessor!.onBatch = (payloads) {
      _payloadRouter!.routeBatch(payloads, _dataStore);
    };

    _payloadRouter!.onScoreUpdate = (eventId, sportId, score) {
      int homeScore = 0;
      int awayScore = 0;

      if (score.hasSoccer()) {
        homeScore = score.soccer.homeScore;
        awayScore = score.soccer.awayScore;
      } else if (score.hasBasketball()) {
        homeScore = score.basketball.homeScoreFT;
        awayScore = score.basketball.awayScoreFT;
      }

      final data = ScoreUpdateData(
        eventId: eventId,
        sportId: sportId,
        homeScore: homeScore,
        awayScore: awayScore,
        timestamp: DateTime.now(),
      );
      final wrap = SportSocketPerfHooks.wrap;
      if (wrap == null) {
        _scoreController.add(data);
      } else {
        wrap<void>('fan.live', () => _scoreController.add(data));
      }
    };

    _payloadRouter!.onEventStatusUpdate = (eventId, event) {
      int? homeScore;
      int? awayScore;
      int? homeScoreOT;
      int? awayScoreOT;
      int? cornersHome;
      int? cornersAway;
      int? yellowCardsHome;
      int? yellowCardsAway;
      int? redCardsHome;
      int? redCardsAway;

      if (event.hasLiveScore()) {
        final score = event.liveScore;
        if (score.hasSoccer()) {
          final soccer = score.soccer;
          if (soccer.hasHomeScore()) homeScore = soccer.homeScore;
          if (soccer.hasAwayScore()) awayScore = soccer.awayScore;
          if (soccer.hasHomeCorner()) cornersHome = soccer.homeCorner;
          if (soccer.hasAwayCorner()) cornersAway = soccer.awayCorner;
          if (soccer.hasYellowCardsHome()) {
            yellowCardsHome = soccer.yellowCardsHome;
          }
          if (soccer.hasYellowCardsAway()) {
            yellowCardsAway = soccer.yellowCardsAway;
          }
          if (soccer.hasRedCardsHome()) redCardsHome = soccer.redCardsHome;
          if (soccer.hasRedCardsAway()) redCardsAway = soccer.redCardsAway;
          if (soccer.hasHomeScoreOT()) homeScoreOT = soccer.homeScoreOT;
          if (soccer.hasAwayScoreOT()) awayScoreOT = soccer.awayScoreOT;
        } else if (score.hasBasketball()) {
          if (score.basketball.hasHomeScoreFT()) {
            homeScore = score.basketball.homeScoreFT;
          }
          if (score.basketball.hasAwayScoreFT()) {
            awayScore = score.basketball.awayScoreFT;
          }
        } else if (score.hasTennis()) {
          if (score.tennis.hasHomeSetScore()) {
            homeScore = score.tennis.homeSetScore;
          }
          if (score.tennis.hasAwaySetScore()) {
            awayScore = score.tennis.awaySetScore;
          }
        } else if (score.hasVolleyball()) {
          if (score.volleyball.hasHomeSetScore()) {
            homeScore = score.volleyball.homeSetScore;
          }
          if (score.volleyball.hasAwaySetScore()) {
            awayScore = score.volleyball.awaySetScore;
          }
        }
      }

      final data = EventStatusData(
        eventId: eventId,
        sportId: event.sportId,
        isLive: event.isLive,
        isLivestream: event.hasIsLiveStream() ? event.isLiveStream : null,
        isSuspended: event.isSuspended,
        gameTime: event.gameTime,
        gamePart: event.gamePart,
        stoppageTime: event.stoppageTime,
        homeScore: homeScore,
        awayScore: awayScore,
        homeScoreOT: homeScoreOT,
        awayScoreOT: awayScoreOT,
        cornersHome: cornersHome,
        cornersAway: cornersAway,
        yellowCardsHome: yellowCardsHome,
        yellowCardsAway: yellowCardsAway,
        redCardsHome: redCardsHome,
        redCardsAway: redCardsAway,
        timestamp: DateTime.now(),
      );
      final wrap = SportSocketPerfHooks.wrap;
      if (wrap == null) {
        _eventStatusController.add(data);
      } else {
        wrap<void>('fan.live', () => _eventStatusController.add(data));
      }
    };

    _payloadRouter!.onOddsChange = (data) {
      final wrap = SportSocketPerfHooks.wrap;
      if (wrap == null) {
        _oddsChangeController.add(data);
      } else {
        wrap<void>('fan.odds', () => _oddsChangeController.add(data));
      }
    };

    _payloadRouter!.onOddsUpdate = (data) {
      final wrap = SportSocketPerfHooks.wrap;
      if (wrap == null) {
        _oddsUpdateController.add(data);
      } else {
        wrap<void>('fan.odds', () => _oddsUpdateController.add(data));
      }
    };

    _logger.info('[SportSocket] ✅ V2 Protocol components initialized');
  }

  void updateUrl(String url) {
    _ensureNotDisposed();
    _connectionHandler.updateUrl(url);
  }

  Future<void> connect() async {
    _ensureNotDisposed();

    _logger.info('SportSocketClient connecting...');

    if (_config.useV2Protocol) {
      _batchProcessor?.start();

      _binaryMessageSubscription =
          _connectionHandler.onBinaryMessage.listen((bytes) {
        final wrap = SportSocketPerfHooks.wrap;
        final payload = wrap == null
            ? _protoParser?.parse(bytes)
            : wrap('decode', () => _protoParser?.parse(bytes));
        if (payload != null) {
          _batchProcessor?.add(payload);
        }
      });

      _v2ReconnectedSubscription = _connectionHandler.onReconnected.listen((_) {
        _logger.info(
            '[SportSocket] 🔄 V2 Reconnected - channels will be resubscribed by SubscriptionManager');
      });

      _logger.info(
          '[SportSocket] V2 Protocol: Binary message pipeline configured');
    } else {
      _messageProcessor.start();

      _messageSubscription = _connectionHandler.onMessage.listen((raw) {
        _messageProcessor.onMessage(raw);
      });
    }

    await _connectionHandler.connect();
  }

  void setBatchFlushPaused(
    bool paused, {
    bool Function(Payload payload)? flushFirst,
  }) {
    final processor = _batchProcessor;
    if (processor == null) return;
    if (paused) {
      processor.pause();
    } else {
      processor.resume(flushFirst: flushFirst);
    }
  }

  Future<void> disconnect() async {
    _ensureNotDisposed();
    await _disconnectInternal();
  }

  Future<void> _disconnectInternal() async {
    _logger.info('[SportSocket] 🔌 DISCONNECTING...');

    if (_autoRefreshManager != null) {
      _logger.info('[SportSocket] Stopping AutoRefreshManager...');
      _autoRefreshManager!.stop();
    }

    if (_config.useV2Protocol) {
      _batchProcessor?.stop();
      await _binaryMessageSubscription?.cancel();
      _binaryMessageSubscription = null;
      await _v2ReconnectedSubscription?.cancel();
      _v2ReconnectedSubscription = null;
    } else {
      _messageProcessor.stop();
    }

    await _messageSubscription?.cancel();
    _messageSubscription = null;

    await _connectionHandler.disconnect();

    _logger.info('[SportSocket] ✅ DISCONNECTED');
  }

  Future<void> ensureConnectionAlive() async {
    _ensureNotDisposed();
    await _connectionHandler.ensureAlive();
  }

  bool get isConnected => _connectionHandler.isConnected;

  ConnectionState get connectionState => _connectionHandler.state;

  void subscribeSport(int sportId) {
    _ensureNotDisposed();
    _messageProcessor.subscribeSport(sportId);
    _logger.info('Subscribed to sport: $sportId');

    if (isConnected) {
      _sendSubscribe(sportId);
    }
  }

  void unsubscribeSport(int sportId) {
    _ensureNotDisposed();
    _messageProcessor.unsubscribeSport(sportId);
    _logger.info('Unsubscribed from sport: $sportId');

    if (isConnected) {
      _sendUnsubscribe(sportId);
    }

    _dataStore.clearSport(sportId);
  }

  Set<int> get subscribedSports => _messageProcessor.subscribedSports;

  void setPrimarySport(int sportId) {
    _ensureNotDisposed();
    _primarySportId = sportId;
    _messageProcessor.setPrimarySport(sportId);

    _currentSportId = sportId;
    _autoRefreshManager?.updateSportId(sportId);

    _logger.info(
        '[SportSocket] 🎯 PRIMARY SPORT set to: $sportId (currentSportId synced)');

    if (!_messageProcessor.subscribedSports.contains(sportId)) {
      subscribeSport(sportId);
    }
  }

  int get primarySportId => _primarySportId;

  bool isPrimarySport(int sportId) => sportId == _primarySportId;

  void _sendSubscribe(int sportId) {
    final message = 'SUB:s:$sportId';
    _logger.info('[SportSocket] 📤 SEND SUBSCRIBE: $message');
    _connectionHandler.send(message);
  }

  void _sendUnsubscribe(int sportId) {
    final message = 'UNSUB:s:$sportId';
    _logger.info('[SportSocket] 📤 SEND UNSUBSCRIBE: $message');
    _connectionHandler.send(message);
  }

  void sendRaw(dynamic message) {
    _ensureNotDisposed();
    if (isConnected) {
      final size =
          message is List ? message.length : (message as String).length;
      _logger.debug(
          '[SportSocket] 📤 SEND RAW: $size ${message is List ? 'bytes' : 'chars'}');
      _connectionHandler.send(message);
    } else {
      _logger.warning('[SportSocket] ⚠️ Cannot send - not connected');
    }
  }

  SportDataStore get dataStore => _dataStore;

  Stream<DataChangeEvent> get onDataChanged => _dataStore.onChanged;

  Stream<ConnectionStateEvent> get onConnectionChanged =>
      _connectionHandler.onStateChanged;

  Stream<ProcessorMetrics> get onMetrics => _messageProcessor.metricsStream;

  Stream<ScoreUpdateData> get onScoreUpdate => _scoreController.stream;

  Stream<EventStatusData> get onEventStatusUpdate =>
      _eventStatusController.stream;

  Stream<BalanceUpdateData> get onBalanceUpdate => _balanceController.stream;

  Stream<MarketStatusData> get onMarketStatusChange =>
      _marketStatusController.stream;

  Stream<OddsChangeData> get onOddsChange => _oddsChangeController.stream;

  Stream<OddsUpdateData> get onOddsUpdate => _oddsUpdateController.stream;

  void requestBalance(String custLogin) {
    _ensureNotDisposed();
    if (isConnected) {
      _connectionHandler.send('userbal:$custLogin');
      _logger.info('[SportSocket] 💰 Requested balance for: $custLogin');
    }
  }

  Future<void> initialize({
    required ISportApiService apiService,
    int sportId = 1,
    bool fetchHot = false,
    bool fetchInitialData = true,
  }) async {
    _ensureNotDisposed();

    _apiService = apiService;
    _currentSportId = sportId;

    _logger.info(
        '[SportSocket] 🚀 INITIALIZING - sportId: $sportId, fetchHot: $fetchHot');

    _logger.info('[SportSocket] Step 1/5: Connecting WebSocket...');
    await connect();
    await _waitForConnection();
    _logger.info('[SportSocket] Step 1/5: ✅ WebSocket connected');

    if (fetchInitialData) {
      _logger.info(
          '[SportSocket] Step 2/5: Fetching initial API data (🚀 INITIAL)...');
      await _fetchInitialData(sportId: sportId, fetchHot: fetchHot);
      _logger.info('[SportSocket] Step 2/5: ✅ Initial API data loaded');
    } else {
      _logger.info(
          '[SportSocket] Step 2/5: ⏭️ Initial API fetch SKIPPED (deferred to first sport screen)');
    }

    _logger.info(
        '[SportSocket] Step 3/5: Subscribing to sport $sportId on WebSocket...');
    subscribeSport(sportId);
    _logger.info('[SportSocket] Step 3/5: ✅ Subscribed to sport $sportId');

    if (_config.autoRefreshConfig.enabled) {
      _logger.info('[SportSocket] Step 4/5: Starting AutoRefreshManager...');
      _startAutoRefresh();
      _logger.info(
          '[SportSocket] Step 4/5: ✅ AutoRefreshManager started (interval: ${_config.autoRefreshConfig.refreshInterval.inSeconds}s)');
    } else {
      _logger.info('[SportSocket] Step 4/5: ⏭️ AutoRefresh disabled');
    }

    _logger.info('[SportSocket] Step 5/5: Setting up monitors...');
    _setupPendingQueueMonitor();
    _setupReconnectionListener();
    _logger.info('[SportSocket] Step 5/5: ✅ Monitors setup complete');

    _logger.info('[SportSocket] ✅ INITIALIZATION COMPLETE - sportId: $sportId');
  }

  Future<void> changeSport(int sportId) async {
    _ensureNotDisposed();

    if (_currentSportId == sportId) {
      _logger.debug(
          '[SportSocket] Already on sport $sportId, skipping changeSport');
      return;
    }

    if (_apiService == null) {
      throw StateError('Client not initialized. Call initialize() first.');
    }

    final oldSportId = _currentSportId;
    _logger.info(
        '[SportSocket] 🔄 CHANGE SPORT - from: $oldSportId → to: $sportId');

    _logger.info(
        '[SportSocket] Step 1/4: Unsubscribing from sport $oldSportId...');
    unsubscribeSport(oldSportId);

    _logger
        .info('[SportSocket] Step 2/4: Clearing data for sport $oldSportId...');
    _dataStore.clearSport(oldSportId);

    _currentSportId = sportId;

    _autoRefreshManager?.updateSportId(sportId);

    _logger.info(
        '[SportSocket] Step 3/4: Fetching API data for sport $sportId (🚀 CHANGE_SPORT)...');
    await _fetchInitialData(sportId: sportId);

    _logger.info('[SportSocket] Step 4/4: Subscribing to sport $sportId...');
    subscribeSport(sportId);

    _logger
        .info('[SportSocket] ✅ CHANGE SPORT COMPLETE - now on sport $sportId');
  }

  int get currentSportId => _currentSportId;

  AutoRefreshManager? get autoRefreshManager => _autoRefreshManager;

  void updateTimeRange(String timeRange) {
    _logger.info('[SportSocketClient] updateTimeRange: $timeRange');
    _autoRefreshManager?.updateTimeRange(timeRange);
  }

  String get currentTimeRange =>
      _autoRefreshManager?.currentTimeRange ?? 'LIVE';

  Future<void> _waitForConnection(
      {Duration timeout = const Duration(seconds: 10)}) async {
    if (isConnected) return;

    final completer = Completer<void>();
    StreamSubscription<ConnectionStateEvent>? subscription;

    final timer = Timer(timeout, () {
      subscription?.cancel();
      if (!completer.isCompleted) {
        completer.completeError(
          TimeoutException('Connection timeout after ${timeout.inSeconds}s'),
        );
      }
    });

    subscription = onConnectionChanged.listen((event) {
      if (event.currentState == ConnectionState.connected) {
        timer.cancel();
        subscription?.cancel();
        if (!completer.isCompleted) {
          completer.complete();
        }
      } else if (event.currentState == ConnectionState.error) {
        timer.cancel();
        subscription?.cancel();
        if (!completer.isCompleted) {
          completer.completeError(
            StateError('Connection failed: ${event.errorMessage}'),
          );
        }
      }
    });

    return completer.future;
  }

  Future<void> _fetchInitialData({
    required int sportId,
    bool fetchHot = false,
  }) async {
    if (_apiService == null) return;

    final stopwatch = Stopwatch()..start();
    _logger
        .info('[SportSocket] 📡 Fetching initial data with FULL HIERARCHY...');

    try {
      await _apiService!.fetchLiveAndPopulate(
        sportId: sportId,
        store: _dataStore,
      );

      _dataStore.emitBatchChanges();

      stopwatch.stop();

      final leagues = _dataStore.getLeaguesBySport(sportId);
      int totalEvents = 0;
      for (final league in leagues) {
        totalEvents += _dataStore.getEventsByLeague(league.leagueId).length;
      }

      _logger.info(
        '[SportSocket] ✅ INITIAL DATA LOADED\n'
        '   └─ leagues: ${leagues.length}\n'
        '   └─ events: $totalEvents\n'
        '   └─ duration: ${stopwatch.elapsedMilliseconds}ms',
      );
    } catch (e, stack) {
      stopwatch.stop();
      _logger.error(
          '[SportSocket] ❌ FETCH FAILED after ${stopwatch.elapsedMilliseconds}ms: $e');
      _logger.debug('Stack trace: $stack');
      rethrow;
    }
  }

  void _startAutoRefresh() {
    if (_apiService == null) return;

    final config = _config.autoRefreshConfig;

    _logger.info('');
    _logger
        .info('╔═══════════════════════════════════════════════════════════');
    _logger.info('║ 🔃 AUTO REFRESH MANAGER - Starting');
    _logger
        .info('╠═══════════════════════════════════════════════════════════');
    _logger.info('║ Config:');
    _logger.info('║    Interval: ${config.refreshInterval.inSeconds}s');
    _logger.info('║    Pending Threshold: ${config.pendingQueueThreshold}');
    _logger.info('║    Max Retries: ${config.maxRetries}');
    _logger.info('║    Min Gap: ${config.minRefreshGap.inSeconds}s');
    _logger.info('║    Sport ID: $_currentSportId');

    _autoRefreshManager = AutoRefreshManager(
      apiService: _apiService!,
      reconciliationService: _reconciliationService,
      messageProcessor: _messageProcessor,
      config: config,
      initialSportId: _currentSportId,
      logger: _logger,
    );

    _autoRefreshManager!.start();

    _logger.info('║ ✅ AutoRefreshManager started');
    _logger
        .info('╚═══════════════════════════════════════════════════════════');
  }

  void _setupPendingQueueMonitor() {
    _messageProcessor.pendingQueue.onThresholdExceeded = (size, threshold) {
      _logger.warning(
        '[SportSocket] ⚠️ PENDING THRESHOLD EXCEEDED\n'
        '   └─ current: $size messages\n'
        '   └─ threshold: $threshold\n'
        '   └─ action: Triggering FULL refresh...',
      );
      _autoRefreshManager?.triggerRefresh(AutoRefreshTrigger.pendingThreshold);
    };
  }

  void _setupReconnectionListener() {
    _connectionStateSubscription?.cancel();
    _connectionStateSubscription = onConnectionChanged.listen((event) {
      if (event.currentState == ConnectionState.connected) {
        if (_wasConnectedBefore) {
          _logger.info(
            '[SportSocket] 🔄 RECONNECTED - WebSocket connection restored\n'
            '   └─ action: Triggering FULL refresh to sync data...',
          );
          _autoRefreshManager?.triggerRefresh(AutoRefreshTrigger.reconnection);
        } else {
          _logger.info('[SportSocket] 🔌 FIRST CONNECTION established');
        }
        _wasConnectedBefore = true;
      } else if (event.currentState == ConnectionState.disconnected) {
        _logger.warning(
            '[SportSocket] 🔌 DISCONNECTED - WebSocket connection lost');
      }
    });
  }

  ReconciliationResult reconcile(List<LeagueData> apiData) {
    _ensureNotDisposed();
    return _reconciliationService.reconcile(apiData);
  }

  ReconciliationResult reconcileSport({
    required int sportId,
    required List<LeagueData> apiLeagues,
  }) {
    _ensureNotDisposed();
    return _reconciliationService.reconcileSport(
      sportId: sportId,
      apiLeagues: apiLeagues,
    );
  }

  ReconciliationResult fullSync({
    required int sportId,
    required List<LeagueData> apiLeagues,
  }) {
    _ensureNotDisposed();
    return _reconciliationService.fullSync(
      sportId: sportId,
      apiLeagues: apiLeagues,
    );
  }

  ProcessorMetrics getMetrics() => _messageProcessor.getMetrics();

  void resetStats() => _messageProcessor.resetStats();

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;

    _logger.info('Disposing SportSocketClient');

    _autoRefreshManager?.dispose();
    _autoRefreshManager = null;

    await _connectionStateSubscription?.cancel();
    _connectionStateSubscription = null;

    await _disconnectInternal();

    _messageProcessor.dispose();

    _batchProcessor?.dispose();
    _protoParser = null;
    _payloadRouter = null;

    _dataStore.dispose();
    await _connectionHandler.dispose();

    await _scoreController.close();
    await _eventStatusController.close();
    await _balanceController.close();
    await _marketStatusController.close();
    await _oddsChangeController.close();
    await _oddsUpdateController.close();
  }

  void _ensureNotDisposed() {
    if (_disposed) {
      throw StateError('SportSocketClient has been disposed');
    }
  }
}
