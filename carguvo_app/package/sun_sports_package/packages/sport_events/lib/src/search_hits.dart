library;

class SearchLeagueHit {
  const SearchLeagueHit({
    required this.sportId,
    required this.leagueId,
    required this.name,
    required this.logo,
  });

  final int sportId;
  final int leagueId;
  final String name;

  final String logo;

  factory SearchLeagueHit.fromApi(Map<dynamic, dynamic> raw) => SearchLeagueHit(
    sportId: _int(raw['0']),
    leagueId: _int(raw['1']),
    name: raw['2']?.toString() ?? '',
    logo: raw['4']?.toString() ?? '',
  );
}

class SearchEventHit {
  const SearchEventHit({
    required this.sportId,
    required this.leagueId,
    required this.leagueName,
    required this.eventId,
    required this.eventName,
    required this.startTimeIso,
    required this.startTimeMs,
    required this.startTime,
    required this.isLive,
    required this.status,
    required this.leagueIcon,
    required this.homeLogo,
    required this.awayLogo,
  });

  final int sportId;

  final int leagueId;

  final String leagueName;

  final int eventId;

  final String eventName;

  final String startTimeIso;

  final int startTimeMs;

  final DateTime? startTime;

  final bool isLive;

  final int status;

  final String leagueIcon;
  final String homeLogo;
  final String awayLogo;

  (String, String)? get teams {
    final parts = eventName.split(' vs ');
    if (parts.length != 2) return null;
    return (parts[0].trim(), parts[1].trim());
  }

  factory SearchEventHit.fromApi(Map<dynamic, dynamic> raw) {
    final iso = raw['5']?.toString() ?? '';
    final ms = _int(raw['6']);
    return SearchEventHit(
      sportId: _int(raw['0']),
      leagueId: _int(raw['1']),
      leagueName: raw['2']?.toString() ?? '',
      eventId: _int(raw['3']),
      eventName: raw['4']?.toString() ?? '',
      startTimeIso: iso,
      startTimeMs: ms,
      startTime: _time(iso, ms),
      isLive: _bool(raw['7']),
      status: _int(raw['8']),
      leagueIcon: raw['9']?.toString() ?? '',
      homeLogo: raw['10']?.toString() ?? '',
      awayLogo: raw['11']?.toString() ?? '',
    );
  }
}

class SearchHits {
  const SearchHits({required this.leagues, required this.events});

  final List<SearchLeagueHit> leagues;
  final List<SearchEventHit> events;

  bool get isEmpty => leagues.isEmpty && events.isEmpty;

  static const SearchHits empty = SearchHits(leagues: [], events: []);

  factory SearchHits.fromApi(Map<dynamic, dynamic> decoded) => SearchHits(
    leagues: decoded['0'] is List
        ? (decoded['0'] as List)
              .whereType<Map>()
              .map(SearchLeagueHit.fromApi)
              .toList()
        : const [],
    events: decoded['1'] is List
        ? (decoded['1'] as List)
              .whereType<Map>()
              .map(SearchEventHit.fromApi)
              .toList()
        : const [],
  );
}

int _int(dynamic v) {
  if (v is num) return v.toInt();
  return int.tryParse(v?.toString() ?? '') ?? 0;
}

bool _bool(dynamic v) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  final s = v?.toString().toLowerCase();
  return s == 'true' || s == '1';
}

DateTime? _time(dynamic iso, dynamic ms) {
  final parsed = DateTime.tryParse(iso?.toString() ?? '');
  if (parsed != null) return parsed;
  final millis = _int(ms);
  if (millis <= 0) return null;
  return DateTime.fromMillisecondsSinceEpoch(millis);
}

List<SearchEventHit> parsePopularEventHits(
  List<dynamic> rawLeagues, {
  int limit = 5,
}) {
  final candidates = <({int marketCount, SearchEventHit hit})>[];
  for (final rawLeague in rawLeagues) {
    if (rawLeague is! Map) continue;
    final key2 = rawLeague['2'];
    final key4 = rawLeague['4'];
    final isAlternate = key2 is String && key4 is num;
    final int leagueId;
    final String leagueName;
    final String leagueLogo;
    if (isAlternate) {
      leagueId = _int(rawLeague['1']);
      leagueName = key2.trim();
      final key5 = rawLeague['5']?.toString() ?? '';
      leagueLogo = key5.startsWith('http')
          ? key5
          : (rawLeague['3']?.toString() ?? '');
    } else {
      leagueId = _int(rawLeague['3']);
      leagueName = key4?.toString() ?? '';
      leagueLogo = rawLeague['6']?.toString() ?? '';
    }
    final rawEvents = rawLeague['0'];
    if (rawEvents is! List) continue;
    for (final rawEvent in rawEvents) {
      if (rawEvent is! Map) continue;
      final home = rawEvent['19']?.toString() ?? '';
      final away = rawEvent['20']?.toString() ?? '';
      candidates.add((
        marketCount: _int(rawEvent['23']),
        hit: SearchEventHit(
          sportId: _int(rawEvent['2']),
          leagueId: leagueId,
          leagueName: leagueName,
          eventId: _int(rawEvent['4']),
          eventName: '$home vs $away',
          startTimeIso: rawEvent['5']?.toString() ?? '',
          startTimeMs: 0,
          startTime: _time(rawEvent['5']?.toString(), 0),
          isLive: _bool(rawEvent['28']),
          status: 0,
          leagueIcon: leagueLogo,
          homeLogo: rawEvent['21']?.toString() ?? '',
          awayLogo: rawEvent['22']?.toString() ?? '',
        ),
      ));
    }
  }
  candidates.sort((a, b) => b.marketCount.compareTo(a.marketCount));
  return [for (final c in candidates.take(limit)) c.hit];
}
