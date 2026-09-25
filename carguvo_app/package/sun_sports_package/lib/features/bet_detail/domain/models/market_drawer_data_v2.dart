import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/features/bet_detail/domain/enums/market_filter.dart';
import 'package:sun_sports/features/bet_detail/domain/helpers/market_layout_helper.dart';

class MarketDrawerDataV2 {
  final String name;

  final MarketFilter filter;

  final MarketLayoutTypeV2 layoutType;

  final LeagueMarketData? market;

  final List<LeagueMarketData> markets;

  final bool isExpanded;

  final int marketId;

  final List<String> cellLabels;

  const MarketDrawerDataV2({
    required this.name,
    required this.filter,
    required this.layoutType,
    this.market,
    this.markets = const [],
    this.isExpanded = true,
    this.marketId = 0,
    this.cellLabels = const [],
  });

  bool get hasValidMarkets {
    if (market != null && market!.odds.isNotEmpty) return true;
    return markets.any((m) => m.odds.isNotEmpty);
  }

  bool get isEmpty => !hasValidMarkets;

  MarketDrawerDataV2 copyWith({
    String? name,
    MarketFilter? filter,
    MarketLayoutTypeV2? layoutType,
    LeagueMarketData? market,
    List<LeagueMarketData>? markets,
    bool? isExpanded,
    int? marketId,
    List<String>? cellLabels,
  }) {
    return MarketDrawerDataV2(
      name: name ?? this.name,
      filter: filter ?? this.filter,
      layoutType: layoutType ?? this.layoutType,
      market: market ?? this.market,
      markets: markets ?? this.markets,
      isExpanded: isExpanded ?? this.isExpanded,
      marketId: marketId ?? this.marketId,
      cellLabels: cellLabels ?? this.cellLabels,
    );
  }
}

enum MarketLayoutTypeV2 {
  handicap,

  overUnder,

  oneXTwo,

  oddEven,

  doubleChance,

  drawNoBet,

  cleanSheet,

  teamOverUnder,

  teamWinner,

  nextLastGoal,

  whichTeamToScore,

  correctScore,

  totalScore,

  playerGoalscorer,

  halfTimeFullTime,

  overExactlyUnder,

  europeanHandicap,

  combo,
}

class MarketDrawerV2Builder {
  MarketDrawerV2Builder._();

  static List<MarketDrawerDataV2> buildDrawers(
    List<LeagueMarketData> markets, {
    int sportId = 1,
    int currentSet = 1,
    int currentMinute = 0,
  }) {
    switch (sportId) {
      case 2:
        return _buildBasketballDrawers(markets);
      case 3:
        return _buildCombatDrawers(markets);
      case 4:
        return _buildTennisDrawers(markets);
      case 5:
        return _buildVolleyballDrawers(markets);
      case 6:
        return _buildTableTennisDrawers(markets);
      case 7:
        return _buildBadmintonDrawers(markets, currentSet: currentSet);
    }

    final drawers = <MarketDrawerDataV2>[];

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 5,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.handicap,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 3,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.overUnder,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 1,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.oneXTwo,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 8,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.oddEven,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 12,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.doubleChance,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 16,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.drawNoBet,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 101,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.teamOverUnder,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 102,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.teamOverUnder,
    );

