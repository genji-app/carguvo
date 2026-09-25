import 'odds_data.dart';

class OddsUpdateData {
  final int eventId;

  final int marketId;

  final String offerId;

  final OddsData odds;

  final DateTime timestamp;

  const OddsUpdateData({
    required this.eventId,
    required this.marketId,
    required this.offerId,
    required this.odds,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'OddsUpdateData(eventId: $eventId, marketId: $marketId, offerId: $offerId)';
  }
}
