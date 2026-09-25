import 'message_key.dart';
import '../utils/constants.dart';

class KeyExtractor {
  ExtractedKey? extract(String raw) {
    if (raw.isEmpty || raw[0] != '{') return null;

    final type = _extractStringValue(raw, JsonField.type);
    if (type == null) return null;

    final sportId = _extractIntValue(raw, JsonField.sportId);

    switch (type) {
      case MessageType.leagueInsert:
        return _extractLeagueKey(raw, type, sportId);

      case MessageType.eventInsert:
      case MessageType.eventUpdate:
      case MessageType.eventRemove:
      case MessageType.scoreUpdate:
        return _extractEventKey(raw, type, sportId);

      case MessageType.marketUpdate:
        return _extractMarketKey(raw, type, sportId);

      case MessageType.oddsUpdate:
      case MessageType.oddsInsert:
        return _extractOddsKey(raw, type, sportId);

      case MessageType.oddsRemove:
        return _extractOddsRemoveKey(raw, type, sportId);

      case MessageType.balanceUpdate:
        return ExtractedKey(
          key: 'balance_${DateTime.now().microsecondsSinceEpoch}',
          type: type,
          raw: raw,
          sportId: sportId,
        );

      default:
        return ExtractedKey(
          key: '${type}_${DateTime.now().microsecondsSinceEpoch}',
          type: type,
          raw: raw,
          sportId: sportId,
        );
    }
  }

  ExtractedKey? _extractLeagueKey(String raw, String type, int? sportId) {
    final leagueId = _extractIntValue(raw, JsonField.leagueId);
    if (leagueId == null) return null;

    return ExtractedKey(
      key: '${type}_$leagueId',
      type: type,
      raw: raw,
      sportId: sportId,
      leagueId: leagueId,
    );
  }

  ExtractedKey? _extractEventKey(String raw, String type, int? sportId) {
    final eventId = _extractIntValue(raw, JsonField.eventId);
    if (eventId == null) return null;

    final leagueId = _extractIntValue(raw, JsonField.leagueId);

    return ExtractedKey(
      key: '${type}_$eventId',
      type: type,
      raw: raw,
      sportId: sportId,
      eventId: eventId,
      leagueId: leagueId,
    );
  }

  ExtractedKey? _extractMarketKey(String raw, String type, int? sportId) {
    var eventId = _extractIntValue(raw, JsonField.domainEventId);
    eventId ??= _extractIntValue(raw, JsonField.eventId);

    var marketId = _extractIntValue(raw, JsonField.domainMarketId);
    marketId ??= _extractIntValue(raw, JsonField.marketId);

    if (eventId == null || marketId == null) return null;

    return ExtractedKey(
      key: '${type}_${eventId}_$marketId',
      type: type,
      raw: raw,
      sportId: sportId,
      eventId: eventId,
      marketId: marketId,
    );
  }

  ExtractedKey? _extractOddsKey(String raw, String type, int? sportId) {
    if (_hasMultipleOddsItems(raw)) {
      return ExtractedKey(
        key: 'odds_batch_${DateTime.now().microsecondsSinceEpoch}',
        type: type,
        raw: raw,
        sportId: sportId,
        isBatch: true,
      );
    }

    final eventId = _extractIntValue(raw, JsonField.eventId);
    final marketId = _extractIntValue(raw, JsonField.marketId);
    final timeRange =
        _extractStringValue(raw, JsonField.timeRange) ?? TimeRange.live;

    if (eventId == null) return null;

    return ExtractedKey(
      key: '${type}_${eventId}_${marketId ?? 0}_$timeRange',
      type: type,
      raw: raw,
      sportId: sportId,
      eventId: eventId,
      marketId: marketId,
    );
  }

  ExtractedKey? _extractOddsRemoveKey(String raw, String type, int? sportId) {
    final eventId = _extractIntValue(raw, JsonField.eventId);
    final marketId = _extractIntValue(raw, JsonField.marketId);

    if (eventId == null) return null;

    return ExtractedKey(
      key: '${type}_${eventId}_${marketId ?? 0}',
      type: type,
      raw: raw,
      sportId: sportId,
      eventId: eventId,
      marketId: marketId,
    );
  }

  bool _hasMultipleOddsItems(String raw) {
    final listStart = raw.indexOf(JsonField.kafkaOddsList);
    if (listStart == -1) return false;

    final multiIndicator = raw.indexOf('},{', listStart);
    if (multiIndicator == -1) return false;

    final listEnd = raw.indexOf(']', listStart);
    return listEnd > multiIndicator;
  }

  String? _extractStringValue(String raw, String prefix) {
    final start = raw.indexOf(prefix);
    if (start == -1) return null;

    final valueStart = start + prefix.length;
    if (valueStart >= raw.length) return null;

    final valueEnd = raw.indexOf('"', valueStart);
    if (valueEnd == -1) return null;

    return raw.substring(valueStart, valueEnd);
  }

  int? _extractIntValue(String raw, String prefix) {
    final start = raw.indexOf(prefix);
    if (start == -1) return null;

    final valueStart = start + prefix.length;
    if (valueStart >= raw.length) return null;

    var valueEnd = valueStart;
    if (valueEnd < raw.length && raw.codeUnitAt(valueEnd) == 45) {
      valueEnd++;
    }

    while (valueEnd < raw.length) {
      final c = raw.codeUnitAt(valueEnd);
      if (c < 48 || c > 57) break;
      valueEnd++;
    }

    if (valueEnd == valueStart) return null;

    return int.tryParse(raw.substring(valueStart, valueEnd));
  }
}
