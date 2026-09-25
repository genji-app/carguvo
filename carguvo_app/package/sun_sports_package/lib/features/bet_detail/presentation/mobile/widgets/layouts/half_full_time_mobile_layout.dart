import 'package:flutter/material.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/features/bet_detail/domain/helpers/market_layout_helper.dart';
import 'package:sun_sports/features/sport/presentation/mobile/widgets/bet_card_mobile.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';
import 'package:sun_sports/shared/widgets/bet_details/models/betting_popup_data.dart';

class HalfFullTimeMobileLayout extends StatelessWidget {
  final LeagueMarketData market;
  final OddsStyle oddsStyle;

  final String homeTeamName;

  final String awayTeamName;

  final LeagueEventData? eventData;

  final LeagueData? leagueData;

  const HalfFullTimeMobileLayout({
    super.key,
    required this.market,
    required this.oddsStyle,
    required this.homeTeamName,
    required this.awayTeamName,
    this.eventData,
    this.leagueData,
  });

  @override
  Widget build(BuildContext context) {
    final odds = market.odds;
    if (odds.isEmpty) return const SizedBox.shrink();

    final sortedOdds = List<LeagueOddsData>.from(odds)
      ..sort(
        (a, b) => MarketLayoutHelper.htFtSortKey(a.points)
            .compareTo(MarketLayoutHelper.htFtSortKey(b.points)),
      );

    return Padding(
      padding: const EdgeInsets.all(10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = (constraints.maxWidth - 8) / 3;
          const itemHeight = 36.0;

          return Wrap(
            spacing: 4,
            runSpacing: 4,
            children: sortedOdds.map((odd) {
              return SizedBox(
                width: itemWidth,
                height: itemHeight,
                child: _buildOddsCard(odd),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildOddsCard(LeagueOddsData odds) {
    final oddsValue =
        _hasValidOdds(odds.oddsHome) ? odds.oddsHome : odds.oddsAway;
    final selectionId = odds.selectionHomeId ?? odds.selectionAwayId ?? '';
    final oddsType =
        _hasValidOdds(odds.oddsHome) ? OddsType.home : OddsType.away;

    if (!_hasValidOdds(oddsValue)) {
      return const SizedBox(height: 36);
    }

    BettingPopupData? bettingData;
    if (eventData != null) {
      bettingData = BettingPopupData(
        oddsData: odds,
        marketData: market,
        eventData: eventData!,
        oddsType: oddsType,
        leagueData: leagueData,
        oddsStyle: oddsStyle,
      );
    }

    return BetCardMobile(
      label: MarketLayoutHelper.htFtLabel(
        odds.points,
        homeName: homeTeamName,
        awayName: awayTeamName,
      ),
      value: MarketLayoutHelper.getOddsValue(
        oddsValue,
        market.marketId,
        oddsStyle,
      ),
      selectionId: selectionId,
      bettingPopupData: bettingData,
    );
  }

  bool _hasValidOdds(OddsValue oddsValue) =>
      oddsValue.decimal > 0 || oddsValue.malay != -100;
}
