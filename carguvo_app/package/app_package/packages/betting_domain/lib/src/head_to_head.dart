library;

enum H2hResult {
  win('T'),
  draw('H'),
  loss('B');

  const H2hResult(this.label);

  final String label;

  H2hResult get mirrored => switch (this) {
    H2hResult.win => H2hResult.loss,
    H2hResult.draw => H2hResult.draw,
    H2hResult.loss => H2hResult.win,
  };
}

class H2hMeeting {
  const H2hMeeting({
    required this.startTime,
    required this.homeGoals,
    required this.awayGoals,
    required this.homeWasHost,
    required this.result,
    this.tournament = '',
  });

  final DateTime? startTime;

  final int homeGoals;

  final int awayGoals;

  final bool homeWasHost;

  final H2hResult result;

  final String tournament;

  int get totalGoals => homeGoals + awayGoals;

  bool get bothScored => homeGoals > 0 && awayGoals > 0;
}

class HeadToHead {
  const HeadToHead({
    required this.homeWins,
    required this.draws,
    required this.awayWins,
    required this.meetings,
    required this.homeForm,
    required this.awayForm,
    this.recent = const [],
  });

  final int homeWins;
  final int draws;
  final int awayWins;

  final int meetings;

  final List<H2hResult> homeForm;
  final List<H2hResult> awayForm;

  final List<H2hMeeting> recent;

  bool get isEmpty => meetings == 0 && homeForm.isEmpty && awayForm.isEmpty;

  int get homeWinCount => homeForm.where((r) => r == H2hResult.win).length;

  int get awayWinCount => awayForm.where((r) => r == H2hResult.win).length;

  double get goalsPerMatch {
    if (recent.isEmpty) return 0;
    final total = recent.fold<int>(0, (sum, m) => sum + m.totalGoals);
    return total / recent.length;
  }

  int get over25Count => recent.where((m) => m.totalGoals >= 3).length;

  int get bttsCount => recent.where((m) => m.bothScored).length;
}

abstract final class HeadToHeadParser {
  static const int maxMeetings = 5;

  static HeadToHead? parse(Map<String, dynamic>? data) {
    final meetings = _matches(data);
    if (meetings.isEmpty) return null;

    final ids = _currentCompetitors(data);
    if (ids == null) return null;
    final (homeId, _) = ids;

    var homeWins = 0;
    var draws = 0;
    var awayWins = 0;
    final homeForm = <H2hResult>[];
    final awayForm = <H2hResult>[];
    final recent = <H2hMeeting>[];
    for (final m in meetings.take(maxMeetings)) {
      final r = resultFor(m, homeId);
      if (r == null) continue;
      homeForm.add(r);
      awayForm.add(r.mirrored);
      recent.add(_meeting(m, homeId, r));
      switch (r) {
        case H2hResult.win:
          homeWins++;
        case H2hResult.draw:
          draws++;
        case H2hResult.loss:
          awayWins++;
      }
    }

    final h2h = HeadToHead(
      homeWins: homeWins,
      draws: draws,
      awayWins: awayWins,
      meetings: homeForm.length,
      homeForm: homeForm.reversed.toList(growable: false),
      awayForm: awayForm.reversed.toList(growable: false),
      recent: List.unmodifiable(recent),
    );
    return h2h.isEmpty ? null : h2h;
  }

  static List<Map<String, dynamic>> _matches(Map<String, dynamic>? data) {
    final raw = data?['headToHead'];
    if (raw is! List) return const [];
    return [
      for (final m in raw)
        if (m is Map) Map<String, dynamic>.from(m),
    ];
  }

  static (String, String)? _currentCompetitors(Map<String, dynamic>? data) {
    final c = data?['competitors'];
    if (c is! Map) return null;
    final home = c['home'];
    final away = c['away'];
    if (home is! Map || away is! Map) return null;
    final homeId = home['id']?.toString() ?? '';
    final awayId = away['id']?.toString() ?? '';
    if (homeId.isEmpty || awayId.isEmpty) return null;
    return (homeId, awayId);
  }

  static H2hResult? resultFor(Map<String, dynamic> m, String teamId) {
    if (teamId.isEmpty) return null;
    final c = m['competitors'];
    if (c is! Map) return null;
    final homeId = c['home'] is Map
        ? (c['home'] as Map)['id']?.toString() ?? ''
        : '';
    final awayId = c['away'] is Map
        ? (c['away'] as Map)['id']?.toString() ?? ''
        : '';
    final homeScore = (m['homeScore'] as num?)?.toInt();
    final awayScore = (m['awayScore'] as num?)?.toInt();
    if (homeScore == null || awayScore == null) return null;
    final isHome = homeId == teamId;
    if (!isHome && awayId != teamId) return null;
    final mine = isHome ? homeScore : awayScore;
    final theirs = isHome ? awayScore : homeScore;
    if (mine > theirs) return H2hResult.win;
    if (mine == theirs) return H2hResult.draw;
    return H2hResult.loss;
  }

  static H2hMeeting _meeting(Map<String, dynamic> m, String homeId, H2hResult r) {
    final c = m['competitors'] as Map;
    final hostId = c['home'] is Map ? (c['home'] as Map)['id']?.toString() ?? '' : '';
    final homeWasHost = hostId == homeId;
    final hostGoals = (m['homeScore'] as num).toInt();
    final guestGoals = (m['awayScore'] as num).toInt();
    return H2hMeeting(
      startTime: _startTime(m['startTime']),
      homeGoals: homeWasHost ? hostGoals : guestGoals,
      awayGoals: homeWasHost ? guestGoals : hostGoals,
      homeWasHost: homeWasHost,
      result: r,
      tournament: _tournament(m),
    );
  }

  static DateTime? _startTime(Object? raw) {
    if (raw is! String || raw.isEmpty) return null;
    return DateTime.tryParse(raw)?.toUtc();
  }

  static String _tournament(Map<String, dynamic> m) {
    for (final key in const ['tournament', 'competition', 'season']) {
      final v = m[key];
      if (v is Map) {
        final name = v['name'];
        if (name is String && name.trim().isNotEmpty) return name.trim();
      } else if (v is String && v.trim().isNotEmpty) {
        return v.trim();
      }
    }
    final flat = m['tournamentName'];
    if (flat is String && flat.trim().isNotEmpty) return flat.trim();
    return '';
  }
}
