enum MarketFilter {
  main,

  fullTime,

  firstHalf,

  secondHalf,

  extraTime,

  corner,

  score,

  booking,

  player,

  set1,

  set2,

  set3,

  set4,

  set5,

  keoRung5,

  keoRung10,

  keoRung15,

  match,

  all,
}

extension MarketFilterExtension on MarketFilter {
  String get displayName {
    switch (this) {
      case MarketFilter.main:
        return 'Chính';
      case MarketFilter.fullTime:
        return 'Toàn trận';
      case MarketFilter.firstHalf:
        return 'Hiệp 1';
      case MarketFilter.secondHalf:
        return 'Hiệp 2';
      case MarketFilter.extraTime:
        return 'Hiệp phụ';
      case MarketFilter.corner:
        return 'Phạt góc';
      case MarketFilter.score:
        return 'Tỷ số';
      case MarketFilter.booking:
        return 'Thẻ phạt';
      case MarketFilter.player:
        return 'Cầu thủ';
      case MarketFilter.set1:
        return 'Set 1';
      case MarketFilter.set2:
        return 'Set 2';
      case MarketFilter.set3:
        return 'Set 3';
      case MarketFilter.set4:
        return 'Set 4';
      case MarketFilter.set5:
        return 'Set 5';
      case MarketFilter.keoRung5:
        return 'Kèo rung 5 phút';
      case MarketFilter.keoRung10:
        return 'Kèo rung 10 phút';
      case MarketFilter.keoRung15:
        return 'Kèo rung 15 phút';
      case MarketFilter.all:
        return 'Tất cả';
      case MarketFilter.match:
        return 'Trận đấu';
    }
  }

  bool get isMainFilter => this == MarketFilter.main;

  bool get isPeriodFilter =>
      this == MarketFilter.fullTime ||
      this == MarketFilter.firstHalf ||
      this == MarketFilter.secondHalf ||
      this == MarketFilter.extraTime ||
      this == MarketFilter.set1 ||
      this == MarketFilter.set2 ||
      this == MarketFilter.set3 ||
      this == MarketFilter.set4 ||
      this == MarketFilter.set5;

  bool get isCategoryFilter =>
      this == MarketFilter.corner ||
      this == MarketFilter.score ||
      this == MarketFilter.booking;

  bool containsMarketId(int marketId) {
    if (this == MarketFilter.all) return true;
    return MarketFilterMapping.getMarketIds(this).contains(marketId);
  }
}

class MarketFilterMapping {
  MarketFilterMapping._();

  static const Set<int> matchMarketIds = {
    1,
    3,
    5,
    2,
    4,
    6,
    23, 25, 27,
    35, 36, 37, 38, 39, 40,
    8, 9,
    50, 51,
    12, 13,
    16, 17,
    7,
    58,
    59,
    60,
    80, 81,
    83, 84,
    85, 86,
    41, 42, 43, 44, 45, 46, 47, 48, 49, 52, 53, 54, 55,
  };

  static const Set<int> cornerMarketIds = {
    17,
    19,
    21,
    18,
    20,
    22,
    56,
    57,
    61,
    62,
    63,
    64,
    66,
    67,
    92,
    93,
    94,
    95,
    96,
    104,
    105,
    106,
    107,
    108,
    109,
    110,
    111,
    112, 113, 114, 115, 116, 117, 118, 119, 120, 121,
    122, 123, 124, 125, 126, 127, 128,
    131,
    134,
    135,
    136,
    145, 197, 198, 199, 1005,
    137,
    140,
    141,
    142,
    144,
  };

  static const Set<int> scoreMarketIds = {
    10,
    11,
    14,
    15,
    145,
  };

  static const Set<int> bookingMarketIds = {
    29,
    30,
    31,
    32,
    33,
    34,
    138,
    139,
    143,
  };

  static const Set<int> playerMarketIds = {153, 155, 156, 158, 1026, 1027};

  static const Set<int> mainMarketIds = {
    1, 3, 5,
    2, 4, 6,
    80, 85, 89,
    23, 24, 25, 26, 27, 28,
    1008, 1009, 1010, 1013,
  };

  static const Set<int> fullTimeMarketIds = {
    1, 3, 5,
    8,
    12,
    16,
    7, 97,
    58, 59,
    76, 77,
    83, 84,
    101, 102,
    103,
    129, 130,
    145,
  };

  static const Set<int> firstHalfMarketIds = {
    2, 4, 6,
    9,
    13,
    75,
  };

  static const Set<int> secondHalfMarketIds = {
    80, 85, 89,
    86,
  };

  static const Set<int> extraTimeMarketIds = {
    23, 24, 25, 26, 27, 28,
  };

  static Set<int> getMarketIds(MarketFilter filter) {
    switch (filter) {
      case MarketFilter.main:
        return mainMarketIds;
      case MarketFilter.fullTime:
        return fullTimeMarketIds;
      case MarketFilter.firstHalf:
        return firstHalfMarketIds;
      case MarketFilter.secondHalf:
        return secondHalfMarketIds;
      case MarketFilter.extraTime:
        return extraTimeMarketIds;
      case MarketFilter.corner:
        return cornerMarketIds;
      case MarketFilter.score:
        return scoreMarketIds;
      case MarketFilter.booking:
        return bookingMarketIds;
      case MarketFilter.player:
        return playerMarketIds;
      case MarketFilter.set1:
      case MarketFilter.set2:
      case MarketFilter.set3:
      case MarketFilter.set4:
      case MarketFilter.set5:
      case MarketFilter.keoRung5:
      case MarketFilter.keoRung10:
      case MarketFilter.keoRung15:
        return const {};
      case MarketFilter.all:
        return {
          ...matchMarketIds,
          ...cornerMarketIds,
          ...scoreMarketIds,
          ...bookingMarketIds,
        };
      case MarketFilter.match:
        return matchMarketIds;
    }
  }

  static MarketFilter getFilterForMarketId(int marketId) {
    if (matchMarketIds.contains(marketId)) return MarketFilter.match;
    if (cornerMarketIds.contains(marketId)) return MarketFilter.corner;
    if (scoreMarketIds.contains(marketId)) return MarketFilter.score;
    if (bookingMarketIds.contains(marketId)) return MarketFilter.booking;
    return MarketFilter.match;
  }
}
