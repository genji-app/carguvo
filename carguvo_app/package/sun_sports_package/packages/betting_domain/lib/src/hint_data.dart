library;

import 'hint_enums.dart';
import 'league_enums.dart';
import 'market_labels.dart';
import 'outright_kind.dart';

class HintData {
  final int marketId;

  final int sportId;

  final MarketCategory market;

  final Period period;

  final String periodLabel;

  final double handicap;

  final double ratio;

  final OddsStyle style;

  final HintTeamType team;

  final String homeName;

  final String awayName;

  final String teamName;

  final int homeScore;

  final int awayScore;

  final int homeCorner;

  final int awayCorner;

  final int homeBookings;

  final int awayBookings;

  final double stake;

  final int totalCostBet;

  final bool isLive;

  final String eventName;

  final String eventDate;

  final OutrightKind outrightKind;

  const HintData({
    required this.marketId,
    required this.market,
    required this.period,
    required this.handicap,
    required this.ratio,
    required this.style,
    required this.team,
    required this.homeName,
    required this.awayName,
    required this.teamName,
    required this.homeScore,
    required this.awayScore,
    required this.isLive,
    this.periodLabel = '',
    this.sportId = 1,
    this.homeCorner = 0,
    this.awayCorner = 0,
    this.homeBookings = 0,
    this.awayBookings = 0,
    this.stake = 100000.0,
    this.totalCostBet = 0,
    this.eventName = '',
    this.eventDate = '',
    this.outrightKind = OutrightKind.champion,
  });

  HintType getHintType() {
    final handicapAbs = handicap.abs();
    final decimal = handicapAbs - handicapAbs.floor();

    switch (market) {
      case MarketCategory.asianHandicap:
      case MarketCategory.cornerHandicap:
      case MarketCategory.bookingsHandicap:
        if (_isZero(decimal)) {
          return HintType.asianHandicapRound;
        } else if (_isHalf(decimal)) {
          return HintType.asianHandicapHalf;
        } else if (_isQuarter(decimal)) {
          return handicap < 0
              ? HintType.asianHandicapQuarterOver
              : HintType.asianHandicapQuarterUnder;
        } else if (_isThreeQuarter(decimal)) {
          return handicap < 0
              ? HintType.asianHandicap3QuarterOver
              : HintType.asianHandicap3QuarterUnder;
        }
        return HintType.asianHandicapRound;

      case MarketCategory.overUnder:
      case MarketCategory.cornerOverUnder:
      case MarketCategory.bookingsOverUnder:
      case MarketCategory.homeOverUnder:
      case MarketCategory.awayOverUnder:
        if (_isZero(decimal)) {
          return HintType.overUnderRound;
        } else if (_isHalf(decimal)) {
          return HintType.overUnderHalf;
        } else if (_isQuarter(decimal)) {
          return HintType.overUnderQuarter;
        } else if (_isThreeQuarter(decimal)) {
          return HintType.overUnder3Quarter;
        }
        return HintType.overUnderHalf;

      case MarketCategory.market1X2:
        return HintType.market1X2;
      case MarketCategory.oddEven:
        return HintType.oddEven;
      case MarketCategory.doubleChance:
        return HintType.doubleChance;
      case MarketCategory.correctScore:
        return HintType.correctScore;
      case MarketCategory.totalScore:
        return HintType.totalScore;
      case MarketCategory.drawNoBet:
        return HintType.drawNoBet;
      case MarketCategory.nextGoal:
        return HintType.nextGoal;
      case MarketCategory.moneyLine:
        return HintType.moneyLine;
      case MarketCategory.outright:
        return HintType.outright;
      default:
        return HintType.unknown;
    }
  }

  int getCaseCount() {
    final hintType = getHintType();
    switch (hintType) {
      case HintType.asianHandicapRound:
      case HintType.overUnderRound:
        return 3;
      case HintType.asianHandicapHalf:
      case HintType.overUnderHalf:
      case HintType.market1X2:
      case HintType.oddEven:
      case HintType.doubleChance:
      case HintType.moneyLine:
      case HintType.outright:
        return 2;
      case HintType.asianHandicapQuarterOver:
      case HintType.asianHandicapQuarterUnder:
      case HintType.asianHandicap3QuarterOver:
      case HintType.asianHandicap3QuarterUnder:
      case HintType.overUnderQuarter:
      case HintType.overUnder3Quarter:
        return 3;
      default:
        return 2;
    }
  }

  static bool _isZero(double decimal) => decimal < 0.001;
  static bool _isHalf(double decimal) => (decimal - 0.5).abs() < 0.001;
  static bool _isQuarter(double decimal) => (decimal - 0.25).abs() < 0.001;
  static bool _isThreeQuarter(double decimal) => (decimal - 0.75).abs() < 0.001;

