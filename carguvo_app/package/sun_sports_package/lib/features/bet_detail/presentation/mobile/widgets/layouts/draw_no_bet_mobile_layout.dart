import 'package:flutter/material.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/features/bet_detail/domain/helpers/market_layout_helper.dart';
import 'package:sun_sports/features/sport/presentation/mobile/widgets/bet_card_mobile.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';
import 'package:sun_sports/shared/widgets/bet_details/models/betting_popup_data.dart';

class DrawNoBetMobileLayout extends StatelessWidget {
  final LeagueMarketData market;
  final OddsStyle oddsStyle;

  final LeagueEventData? eventData;

  final LeagueData? leagueData;

  final String homeTeamName;

  final String awayTeamName;

  const DrawNoBetMobileLayout({
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
    if (market.odds.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(10),
      child: _buildOddsRow(market.odds.first),
    );
  }

  Widget _buildOddsRow(LeagueOddsData odds) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: _buildCell(
          label: homeTeamName,
          oddsValue: odds.oddsHome,
          odds: odds,
          oddsType: OddsType.home,
          selectionId: odds.selectionHomeId,
        ),
      ),
      const SizedBox(width: 6),
      Expanded(
        child: _buildCell(
          label: awayTeamName,
          oddsValue: odds.oddsAway,
          odds: odds,
          oddsType: OddsType.away,
          selectionId: odds.selectionAwayId,
        ),
      ),
    ],
  );

  Widget _buildCell({
    required String label,
    required OddsValue oddsValue,
    required LeagueOddsData odds,
    required OddsType oddsType,
    String? selectionId,
  }) {
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
      label: label,
      value: MarketLayoutHelper.getOddsValue(
        oddsValue,
        market.marketId,
        oddsStyle,
      ),
      selectionId: selectionId ?? '',
      bettingPopupData: bettingData,
    );
  }

  bool _hasValidOdds(OddsValue oddsValue) =>
      oddsValue.decimal > 0 || oddsValue.malay != -100;
}
