import 'odds_data.dart';

class OddsChangeData {
  final int eventId;

  final int marketId;

  final String offerId;

  final String selectionId;

  final String selectionType;

  final double previousValue;

  final double currentValue;

  final OddsDirection direction;

  final OddsStyleValues? styleValues;

  final DateTime timestamp;

  const OddsChangeData({
    required this.eventId,
    required this.marketId,
    required this.offerId,
    required this.selectionId,
    required this.selectionType,
    required this.previousValue,
    required this.currentValue,
    required this.direction,
    this.styleValues,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'OddsChangeData(eventId: $eventId, marketId: $marketId, '
        'selectionId: $selectionId, type: $selectionType, '
        'prev: $previousValue, curr: $currentValue, dir: $direction)';
  }
}

class OddsStyleValues {
  final double decimal;

  final String? malay;

  final String? indo;

  final String? hk;

  const OddsStyleValues({
    required this.decimal,
    this.malay,
    this.indo,
    this.hk,
  });

  @override
  String toString() {
    return 'OddsStyleValues(decimal: $decimal, malay: $malay, indo: $indo, hk: $hk)';
  }
}
