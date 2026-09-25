import 'package:flutter/material.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/features/bet_detail/domain/helpers/market_layout_helper.dart';
import 'package:sun_sports/features/sport/presentation/mobile/widgets/bet_card_mobile.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';
import 'package:sun_sports/shared/widgets/bet_details/models/betting_popup_data.dart';

class PlayerGoalscorerMobileLayout extends StatelessWidget {
  final LeagueMarketData market;
  final OddsStyle oddsStyle;

  final LeagueEventData? eventData;

  final LeagueData? leagueData;

  const PlayerGoalscorerMobileLayout({
    super.key,
    required this.market,
    required this.oddsStyle,
    this.eventData,
    this.leagueData,
  });

  @override
  Widget build(BuildContext context) {
    final odds = market.odds;
    if (odds.isEmpty) return const SizedBox.shrink();

    final rows = <Widget>[];
    for (var i = 0; i < odds.length; i += 2) {
      final left = odds[i];
      final right = (i + 1 < odds.length) ? odds[i + 1] : null;

      rows.add(
        Padding(
          padding: EdgeInsets.only(bottom: i + 2 < odds.length ? 6 : 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildCell(left)),
              const SizedBox(width: 6),
              Expanded(
                child: right != null
                    ? _buildCell(right)
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: rows,
      ),
    );
  }

  Widget _buildCell(LeagueOddsData odds) {
    if (!_hasValidOdds(odds.oddsHome)) {
      return const SizedBox(height: 36);
    }

    BettingPopupData? bettingData;
    if (eventData != null) {
      bettingData = BettingPopupData(
        oddsData: odds,
        marketData: market,
        eventData: eventData!,
        oddsType: OddsType.home,
        leagueData: leagueData,
        oddsStyle: oddsStyle,
      );
    }

    return BetCardMobile(
      label: odds.playerName,
      value: MarketLayoutHelper.getOddsValue(
        odds.oddsHome,
        market.marketId,
        oddsStyle,
      ),
      selectionId: odds.selectionHomeId ?? '',
      bettingPopupData: bettingData,
    );
  }

  bool _hasValidOdds(OddsValue oddsValue) =>
      oddsValue.decimal > 0 ||
      oddsValue.malay != -100 ||
      oddsValue.indo != -100 ||
      oddsValue.hongKong != -100;
}
