import 'dart:async';

import '../client/reconciliation_service.dart';
import '../processor/message_processor.dart';
import '../processor/message_key.dart';
import '../utils/logger.dart';
import '../utils/constants.dart';
import 'i_sport_api_service.dart';

enum AutoRefreshTrigger {
  initial,

  timer,

  pendingThreshold,

  reconnection,

  manual;

  String get description {
    switch (this) {
      case AutoRefreshTrigger.initial:
        return '🚀 INITIAL (first connect)';
      case AutoRefreshTrigger.timer:
        return '⏱️ TIMER (periodic refresh)';
      case AutoRefreshTrigger.pendingThreshold:
        return '⚠️ PENDING_THRESHOLD (queue overflow)';
      case AutoRefreshTrigger.reconnection:
        return '🔄 RECONNECTION (socket reconnected)';
      case AutoRefreshTrigger.manual:
        return '👆 MANUAL (user action)';
    }
  }
}

class AutoRefreshResult {
  final AutoRefreshTrigger trigger;

  final bool success;

  final Duration duration;

  final int addedLeagues;

  final int updatedLeagues;

  final int removedLeagues;

  final int flushedPending;

  final String? errorMessage;

  final DateTime timestamp;

  const AutoRefreshResult({
    required this.trigger,
    required this.success,
    required this.duration,
    this.addedLeagues = 0,
    this.updatedLeagues = 0,
    this.removedLeagues = 0,
    this.flushedPending = 0,
    this.errorMessage,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'AutoRefreshResult(trigger: $trigger, success: $success, '
        'duration: ${duration.inMilliseconds}ms, '
        'leagues: +$addedLeagues/~$updatedLeagues/-$removedLeagues, '
        'flushed: $flushedPending)';
  }
}

class AutoRefreshConfig {
  final Duration refreshInterval;

  final Duration todayRefreshInterval;

  final Duration earlyRefreshInterval;

  final int pendingQueueThreshold;

  final bool enabled;

  final Duration minRefreshGap;

  final int maxRetries;

  final Duration retryDelay;

  const AutoRefreshConfig({
    this.refreshInterval = const Duration(seconds: 30),
    this.todayRefreshInterval = const Duration(seconds: 60),
    this.earlyRefreshInterval = const Duration(seconds: 120),
    this.pendingQueueThreshold = 300,
    this.enabled = true,
    this.minRefreshGap = const Duration(seconds: 5),
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 2),
  });

  Duration getIntervalForTimeRange(String timeRange) {
    switch (timeRange) {
      case TimeRange.live:
        return refreshInterval;
      case TimeRange.today:
        return todayRefreshInterval;
      case TimeRange.early:
        return earlyRefreshInterval;
      default:
        return refreshInterval;
    }
  }

  factory AutoRefreshConfig.live() => const AutoRefreshConfig(
        refreshInterval: Duration(seconds: 30),
        todayRefreshInterval: Duration(seconds: 60),
        earlyRefreshInterval: Duration(seconds: 120),
        pendingQueueThreshold: 300,
        maxRetries: 3,
      );

  factory AutoRefreshConfig.preMatch() => const AutoRefreshConfig(
        refreshInterval: Duration(seconds: 60),
        todayRefreshInterval: Duration(seconds: 90),
        earlyRefreshInterval: Duration(seconds: 180),
        pendingQueueThreshold: 500,
        maxRetries: 3,
      );

  factory AutoRefreshConfig.disabled() => const AutoRefreshConfig(
        enabled: false,
      );

  AutoRefreshConfig copyWith({
    Duration? refreshInterval,
    Duration? todayRefreshInterval,
    Duration? earlyRefreshInterval,
    int? pendingQueueThreshold,
    bool? enabled,
    Duration? minRefreshGap,
    int? maxRetries,
    Duration? retryDelay,
  }) {
    return AutoRefreshConfig(
      refreshInterval: refreshInterval ?? this.refreshInterval,
      todayRefreshInterval: todayRefreshInterval ?? this.todayRefreshInterval,
      earlyRefreshInterval: earlyRefreshInterval ?? this.earlyRefreshInterval,
      pendingQueueThreshold:
          pendingQueueThreshold ?? this.pendingQueueThreshold,
      enabled: enabled ?? this.enabled,
      minRefreshGap: minRefreshGap ?? this.minRefreshGap,
      maxRetries: maxRetries ?? this.maxRetries,
      retryDelay: retryDelay ?? this.retryDelay,
    );
  }
}

