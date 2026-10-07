library;

class HotStatsInput {
  const HotStatsInput({
    required this.mainLine,
    required this.home,
    required this.away,
  });

  final double? mainLine;
  final String home;
  final String away;
}

enum HotTrendSide { home, away }

class HotTrend {
  const HotTrend({
    required this.team,
    required this.percent,
    this.side,
  });

  final String team;

  final double percent;

  final HotTrendSide? side;

  String get percentText => '${percent.toStringAsFixed(2)}%';
}

class HotStatsRules {
  HotStatsRules._();

  static HotTrend? bettingTrend(
    Map<String, dynamic> simpleJson,
    HotStatsInput input,
  ) {
    final markets = simpleJson['1'];
    if (markets is! Map) return null;

    List<_Sel> selections(String marketId) => [
      for (final raw in (markets[marketId] as List<dynamic>? ?? const []))
        if (raw is Map)
          _Sel(
            points: double.tryParse(raw['2']?.toString() ?? ''),
            name: raw['3']?.toString().trim() ?? '',
            percent: (raw['4'] as num?)?.toDouble() ?? 0,
          ),
    ];

    HotTrendSide? sideByName(String name) {
      final n = name.trim().toLowerCase();
      if (n.isEmpty) return null;
      if (n == input.home.trim().toLowerCase()) return HotTrendSide.home;
      if (n == input.away.trim().toLowerCase()) return HotTrendSide.away;
      return null;
    }

    final m5 = selections('5');
    final mainLine = input.mainLine;
    if (m5.isNotEmpty && mainLine != null) {
      if (mainLine == 0) {
        _Sel? best;
        for (final s in m5) {
          if ((s.points ?? 0).abs() <= 0.5 && s.percent > (best?.percent ?? 0)) {
            best = s;
          }
        }
        if (best != null && best.percent > 0 && best.name.isNotEmpty) {
          return HotTrend(
            team: best.name,
            percent: best.percent,
            side: sideByName(best.name),
          );
        }
      } else {
        _Sel? home;
        _Sel? away;
        var homeDiff = double.infinity;
        var awayDiff = double.infinity;
        for (final s in m5) {
          final pts = s.points ?? 0;
          if (pts <= 0) {
            final d = (pts - (-mainLine)).abs();
            if (d < homeDiff) {
              homeDiff = d;
              home = s;
            }
          } else {
            final d = (pts - mainLine).abs();
            if (d < awayDiff) {
              awayDiff = d;
              away = s;
            }
          }
        }
        final homeWins = (home?.percent ?? 0) >= (away?.percent ?? 0);
        final chosen = homeWins ? home : away;
        if (chosen != null && chosen.percent > 0 && chosen.name.isNotEmpty) {
          return HotTrend(
            team: chosen.name,
            percent: chosen.percent,
            side: sideByName(chosen.name) ??
                (homeWins ? HotTrendSide.home : HotTrendSide.away),
          );
        }
      }
    }

    final m1 = selections('1');
    _Sel? top;
    for (final s in m1) {
      if (s.percent > (top?.percent ?? 0)) top = s;
    }
    if (top == null || top.percent <= 0) return null;
    return switch (top.name.toLowerCase()) {
      'home' => HotTrend(
        team: input.home,
        percent: top.percent,
        side: HotTrendSide.home,
      ),
      'away' => HotTrend(
        team: input.away,
        percent: top.percent,
        side: HotTrendSide.away,
      ),
      _ => HotTrend(
        team: top.name,
        percent: top.percent,
        side: sideByName(top.name),
      ),
    };
  }

  static String? bettingTrendLabel(
    Map<String, dynamic> simpleJson,
    HotStatsInput input,
  ) {
    final trend = bettingTrend(simpleJson, input);
    if (trend == null) return null;
    return '${trend.team} ${trend.percent.toStringAsFixed(2)}%';
  }

  static int? totalUsers(Map<String, dynamic> usersJson) {
    final raw = usersJson['1'];
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw);
    return null;
  }
}

class _Sel {
  const _Sel({required this.points, required this.name, required this.percent});

  final double? points;
  final String name;
  final double percent;
}
