import 'package:meta/meta.dart';

@immutable
class ProcessorMetrics {
  final int receivedTotal;

  final int receivedPerSecond;

  final int processedTotal;

  final int processedPerSecond;

  final int droppedTotal;

  final int parseErrorsTotal;

  final int pendingQueueSize;

  final int pendingQueueDropped;

  final int pendingQueueExpired;

  final int bufferSize;

  final double dedupRatio;

  final Map<String, int> byMessageType;

  final DateTime timestamp;

  const ProcessorMetrics({
    required this.receivedTotal,
    required this.receivedPerSecond,
    required this.processedTotal,
    required this.processedPerSecond,
    required this.droppedTotal,
    required this.parseErrorsTotal,
    required this.pendingQueueSize,
    required this.pendingQueueDropped,
    required this.pendingQueueExpired,
    required this.bufferSize,
    required this.dedupRatio,
    required this.byMessageType,
    required this.timestamp,
  });

  factory ProcessorMetrics.empty() {
    return ProcessorMetrics(
      receivedTotal: 0,
      receivedPerSecond: 0,
      processedTotal: 0,
      processedPerSecond: 0,
      droppedTotal: 0,
      parseErrorsTotal: 0,
      pendingQueueSize: 0,
      pendingQueueDropped: 0,
      pendingQueueExpired: 0,
      bufferSize: 0,
      dedupRatio: 0.0,
      byMessageType: const {},
      timestamp: DateTime.now(),
    );
  }

  double get efficiency {
    if (receivedTotal == 0) return 100.0;
    return (processedTotal / receivedTotal) * 100;
  }

  int get totalErrors => droppedTotal + parseErrorsTotal;

  double get errorRate {
    if (receivedTotal == 0) return 0.0;
    return (totalErrors / receivedTotal) * 100;
  }

  bool get isHealthy {
    return errorRate < 10.0 && pendingQueueSize < 1000 && bufferSize < 5000;
  }

  String? get mostCommonType {
    if (byMessageType.isEmpty) return null;

    String? maxType;
    var maxCount = 0;

    for (final entry in byMessageType.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        maxType = entry.key;
      }
    }

    return maxType;
  }

  @override
  String toString() {
    return 'ProcessorMetrics('
        'received: $receivedPerSecond/s, '
        'processed: $processedPerSecond/s, '
        'dropped: $droppedTotal, '
        'pending: $pendingQueueSize, '
        'dedup: ${dedupRatio.toStringAsFixed(1)}%, '
        'healthy: $isHealthy)';
  }

  Map<String, dynamic> toJson() {
    return {
      'receivedTotal': receivedTotal,
      'receivedPerSecond': receivedPerSecond,
      'processedTotal': processedTotal,
      'processedPerSecond': processedPerSecond,
      'droppedTotal': droppedTotal,
      'parseErrorsTotal': parseErrorsTotal,
      'pendingQueueSize': pendingQueueSize,
      'pendingQueueDropped': pendingQueueDropped,
      'pendingQueueExpired': pendingQueueExpired,
      'bufferSize': bufferSize,
      'dedupRatio': dedupRatio,
      'byMessageType': byMessageType,
      'timestamp': timestamp.toIso8601String(),
      'efficiency': efficiency,
      'errorRate': errorRate,
      'isHealthy': isHealthy,
    };
  }
}