  static MarketCategory getMarketCategory(int marketId) {
    if ([
      200, 205, 206, 207, 208, 209,
      400, 403, 404, 405, 406, 407,
      500, 504, 505, 506, 507, 508,
      700, 704, 705,
    ].contains(marketId)) {
      return MarketCategory.moneyLine;
    }

    if ([
      5, 6, 85, 27, 28, 44, 45, 46, 47, 48, 49,
      201, 203, 210, 211, 212, 213, 402, 509, 702, 709, 711,
    ].contains(marketId)) {
      return MarketCategory.asianHandicap;
    }

    if ([
      3, 4, 80, 25, 26, 38, 39, 40, 41, 42, 43,
      202, 204, 214, 215, 216, 217, 401, 510, 701, 710, 712,
    ].contains(marketId)) {
      return MarketCategory.overUnder;
    }

    if (marketId == 101 || marketId == 194) {
      return MarketCategory.homeOverUnder;
    }
    if (marketId == 102 || marketId == 193) {
      return MarketCategory.awayOverUnder;
    }

    if ([19, 20].contains(marketId)) {
      return MarketCategory.cornerHandicap;
    }

    if ([21, 22, 61, 62, 63, 64, 92, 93, 94, 95, 96].contains(marketId) ||
        (marketId >= 104 && marketId <= 128)) {
      return MarketCategory.cornerOverUnder;
    }

    if ([33, 34].contains(marketId)) {
      return MarketCategory.bookingsHandicap;
    }
    if ([31, 32].contains(marketId)) {
      return MarketCategory.bookingsOverUnder;
    }

    if ([1, 2, 89, 23, 24, 50, 51, 52, 53, 54, 55].contains(marketId)) {
      return MarketCategory.market1X2;
    }

    if ([8, 9, 86, 76, 77].contains(marketId)) {
      return MarketCategory.oddEven;
    }

    if ([12, 13].contains(marketId)) {
      return MarketCategory.doubleChance;
    }

    if ([10, 11].contains(marketId)) {
      return MarketCategory.correctScore;
    }
    if ([14, 15].contains(marketId)) {
      return MarketCategory.totalScore;
    }

    if ([16, 75, 157].contains(marketId)) {
      return MarketCategory.drawNoBet;
    }

    if (marketId == 7) return MarketCategory.nextGoal;
    if (marketId == 97) return MarketCategory.lastGoal;
    if ([17, 18].contains(marketId)) return MarketCategory.corner1X2;
    if ([56, 57].contains(marketId)) return MarketCategory.cornerOddEven;
    if ([29, 30].contains(marketId)) return MarketCategory.bookings1X2;
    if (marketId == 138) return MarketCategory.yellowCards1X2;
    if (marketId == 139) return MarketCategory.yellowCardsOverUnder;
    if ([66, 67].contains(marketId)) return MarketCategory.lastCorner;
    if (marketId == 137) return MarketCategory.nextCorner;
    if ([131, 134, 135, 136].contains(marketId)) {
      return MarketCategory.cornerRange;
    }
    if (marketId == 58) return MarketCategory.toQualify;
    if (marketId == 59) return MarketCategory.whichTeamKickOff;
    if (marketId == 103) return MarketCategory.whichTeamToScore;
    if ([153, 155, 156, 158, 1026, 1027].contains(marketId)) {
      return MarketCategory.playerGoalscorer;
    }
    if (marketId == 129) return MarketCategory.penaltyWinner;
    if (marketId == 130) return MarketCategory.penaltyTotal;
    if (marketId == 83 || marketId == 1001) {
      return MarketCategory.homeCleanSheet;
    }
    if (marketId == 84 || marketId == 1002) {
      return MarketCategory.awayCleanSheet;
    }
    if (marketId == 35) return MarketCategory.outright;

    if (marketId == 68) return MarketCategory.halfTimeFullTime;
    if (marketId == 147 || marketId == 1003) {
      return MarketCategory.restOfMatchWinner;
    }
    if (marketId == 146 || marketId == 1004) {
      return MarketCategory.europeanNextGoal;
    }
    if (marketId == 152 || marketId == 195) {
      return MarketCategory.europeanHandicapGoal;
    }
    if (marketId == 144) return MarketCategory.europeanHandicapCorner;
    if ([140, 141, 145].contains(marketId)) {
      return MarketCategory.cornerOverExactlyUnder;
    }
    if (marketId == 78 || marketId == 79) return MarketCategory.winToNil;
    if ([65, 87, 88].contains(marketId)) {
      return MarketCategory.highestScoringHalf;
    }
    if (marketId == 197 || marketId == 198) return MarketCategory.exactCorner;
    if (marketId == 199 || marketId == 1005) {
      return MarketCategory.nextCorner3Way;
    }
    if (marketId == 1018) return MarketCategory.nextPenaltyScored;
    if (marketId == 81 || marketId == 82 || marketId == 98) {
      return MarketCategory.combo;
    }
    if (marketId == 143) return MarketCategory.yellowCardsDoubleChance;

    return MarketCategory.unknown;
  }

