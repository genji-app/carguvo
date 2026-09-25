import 'dart:convert';

import 'package:meta/meta.dart';

@immutable
class VoltaWire {
  const VoltaWire._();

  static const int voltaLeagueId = 2008;

  static List<VoltaWireEvent> decodeFrame(String text) {
    final Object? outer = _tryJson(text);
    if (outer is! Map<String, Object?>) return const <VoltaWireEvent>[];
    if (outer['t'] != 'current') return const <VoltaWireEvent>[];

    final Object? payload = outer['d'];
    final Object? decoded = payload is String ? _tryJson(payload) : payload;
    if (decoded is! List<Object?>) return const <VoltaWireEvent>[];

    return decodeLeagues(decoded);
  }

  static List<VoltaWireEvent> decodeLeagues(List<Object?> input) {
    final Object? normalized = normalizeIndexed(input);
    if (normalized is! List<Object?>) return const <VoltaWireEvent>[];
    final List<Object?> raw = normalized;

    if (raw.isEmpty) return const <VoltaWireEvent>[];
    final Object? first = raw.first;
    if (first is num || first is String) return _decodeLeague(raw);

    final List<VoltaWireEvent> out = <VoltaWireEvent>[];
    for (final Object? league in raw) {
      if (league is List<Object?>) out.addAll(_decodeLeague(league));
    }
    return out;
  }

  static List<VoltaWireEvent> _decodeLeague(List<Object?> league) {
    if (_int(_at(league, 0)) != voltaLeagueId) {
      return const <VoltaWireEvent>[];
    }
    final Object? events = _at(league, 2);
    if (events is! List<Object?>) return const <VoltaWireEvent>[];

    final List<VoltaWireEvent> out = <VoltaWireEvent>[];
    for (final Object? row in events) {
      if (row is! List<Object?>) continue;
      final VoltaWireEvent? event = VoltaWireEvent.fromArray(row);
      if (event != null) out.add(event);
    }
    return out;
  }

  static const int maxIndexKey = 128;

  static Object? normalizeIndexed(Object? node) {
    if (node is List) {
      return <Object?>[for (final Object? item in node) normalizeIndexed(item)];
    }
    if (node is! Map) return node;

    final Map<Object?, Object?> map = node;
    int maxIndex = -1;
    bool indexed = map.isNotEmpty;
    for (final Object? key in map.keys) {
      final int? index = key is int ? key : int.tryParse('$key');
      if (index == null || index < 0 || index > maxIndexKey) {
        indexed = false;
        break;
      }
      if (index > maxIndex) maxIndex = index;
    }

    if (!indexed) {
      return <Object?, Object?>{
        for (final MapEntry<Object?, Object?> e in map.entries)
          e.key: normalizeIndexed(e.value),
      };
    }

    final List<Object?> out = List<Object?>.filled(maxIndex + 1, null);
    map.forEach((Object? key, Object? value) {
      final int index = key is int ? key : int.parse('$key');
      out[index] = normalizeIndexed(value);
    });
    return out;
  }

  static Object? _tryJson(String text) {
    try {
      return jsonDecode(text);
    } on FormatException {
      return null;
    }
  }

  static Object? _at(List<Object?> list, int index) =>
      index >= 0 && index < list.length ? list[index] : null;

  static int _int(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static String _str(Object? value) => value is String ? value : '';

  static String? _url(Object? value) {
    final String s = _str(value).trim();
    return s.isEmpty ? null : s;
  }

  static int _epochSeconds(Object? value) {
    final String s = _str(value);
    if (s.isEmpty) return 0;
    final DateTime? at = DateTime.tryParse(s);
    if (at == null) return 0;
    return at.millisecondsSinceEpoch ~/ 1000;
  }
}

@immutable
class VoltaWireEvent {
  final int eventId;
  final String home;
  final String away;
  final String? homeLogo;
  final String? awayLogo;

  final int startSecond;
  final int finishSecond;

  final int won;

  final int matchType;

  final int homeStake;
  final int awayStake;
  final int homePlayers;
  final int awayPlayers;

  final VoltaWireOdds? odds;

  final String? liveUrl;

  final String? md5;

