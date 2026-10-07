import 'models/models.dart';

abstract final class GameApiParsers {
  static List<ProviderGames> parseProviderGames(dynamic data) {
    if (data is! List<dynamic>) return const [];
    return data.whereType<Map<String, dynamic>>().map(ProviderGames.fromJson).toList();
  }

  static String parseGameUrl(dynamic data) {
    if (data is Map<String, dynamic>) {
      final url = data['url'] ?? data['link'];
      if (url is String && url.isNotEmpty) {
        return url;
      }
    }
    throw const FormatException('Missing or invalid "url" in game launch response');
  }

  static Map<int, List<JackpotEntry>> parseJackpots(dynamic data) {
    if (data is! Map<String, dynamic>) return const {};
    final list = data['jackpots'] as List<dynamic>? ?? const [];

    final grouped = <int, List<JackpotEntry>>{};
    for (final item in list) {
      if (item is Map<String, dynamic>) {
        try {
          final entry = JackpotEntry.fromJson(item);
          if (entry.gameId > 0) {
            grouped.putIfAbsent(entry.gameId, () => []).add(entry);
          }
        } catch (_) {
        }
      }
    }
    return grouped;
  }

  static int parseHistoryConfig(dynamic data) {
    if (data is Map<String, dynamic>) {
      final time = data['timeCountDown'];
      if (time is num) {
        return time.toInt();
      }
    }
    return 0;
  }

  static bool parseUpdateHistoryConfig(dynamic data) {
    if (data is Map<String, dynamic>) {
      final status = data['status'];
      return status == 1;
    }
    return false;
  }

  static CardLastJoinData? parseCardLastJoin(dynamic data) {
    if (data is Map<String, dynamic>) {
      return CardLastJoinData.fromJson(data);
    }
    return null;
  }

  static UserBalanceData parseUserBalance(dynamic data) {
    if (data is Map<String, dynamic>) {
      return UserBalanceData.fromJson(data);
    }
    throw const FormatException('Missing "data" in fetch-balance response');
  }
}
