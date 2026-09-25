import 'package:betting_domain/betting_domain.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/features/bet_detail/domain/models/market_drawer_data.dart';

class ResolvedOdds {
  final double value;
  final OddsStyle style;
  const ResolvedOdds({required this.value, required this.style});
}

class MarketLayoutHelper {
  MarketLayoutHelper._();

  static bool is1X2(int id) => MarketOddsRules.is1X2(id);

  static bool isHandicap(int id) => MarketOddsRules.isHandicap(id);

  static bool isOverUnder(int id) => MarketOddsRules.isOverUnder(id);

  static bool isOddEven(int id) => MarketOddsRules.isOddEven(id);

  static bool isCorrectScore(int id) => MarketOddsRules.isCorrectScore(id);

  static bool isDoubleChance(int id) => MarketOddsRules.isDoubleChance(id);

  static bool isTotalScore(int id) => MarketOddsRules.isTotalScore(id);

  static bool isDrawNoBet(int id) => MarketOddsRules.isDrawNoBet(id);

  static bool isCornerRange(int id) => MarketOddsRules.isCornerRange(id);

  static bool isExactGoals(int id) => [132, 133, 197, 198].contains(id);

  static bool isSecondHalf(int id) => MarketOddsRules.isSecondHalf(id);

  static bool isYesNo(int id) => const [
        36, 37, 60, 69, 70, 71, 72, 73, 74, 83, 84, 99, 100, 148, 149, 154,
        1008,
        1001, 1002,
        78, 79, 1018,
      ].contains(id);

  static bool isHalfTimeFullTime(int id) => id == 68;

  static bool isOverExactlyUnder(int id) => const [140, 141, 145].contains(id);

  static bool isEuropeanHandicap(int id) => const [144, 152, 195].contains(id);

  static bool isCombo(int id) => const [81, 82, 98].contains(id);

  static String? comboCellLabel(int marketId, String points, {String? homeName, String? awayName}) => MarketLabels.comboCellLabel(marketId, points, homeName: homeName, awayName: awayName);

  static String comboSelectionName(int marketId, String points) => MarketLabels.comboSelectionName(marketId, points);

  static bool comboHasDecodableCell(int marketId, List<LeagueOddsData> odds) {
    for (final o in odds) {
      if (comboCellLabel(marketId, o.points) != null) return true;
    }
    return false;
  }

  static int comboSortKey(String points) => MarketLabels.comboSortKey(points);

  static String htFtLabel(String points, {String? homeName, String? awayName}) => MarketLabels.htFtLabel(points, homeName: homeName, awayName: awayName);

  static String htFtSelectionCode(String points) => MarketLabels.htFtSelectionCode(points);

  static int htFtSortKey(String points) => MarketLabels.htFtSortKey(points);

  static String totalScoreLabel(String points) => MarketLabels.totalScoreLabel(points);

  static bool isAlwaysDecimal(int marketId) =>
      MarketOddsRules.isAlwaysDecimal(marketId);

  static OddsStyle getEffectiveOddsStyle(int marketId, OddsStyle userStyle) =>
      MarketOddsRules.getEffectiveOddsStyle(marketId, userStyle);

  static String getOddsValue(
    OddsValue oddsValue,
    int marketId,
    OddsStyle userStyle,
  ) {
    final effectiveStyle = getEffectiveOddsStyle(marketId, userStyle);
    return resolveOdds(oddsValue, effectiveStyle) ?? '-';
  }

  static String? resolveOdds(OddsValue oddsValue, OddsStyle style) {
    final preferred = _formatStyle(oddsValue, style);
    if (preferred != null) return preferred;
    for (final fallback in const [
      OddsStyle.decimal,
      OddsStyle.indo,
      OddsStyle.malay,
      OddsStyle.hongKong,
    ]) {
      if (fallback == style) continue;
      final value = _formatStyle(oddsValue, fallback);
      if (value != null) return value;
    }
    return null;
  }

  static double? resolveOddsAsDouble(OddsValue oddsValue, OddsStyle style) {
    return resolveOddsWithStyle(oddsValue, style)?.value;
  }

