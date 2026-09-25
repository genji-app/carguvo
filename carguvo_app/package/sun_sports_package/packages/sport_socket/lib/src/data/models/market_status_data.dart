import 'market_data.dart';

class MarketStatusData {
  final int eventId;

  final int marketId;

  final int sportId;

  final MarketStatus status;

  final bool isSuspended;

  final DateTime timestamp;

  const MarketStatusData({
    required this.eventId,
    required this.marketId,
    required this.sportId,
    required this.status,
    required this.isSuspended,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'MarketStatusData(eventId: $eventId, marketId: $marketId, '
        'status: $status, isSuspended: $isSuspended)';
  }
}
