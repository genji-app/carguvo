import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/features/bet_detail/domain/enums/market_filter.dart';

class MarketDrawerData {
  final String name;

  final MarketFilter filter;

  final MarketPoolType poolType;

  final List<LeagueMarketData> markets;

  final bool isExpanded;

  const MarketDrawerData({
    required this.name,
    required this.filter,
    required this.poolType,
    required this.markets,
    this.isExpanded = true,
  });

  bool get hasValidMarkets => markets.any((m) => m.odds.isNotEmpty);

  bool get isEmpty => markets.isEmpty || !hasValidMarkets;

  int get totalOddsCount => markets.fold(0, (sum, m) => sum + m.odds.length);

  MarketDrawerData copyWith({
    String? name,
    MarketFilter? filter,
    MarketPoolType? poolType,
    List<LeagueMarketData>? markets,
    bool? isExpanded,
  }) {
    return MarketDrawerData(
      name: name ?? this.name,
      filter: filter ?? this.filter,
      poolType: poolType ?? this.poolType,
      markets: markets ?? this.markets,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}

enum MarketPoolType {
  main,

  main6,

  together,

  together4,

  correctScore,

  correctScore6,

  only2,

  only2x2,

  only3,

  only3x2,

  only4,

  market2,
}

class MarketDrawerBuilder {
  MarketDrawerBuilder._();

  static List<MarketDrawerData> buildDrawers(
    List<LeagueMarketData> markets, {
    bool isDesktop = true,
  }) {
    final drawers = <MarketDrawerData>[];

    final mainFT = _findMarkets(markets, [5, 3, 1]);
    final mainHT = _findMarkets(markets, [6, 4, 2]);
    if (mainFT.isNotEmpty || mainHT.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Trận đấu',
          filter: MarketFilter.match,
          poolType: MarketPoolType.main6,
          markets: [...mainFT, ...mainHT],
        ),
      );
    }

    final oddEven = _findMarkets(markets, [8, 9]);
    if (oddEven.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Lẻ/Chẵn',
          filter: MarketFilter.match,
          poolType: oddEven.length >= 2
              ? MarketPoolType.only2x2
              : MarketPoolType.only2,
          markets: oddEven,
        ),
      );
    }

    final doubleChance = _findMarkets(markets, [12, 13]);
    if (doubleChance.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Cơ hội kép',
          filter: MarketFilter.match,
          poolType: doubleChance.length >= 2
              ? MarketPoolType.only3x2
              : MarketPoolType.only3,
          markets: doubleChance,
        ),
      );
    }

    final drawNoBet = _findMarkets(markets, [16, 75]);
    if (drawNoBet.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Hòa hoàn tiền',
          filter: MarketFilter.match,
          poolType: drawNoBet.length >= 2
              ? MarketPoolType.only2x2
              : MarketPoolType.only2,
          markets: drawNoBet,
        ),
      );
    }

    final secondHalf = _findMarkets(markets, [85, 80, 89]);
    if (secondHalf.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Hiệp 2',
          filter: MarketFilter.match,
          poolType: MarketPoolType.main,
          markets: secondHalf,
        ),
      );
    }

    final extraTimeFT = _findMarkets(markets, [27, 25, 23]);
    final extraTimeHT = _findMarkets(markets, [28, 26, 24]);
    if (extraTimeFT.isNotEmpty || extraTimeHT.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Hiệp phụ',
          filter: MarketFilter.match,
          poolType: MarketPoolType.main6,
          markets: [...extraTimeFT, ...extraTimeHT],
        ),
      );
    }

    _addTimeRangeDrawers(markets, drawers);

    final nextGoal = _findMarkets(markets, [7]);
    if (nextGoal.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Bàn tiếp theo',
          filter: MarketFilter.match,
          poolType: MarketPoolType.only3,
          markets: nextGoal,
        ),
      );
    }

    final lastGoal = _findMarkets(markets, [97]);
    if (lastGoal.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Bàn cuối cùng',
          filter: MarketFilter.match,
          poolType: MarketPoolType.only3,
          markets: lastGoal,
        ),
      );
    }

    final whichTeamToScore = _findMarkets(markets, [103]);
    if (whichTeamToScore.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Đội ghi bàn',
          filter: MarketFilter.match,
          poolType: MarketPoolType.only4,
          markets: whichTeamToScore,
        ),
      );
    }

    final toQualify = _findMarkets(markets, [58]);
    if (toQualify.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Đội vào vòng trong',
          filter: MarketFilter.match,
          poolType: MarketPoolType.only2,
          markets: toQualify,
        ),
      );
    }

    final whichTeamKickOff = _findMarkets(markets, [59]);
    if (whichTeamKickOff.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Đội giao bóng trước',
          filter: MarketFilter.match,
          poolType: MarketPoolType.only2,
          markets: whichTeamKickOff,
        ),
      );
    }

    final homeOU = _findMarkets(markets, [101]);
    if (homeOU.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Tài/Xỉu Đội nhà',
          filter: MarketFilter.match,
          poolType: MarketPoolType.market2,
          markets: homeOU,
        ),
      );
    }

    final awayOU = _findMarkets(markets, [102]);
    if (awayOU.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Tài/Xỉu Đội khách',
          filter: MarketFilter.match,
          poolType: MarketPoolType.market2,
          markets: awayOU,
        ),
      );
    }

    final homeAwayOddEven = _findMarkets(markets, [76, 77]);
    if (homeAwayOddEven.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Lẻ/Chẵn theo đội',
          filter: MarketFilter.match,
          poolType: MarketPoolType.only2x2,
          markets: homeAwayOddEven,
        ),
      );
    }

    final penaltyShootoutWinner = _findMarkets(markets, [129]);
    if (penaltyShootoutWinner.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Đội thắng Penalty',
          filter: MarketFilter.match,
          poolType: MarketPoolType.only2,
          markets: penaltyShootoutWinner,
        ),
      );
    }

    final penaltyShootoutTotal = _findMarkets(markets, [130]);
    if (penaltyShootoutTotal.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Tài/Xỉu Penalty',
          filter: MarketFilter.match,
          poolType: MarketPoolType.market2,
          markets: penaltyShootoutTotal,
        ),
      );
    }

    final cleanSheet = _findMarkets(markets, [83, 84]);
    if (cleanSheet.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Giữ sạch lưới',
          filter: MarketFilter.match,
          poolType: MarketPoolType.only2x2,
          markets: cleanSheet,
        ),
      );
    }

    final correctScoreFT = _findMarkets(markets, [10]);
    final correctScoreHT = _findMarkets(markets, [11]);

    if (isDesktop) {
      if (correctScoreFT.isNotEmpty || correctScoreHT.isNotEmpty) {
        drawers.add(
          MarketDrawerData(
            name: 'Tỷ số chính xác',
            filter: MarketFilter.score,
            poolType: MarketPoolType.correctScore6,
            markets: [...correctScoreFT, ...correctScoreHT],
          ),
        );
      }
    } else {
      if (correctScoreFT.isNotEmpty) {
        drawers.add(
          MarketDrawerData(
            name: 'Tỷ số chính xác',
            filter: MarketFilter.score,
            poolType: MarketPoolType.correctScore,
            markets: correctScoreFT,
          ),
        );
      }
      if (correctScoreHT.isNotEmpty) {
        drawers.add(
          MarketDrawerData(
            name: 'Tỷ số chính xác H1',
            filter: MarketFilter.score,
            poolType: MarketPoolType.correctScore,
            markets: correctScoreHT,
          ),
        );
      }
    }

    final totalScore = _findMarkets(markets, [14, 15]);
    if (totalScore.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Tổng bàn thắng',
          filter: MarketFilter.score,
          poolType: MarketPoolType.together,
          markets: totalScore,
        ),
      );
    }

    final totalGoalsExactly = _findMarkets(markets, [145]);
    if (totalGoalsExactly.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Tổng bàn thắng chính xác',
          filter: MarketFilter.score,
          poolType: MarketPoolType.together,
          markets: totalGoalsExactly,
        ),
      );
    }

    final cornerFT = _findMarkets(markets, [19, 21, 17]);
    final cornerHT = _findMarkets(markets, [20, 22, 18]);
    if (cornerFT.isNotEmpty || cornerHT.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Phạt góc',
          filter: MarketFilter.corner,
          poolType: MarketPoolType.main6,
          markets: [...cornerFT, ...cornerHT],
        ),
      );
    }

    final cornerOddEven = _findMarkets(markets, [56, 57]);
    if (cornerOddEven.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Phạt góc Lẻ/Chẵn',
          filter: MarketFilter.corner,
          poolType: cornerOddEven.length >= 2
              ? MarketPoolType.only2x2
              : MarketPoolType.only2,
          markets: cornerOddEven,
        ),
      );
    }

    final lastCorner = _findMarkets(markets, [66, 67]);
    if (lastCorner.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Phạt góc cuối cùng',
          filter: MarketFilter.corner,
          poolType: lastCorner.length >= 2
              ? MarketPoolType.only2x2
              : MarketPoolType.only2,
          markets: lastCorner,
        ),
      );
    }

    final cornerOUByTeam = _findMarkets(markets, [61, 63, 62, 64]);
    if (cornerOUByTeam.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Phạt góc Tài/Xỉu theo đội',
          filter: MarketFilter.corner,
          poolType: cornerOUByTeam.length >= 4
              ? MarketPoolType.together4
              : MarketPoolType.together,
          markets: cornerOUByTeam,
        ),
      );
    }

    final cornerRange = _findMarkets(markets, [131, 136, 134, 135]);
    if (cornerRange.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Phạt góc khoảng',
          filter: MarketFilter.corner,
          poolType: cornerRange.length >= 4
              ? MarketPoolType.together4
              : MarketPoolType.together,
          markets: cornerRange,
        ),
      );
    }

    final nextCorner = _findMarkets(markets, [137]);
    if (nextCorner.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Phạt góc tiếp theo',
          filter: MarketFilter.corner,
          poolType: MarketPoolType.only3,
          markets: nextCorner,
        ),
      );
    }

    _addCornerTimeRangeDrawers(markets, drawers);

    final extraTimeCornerOU = _findMarkets(markets, [142]);
    if (extraTimeCornerOU.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Phạt góc hiệp phụ Tài/Xỉu',
          filter: MarketFilter.corner,
          poolType: MarketPoolType.market2,
          markets: extraTimeCornerOU,
        ),
      );
    }

    final europeanHandicapCorner = _findMarkets(markets, [144]);
    if (europeanHandicapCorner.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Chấp phạt góc châu Âu',
          filter: MarketFilter.corner,
          poolType: MarketPoolType.market2,
          markets: europeanHandicapCorner,
        ),
      );
    }

    final bookingFT = _findMarkets(markets, [
      33,
      31,
      29,
    ]);
    final bookingHT = _findMarkets(markets, [
      34,
      32,
      30,
    ]);
    if (bookingFT.isNotEmpty || bookingHT.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Thẻ phạt',
          filter: MarketFilter.booking,
          poolType: MarketPoolType.main6,
          markets: [...bookingFT, ...bookingHT],
        ),
      );
    }

    final yellowCards1X2 = _findMarkets(markets, [138]);
    if (yellowCards1X2.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Thẻ vàng 1X2',
          filter: MarketFilter.booking,
          poolType: MarketPoolType.only3,
          markets: yellowCards1X2,
        ),
      );
    }

    final yellowCardsOU = _findMarkets(markets, [139]);
    if (yellowCardsOU.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Thẻ vàng Tài/Xỉu',
          filter: MarketFilter.booking,
          poolType: MarketPoolType.market2,
          markets: yellowCardsOU,
        ),
      );
    }

    final yellowCardsDC = _findMarkets(markets, [143]);
    if (yellowCardsDC.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Thẻ vàng cơ hội kép',
          filter: MarketFilter.booking,
          poolType: MarketPoolType.only3,
          markets: yellowCardsDC,
        ),
      );
    }

    return drawers;
  }

  static void _addTimeRangeDrawers(
    List<LeagueMarketData> markets,
    List<MarketDrawerData> drawers,
  ) {
    const timeRanges = [
      {
        'name': '0-15 phút',
        'ids': [44, 38, 50],
      },
      {
        'name': '15-30 phút',
        'ids': [45, 39, 51],
      },
      {
        'name': '30-45 phút',
        'ids': [46, 40, 52],
      },
      {
        'name': '45-60 phút',
        'ids': [47, 41, 53],
      },
      {
        'name': '60-75 phút',
        'ids': [48, 42, 54],
      },
      {
        'name': '75-90 phút',
        'ids': [49, 43, 55],
      },
    ];

    for (final range in timeRanges) {
      final rangeMarkets = _findMarkets(markets, (range['ids'] as List<int>));
      if (rangeMarkets.isNotEmpty) {
        drawers.add(
          MarketDrawerData(
            name: range['name'] as String,
            filter: MarketFilter.match,
            poolType: MarketPoolType.main,
            markets: rangeMarkets,
          ),
        );
      }
    }
  }

  static void _addCornerTimeRangeDrawers(
    List<LeagueMarketData> markets,
    List<MarketDrawerData> drawers,
  ) {
    const corner15min = [
      {
        'name': 'Phạt góc 0-15\'',
        'ids': [92],
      },
      {
        'name': 'Phạt góc 15-30\'',
        'ids': [93],
      },
      {
        'name': 'Phạt góc 30-45\'',
        'ids': [94],
      },
      {
        'name': 'Phạt góc 45-60\'',
        'ids': [95],
      },
      {
        'name': 'Phạt góc 60-75\'',
        'ids': [96],
      },
    ];

    const corner10min = [
      {
        'name': 'Phạt góc 0-10\'',
        'ids': [104],
      },
      {
        'name': 'Phạt góc 10-20\'',
        'ids': [105],
      },
      {
        'name': 'Phạt góc 20-30\'',
        'ids': [106],
      },
      {
        'name': 'Phạt góc 30-40\'',
        'ids': [107],
      },
      {
        'name': 'Phạt góc 40-50\'',
        'ids': [108],
      },
      {
        'name': 'Phạt góc 50-60\'',
        'ids': [109],
      },
      {
        'name': 'Phạt góc 60-70\'',
        'ids': [110],
      },
      {
        'name': 'Phạt góc 70-80\'',
        'ids': [111],
      },
    ];

    const corner5min = [
      {
        'name': 'Phạt góc 0-5\'',
        'ids': [112],
      },
      {
        'name': 'Phạt góc 5-10\'',
        'ids': [113],
      },
      {
        'name': 'Phạt góc 10-15\'',
        'ids': [114],
      },
      {
        'name': 'Phạt góc 15-20\'',
        'ids': [115],
      },
      {
        'name': 'Phạt góc 20-25\'',
        'ids': [116],
      },
      {
        'name': 'Phạt góc 25-30\'',
        'ids': [117],
      },
      {
        'name': 'Phạt góc 30-35\'',
        'ids': [118],
      },
      {
        'name': 'Phạt góc 35-40\'',
        'ids': [119],
      },
      {
        'name': 'Phạt góc 40-45\'',
        'ids': [120],
      },
      {
        'name': 'Phạt góc 45-50\'',
        'ids': [121],
      },
      {
        'name': 'Phạt góc 50-55\'',
        'ids': [122],
      },
      {
        'name': 'Phạt góc 55-60\'',
        'ids': [123],
      },
      {
        'name': 'Phạt góc 60-65\'',
        'ids': [124],
      },
      {
        'name': 'Phạt góc 65-70\'',
        'ids': [125],
      },
      {
        'name': 'Phạt góc 70-75\'',
        'ids': [126],
      },
      {
        'name': 'Phạt góc 75-80\'',
        'ids': [127],
      },
      {
        'name': 'Phạt góc 80-85\'',
        'ids': [128],
      },
    ];

    for (final range in corner15min) {
      final rangeMarkets = _findMarkets(markets, (range['ids'] as List<int>));
      if (rangeMarkets.isNotEmpty) {
        drawers.add(
          MarketDrawerData(
            name: range['name'] as String,
            filter: MarketFilter.corner,
            poolType: MarketPoolType.market2,
            markets: rangeMarkets,
          ),
        );
      }
    }

    for (final range in corner10min) {
      final rangeMarkets = _findMarkets(markets, (range['ids'] as List<int>));
      if (rangeMarkets.isNotEmpty) {
        drawers.add(
          MarketDrawerData(
            name: range['name'] as String,
            filter: MarketFilter.corner,
            poolType: MarketPoolType.market2,
            markets: rangeMarkets,
          ),
        );
      }
    }

    for (final range in corner5min) {
      final rangeMarkets = _findMarkets(markets, (range['ids'] as List<int>));
      if (rangeMarkets.isNotEmpty) {
        drawers.add(
          MarketDrawerData(
            name: range['name'] as String,
            filter: MarketFilter.corner,
            poolType: MarketPoolType.market2,
            markets: rangeMarkets,
          ),
        );
      }
    }
  }

  static List<LeagueMarketData> _findMarkets(
    List<LeagueMarketData> markets,
    List<int> marketIds,
  ) {
    final result = <LeagueMarketData>[];
    for (final id in marketIds) {
      final market = markets.where((m) => m.marketId == id).firstOrNull;
      if (market != null && market.odds.isNotEmpty) {
        result.add(market);
      }
    }
    return result;
  }
}