  static ResolvedOdds? resolveOddsWithStyle(
    OddsValue oddsValue,
    OddsStyle style,
  ) {
    final native = _rawStyle(oddsValue, style);
    if (native != null) return ResolvedOdds(value: native, style: style);
    for (final fallback in const [
      OddsStyle.decimal,
      OddsStyle.indo,
      OddsStyle.malay,
      OddsStyle.hongKong,
    ]) {
      if (fallback == style) continue;
      final value = _rawStyle(oddsValue, fallback);
      if (value != null) return ResolvedOdds(value: value, style: fallback);
    }
    return null;
  }

  static double? _rawStyle(OddsValue oddsValue, OddsStyle style) {
    switch (style) {
      case OddsStyle.malay:
        return (oddsValue.malay == -100 || oddsValue.malay == 0)
            ? null
            : oddsValue.malay;
      case OddsStyle.indo:
        return (oddsValue.indo == -100 || oddsValue.indo == 0)
            ? null
            : oddsValue.indo;
      case OddsStyle.decimal:
        return oddsValue.decimal <= 0 ? null : oddsValue.decimal;
      case OddsStyle.hongKong:
        return (oddsValue.hongKong == -100 || oddsValue.hongKong == 0)
            ? null
            : oddsValue.hongKong;
    }
  }

  static String? _formatStyle(OddsValue oddsValue, OddsStyle style) {
    final v = _rawStyle(oddsValue, style);
    return v?.toStringAsFixed(2);
  }

  static MarketPoolType getPoolType({
    required List<int> marketIds,
    required bool isLandscape,
  }) {
    final sortedIds = [...marketIds]..sort();

    if (_matchesPattern(sortedIds, [1, 2, 3, 4, 5, 6])) {
      return isLandscape ? MarketPoolType.main6 : MarketPoolType.main;
    }

    if (_matchesPattern(sortedIds, [1, 3, 5])) {
      return MarketPoolType.main;
    }

    if (_matchesPattern(sortedIds, [17, 18, 19, 20, 21, 22])) {
      return isLandscape ? MarketPoolType.main6 : MarketPoolType.main;
    }

    if (_matchesPattern(sortedIds, [23, 24, 25, 26, 27, 28])) {
      return isLandscape ? MarketPoolType.main6 : MarketPoolType.main;
    }

    if (sortedIds.contains(10) && sortedIds.contains(11)) {
      return isLandscape
          ? MarketPoolType.correctScore6
          : MarketPoolType.correctScore;
    }
    if (sortedIds.contains(10) || sortedIds.contains(11)) {
      return MarketPoolType.correctScore;
    }

    if (_matchesPattern(sortedIds, [8, 9])) {
      return isLandscape ? MarketPoolType.only2x2 : MarketPoolType.only2;
    }
    if (sortedIds.contains(8) || sortedIds.contains(9)) {
      return MarketPoolType.only2;
    }

    if (_matchesPattern(sortedIds, [12, 13])) {
      return isLandscape ? MarketPoolType.only3x2 : MarketPoolType.only3;
    }
    if (sortedIds.contains(12) || sortedIds.contains(13)) {
      return MarketPoolType.only3;
    }

    if (_matchesPattern(sortedIds, [16, 35])) {
      return isLandscape ? MarketPoolType.only2x2 : MarketPoolType.only2;
    }

    if (_matchesPattern(sortedIds, [14, 15])) {
      return isLandscape ? MarketPoolType.together : MarketPoolType.together;
    }

    if (sortedIds.contains(7)) {
      return MarketPoolType.only3;
    }

    if (_matchesPattern(sortedIds, [80, 81])) {
      return MarketPoolType.market2;
    }

    return MarketPoolType.main;
  }

  static bool _matchesPattern(List<int> sortedIds, List<int> pattern) {
    if (sortedIds.length != pattern.length) return false;
    final sortedPattern = [...pattern]..sort();
    for (var i = 0; i < sortedIds.length; i++) {
      if (sortedIds[i] != sortedPattern[i]) return false;
    }
    return true;
  }
}

class CorrectScoreHelper {
  CorrectScoreHelper._();

  static bool isAOS(String points) => CorrectScoreLabels.isAOS(points);

  static bool isWinningMargin(int marketId) => CorrectScoreLabels.isWinningMargin(marketId);

  static String marginDisplayText(String points) => CorrectScoreLabels.marginDisplayText(points);

  static bool marginIsHome(String points) => CorrectScoreLabels.marginIsHome(points);