  static Period getPeriod(int marketId) {
    if ([
      2, 4, 6, 9, 11, 13, 18, 20, 22, 24, 26, 28, 30, 32, 34, 57, 75, 136,
      193, 194, 1001, 1002, 1003, 1004, 140, 195, 197, 198, 199,
    ].contains(marketId)) {
      return Period.halfTime;
    }
    if ([80, 85, 86, 89].contains(marketId)) {
      return Period.secondHalf;
    }
    return Period.fullTime;
  }

  static String hintSelectionName({
    required MarketCategory market,
    required String teamName,
    required String playerName,
    required String points,
    int marketId = 0,
    String homeName = '',
    String awayName = '',
  }) {
    if (market == MarketCategory.playerGoalscorer) {
      return playerName.isNotEmpty ? playerName : teamName;
    }
    if (market == MarketCategory.correctScore) {
      return CorrectScoreLabels.getDisplayText(points);
    }
    if (market == MarketCategory.totalScore ||
        market == MarketCategory.cornerRange) {
      return points.replaceAll(':', '-');
    }
    if (market == MarketCategory.halfTimeFullTime) {
      return MarketLabels.htFtLabel(
        points,
        homeName: homeName,
        awayName: awayName,
      );
    }
    if (market == MarketCategory.combo) {
      final comboMarketId =
          marketId != 0 ? marketId : (points.contains(':') ? 82 : 98);
      return MarketLabels.comboCellLabel(
            comboMarketId,
            points,
            homeName: homeName,
            awayName: awayName,
          ) ??
          points;
    }
    if (market == MarketCategory.exactCorner) {
      return MarketLabels.totalScoreLabel(points);
    }
    return teamName;
  }

  static int keoRungWindowSize(int marketId) {
    const five = {164, 165, 166, 167, 171, 172, 173, 174, 175, 176, 177, 178};
    const ten = {159, 160, 161, 162, 163, 168, 169, 170, 179, 180, 190, 191};
    const fifteen = {181, 182, 186};
    if (five.contains(marketId)) return 5;
    if (ten.contains(marketId)) return 10;
    if (fifteen.contains(marketId)) return 15;
    return 0;
  }

  static String keoRungPeriodLabel({
    required int marketId,
    required int period,
    required int continuousMinute,
  }) {
    final size = keoRungWindowSize(marketId);
    if (size == 0) return '';
    final int start;
    if (period > 0) {
      start = period * size;
    } else if (continuousMinute > 0) {
      start = (continuousMinute ~/ size + 1) * size;
    } else {
      return '';
    }
    final end = start + size - 1;
    String pad(int v) => v.toString().padLeft(2, '0');
    return '${pad(start)}:00 - ${pad(end)}:59';
  }

  static double selectedHandicap({
    required String rawPoints,
    required MarketCategory market,
    required OddsType oddsType,
  }) {
    final raw = double.tryParse(rawPoints) ?? 0.0;
    final isHandicap =
        market == MarketCategory.asianHandicap ||
        market == MarketCategory.cornerHandicap ||
        market == MarketCategory.bookingsHandicap;
    if (isHandicap && oddsType == OddsType.away) {
      return -raw;
    }
    return raw;
  }

  static HintTeamType mapOddsTypeToTeam(OddsType oddsType) {
    switch (oddsType) {
      case OddsType.home:
        return HintTeamType.home;
      case OddsType.away:
        return HintTeamType.away;
      case OddsType.draw:
        return HintTeamType.draw;
      default:
        return HintTeamType.none;
    }
  }

  static const _overUnderMarkets = {
    MarketCategory.overUnder,
    MarketCategory.cornerOverUnder,
    MarketCategory.bookingsOverUnder,
    MarketCategory.homeOverUnder,
    MarketCategory.awayOverUnder,
  };

  bool get isOver =>
      team == HintTeamType.home && _overUnderMarkets.contains(market);

  bool get isUnder =>
      team == HintTeamType.away && _overUnderMarkets.contains(market);

  bool get isOdd =>
      team == HintTeamType.home && market == MarketCategory.oddEven;

  bool get isEven =>
      team == HintTeamType.away && market == MarketCategory.oddEven;

  String get selectionName {
    if (isOver) return 'Tài';
    if (isUnder) return 'Xỉu';
    if (isOdd) return 'Lẻ';
    if (isEven) return 'Chẵn';
    if (team == HintTeamType.draw) return 'Hòa';
    return teamName;
  }
}
