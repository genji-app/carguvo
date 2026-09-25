import 'package:flutter/material.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/features/bet_detail/domain/helpers/market_layout_helper.dart';
import 'package:sun_sports/features/sport/presentation/mobile/widgets/bet_card_mobile.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';
import 'package:sun_sports/shared/widgets/bet_details/models/betting_popup_data.dart';

class Only4MobileLayout extends StatelessWidget {
  final List<LeagueMarketData> markets;
  final OddsStyle oddsStyle;

  final LeagueEventData? eventData;

  final LeagueData? leagueData;

  const Only4MobileLayout({
    super.key,
    required this.markets,
    required this.oddsStyle,
    this.eventData,
    this.leagueData,
  });

  @override
  Widget build(BuildContext context) {
    if (markets.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          _buildRow(['Không có', 'Đội Nhà'], [0, 1]),
          const SizedBox(height: 6),
          _buildRow(['Đội Khách', 'Cả 2 Đội'], [2, 3]),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> headers, List<int> indices) {
    final market = markets.first;

    return Row(
      children: [
        for (var i = 0; i < indices.length; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: i == 0 ? 3 : 0,
                left: i == indices.length - 1 ? 3 : 0,
              ),
              child:
                  market.odds.isEmpty || indices[i] >= market.odds.length
                  ? const SizedBox(height: 36)
                  : _buildCell(
                      i < headers.length ? headers[i] : '',
                      market.odds[indices[i]],
                      market,
                    ),
            ),
          ),
      ],
    );
  }

  Widget _buildCell(String label, LeagueOddsData odds, LeagueMarketData market) {
    final oddsValue = _hasValidOdds(odds.oddsHome)
        ? odds.oddsHome
        : odds.oddsAway;
    final selectionId = odds.selectionHomeId ?? odds.selectionAwayId ?? '';
    final oddsType = _hasValidOdds(odds.oddsHome)
        ? OddsType.home
        : OddsType.away;

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
      selectionId: selectionId,
      bettingPopupData: bettingData,
    );
  }

  bool _hasValidOdds(OddsValue oddsValue) =>
      oddsValue.decimal > 0 || oddsValue.malay != -100;
}
