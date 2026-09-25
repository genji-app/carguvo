import 'dart:async';

import 'key_extractor.dart';
import 'batch_parser.dart';
import 'priority_sorter.dart';
import 'pending_queue.dart';
import 'message_key.dart';
import '../utils/logger.dart';
import '../events/processor_metrics.dart';

typedef MessageCallback = void Function(ParsedMessage message);

typedef BatchCallback = void Function(List<ParsedMessage> messages);

class MessageProcessor {
  final KeyExtractor _keyExtractor;
  final BatchParser _batchParser;
  final PrioritySorter _prioritySorter;
  final PendingQueue _pendingQueue;
  final Logger _logger;

  final Duration _sampleInterval;
  final int _maxParsePerSample;

  final Set<int> _subscribedSports = {};

  int? _primarySportId;

  final Map<String, ExtractedKey> _latestByKey = {};

  Timer? _sampleTimer;
  Timer? _cleanupTimer;
  Timer? _metricsTimer;

  BatchCallback? onBatchProcessed;
  MessageCallback? onMessageProcessed;

  final StreamController<ProcessorMetrics> _metricsController =
      StreamController<ProcessorMetrics>.broadcast();

  Stream<ProcessorMetrics> get metricsStream => _metricsController.stream;

  int _receivedTotal = 0;
  int _processedTotal = 0;
  int _droppedTotal = 0;
  int _parseErrorsTotal = 0;
  final Map<String, int> _countByType = {};
  DateTime _statsStartTime = DateTime.now();

  bool _isRunning = false;

  bool get isRunning => _isRunning;

  MessageProcessor({
    Duration sampleInterval = const Duration(milliseconds: 200),
    int maxParsePerSample = 500,
    int maxPendingQueueSize = 5000,
    Duration pendingExpiration = const Duration(seconds: 10),
    Logger? logger,
  })  : _sampleInterval = sampleInterval,
        _maxParsePerSample = maxParsePerSample,
        _keyExtractor = KeyExtractor(),
        _batchParser = BatchParser(logger: logger),
        _prioritySorter = PrioritySorter(),
        _pendingQueue = PendingQueue(
          maxSize: maxPendingQueueSize,
          expirationTime: pendingExpiration,
        ),
        _logger = logger ?? const NoOpLogger();

  void start() {
    if (_isRunning) return;

    _isRunning = true;
    _statsStartTime = DateTime.now();

    _sampleTimer = Timer.periodic(_sampleInterval, (_) => _processSample());

    _cleanupTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _cleanupPending(),
    );