class AutoRefreshManager {
  final ISportApiService _apiService;
  final ReconciliationService _reconciliationService;
  final MessageProcessor _messageProcessor;
  final AutoRefreshConfig _config;
  final Logger _logger;

  int _currentSportId;
  String _currentTimeRange;
  Timer? _timer;
  DateTime? _lastRefreshTime;
  DateTime? _timerStartTime;
  int _tickCount = 0;
  bool _isRefreshing = false;
  bool _isDisposed = false;

  final StreamController<AutoRefreshResult> _resultController =
      StreamController<AutoRefreshResult>.broadcast();

  bool get _debugLoggingEnabled {
    var enabled = false;
    assert(enabled = true);
    return enabled;
  }

  AutoRefreshManager({
    required ISportApiService apiService,
    required ReconciliationService reconciliationService,
    required MessageProcessor messageProcessor,
    required AutoRefreshConfig config,
    required int initialSportId,
    String initialTimeRange = TimeRange.live,
    Logger? logger,
  })  : _apiService = apiService,
        _reconciliationService = reconciliationService,
        _messageProcessor = messageProcessor,
        _config = config,
        _currentSportId = initialSportId,
        _currentTimeRange = initialTimeRange,
        _logger = logger ?? const NoOpLogger();

  Stream<AutoRefreshResult> get onRefresh => _resultController.stream;

  int get currentSportId => _currentSportId;

  String get currentTimeRange => _currentTimeRange;

  bool get isRefreshing => _isRefreshing;

  bool get isRunning => _timer != null;

  void updateTimeRange(String timeRange) {
    if (_currentTimeRange == timeRange) {
      _logger.debug('[AutoRefresh] TimeRange unchanged: $timeRange');
      return;
    }

    final oldInterval = _config.getIntervalForTimeRange(_currentTimeRange);
    final newInterval = _config.getIntervalForTimeRange(timeRange);

    _logger.info(
      '[AutoRefresh] TimeRange changed: $_currentTimeRange → $timeRange\n'
      '   └─ interval: ${oldInterval.inSeconds}s → ${newInterval.inSeconds}s',
    );

    _currentTimeRange = timeRange;

    if (isRunning) {
      _restartTimer();
    }
  }

  void _restartTimer() {
    _timer?.cancel();
    _tickCount = 0;
    _timerStartTime = DateTime.now();

    final interval = _config.getIntervalForTimeRange(_currentTimeRange);

    _timer = Timer.periodic(interval, (_) {
      _tickCount++;
      // ignore: avoid_print
      triggerRefresh(AutoRefreshTrigger.timer);
    });

    _logger.info(
      '[AutoRefresh] ✅ TIMER RESTARTED\n'
      '   └─ timeRange: $_currentTimeRange\n'
      '   └─ interval: ${interval.inSeconds}s',
    );
  }

  void start() {
    _logger.info('[AutoRefresh] start() called - checking config...');
    _logger.info('[AutoRefresh]   enabled: ${_config.enabled}');
    _logger.info('[AutoRefresh]   isDisposed: $_isDisposed');
    _logger.info('[AutoRefresh]   timeRange: $_currentTimeRange');

    if (!_config.enabled) {
      _logger
          .warning('[AutoRefresh] ⏭️ NOT STARTING - config.enabled is FALSE');
      return;
    }

    if (_isDisposed) {
      _logger.warning('[AutoRefresh] ⏭️ NOT STARTING - manager is DISPOSED');
      return;
    }

    _timer?.cancel();
    _timerStartTime = DateTime.now();
    _tickCount = 0;

    final interval = _config.getIntervalForTimeRange(_currentTimeRange);

    _timer = Timer.periodic(interval, (_) {
      _tickCount++;
      // ignore: avoid_print
      triggerRefresh(AutoRefreshTrigger.timer);
    });

    _logger.info(
      '[AutoRefresh] ✅ TIMER STARTED\n'
      '   └─ timeRange: $_currentTimeRange\n'
      '   └─ interval: ${interval.inSeconds}s\n'
      '   └─ threshold: ${_config.pendingQueueThreshold}\n'
      '   └─ next tick in: ${interval.inSeconds}s',
    );
  }