  const VoltaWireEvent({
    required this.eventId,
    required this.home,
    required this.away,
    required this.startSecond,
    required this.finishSecond,
    required this.won,
    required this.matchType,
    required this.homeStake,
    required this.awayStake,
    required this.homePlayers,
    required this.awayPlayers,
    this.homeLogo,
    this.awayLogo,
    this.odds,
    this.md5,
    this.liveUrl,
  });

  static VoltaWireEvent? fromArray(List<Object?> raw) {
    final int eventId = VoltaWire._int(VoltaWire._at(raw, 8));
    if (eventId == 0) return null;

    final VoltaWireOdds? odds = VoltaWireOdds.parse(
      VoltaWire._str(_oddsRaw(raw)),
    );
    if (odds == null) return null;

    final Object? bet = VoltaWire._at(raw, 24);
    final List<Object?> betList = bet is List<Object?> ? bet : const <Object?>[];

    return VoltaWireEvent(
      eventId: eventId,
      home: VoltaWire._str(VoltaWire._at(raw, 2)),
      away: VoltaWire._str(VoltaWire._at(raw, 3)),
      homeLogo: VoltaWire._url(VoltaWire._at(raw, 19)),
      awayLogo: VoltaWire._url(VoltaWire._at(raw, 20)),
      startSecond: VoltaWire._epochSeconds(VoltaWire._at(raw, 0)),
      finishSecond: VoltaWire._epochSeconds(VoltaWire._at(raw, 28)),
      won: VoltaWire._int(VoltaWire._at(raw, 25)),
      matchType: VoltaWire._int(VoltaWire._at(raw, 14)),
      homeStake: VoltaWire._int(VoltaWire._at(betList, 0)),
      awayStake: VoltaWire._int(VoltaWire._at(betList, 1)),
      homePlayers: VoltaWire._int(VoltaWire._at(betList, 2)),
      awayPlayers: VoltaWire._int(VoltaWire._at(betList, 3)),
      odds: odds,
      md5: VoltaWire._url(VoltaWire._at(raw, 29)),
      liveUrl: VoltaWire._url(VoltaWire._at(raw, 22)),
    );
  }

  static Object? _oddsRaw(List<Object?> raw) {
    final Object? l7 = VoltaWire._at(raw, 7);
    if (l7 is! List<Object?>) return null;
    final Object? l16 = VoltaWire._at(l7, 16);
    if (l16 is! List<Object?>) return null;
    return VoltaWire._at(l16, 0);
  }
}

@immutable
class VoltaWireOdds {
  final double homeOdds;
  final double awayOdds;

  final String homeOddsText;
  final String awayOddsText;

  final String homeSelectionId;
  final String awaySelectionId;
  final String offerId;

  const VoltaWireOdds({
    required this.homeOdds,
    required this.awayOdds,
    required this.homeSelectionId,
    required this.awaySelectionId,
    required this.offerId,
    this.homeOddsText = fallbackOddsText,
    this.awayOddsText = fallbackOddsText,
  });

  static const double fallbackOdds = 1.98;

  static const String fallbackOddsText = '1.98';

  static VoltaWireOdds? parse(String raw) {
    if (raw.isEmpty) return null;
    final List<String> parts = raw
        .split(' ')
        .where((String p) => p.isNotEmpty)
        .toList();
    if (parts.length < 2) return null;

    final List<String> homeParts = parts[0].split('*');
    final List<String> awayParts = parts[1].split('*');
    if (homeParts.length < 2 || awayParts.length < 2) return null;
    if (homeParts[1].isEmpty || awayParts[1].isEmpty) return null;

    final String homeText = homeParts[0].trim();
    final String awayText = awayParts[0].trim();

    return VoltaWireOdds(
      homeOdds: double.tryParse(homeText) ?? fallbackOdds,
      awayOdds: double.tryParse(awayText) ?? fallbackOdds,
      homeOddsText: homeText.isEmpty ? fallbackOddsText : homeText,
      awayOddsText: awayText.isEmpty ? fallbackOddsText : awayText,
      homeSelectionId: homeParts[1],
      awaySelectionId: awayParts[1],
      offerId: parts.length > 2 ? parts[2] : '',
    );
  }
}
