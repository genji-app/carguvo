import 'package:flutter/material.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/features/bet_detail/domain/models/market_drawer_data_v2.dart';
import 'package:sun_sports/features/bet_detail/presentation/mobile/widgets/layouts/layouts.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';

class MarketDrawerV2MobileWidget extends StatelessWidget {
  final MarketDrawerDataV2 drawer;
  final OddsStyle oddsStyle;
  final VoidCallback onToggle;

  final LeagueEventData? eventData;

  final LeagueData? leagueData;

  const MarketDrawerV2MobileWidget({
    super.key,
    required this.drawer,
    required this.oddsStyle,
    required this.onToggle,
    this.eventData,
    this.leagueData,
  });

  String get homeTeamName => eventData?.homeName ?? 'Nhà';

  String get awayTeamName => eventData?.awayName ?? 'Khách';

  List<String> _resolveTeamLabels(List<String> labels) => [
        for (final label in labels)
          label == 'Đội nhà'
              ? homeTeamName
              : label == 'Đội khách'
                  ? awayTeamName
                  : label,
      ];

  @override
  Widget build(BuildContext context) {
    return ExpandableMarketCard(
      title: MarketHelper.resolveTeamNamesInMarketName(
        drawer.name,
        homeName: eventData?.homeName,
        awayName: eventData?.awayName,
      ),
      isExpanded: drawer.isExpanded,
      onToggle: onToggle,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (drawer.isEmpty) {
      return const SizedBox.shrink();
    }

    switch (drawer.layoutType) {
      case MarketLayoutTypeV2.handicap:
        return _buildHandicapLayout();

      case MarketLayoutTypeV2.overUnder:
      case MarketLayoutTypeV2.teamOverUnder:
        return _buildOverUnderLayout();

      case MarketLayoutTypeV2.oneXTwo:
        return _buildOneXTwoLayout();

      case MarketLayoutTypeV2.oddEven:
        return _buildOddEvenLayout();

      case MarketLayoutTypeV2.doubleChance:
        return _buildDoubleChanceLayout();

      case MarketLayoutTypeV2.drawNoBet:
        return _buildDrawNoBetLayout();

      case MarketLayoutTypeV2.cleanSheet:
        return _buildCleanSheetLayout();

      case MarketLayoutTypeV2.teamWinner:
        return _buildTeamWinnerLayout();

      case MarketLayoutTypeV2.nextLastGoal:
        return _buildNextLastGoalLayout();

      case MarketLayoutTypeV2.whichTeamToScore:
        return _buildWhichTeamToScoreLayout();

      case MarketLayoutTypeV2.correctScore:
        return _buildCorrectScoreLayout();

      case MarketLayoutTypeV2.totalScore:
        return _buildTotalScoreLayout();

      case MarketLayoutTypeV2.playerGoalscorer:
        return _buildPlayerGoalscorerLayout();

      case MarketLayoutTypeV2.halfTimeFullTime:
        return _buildHalfTimeFullTimeLayout();

      case MarketLayoutTypeV2.overExactlyUnder:
        return _buildOverExactlyUnderLayout();

      case MarketLayoutTypeV2.europeanHandicap:
        return _buildEuropeanHandicapLayout();

      case MarketLayoutTypeV2.combo:
        return _buildComboLayout();
    }
  }

  Widget _buildComboLayout() {
    final market = drawer.market;
    if (market == null) return const SizedBox.shrink();

    return ComboMobileLayout(
      market: market,
      oddsStyle: oddsStyle,
      homeTeamName: homeTeamName,
      awayTeamName: awayTeamName,
      eventData: eventData,
      leagueData: leagueData,
    );
  }

  Widget _buildOverExactlyUnderLayout() {
    final market = drawer.market;
    if (market == null) return const SizedBox.shrink();

    return OverExactlyUnderMobileLayout(
      market: market,
      oddsStyle: oddsStyle,
      eventData: eventData,
      leagueData: leagueData,
    );
  }

  Widget _buildEuropeanHandicapLayout() {
    final market = drawer.market;
    if (market == null) return const SizedBox.shrink();

    return EuropeanHandicapMobileLayout(
      market: market,
      oddsStyle: oddsStyle,
      homeTeamName: homeTeamName,
      awayTeamName: awayTeamName,
      eventData: eventData,
      leagueData: leagueData,
    );
  }

  Widget _buildHalfTimeFullTimeLayout() {
    final market = drawer.market;
    if (market == null) return const SizedBox.shrink();

    return HalfFullTimeMobileLayout(
      market: market,
      oddsStyle: oddsStyle,
      homeTeamName: homeTeamName,
      awayTeamName: awayTeamName,
      eventData: eventData,
      leagueData: leagueData,
    );
  }

  Widget _buildPlayerGoalscorerLayout() {
    final market = drawer.market;
    if (market == null) return const SizedBox.shrink();

    return PlayerGoalscorerMobileLayout(
      market: market,
      oddsStyle: oddsStyle,
      eventData: eventData,
      leagueData: leagueData,
    );
  }

  Widget _buildHandicapLayout() {
    final market = drawer.market;
    if (market == null) return const SizedBox.shrink();

    return HandicapMobileLayout(
      market: market,
      oddsStyle: oddsStyle,
      homeTeamName: homeTeamName,
      awayTeamName: awayTeamName,
      eventData: eventData,
      leagueData: leagueData,
    );
  }

  Widget _buildOverUnderLayout() {
    final market = drawer.market;
    if (market == null) return const SizedBox.shrink();

    return OverUnderMobileLayout(
      market: market,
      oddsStyle: oddsStyle,
      eventData: eventData,
      leagueData: leagueData,
    );
  }

  Widget _buildOneXTwoLayout() {
    final market = drawer.market;
    if (market == null) return const SizedBox.shrink();

    return OneXTwoMobileLayout(
      market: market,
      oddsStyle: oddsStyle,
      eventData: eventData,
      leagueData: leagueData,
      homeTeamName: homeTeamName,
      awayTeamName: awayTeamName,
    );
  }

  Widget _buildOddEvenLayout() {
    final market = drawer.market;
    if (market == null) return const SizedBox.shrink();

    return OddEvenMobileLayout(
      market: market,
      oddsStyle: oddsStyle,
      eventData: eventData,
      leagueData: leagueData,
    );
  }

  Widget _buildDoubleChanceLayout() {
    final market = drawer.market;
    if (market == null) return const SizedBox.shrink();

    return DoubleChanceMobileLayout(
      market: market,
      oddsStyle: oddsStyle,
      eventData: eventData,
      leagueData: leagueData,
    );
  }

  Widget _buildDrawNoBetLayout() {
    final market = drawer.market;
    if (market == null) return const SizedBox.shrink();

    return DrawNoBetMobileLayout(
      market: market,
      oddsStyle: oddsStyle,
      homeTeamName: homeTeamName,
      awayTeamName: awayTeamName,
      eventData: eventData,
      leagueData: leagueData,
    );
  }

  Widget _buildCleanSheetLayout() {
    if (drawer.markets.isEmpty) return const SizedBox.shrink();

    return CleanSheetMobileLayout(
      markets: drawer.markets,
      oddsStyle: oddsStyle,
      homeTeamName: homeTeamName,
      awayTeamName: awayTeamName,
      eventData: eventData,
      leagueData: leagueData,
    );
  }

  Widget _buildTeamWinnerLayout() {
    final market = drawer.market;
    if (market == null) return const SizedBox.shrink();

    return Only2MobileLayout(
      markets: [market],
      oddsStyle: oddsStyle,
      customHeaders: drawer.cellLabels.length == 2
          ? _resolveTeamLabels(drawer.cellLabels)
          : [homeTeamName, awayTeamName],
      eventData: eventData,
      leagueData: leagueData,
    );
  }

  Widget _buildNextLastGoalLayout() {
    final market = drawer.market;
    if (market == null) return const SizedBox.shrink();

    return Only3MobileLayout(
      markets: [market],
      oddsStyle: oddsStyle,
      customHeaders: drawer.cellLabels.length == 3
          ? _resolveTeamLabels(drawer.cellLabels)
          : [homeTeamName, 'Không có', awayTeamName],
      eventData: eventData,
      leagueData: leagueData,
    );
  }

  Widget _buildWhichTeamToScoreLayout() {
    final market = drawer.market;
    if (market == null) return const SizedBox.shrink();

    return Only4MobileLayout(
      markets: [market],
      oddsStyle: oddsStyle,
      eventData: eventData,
      leagueData: leagueData,
    );
  }

  Widget _buildCorrectScoreLayout() {
    final market = drawer.market;
    if (market == null) return const SizedBox.shrink();

    return CorrectScoreMobileLayout(
      markets: [market],
      oddsStyle: oddsStyle,
      eventData: eventData,
      leagueData: leagueData,
    );
  }

  Widget _buildTotalScoreLayout() {
    final market = drawer.market;
    if (market == null) return const SizedBox.shrink();

    return TogetherMobileLayout(
      markets: [market],
      oddsStyle: oddsStyle,
      eventData: eventData,
      leagueData: leagueData,
    );
  }
}