  void stop() {
    final wasRunning = _timer != null;
    _timer?.cancel();
    _timer = null;
    _logger.info('[AutoRefresh] ⏹️ STOPPED (was running: $wasRunning)');
  }

  Map<String, dynamic> getDiagnostics() {
    int? secondsUntilNextTick;
    final currentInterval = _config.getIntervalForTimeRange(_currentTimeRange);
    if (_timerStartTime != null && isRunning) {
      final elapsed = DateTime.now().difference(_timerStartTime!);
      final intervalSeconds = currentInterval.inSeconds;
      final nextTickAt = ((_tickCount + 1) * intervalSeconds);
      secondsUntilNextTick = nextTickAt - elapsed.inSeconds;
      if (secondsUntilNextTick < 0) secondsUntilNextTick = 0;
    }

    return {
      'isRunning': isRunning,
      'isRefreshing': _isRefreshing,
      'isDisposed': _isDisposed,
      'currentSportId': _currentSportId,
      'currentTimeRange': _currentTimeRange,
      'tickCount': _tickCount,
      'secondsUntilNextTick': secondsUntilNextTick,
      'timerStartTime': _timerStartTime?.toIso8601String(),
      'lastRefreshTime': _lastRefreshTime?.toIso8601String(),
      'config': {
        'enabled': _config.enabled,
        'refreshInterval': _config.refreshInterval.inSeconds,
        'todayRefreshInterval': _config.todayRefreshInterval.inSeconds,
        'earlyRefreshInterval': _config.earlyRefreshInterval.inSeconds,
        'currentInterval': currentInterval.inSeconds,
        'pendingQueueThreshold': _config.pendingQueueThreshold,
        'minRefreshGap': _config.minRefreshGap.inSeconds,
        'maxRetries': _config.maxRetries,
      },
    };
  }

  void logStatus() {
    _logger.debug('[AutoRefresh] status: ${getDiagnostics()}');
  }

  void updateSportId(int sportId) {
    _currentSportId = sportId;
    _logger.debug('AutoRefreshManager sportId updated to $sportId');
  }

  Future<AutoRefreshResult?> triggerRefresh(AutoRefreshTrigger trigger) async {
    if (_isRefreshing) {
      _logger.debug('Refresh already in progress, skipping');
      return null;
    }

    if (_lastRefreshTime != null) {
      final elapsed = DateTime.now().difference(_lastRefreshTime!);
      if (elapsed < _config.minRefreshGap) {
        _logger.debug(
          'Skipping refresh, min gap not met: ${elapsed.inSeconds}s < ${_config.minRefreshGap.inSeconds}s',
        );
        return null;
      }
    }

    _isRefreshing = true;
    _lastRefreshTime = DateTime.now();

    try {
      final result = await _refreshWithRetry(trigger);
      if (!_isDisposed) {
        _resultController.add(result);
      }
      return result;
    } finally {
      _isRefreshing = false;
    }
  }

  bool checkPendingThreshold() {
    final queueSize = _messageProcessor.pendingQueue.length;
    return queueSize >= _config.pendingQueueThreshold;
  }

  void dispose() {
    _isDisposed = true;
    stop();
    _resultController.close();
  }

