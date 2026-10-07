import 'dart:async';

import '../proto/proto.dart';
import '../utils/perf_hooks.dart';

typedef PayloadBatchCallback = void Function(List<Payload> payloads);

class LightBatchProcessor {
  final Duration batchInterval;

  final int maxBatchSize;

  final List<Payload> _buffer = [];

  Timer? _flushTimer;

  bool _isPaused = false;
  Timer? _pauseFailsafeTimer;

  static const pauseFailsafeInterval = Duration(seconds: 10);

  PayloadBatchCallback? onBatch;

  bool _isRunning = false;

  int _receivedTotal = 0;
  int _batchesTotal = 0;
  int _processedTotal = 0;
  DateTime _statsStartTime = DateTime.now();

  bool get isRunning => _isRunning;
  int get bufferSize => _buffer.length;

  LightBatchProcessor({
    this.batchInterval = const Duration(milliseconds: 50),
    this.maxBatchSize = 1000,
  });

  void start() {
    if (_isRunning) return;

    _isRunning = true;
    _statsStartTime = DateTime.now();
  }

  void stop() {
    if (!_isRunning) return;

    _isRunning = false;
    _isPaused = false;
    _pauseFailsafeTimer?.cancel();
    _pauseFailsafeTimer = null;
    _flush();
  }

  bool get isPaused => _isPaused;

  void pause() {
    if (_isPaused) return;
    _isPaused = true;
    _flushTimer?.cancel();
    _flushTimer = null;
    _armPauseFailsafe();
  }

  void resume({bool Function(Payload payload)? flushFirst}) {
    if (!_isPaused) return;
    _isPaused = false;
    _pauseFailsafeTimer?.cancel();
    _pauseFailsafeTimer = null;
    if (_buffer.isEmpty) return;

    if (flushFirst == null) {
      _flush();
      return;
    }

    final priority = <Payload>[];
    final deferred = <Payload>[];
    for (final p in _buffer) {
      (flushFirst(p) ? priority : deferred).add(p);
    }
    _buffer
      ..clear()
      ..addAll(deferred);

    if (priority.isNotEmpty) {
      _batchesTotal++;
      _processedTotal += priority.length;
      onBatch?.call(priority);
    }
    if (_buffer.isNotEmpty) {
      _scheduleFlush();
    }
  }

  void _armPauseFailsafe() {
    _pauseFailsafeTimer = Timer(pauseFailsafeInterval, () {
      _pauseFailsafeTimer = null;
      if (!_isPaused) return;
      _flush();
      _armPauseFailsafe();
    });
  }

  void add(Payload payload) {
    _receivedTotal++;
    _buffer.add(payload);

    if (!_isRunning) {
      start();
    }

    if (_buffer.length >= maxBatchSize) {
      _flush();
      return;
    }

    _scheduleFlush();
  }

  void addAll(Iterable<Payload> payloads) {
    for (final p in payloads) {
      add(p);
    }
  }

  void _scheduleFlush() {
    if (!_isRunning || _isPaused) return;
    _flushTimer ??= Timer(batchInterval, _onFlushTimer);
  }

  void _onFlushTimer() {
    _flushTimer = null;
    _flush();
    if (_buffer.isNotEmpty) {
      _scheduleFlush();
    }
  }

  void _flush() {
    _flushTimer?.cancel();
    _flushTimer = null;

    if (_buffer.isEmpty) return;

    final batch = List<Payload>.from(_buffer);
    _buffer.clear();

    _batchesTotal++;
    _processedTotal += batch.length;

    final wrap = SportSocketPerfHooks.wrap;
    if (wrap == null) {
      onBatch?.call(batch);
    } else {
      wrap<void>('apply', () => onBatch?.call(batch));
    }
  }

  void flush() => _flush();

  LightBatchStats getStats() {
    final now = DateTime.now();
    final duration = now.difference(_statsStartTime);
    final seconds = duration.inSeconds > 0 ? duration.inSeconds : 1;

    return LightBatchStats(
      receivedTotal: _receivedTotal,
      receivedPerSecond: _receivedTotal ~/ seconds,
      processedTotal: _processedTotal,
      batchesTotal: _batchesTotal,
      avgBatchSize: _batchesTotal > 0 ? _processedTotal ~/ _batchesTotal : 0,
      bufferSize: _buffer.length,
      timestamp: now,
    );
  }

  void resetStats() {
    _receivedTotal = 0;
    _batchesTotal = 0;
    _processedTotal = 0;
    _statsStartTime = DateTime.now();
  }

  void dispose() {
    stop();
    _pauseFailsafeTimer?.cancel();
    _pauseFailsafeTimer = null;
    _buffer.clear();
  }
}

class LightBatchStats {
  final int receivedTotal;
  final int receivedPerSecond;
  final int processedTotal;
  final int batchesTotal;
  final int avgBatchSize;
  final int bufferSize;
  final DateTime timestamp;

  const LightBatchStats({
    required this.receivedTotal,
    required this.receivedPerSecond,
    required this.processedTotal,
    required this.batchesTotal,
    required this.avgBatchSize,
    required this.bufferSize,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'LightBatchStats(received: $receivedTotal ($receivedPerSecond/s), '
        'processed: $processedTotal, batches: $batchesTotal, '
        'avgSize: $avgBatchSize, buffer: $bufferSize)';
  }
}
