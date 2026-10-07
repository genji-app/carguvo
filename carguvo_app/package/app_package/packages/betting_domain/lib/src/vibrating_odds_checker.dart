library;

import 'league_enums.dart';

class VibratingOddsChecker {
  static const int footballSportId = 1;

  static const Set<int> overUnderMarketIds = {
    3,
    4,
    21,
    22,
    31,
    32,
  };

  static const Set<int> _cornerMarketIds = {21, 22};

  static bool isVibrating({
    required int sportId,
    required bool isLive,
    required int marketId,
    required String points,
    required double oddsValue,
    required OddsStyle oddsFormat,
    required int homeScore,
    required int awayScore,
    int cornersHome = 0,
    int cornersAway = 0,
  }) {
    if (sportId != footballSportId) return false;

    if (!isLive) return false;

    if (!overUnderMarketIds.contains(marketId)) return false;

    if (points.contains('-')) return false;

    if (!_isLineMatching(
      marketId, points, homeScore, awayScore, cornersHome, cornersAway,
    )) {
      return false;
    }

    return _meetsThreshold(oddsValue, oddsFormat);
  }

  static bool _isLineMatching(
    int marketId,
    String points,
    int homeScore,
    int awayScore,
    int cornersHome,
    int cornersAway,
  ) {
    final parsedLine = double.tryParse(points);
    if (parsedLine == null) return false;

    final double expectedLine;
    if (_cornerMarketIds.contains(marketId)) {
      expectedLine = (cornersHome + cornersAway) + 0.5;
    } else {
      expectedLine = (homeScore + awayScore) + 0.5;
    }

    return parsedLine == expectedLine;
  }

  static bool _meetsThreshold(double odds, OddsStyle format) {
    return switch (format) {
      OddsStyle.malay => odds.abs() > 0 && odds.abs() <= 0.6,
      OddsStyle.decimal => odds >= 2.67,
      OddsStyle.indo || OddsStyle.hongKong => odds >= 1.67,
    };
  }
}