  Future<AutoRefreshResult> _refreshWithRetry(
      AutoRefreshTrigger trigger) async {
    final stopwatch = Stopwatch()..start();

    for (int i = 0; i < _config.maxRetries; i++) {
      try {
        final result = await _executeRefresh(trigger, stopwatch);
        return result;
      } catch (e, stack) {
        _logger.warning('Refresh attempt ${i + 1} failed: $e');
        _logger.debug('Stack trace: $stack');

        if (i < _config.maxRetries - 1) {
          final delay = _config.retryDelay * (i + 1);
          await Future<void>.delayed(delay);
        }
      }
    }

    stopwatch.stop();
    _logger.error('Refresh failed after ${_config.maxRetries} retries');

    return AutoRefreshResult(
      trigger: trigger,
      success: false,
      duration: stopwatch.elapsed,
      errorMessage: 'Failed after ${_config.maxRetries} retries',
      timestamp: DateTime.now(),
    );
  }

  Future<AutoRefreshResult> _executeRefresh(
    AutoRefreshTrigger trigger,
    Stopwatch stopwatch,
  ) async {
    _logger.info(
        '[AutoRefresh] ${trigger.description} - sportId=$_currentSportId, timeRange=$_currentTimeRange');

    switch (trigger) {
      case AutoRefreshTrigger.timer:
      case AutoRefreshTrigger.manual:
        return _refreshCurrentTab(trigger, stopwatch);

      case AutoRefreshTrigger.initial:
      case AutoRefreshTrigger.reconnection:
      case AutoRefreshTrigger.pendingThreshold:
        return _refreshFull(trigger, stopwatch);
    }
  }

  Future<AutoRefreshResult> _refreshCurrentTab(
    AutoRefreshTrigger trigger,
    Stopwatch stopwatch,
  ) async {
    _logger.info(
        '[AutoRefresh] Fetching $_currentTimeRange & POPULATE (full hierarchy)...');

    final store = _reconciliationService.store;
    final leaguesBefore = store.getLeaguesBySport(_currentSportId).length;

    final debugLog = _debugLoggingEnabled;
    int eventsBefore = 0;
    if (debugLog) {
      for (final league in store.getLeaguesBySport(_currentSportId)) {
        eventsBefore += store.getEventsByLeague(league.leagueId).length;
      }
    }

    switch (_currentTimeRange) {
      case TimeRange.live:
        await _apiService.fetchLiveAndPopulate(
          sportId: _currentSportId,
          store: store,
          background: true,
        );
        break;
      case TimeRange.today:
        await _apiService.fetchTodayAndPopulate(
          sportId: _currentSportId,
          store: store,
          background: true,
        );
        break;
      case TimeRange.early:
        await _apiService.fetchEarlyAndPopulate(
          sportId: _currentSportId,
          store: store,
          background: true,
        );
        break;
      default:
        await _apiService.fetchLiveAndPopulate(
          sportId: _currentSportId,
          store: store,
          background: true,
        );
    }

    final leaguesAfter = store.getLeaguesBySport(_currentSportId).length;
    int eventsAfter = 0;
    if (debugLog) {
      for (final league in store.getLeaguesBySport(_currentSportId)) {
        eventsAfter += store.getEventsByLeague(league.leagueId).length;
      }
    }

    final cleanedCount = _cleanupPendingQueue();

    stopwatch.stop();

    if (debugLog) {
      _logger.info(
        '[AutoRefresh] ✅ $_currentTimeRange REFRESH DONE - ${trigger.description}\n'
        '   └─ leagues: $leaguesBefore → $leaguesAfter\n'
        '   └─ events: $eventsBefore → $eventsAfter\n'
        '   └─ cleaned: $cleanedCount pending\n'
        '   └─ duration: ${stopwatch.elapsedMilliseconds}ms',
      );
    }

    return AutoRefreshResult(
      trigger: trigger,
      success: true,
      duration: stopwatch.elapsed,
      addedLeagues: leaguesAfter - leaguesBefore,
      updatedLeagues: leaguesAfter,
      removedLeagues: 0,
      flushedPending: cleanedCount,
      timestamp: DateTime.now(),
    );
  }

