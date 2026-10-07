import 'dart:convert';

import 'message_key.dart';
import '../utils/constants.dart';
import '../utils/result.dart';
import '../utils/logger.dart';

class BatchParser {
  final Logger _logger;

  BatchParser({Logger? logger}) : _logger = logger ?? const NoOpLogger();

  List<ParsedMessage> parseBatch(List<ExtractedKey> keys) {
    final results = <ParsedMessage>[];

    for (final key in keys) {
      final result = parseOne(key);
      result.whenSuccess((msg) => results.add(msg));
    }

    return results;
  }

  Result<ParsedMessage, ParseError> parseOne(ExtractedKey key) {
    try {
      final json = jsonDecode(key.raw) as Map<String, dynamic>;

      final sportId = _parseInt(json['s']) ?? 0;

      final data = json['d'] as Map<String, dynamic>? ?? {};

      return Success(ParsedMessage(
        type: key.type,
        sportId: sportId,
        data: data,
        raw: key.raw,
        timestamp: DateTime.now(),
      ));
    } catch (e, stackTrace) {
      _logger.warning(
        'Failed to parse message: ${key.type}',
        e,
        stackTrace,
      );
      return Failure(ParseError(key.raw, e.toString()));
    }
  }

  List<ParsedMessage> parseOddsUp(ExtractedKey key) {
    try {
      final json = jsonDecode(key.raw) as Map<String, dynamic>;
      final sportId = _parseInt(json['s']) ?? 0;
      final data = json['d'] as Map<String, dynamic>? ?? {};

      final oddsList = data['kafkaOddsList'] as List<dynamic>?;
      if (oddsList == null || oddsList.isEmpty) {
        return [
          ParsedMessage(
            type: key.type,
            sportId: sportId,
            data: data,
            raw: key.raw,
            timestamp: DateTime.now(),
          ),
        ];
      }

      final results = <ParsedMessage>[];
      for (final oddsItem in oddsList) {
        if (oddsItem is Map<String, dynamic>) {
          results.add(ParsedMessage(
            type: key.type,
            sportId: sportId,
            data: oddsItem,
            raw: key.raw,
            timestamp: DateTime.now(),
          ));
        }
      }

      return results;
    } catch (e, stackTrace) {
      _logger.warning(
          'Failed to parse odds_up: ${e.toString()}', e, stackTrace);
      return [];
    }
  }

  List<ParsedMessage> parseWithOddsExpansion(List<ExtractedKey> keys) {
    final results = <ParsedMessage>[];

    for (final key in keys) {
      if (key.isBatch &&
          (key.type == MessageType.oddsUpdate ||
              key.type == MessageType.oddsInsert)) {
        results.addAll(parseOddsUp(key));
      } else {
        final result = parseOne(key);
        result.whenSuccess((msg) => results.add(msg));
      }
    }

    return results;
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is num) return value.toInt();
    return null;
  }
}
