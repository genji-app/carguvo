library;

import 'league_enums.dart';

class MarketOddsRules {
  MarketOddsRules._();

  static bool is1X2(int id) =>
      [1, 2, 17, 18, 23, 24, 29, 30, 50, 51, 52, 53, 54, 55, 89].contains(id);

  static const Set<int> oddEvenMarketIds = {
    8, 9, 56, 57, 76, 77, 86, 164, 179, 1013, 1015, 1016,
  };

  static bool isOddEven(int id) => oddEvenMarketIds.contains(id);

  static bool isCorrectScore(int id) => [10, 11, 1006, 1012].contains(id);

  static const Set<int> doubleChanceMarketIds = {12, 13, 143};

  static bool isDoubleChance(int id) => doubleChanceMarketIds.contains(id);

  static bool isTotalScore(int id) => [14, 15, 1007].contains(id);

  static bool isDrawNoBet(int id) => [16, 75, 157].contains(id);

  static bool isCornerRange(int id) => [131, 134, 135, 136].contains(id);

  static bool isSecondHalf(int id) => [80, 85, 86, 89].contains(id);

  static const Set<int> handicapMarketIds = {
    5, 6,
    85,
    27, 28,
    19, 20,
    33, 34,
    44, 45, 46, 47, 48, 49,
    144,
    176, 180, 186,
    201, 203, 210, 211, 212, 213,
    308, 309, 310,
    402,
    509,
    609,
    702, 709, 711,
  };

  static bool isHandicap(int id) => handicapMarketIds.contains(id);

  static const Set<int> overUnderMarketIds = {
    3, 4, 80,
    25, 26,
    21, 22,
    31, 32,
    38, 39, 40, 41, 42, 43,
    101, 102,
    193, 194,
    1009, 1010,
    61, 62, 63, 64,
    92, 93, 94, 95, 96,
    104, 105, 106, 107, 108, 109, 110, 111,
    112, 113, 114, 115, 116, 117, 118, 119, 120, 121,
    122, 123, 124, 125, 126, 127, 128,
    130,
    139,
    142,
    160, 161, 162, 165, 166, 169, 170, 171, 172, 173, 182,
    202, 204, 214, 215, 216, 217,
    301, 305, 307,
    401,
    510,
    610,
    701, 710, 712,
  };

  static bool isOverUnder(int id) => overUnderMarketIds.contains(id);

  static bool isWinningMargin(int id) => id == 1017;

  static bool isExactGoals(int id) => [132, 133, 197, 198].contains(id);

  static const Set<int> playerMarketIds = {153, 155, 156, 158, 1026, 1027};

  static bool isPlayerMarket(int id) => playerMarketIds.contains(id);

  static const Set<int> yesNoMarketIds = {
    36, 37, 60, 148, 149, 154,
    69, 70, 71, 72, 73, 74,
    83, 84,
    99, 100, 1008,
    1001, 1002,
    78, 79, 1018,
  };

  static bool isYesNo(int id) => yesNoMarketIds.contains(id);

  static const Set<int> europeanHandicapMarketIds = {144, 152, 195};

  static bool isEuropeanHandicap(int id) => europeanHandicapMarketIds.contains(id);

  static bool isHalfTimeFullTime(int id) => id == 68;

  static const Set<int> overExactlyUnderMarketIds = {140, 141, 145};

  static bool isOverExactlyUnder(int id) => overExactlyUnderMarketIds.contains(id);

  static bool isWhichTeamToScore(int id) => id == 103;

  static const Set<int> windowedNextNoneMarketIds = {177, 178, 190, 191, 199, 1005};

  static bool isWindowedNextNone(int id) => windowedNextNoneMarketIds.contains(id);

  static bool isAlwaysDecimal(int marketId) {
    return is1X2(marketId) ||
        isOddEven(marketId) ||
        isDrawNoBet(marketId) ||
        isCorrectScore(marketId) ||
        isDoubleChance(marketId) ||
        isTotalScore(marketId) ||
        isCornerRange(marketId) ||
        isSecondHalf(marketId) ||
        [
          7,
          97,
          1011, 1019,
          68, 147, 1003, 193, 194,
          1008, 1017,
          153, 155, 156, 158,
          58,
          59,
          61, 62, 63, 64,
          66, 67,
          104, 105, 106, 107, 108, 109, 110, 111,
          112, 113, 114, 115, 116, 117, 118, 119, 120,
          121, 122, 123, 124, 125, 126, 127, 128,
          129, 130,
          140, 141,
          145,
          143,
          138,
          144, 152, 195,
          199, 1005,
          1018,
          81, 82, 98,
          103,
          101, 102,
          35,
          200, 205, 206, 207, 208, 209,
          300, 304, 306,
          400, 404, 405, 406, 407,
          500, 504, 505, 506, 507, 508,
          600, 602, 603, 604, 605, 606, 607, 608,
          700, 705,
          167, 168, 181, 174, 163, 175, 159,
          178, 191, 177, 190,
          165, 166, 169, 170,
          164, 179,
        ].contains(marketId);
  }

  static OddsStyle getEffectiveOddsStyle(int marketId, OddsStyle userStyle) {
    if (isAlwaysDecimal(marketId)) {
      return OddsStyle.decimal;
    }
    return userStyle;
  }
}
