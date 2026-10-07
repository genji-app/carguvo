import 'dart:convert';
import 'dart:typed_data';

class V2SubscriptionHelper {
  static const String defaultLanguage = 'vi';

  static String leagueChannel(int sportId, {String lang = defaultLanguage}) {
    return 'ln:$lang:s:$sportId:l';
  }

  static String matchChannel(
    int sportId,
    int timeRange, {
    String lang = defaultLanguage,
    int? sportTypeId,
  }) {
    if (sportTypeId != null) {
      return 'ln:$lang:s:$sportId:st:$sportTypeId:tr:$timeRange:e';
    }
    return 'ln:$lang:s:$sportId:tr:$timeRange:e';
  }

  static String matchDetailChannel(int eventId,
      {String lang = defaultLanguage}) {
    return 'ln:$lang:e:$eventId';
  }

  static String leagueEventsChannel(
    int leagueId,
    int timeRange, {
    String lang = defaultLanguage,
  }) {
    return 'ln:$lang:l:$leagueId:tr:$timeRange:e';
  }

  static String hotChannel(
    int sportId, {
    String lang = defaultLanguage,
    int? timeRange,
  }) {
    if (timeRange != null) {
      return 'ln:$lang:s:$sportId:tr:$timeRange:e:hot';
    }
    return 'ln:$lang:s:$sportId:e:hot';
  }

  static String outrightChannel(int sportId, {String lang = defaultLanguage}) {
    return 'ln:$lang:s:$sportId:e:ort';
  }

  static Uint8List subscribeMessage(String channel) {
    final message = 'SUBSCRIBE:$channel';
    return Uint8List.fromList(utf8.encode(message));
  }

  static Uint8List unsubscribeMessage(String channel) {
    final message = 'UNSUBSCRIBE:$channel';
    return Uint8List.fromList(utf8.encode(message));
  }

  static Uint8List pingMessage(int pingNumber) {
    final message = 'ping_$pingNumber';
    return Uint8List.fromList(utf8.encode(message));
  }

  static int? parseSportId(String channel) {
    final parts = channel.split(':');
    final sIndex = parts.indexOf('s');
    if (sIndex >= 0 && sIndex < parts.length - 1) {
      return int.tryParse(parts[sIndex + 1]);
    }
    return null;
  }

  static int? parseTimeRange(String channel) {
    final parts = channel.split(':');
    final trIndex = parts.indexOf('tr');
    if (trIndex >= 0 && trIndex < parts.length - 1) {
      return int.tryParse(parts[trIndex + 1]);
    }
    return null;
  }

  static int? parseEventId(String channel) {
    final parts = channel.split(':');
    final eIndex = parts.indexOf('e');
    if (eIndex >= 0 && eIndex < parts.length - 1) {
      return int.tryParse(parts[eIndex + 1]);
    }
    return null;
  }

  static bool isLeagueChannel(String channel) {
    return channel.endsWith(':l') && channel.contains(':s:');
  }

  static bool isMatchChannel(String channel) {
    return channel.endsWith(':e') && channel.contains(':tr:');
  }

  static bool isMatchDetailChannel(String channel) {
    final parts = channel.split(':');
    if (parts.length < 3) return false;
    final eIndex = parts.indexOf('e');
    if (eIndex < 0 || eIndex >= parts.length - 1) return false;
    return int.tryParse(parts[eIndex + 1]) != null;
  }

  static bool isHotChannel(String channel) {
    return channel.endsWith(':e:hot');
  }

  static bool isOutrightChannel(String channel) {
    return channel.endsWith(':e:ort');
  }
}

class V2TimeRange {
  static const int live = 0;
  static const int today = 1;
  static const int early = 2;

  static const int all = 4;

  static const int todayAndEarly = 3;

  static int fromString(String timeRange) {
    switch (timeRange.toUpperCase()) {
      case 'LIVE':
        return live;
      case 'TODAY':
        return today;
      case 'EARLY':
        return early;
      default:
        return live;
    }
  }

  static String toStringValue(int timeRange) {
    switch (timeRange) {
      case live:
        return 'LIVE';
      case today:
        return 'TODAY';
      case early:
        return 'EARLY';
      default:
        return 'LIVE';
    }
  }
}

class CombatSportType {
  static const int muayThai = 1;
  static const int mma = 2;
  static const int boxing = 3;
}