  Future<AutoRefreshResult> _refreshFull(
    AutoRefreshTrigger trigger,
    Stopwatch stopwatch,
  ) async {
    _logger.info('[AutoRefresh] Fetching FULL (EARLY + LIVE) parallel...');

    final results = await Future.wait([
      _apiService.fetchEarlyLeagues(sportId: _currentSportId),
      _apiService.fetchLiveLeagues(sportId: _currentSportId),
    ]);

    final earlyLeagues = results[0];
    final liveLeagues = results[1];

    final allLeagues = [...earlyLeagues, ...liveLeagues];

    _logger.info(
        '[AutoRefresh] API fetched - early: ${earlyLeagues.length}, live: ${liveLeagues.length}');

    if (allLeagues.isEmpty &&
        _reconciliationService.store
            .getLeaguesBySport(_currentSportId)
            .isNotEmpty) {
      _logger.warning(
        '[AutoRefresh] ⚠️ FULL refresh returned EMPTY while store has data — '
        'skipping fullSync (likely swallowed fetch failure after reconnect)',
      );
      throw StateError(
        'AutoRefresh FULL: empty snapshot while store non-empty',
      );
    }

    final result = _reconciliationService.fullSync(
      sportId: _currentSportId,
      apiLeagues: allLeagues,
    );

    final flushedCount = _cleanupPendingQueue();

    stopwatch.stop();

    _logger.info(
      '[AutoRefresh] ✅ FULL REFRESH DONE - ${trigger.description}\n'
      '   └─ leagues: +${result.addedLeagues.length}/~${result.updatedLeagues.length}/-${result.removedLeagues.length}\n'
      '   └─ pending flushed: $flushedCount\n'
      '   └─ duration: ${stopwatch.elapsedMilliseconds}ms',
    );

    return AutoRefreshResult(
      trigger: trigger,
      success: true,
      duration: stopwatch.elapsed,
      addedLeagues: result.addedLeagues.length,
      flushedPending: flushedCount,
      timestamp: DateTime.now(),
    );
  }

  int _cleanupPendingQueue() {
    final pendingQueue = _messageProcessor.pendingQueue;
    final store = _reconciliationService.store;

    if (pendingQueue.isEmpty) {
      _logger.debug('[AutoRefresh] 🧹 Pending queue empty, nothing to cleanup');
      return 0;
    }

    final storeEventIds = store.allEventIds.toSet();
    final pendingBefore = pendingQueue.length;
    final parentsBefore = pendingQueue.parentCount;

    _logger.info('[AutoRefresh] 🧹 Cleaning pending queue...');
    _logger.info('   └─ Store events: ${storeEventIds.length}');
    _logger.info(
        '   └─ Pending before: $pendingBefore items, $parentsBefore parents');

    final flushedMessages = pendingQueue.flushByParents(storeEventIds);
    var reprocessedCount = 0;

    if (flushedMessages.isNotEmpty) {
      _logger.info(
          '   └─ 🔁 Flushed ${flushedMessages.length} messages to reprocess');

      for (final msg in flushedMessages) {
        _messageProcessor.onMessageProcessed?.call(
          ParsedMessage(
            type: msg.type,
            data: msg.data,
            raw: '',
            sportId: _currentSportId,
            timestamp: DateTime.now(),
          ),
        );
        reprocessedCount++;
      }
    }

    final orphanResult = pendingQueue.removeOrphans(storeEventIds);

    if (orphanResult.removedCount > 0) {
      _logger.info(
          '   └─ 🗑️ Removed ${orphanResult.removedCount} orphan messages');
      if (orphanResult.orphanParentIds.length <= 5) {
        _logger.info('   └─ Orphan parents: ${orphanResult.orphanParentIds}');
      } else {
        _logger.info(
            '   └─ Orphan parents: ${orphanResult.orphanParentIds.take(5).toList()}... +${orphanResult.orphanParentIds.length - 5} more');
      }
    }

    _logger.info('   └─ Pending after: ${pendingQueue.length} items');

    return reprocessedCount;
  }
}
