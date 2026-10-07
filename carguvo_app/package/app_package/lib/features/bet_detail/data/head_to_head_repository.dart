library;

import 'package:betting_domain/betting_domain.dart'
    show HeadToHead, HeadToHeadParser;
import 'package:app_package/core/services/network/sb_http_manager.dart';
import 'package:app_package/core/utils/app_logger.dart';

abstract final class HeadToHeadRepository {
  static final Map<int, HeadToHead?> _cache = {};
  static final Map<int, Future<HeadToHead?>> _inFlight = {};

  static HeadToHead? cached(int eventStatsId) => _cache[eventStatsId];

  static bool hasResult(int eventStatsId) => _cache.containsKey(eventStatsId);

  static Future<HeadToHead?> fetch(int eventStatsId) {
    if (eventStatsId <= 0) return Future.value(null);
    if (_cache.containsKey(eventStatsId)) {
      return Future.value(_cache[eventStatsId]);
    }
    return _inFlight[eventStatsId] ??= _load(eventStatsId).whenComplete(() {
      _inFlight.remove(eventStatsId);
    });
  }

  static Future<HeadToHead?> _load(int eventStatsId) async {
    try {
      final raw = await SbHttpManager.instance.getHeadToHead(eventStatsId);
      final data = raw['data'];
      final parsed = HeadToHeadParser.parse(
        data is Map ? Map<String, dynamic>.from(data) : null,
      );
      _cache[eventStatsId] = parsed;
      return parsed;
    } catch (e) {
      AppLoggers.api.w('head-to-head fetch failed for $eventStatsId: $e');
      return null;
    }
  }

  static void clear() {
    _cache.clear();
    _inFlight.clear();
  }
}