  static String getDisplayText(String points, {int marketId = 0}) => CorrectScoreLabels.getDisplayText(points, marketId: marketId);

  static (int homeScore, int awayScore)? parseScores(String points) => CorrectScoreLabels.parseScores(points);

  static CorrectScoreGroups groupOdds(
    List<LeagueOddsData> odds, {
    int marketId = 0,
  }) {
    final home = <LeagueOddsData>[];
    final draw = <LeagueOddsData>[];
    final away = <LeagueOddsData>[];

    if (isWinningMargin(marketId)) {
      for (final o in odds) {
        (marginIsHome(o.points) ? home : away).add(o);
      }
      int byPoints(LeagueOddsData a, LeagueOddsData b) =>
          (int.tryParse(a.points) ?? 0) - (int.tryParse(b.points) ?? 0);
      home.sort(byPoints);
      away.sort(byPoints);
      return CorrectScoreGroups(home: home, draw: draw, away: away);
    }

    for (final o in odds) {
      final scores = parseScores(o.points);
      if (scores == null) continue;

      final (homeScore, awayScore) = scores;

      if (homeScore > awayScore) {
        home.add(o);
      } else if (homeScore < awayScore) {
        away.add(o);
      } else {
        draw.add(o);
      }
    }

    home.sort(_sortByHomeFirst);
    draw.sort(_sortByHomeFirst);
    away.sort(_sortByAwayFirst);

    return CorrectScoreGroups(home: home, draw: draw, away: away);
  }

  static int _sortByHomeFirst(LeagueOddsData a, LeagueOddsData b) {
    final scoresA = parseScores(a.points);
    final scoresB = parseScores(b.points);
    if (scoresA == null || scoresB == null) return 0;

    final (ah, aa) = scoresA;
    final (bh, ba) = scoresB;

    if (ah != bh) return ah - bh;
    return aa - ba;
  }

  static int _sortByAwayFirst(LeagueOddsData a, LeagueOddsData b) {
    final scoresA = parseScores(a.points);
    final scoresB = parseScores(b.points);
    if (scoresA == null || scoresB == null) return 0;

    final (ah, aa) = scoresA;
    final (bh, ba) = scoresB;

    if (aa != ba) return aa - ba;
    return ah - bh;
  }
}

class CorrectScoreGroups {
  final List<LeagueOddsData> home;
  final List<LeagueOddsData> draw;
  final List<LeagueOddsData> away;

  const CorrectScoreGroups({
    required this.home,
    required this.draw,
    required this.away,
  });

  int get maxRows {
    final lengths = [home.length, draw.length, away.length];
    return lengths.reduce((a, b) => a > b ? a : b);
  }

  bool get hasData => home.isNotEmpty || draw.isNotEmpty || away.isNotEmpty;
}

class MarketHeadersHelper {
  MarketHeadersHelper._();

  static List<String> getMain6Headers() => [
    'Kèo',
    'Tài/Xỉu',
    '1X2',
    'Kèo H1',
    'T/X H1',
    '1X2 H1',
  ];

  static List<String> getMain3Headers() => ['Kèo', 'Tài/Xỉu', '1X2'];

  static List<String> getCorrectScore6Headers() => [
    'Đội Nhà',
    'Hoà',
    'Đội Khách',
    'Nhà H1',
    'Hoà H1',
    'Khách H1',
  ];

  static List<String> getCorrectScore3Headers() => [
    'Đội Nhà',
    'Hoà',
    'Đội Khách',
  ];

  static List<String> getOddEvenHeaders() => ['Lẻ', 'Chẵn', 'Lẻ H1', 'Chẵn H1'];

  static List<String> getDoubleChance6Headers() => [
    '1X',
    'X2',
    '12',
    '1X H1',
    'X2 H1',
    '12 H1',
  ];

  static List<String> getDoubleChance3Headers() => ['1X', 'X2', '12'];

  static List<String> getOnly2Headers() => ['Nhà', 'Khách'];

  static List<String> getTogetherHeaders() => ['FT', 'H1'];

  static List<String> getMarket2Headers() => ['Over', 'Under'];

  static List<String> getNextGoalHeaders() => ['Nhà', 'Hoà', 'Khách'];

  static List<String> getOnly4Headers() => [
    'Không ai',
    'Nhà',
    'Khách',
    'Cả hai',
  ];
}