    final homeCleanSheet = _findMarket(markets, 83);
    final awayCleanSheet = _findMarket(markets, 84);
    if (homeCleanSheet != null || awayCleanSheet != null) {
      drawers.add(
        MarketDrawerDataV2(
          name: 'Toàn trận - Giữ sạch lưới',
          filter: MarketFilter.fullTime,
          layoutType: MarketLayoutTypeV2.cleanSheet,
          markets: [
            if (homeCleanSheet != null) homeCleanSheet,
            if (awayCleanSheet != null) awayCleanSheet,
          ],
        ),
      );
    }

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 7,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.nextLastGoal,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 97,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.nextLastGoal,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 103,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.whichTeamToScore,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 58,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.teamWinner,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 59,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.teamWinner,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 129,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.teamWinner,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 130,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.teamOverUnder,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 1006,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.correctScore,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 1009,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.teamOverUnder,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 1010,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.teamOverUnder,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 1008,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.teamWinner,
      cellLabels: const ['Có', 'Không'],
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 1013,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.oddEven,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 1015,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.oddEven,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 1016,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.oddEven,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 1007,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.totalScore,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 1017,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.correctScore,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 76,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.oddEven,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 77,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.oddEven,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 36,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.teamWinner,
      cellLabels: const ['Có', 'Không'],
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 60,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.teamWinner,
      cellLabels: const ['Có', 'Không'],
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 148,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.teamWinner,
      cellLabels: const ['Có', 'Không'],
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 149,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.teamWinner,
      cellLabels: const ['Có', 'Không'],
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 154,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.teamWinner,
      cellLabels: const ['Có', 'Không'],
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 150,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.teamWinner,
      cellLabels: const ['Hòa', 'Đội khách'],
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 151,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.teamWinner,
      cellLabels: const ['Đội nhà', 'Hòa'],
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 146,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.nextLastGoal,
      cellLabels: const ['Đội nhà', 'Không có bàn thắng', 'Đội khách'],
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 65,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.nextLastGoal,
      cellLabels: const ['Hiệp 1', 'Hòa', 'Hiệp 2'],
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 68,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.halfTimeFullTime,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 147,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.oneXTwo,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 152,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.europeanHandicap,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 78,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.teamWinner,
      cellLabels: const ['Có', 'Không'],
    );
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 79,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.teamWinner,
      cellLabels: const ['Có', 'Không'],
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 87,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.nextLastGoal,
      cellLabels: const ['Hiệp 1', 'Hòa', 'Hiệp 2'],
    );
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 88,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.nextLastGoal,
      cellLabels: const ['Hiệp 1', 'Hòa', 'Hiệp 2'],
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 157,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.drawNoBet,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 1018,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.teamWinner,
      cellLabels: const ['Có', 'Không'],
    );

    for (final id in const [98, 81, 82]) {
      final comboMarket = _findMarket(markets, id);
      if (comboMarket == null ||
          !MarketLayoutHelper.comboHasDecodableCell(id, comboMarket.odds)) {
        continue;
      }
      _addSingleMarketDrawer(
        drawers: drawers,
        markets: markets,
        marketId: id,
        filter: MarketFilter.fullTime,
        layoutType: MarketLayoutTypeV2.combo,
      );
    }

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 99,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.teamWinner,
      cellLabels: const ['Có', 'Không'],
    );
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 100,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.teamWinner,
      cellLabels: const ['Có', 'Không'],
    );

    for (final id in const [69, 70, 71, 72, 73, 74]) {
      _addSingleMarketDrawer(
        drawers: drawers,
        markets: markets,
        marketId: id,
        filter: MarketFilter.fullTime,
        layoutType: MarketLayoutTypeV2.teamWinner,
        cellLabels: const ['Có', 'Không'],
      );
    }

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 6,
      filter: MarketFilter.firstHalf,
      layoutType: MarketLayoutTypeV2.handicap,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 4,
      filter: MarketFilter.firstHalf,
      layoutType: MarketLayoutTypeV2.overUnder,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 2,
      filter: MarketFilter.firstHalf,
      layoutType: MarketLayoutTypeV2.oneXTwo,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 9,
      filter: MarketFilter.firstHalf,
      layoutType: MarketLayoutTypeV2.oddEven,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 13,
      filter: MarketFilter.firstHalf,
      layoutType: MarketLayoutTypeV2.doubleChance,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 75,
      filter: MarketFilter.firstHalf,
      layoutType: MarketLayoutTypeV2.drawNoBet,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 37,
      filter: MarketFilter.firstHalf,
      layoutType: MarketLayoutTypeV2.teamWinner,
      cellLabels: const ['Có', 'Không'],
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 194,
      filter: MarketFilter.firstHalf,
      layoutType: MarketLayoutTypeV2.teamOverUnder,
    );
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 193,
      filter: MarketFilter.firstHalf,
      layoutType: MarketLayoutTypeV2.teamOverUnder,
    );

    final homeCleanSheetH1 = _findMarket(markets, 1001);
    final awayCleanSheetH1 = _findMarket(markets, 1002);
    if (homeCleanSheetH1 != null || awayCleanSheetH1 != null) {
      drawers.add(
        MarketDrawerDataV2(
          name: 'Hiệp 1 - Giữ sạch lưới',
          filter: MarketFilter.firstHalf,
          layoutType: MarketLayoutTypeV2.cleanSheet,
          markets: [
            if (homeCleanSheetH1 != null) homeCleanSheetH1,
            if (awayCleanSheetH1 != null) awayCleanSheetH1,
          ],
        ),
      );
    }

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 1003,
      filter: MarketFilter.firstHalf,
      layoutType: MarketLayoutTypeV2.oneXTwo,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 1004,
      filter: MarketFilter.firstHalf,
      layoutType: MarketLayoutTypeV2.nextLastGoal,
      cellLabels: const ['Đội nhà', 'Không có bàn thắng', 'Đội khách'],
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 195,
      filter: MarketFilter.firstHalf,
      layoutType: MarketLayoutTypeV2.europeanHandicap,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 85,
      filter: MarketFilter.secondHalf,
      layoutType: MarketLayoutTypeV2.handicap,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 80,
      filter: MarketFilter.secondHalf,
      layoutType: MarketLayoutTypeV2.overUnder,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 89,
      filter: MarketFilter.secondHalf,
      layoutType: MarketLayoutTypeV2.oneXTwo,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 86,
      filter: MarketFilter.secondHalf,
      layoutType: MarketLayoutTypeV2.oddEven,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 10,
      filter: MarketFilter.score,
      layoutType: MarketLayoutTypeV2.correctScore,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 11,
      filter: MarketFilter.score,
      layoutType: MarketLayoutTypeV2.correctScore,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 14,
      filter: MarketFilter.score,
      layoutType: MarketLayoutTypeV2.totalScore,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 15,
      filter: MarketFilter.score,
      layoutType: MarketLayoutTypeV2.totalScore,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 132,
      filter: MarketFilter.score,
      layoutType: MarketLayoutTypeV2.totalScore,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 133,
      filter: MarketFilter.score,
      layoutType: MarketLayoutTypeV2.totalScore,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 19,
      filter: MarketFilter.corner,
      layoutType: MarketLayoutTypeV2.handicap,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 21,
      filter: MarketFilter.corner,
      layoutType: MarketLayoutTypeV2.overUnder,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 17,
      filter: MarketFilter.corner,
      layoutType: MarketLayoutTypeV2.oneXTwo,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 20,
      filter: MarketFilter.corner,
      layoutType: MarketLayoutTypeV2.handicap,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 22,
      filter: MarketFilter.corner,
      layoutType: MarketLayoutTypeV2.overUnder,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 18,
      filter: MarketFilter.corner,
      layoutType: MarketLayoutTypeV2.oneXTwo,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 56,
      filter: MarketFilter.corner,
      layoutType: MarketLayoutTypeV2.oddEven,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 57,
      filter: MarketFilter.corner,
      layoutType: MarketLayoutTypeV2.oddEven,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 66,
      filter: MarketFilter.corner,
      layoutType: MarketLayoutTypeV2.teamWinner,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 67,
      filter: MarketFilter.corner,
      layoutType: MarketLayoutTypeV2.teamWinner,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 61,
      filter: MarketFilter.corner,
      layoutType: MarketLayoutTypeV2.teamOverUnder,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 62,
      filter: MarketFilter.corner,
      layoutType: MarketLayoutTypeV2.teamOverUnder,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 63,
      filter: MarketFilter.corner,
      layoutType: MarketLayoutTypeV2.teamOverUnder,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 64,
      filter: MarketFilter.corner,
      layoutType: MarketLayoutTypeV2.teamOverUnder,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 131,
      filter: MarketFilter.corner,
      layoutType: MarketLayoutTypeV2.totalScore,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 136,
      filter: MarketFilter.corner,
      layoutType: MarketLayoutTypeV2.totalScore,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 134,
      filter: MarketFilter.corner,
      layoutType: MarketLayoutTypeV2.totalScore,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 135,
      filter: MarketFilter.corner,
      layoutType: MarketLayoutTypeV2.totalScore,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 90,
      filter: MarketFilter.corner,
      layoutType: MarketLayoutTypeV2.nextLastGoal,
      cellLabels: const ['Đội nhà', 'Không bên nào', 'Đội khách'],
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 91,
      filter: MarketFilter.corner,
      layoutType: MarketLayoutTypeV2.nextLastGoal,
      cellLabels: const ['Đội nhà', 'Không bên nào', 'Đội khách'],
    );

    _addCornerTimeRangeDrawers(markets, drawers);

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 145,
      filter: MarketFilter.corner,
      layoutType: MarketLayoutTypeV2.overExactlyUnder,
    );
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 140,
      filter: MarketFilter.corner,
      layoutType: MarketLayoutTypeV2.overExactlyUnder,
    );
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 141,
      filter: MarketFilter.corner,
      layoutType: MarketLayoutTypeV2.overExactlyUnder,
    );
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 142,
      filter: MarketFilter.corner,
      layoutType: MarketLayoutTypeV2.overUnder,
    );
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 144,
      filter: MarketFilter.corner,
      layoutType: MarketLayoutTypeV2.europeanHandicap,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 1005,
      filter: MarketFilter.corner,
      layoutType: MarketLayoutTypeV2.nextLastGoal,
      cellLabels: const ['Đội nhà', 'Không có phạt góc', 'Đội khách'],
    );
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 199,
      filter: MarketFilter.corner,
      layoutType: MarketLayoutTypeV2.nextLastGoal,
      cellLabels: const ['Đội nhà', 'Không có phạt góc', 'Đội khách'],
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 198,
      filter: MarketFilter.corner,
      layoutType: MarketLayoutTypeV2.totalScore,
    );
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 197,
      filter: MarketFilter.corner,
      layoutType: MarketLayoutTypeV2.totalScore,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 33,
      filter: MarketFilter.booking,
      layoutType: MarketLayoutTypeV2.handicap,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 31,
      filter: MarketFilter.booking,
      layoutType: MarketLayoutTypeV2.overUnder,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 29,
      filter: MarketFilter.booking,
      layoutType: MarketLayoutTypeV2.oneXTwo,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 34,
      filter: MarketFilter.booking,
      layoutType: MarketLayoutTypeV2.handicap,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 32,
      filter: MarketFilter.booking,
      layoutType: MarketLayoutTypeV2.overUnder,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 30,
      filter: MarketFilter.booking,
      layoutType: MarketLayoutTypeV2.oneXTwo,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 138,
      filter: MarketFilter.booking,
      layoutType: MarketLayoutTypeV2.oneXTwo,
    );
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 139,
      filter: MarketFilter.booking,
      layoutType: MarketLayoutTypeV2.overUnder,
    );
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 143,
      filter: MarketFilter.booking,
      layoutType: MarketLayoutTypeV2.doubleChance,
    );

    for (final id in const [153, 155, 156, 158, 1026, 1027]) {
      _addSingleMarketDrawer(
        drawers: drawers,
        markets: markets,
        marketId: id,
        filter: MarketFilter.player,
        layoutType: MarketLayoutTypeV2.playerGoalscorer,
      );
    }

    _addTimeRangeDrawers(markets, drawers);

    _addExtraTimeDrawers(markets, drawers);

    _addKeoRungDrawers(markets, drawers, currentMinute: currentMinute);

    return drawers;
  }

  static void _addKeoRungDrawers(
    List<LeagueMarketData> markets,
    List<MarketDrawerDataV2> drawers, {
    int currentMinute = 0,
  }) {
    const nextLabels = ['Đội nhà', 'Không có bàn thắng', 'Đội khách'];
    const nextCornerLabels = ['Đội nhà', 'Không có phạt góc', 'Đội khách'];

    String windowLabel(int size, LeagueMarketData? market) {
      var period = 0;
      if (market != null && market.odds.isNotEmpty) {
        period = market.odds.first.period;
      }
      final start = period > 0
          ? period * size
          : (currentMinute > 0 ? (currentMinute ~/ size + 1) * size : -1);
      if (start < 0) return '';
      final end = start + size - 1;
      String pad(int v) => v.toString().padLeft(2, '0');
      return ' (${pad(start)}:00 - ${pad(end)}:59)';
    }

    void addBucket(
      MarketFilter filter,
      int windowSize,
      List<(int, String, MarketLayoutTypeV2, List<String>)> items,
    ) {
      for (final (id, name, layout, labels) in items) {
        final suffix = windowLabel(windowSize, _findMarket(markets, id));
        _addSingleMarketDrawer(
          drawers: drawers,
          markets: markets,
          marketId: id,
          name: '$name$suffix',
          filter: filter,
          layoutType: layout,
          cellLabels: labels,
        );
      }
    }

    const ou = MarketLayoutTypeV2.overUnder;
    const x12 = MarketLayoutTypeV2.oneXTwo;
    const hdp = MarketLayoutTypeV2.handicap;
    const oe = MarketLayoutTypeV2.oddEven;
    const teamOu = MarketLayoutTypeV2.teamOverUnder;
    const next = MarketLayoutTypeV2.nextLastGoal;

    addBucket(MarketFilter.keoRung5, 5, [
      (172, 'Tài/Xỉu', ou, const []),
      (167, '1X2', x12, const []),
      (176, 'Phạt góc kèo chấp', hdp, const []),
      (171, 'Phạt góc Tài/Xỉu', ou, const []),
      (174, 'Phạt góc 1X2', x12, const []),
      (164, 'Phạt góc Lẻ/Chẵn', oe, const []),
      (177, 'Phạt góc tiếp theo', next, nextCornerLabels),
      (165, 'Đội nhà phạt góc Tài/Xỉu', teamOu, const []),
      (166, 'Đội khách phạt góc Tài/Xỉu', teamOu, const []),
      (173, 'Thẻ Tài/Xỉu', ou, const []),
      (175, 'Thẻ 1X2', x12, const []),
      (178, 'Đội tiếp theo ghi bàn', next, nextLabels),
    ]);

    addBucket(MarketFilter.keoRung10, 10, [
      (162, 'Tài/Xỉu', ou, const []),
      (168, '1X2', x12, const []),
      (180, 'Phạt góc kèo chấp', hdp, const []),
      (161, 'Phạt góc Tài/Xỉu', ou, const []),
      (163, 'Phạt góc 1X2', x12, const []),
      (179, 'Phạt góc Lẻ/Chẵn', oe, const []),
      (190, 'Phạt góc tiếp theo', next, nextCornerLabels),
      (169, 'Đội nhà phạt góc Tài/Xỉu', teamOu, const []),
      (170, 'Đội khách phạt góc Tài/Xỉu', teamOu, const []),
      (160, 'Thẻ Tài/Xỉu', ou, const []),
      (159, 'Thẻ 1X2', x12, const []),
      (191, 'Đội tiếp theo ghi bàn', next, nextLabels),
    ]);

    addBucket(MarketFilter.keoRung15, 15, [
      (182, 'Tài/Xỉu', ou, const []),
      (181, '1X2', x12, const []),
      (186, 'Kèo chấp', hdp, const []),
    ]);
  }

  static void _addSingleMarketDrawer({
    required List<MarketDrawerDataV2> drawers,
    required List<LeagueMarketData> markets,
    required int marketId,
    required MarketFilter filter,
    required MarketLayoutTypeV2 layoutType,
    String? name,
    List<String> cellLabels = const [],
  }) {
    final market = _findMarket(markets, marketId);
    if (market != null && market.odds.isNotEmpty) {
      drawers.add(
        MarketDrawerDataV2(
          name: name ?? MarketHelper.getMarketNameViDisplay(marketId),
          filter: filter,
          layoutType: layoutType,
          market: market,
          marketId: marketId,
          cellLabels: cellLabels,
        ),
      );
    }
  }

  static void _addTimeRangeDrawers(
    List<LeagueMarketData> markets,
    List<MarketDrawerDataV2> drawers,
  ) {
    const timeRanges = [
      {'name': '00:00 - 14:59', 'hdp': 44, 'ou': 38, '1x2': 50},
      {'name': '15:00 - 29:59', 'hdp': 45, 'ou': 39, '1x2': 51},
      {'name': '30:00 - 44:59', 'hdp': 46, 'ou': 40, '1x2': 52},
      {'name': '45:00 - 59:59', 'hdp': 47, 'ou': 41, '1x2': 53},
      {'name': '60:00 - 74:59', 'hdp': 48, 'ou': 42, '1x2': 54},
      {'name': '75:00 - 90:00', 'hdp': 49, 'ou': 43, '1x2': 55},
    ];

    for (final range in timeRanges) {
      final rangeName = range['name'] as String;

      _addSingleMarketDrawer(
        drawers: drawers,
        markets: markets,
        marketId: range['hdp'] as int,
        name: 'Kèo chấp $rangeName',
        filter: MarketFilter.fullTime,
        layoutType: MarketLayoutTypeV2.handicap,
      );

      _addSingleMarketDrawer(
        drawers: drawers,
        markets: markets,
        marketId: range['ou'] as int,
        name: 'Tài/Xỉu $rangeName',
        filter: MarketFilter.fullTime,
        layoutType: MarketLayoutTypeV2.overUnder,
      );

      _addSingleMarketDrawer(
        drawers: drawers,
        markets: markets,
        marketId: range['1x2'] as int,
        name: '1X2 $rangeName',
        filter: MarketFilter.fullTime,
        layoutType: MarketLayoutTypeV2.oneXTwo,
      );
    }
  }

  static void _addExtraTimeDrawers(
    List<LeagueMarketData> markets,
    List<MarketDrawerDataV2> drawers,
  ) {
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 27,
      filter: MarketFilter.extraTime,
      layoutType: MarketLayoutTypeV2.handicap,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 25,
      filter: MarketFilter.extraTime,
      layoutType: MarketLayoutTypeV2.overUnder,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 23,
      filter: MarketFilter.extraTime,
      layoutType: MarketLayoutTypeV2.oneXTwo,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 28,
      filter: MarketFilter.extraTime,
      layoutType: MarketLayoutTypeV2.handicap,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 26,
      filter: MarketFilter.extraTime,
      layoutType: MarketLayoutTypeV2.overUnder,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 24,
      filter: MarketFilter.extraTime,
      layoutType: MarketLayoutTypeV2.oneXTwo,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 1012,
      filter: MarketFilter.extraTime,
      layoutType: MarketLayoutTypeV2.correctScore,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 1011,
      filter: MarketFilter.extraTime,
      layoutType: MarketLayoutTypeV2.nextLastGoal,
      cellLabels: const ['Đội nhà', 'Không có bàn thắng', 'Đội khách'],
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 1019,
      filter: MarketFilter.extraTime,
      layoutType: MarketLayoutTypeV2.oneXTwo,
    );
  }

  static void _addCornerTimeRangeDrawers(
    List<LeagueMarketData> markets,
    List<MarketDrawerDataV2> drawers,
  ) {
    const cornerTimeRanges = [
      {'name': 'Phạt góc 0-15 phút', 'id': 92},
      {'name': 'Phạt góc 15-30 phút', 'id': 93},
      {'name': 'Phạt góc 30-45 phút', 'id': 94},
      {'name': 'Phạt góc 45-60 phút', 'id': 95},
      {'name': 'Phạt góc 60-75 phút', 'id': 96},
    ];

    for (final range in cornerTimeRanges) {
      _addSingleMarketDrawer(
        drawers: drawers,
        markets: markets,
        marketId: range['id'] as int,
        name: range['name'] as String,
        filter: MarketFilter.corner,
        layoutType: MarketLayoutTypeV2.overUnder,
      );
    }
  }

  static List<MarketDrawerDataV2> _buildBasketballDrawers(
    List<LeagueMarketData> markets,
  ) {
    final drawers = <MarketDrawerDataV2>[];

    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 200,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.teamWinner);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 201,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.handicap);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 202,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.overUnder);

    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 203,
      filter: MarketFilter.firstHalf,
      layoutType: MarketLayoutTypeV2.handicap);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 204,
      filter: MarketFilter.firstHalf,
      layoutType: MarketLayoutTypeV2.overUnder);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 205,
      filter: MarketFilter.firstHalf,
      layoutType: MarketLayoutTypeV2.teamWinner);

    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 206,
      filter: MarketFilter.set1,
      layoutType: MarketLayoutTypeV2.teamWinner);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 210,
      filter: MarketFilter.set1,
      layoutType: MarketLayoutTypeV2.handicap);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 214,
      filter: MarketFilter.set1,
      layoutType: MarketLayoutTypeV2.overUnder);

    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 207,
      filter: MarketFilter.set2,
      layoutType: MarketLayoutTypeV2.teamWinner);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 211,
      filter: MarketFilter.set2,
      layoutType: MarketLayoutTypeV2.handicap);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 215,
      filter: MarketFilter.set2,
      layoutType: MarketLayoutTypeV2.overUnder);

    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 208,
      filter: MarketFilter.set3,
      layoutType: MarketLayoutTypeV2.teamWinner);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 212,
      filter: MarketFilter.set3,
      layoutType: MarketLayoutTypeV2.handicap);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 216,
      filter: MarketFilter.set3,
      layoutType: MarketLayoutTypeV2.overUnder);

    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 209,
      filter: MarketFilter.set4,
      layoutType: MarketLayoutTypeV2.teamWinner);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 213,
      filter: MarketFilter.set4,
      layoutType: MarketLayoutTypeV2.handicap);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 217,
      filter: MarketFilter.set4,
      layoutType: MarketLayoutTypeV2.overUnder);

    return drawers;
  }

  static List<MarketDrawerDataV2> _buildCombatDrawers(
    List<LeagueMarketData> markets,
  ) {
    final drawers = <MarketDrawerDataV2>[];

    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 300,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.teamWinner);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 301,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.overUnder);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 308,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.handicap);

    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 304,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.teamWinner);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 305,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.overUnder);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 310,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.handicap);

    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 306,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.teamWinner);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 307,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.overUnder);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 309,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.handicap);

    return drawers;
  }

  static List<MarketDrawerDataV2> _buildTennisDrawers(
    List<LeagueMarketData> markets,
  ) {
    final drawers = <MarketDrawerDataV2>[];

    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 400,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.teamWinner);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 401,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.overUnder);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 402,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.handicap);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 403,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.teamWinner);

    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 404,
      filter: MarketFilter.set1,
      layoutType: MarketLayoutTypeV2.teamWinner);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 405,
      filter: MarketFilter.set2,
      layoutType: MarketLayoutTypeV2.teamWinner);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 406,
      filter: MarketFilter.set3,
      layoutType: MarketLayoutTypeV2.teamWinner);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 407,
      filter: MarketFilter.set4,
      layoutType: MarketLayoutTypeV2.teamWinner);

    return drawers;
  }

  static List<MarketDrawerDataV2> _buildVolleyballDrawers(
    List<LeagueMarketData> markets,
  ) {
    final drawers = <MarketDrawerDataV2>[];

    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 500,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.teamWinner);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 509,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.handicap);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 510,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.overUnder);

    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 504,
      filter: MarketFilter.set1,
      layoutType: MarketLayoutTypeV2.teamWinner);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 505,
      filter: MarketFilter.set2,
      layoutType: MarketLayoutTypeV2.teamWinner);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 506,
      filter: MarketFilter.set3,
      layoutType: MarketLayoutTypeV2.teamWinner);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 507,
      filter: MarketFilter.set4,
      layoutType: MarketLayoutTypeV2.teamWinner);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 508,
      filter: MarketFilter.set5,
      layoutType: MarketLayoutTypeV2.teamWinner);

    return drawers;
  }

  static List<MarketDrawerDataV2> _buildTableTennisDrawers(
    List<LeagueMarketData> markets,
  ) {
    final drawers = <MarketDrawerDataV2>[];

    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 600,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.teamWinner);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 609,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.handicap);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 610,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.overUnder);

    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 602,
      filter: MarketFilter.set1,
      layoutType: MarketLayoutTypeV2.teamWinner);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 603,
      filter: MarketFilter.set2,
      layoutType: MarketLayoutTypeV2.teamWinner);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 604,
      filter: MarketFilter.set3,
      layoutType: MarketLayoutTypeV2.teamWinner);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 605,
      filter: MarketFilter.set4,
      layoutType: MarketLayoutTypeV2.teamWinner);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 606,
      filter: MarketFilter.set5,
      layoutType: MarketLayoutTypeV2.teamWinner);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 607,
      filter: MarketFilter.set5,
      layoutType: MarketLayoutTypeV2.teamWinner);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 608,
      filter: MarketFilter.set5,
      layoutType: MarketLayoutTypeV2.teamWinner);

    return drawers;
  }

  static List<MarketDrawerDataV2> _buildBadmintonDrawers(
    List<LeagueMarketData> markets, {
    int currentSet = 1,
  }) {
    final drawers = <MarketDrawerDataV2>[];
    final currentGame = 'Game $currentSet';
    final nextGame = 'Game ${currentSet + 1}';

    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 700,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.teamWinner);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 709,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.handicap);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 710,
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.overUnder);

    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 705,
      name: '$currentGame - Đội thắng', filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.teamWinner);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 701,
      name: '$currentGame - Tài xỉu', filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.overUnder);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 702,
      name: '$currentGame - Kèo chấp', filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.handicap);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 711,
      name: '$currentGame - Kèo chấp Point', filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.handicap);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 712,
      name: '$currentGame - Tài xỉu Point', filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.overUnder);

    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 704,
      name: '$nextGame - Đội thắng', filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.teamWinner);

    return drawers;
  }

  static LeagueMarketData? _findMarket(
    List<LeagueMarketData> markets,
    int marketId,
  ) {
    return markets.where((m) => m.marketId == marketId).firstOrNull;
  }
}