    _metricsTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _emitMetrics(),
    );

    _logger.info('MessageProcessor started');
  }

  void stop() {
    if (!_isRunning) return;

    _isRunning = false;

    _sampleTimer?.cancel();
    _sampleTimer = null;

    _cleanupTimer?.cancel();
    _cleanupTimer = null;

    _metricsTimer?.cancel();
    _metricsTimer = null;

    _logger.info('MessageProcessor stopped');
  }

  void subscribeSport(int sportId) {
    _subscribedSports.add(sportId);
    _logger.info('✅ Subscribed to sport: $sportId → $_subscribedSports');
  }

  void unsubscribeSport(int sportId) {
    _subscribedSports.remove(sportId);
    _logger.info('❌ Unsubscribed from sport: $sportId → $_subscribedSports');
  }

  void clearSubscriptions() {
    _subscribedSports.clear();
    _logger.info('🗑️ Cleared all subscriptions → $_subscribedSports');
  }

  Set<int> get subscribedSports => Set.unmodifiable(_subscribedSports);

  void setPrimarySport(int sportId) {
    _primarySportId = sportId;
    _logger.info('🎯 Primary sport set to: $sportId');
  }

  int? get primarySportId => _primarySportId;

  void onMessage(String raw) {
    _receivedTotal++;

    if (_receivedTotal % 10 == 1) {
      _logger.debug(
        '📩 WS MSG #$_receivedTotal: ${raw.length > 80 ? '${raw.substring(0, 80)}...' : raw}',
      );
      _logger.debug('   └─ subscribedSports: $_subscribedSports');
    }

    final key = _keyExtractor.extract(raw);
    if (key == null) {
      _droppedTotal++;
      _logger.debug('⏭️ Dropped - key extraction failed');
      return;
    }

    if (!_shouldProcess(key)) {
      _logger.debug(
        '⏭️ Filtered - sportId: ${key.sportId}, subscribed: $_subscribedSports',
      );
      return;
    }

    _countByType[key.type] = (_countByType[key.type] ?? 0) + 1;

    _latestByKey[key.key] = key;

    if (_latestByKey.length >= _maxParsePerSample * 2) {
      _processSample();
    }
  }

  bool _shouldProcess(ExtractedKey key) {
    if (key.type == 'balance_up' || key.type == 'user_bal') return true;

    if (key.sportId == null) return true;

    final isSubscribed =
        _subscribedSports.isEmpty || _subscribedSports.contains(key.sportId);

    if (key.type == 'odds_up' ||
        key.type == 'odds_ins' ||
        key.type == 'score_up' ||
        key.type == 'event_up') {
      return isSubscribed;
    }

    if (_primarySportId != null) {
      return key.sportId == _primarySportId;
    }

    return isSubscribed;
  }

  void _processSample() {
    if (_latestByKey.isEmpty) return;

    final stopwatch = Stopwatch()..start();

    final keys = _latestByKey.values.toList();
    _latestByKey.clear();

    final batchKeys = keys.length > _maxParsePerSample
        ? keys.sublist(0, _maxParsePerSample)
        : keys;

    if (keys.length > _maxParsePerSample) {
      for (var i = _maxParsePerSample; i < keys.length; i++) {
        _latestByKey[keys[i].key] = keys[i];
      }
      _droppedTotal += keys.length - _maxParsePerSample;
    }

    _prioritySorter.sortInPlace(batchKeys);

    _debugPrintBatchInput(batchKeys);

    final messages = _batchParser.parseWithOddsExpansion(batchKeys);

    _processedTotal += messages.length;
    _parseErrorsTotal += batchKeys.length - messages.length;

    stopwatch.stop();

    _debugPrintParsedOutput(messages);

    if (messages.isNotEmpty) {
      onBatchProcessed?.call(messages);

      if (onMessageProcessed != null) {
        for (final msg in messages) {
          onMessageProcessed!(msg);
        }
      }
    }

    _debugPrintPendingQueue();

    _logger.debug(
      'Processed batch: ${messages.length} messages in ${stopwatch.elapsedMilliseconds}ms',
    );
  }

  void _cleanupPending() {
    final removed = _pendingQueue.cleanupExpired();
    if (removed > 0) {
      _logger.debug('Cleaned up $removed expired pending messages');
    }
  }

  void _emitMetrics() {
    final now = DateTime.now();
    final duration = now.difference(_statsStartTime);
    final seconds = duration.inSeconds > 0 ? duration.inSeconds : 1;

    final metrics = ProcessorMetrics(
      receivedTotal: _receivedTotal,
      receivedPerSecond: _receivedTotal ~/ seconds,
      processedTotal: _processedTotal,
      processedPerSecond: _processedTotal ~/ seconds,
      droppedTotal: _droppedTotal,
      parseErrorsTotal: _parseErrorsTotal,
      pendingQueueSize: _pendingQueue.length,
      pendingQueueDropped: _pendingQueue.droppedCount,
      pendingQueueExpired: _pendingQueue.expiredCount,
      bufferSize: _latestByKey.length,
      dedupRatio: _receivedTotal > 0
          ? ((_receivedTotal - _processedTotal) / _receivedTotal * 100)
          : 0.0,
      byMessageType: Map.from(_countByType),
      timestamp: now,
    );

    _metricsController.add(metrics);
  }

  ProcessorMetrics getMetrics() {
    final now = DateTime.now();
    final duration = now.difference(_statsStartTime);
    final seconds = duration.inSeconds > 0 ? duration.inSeconds : 1;

    return ProcessorMetrics(
      receivedTotal: _receivedTotal,
      receivedPerSecond: _receivedTotal ~/ seconds,
      processedTotal: _processedTotal,
      processedPerSecond: _processedTotal ~/ seconds,
      droppedTotal: _droppedTotal,
      parseErrorsTotal: _parseErrorsTotal,
      pendingQueueSize: _pendingQueue.length,
      pendingQueueDropped: _pendingQueue.droppedCount,
      pendingQueueExpired: _pendingQueue.expiredCount,
      bufferSize: _latestByKey.length,
      dedupRatio: _receivedTotal > 0
          ? ((_receivedTotal - _processedTotal) / _receivedTotal * 100)
          : 0.0,
      byMessageType: Map.from(_countByType),
      timestamp: now,
    );
  }

  void resetStats() {
    _receivedTotal = 0;
    _processedTotal = 0;
    _droppedTotal = 0;
    _parseErrorsTotal = 0;
    _countByType.clear();
    _statsStartTime = DateTime.now();
    _pendingQueue.resetStats();
  }

  PendingQueue get pendingQueue => _pendingQueue;

  void _debugPrintBatchInput(List<ExtractedKey> batchKeys) {
    if (batchKeys.isEmpty) return;

    final typeGroups = <String, List<String>>{};

    for (final key in batchKeys) {
      final ids = <String>[];
      if (key.leagueId != null) ids.add('L:${key.leagueId}');
      if (key.eventId != null) ids.add('E:${key.eventId}');
      if (key.marketId != null) ids.add('M:${key.marketId}');
      if (key.isBatch) ids.add('BATCH');

      final idStr = ids.isNotEmpty ? ids.join(',') : key.key;
      typeGroups.putIfAbsent(key.type, () => []).add(idStr);
    }

  }

  void _debugPrintParsedOutput(List<ParsedMessage> messages) {
    if (messages.isEmpty) return;

    final typeGroups = <String, List<String>>{};

    for (final msg in messages) {
      final ids = <String>[];

      final leagueId = msg.getInt('leagueId') ?? msg.getInt('li');
      final eventId = msg.getInt('eventId') ?? msg.getInt('ei');
      final marketId = msg.getInt('marketId') ?? msg.getInt('mi');
      final offerId = msg.getString('strOfferId') ?? msg.getString('offerId');

      if (leagueId != null) ids.add('L:$leagueId');
      if (eventId != null) ids.add('E:$eventId');
      if (marketId != null) ids.add('M:$marketId');
      if (offerId != null) ids.add('O:$offerId');

      final idStr = ids.isNotEmpty ? ids.join(',') : 'no-id';
      typeGroups.putIfAbsent(msg.type, () => []).add(idStr);
    }

  }

  void _debugPrintPendingQueue() {
    final pending = _pendingQueue;
    if (pending.isEmpty) return;

  }

  void dispose() {
    stop();
    _latestByKey.clear();
    _pendingQueue.clear();
    _metricsController.close();
  }
}
