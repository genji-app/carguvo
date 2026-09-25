import 'package:flutter/material.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/features/bet_detail/domain/helpers/market_layout_helper.dart';
import 'package:sun_sports/features/sport/presentation/mobile/widgets/bet_card_mobile.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';
import 'package:sun_sports/shared/widgets/bet_details/models/betting_popup_data.dart';

class ComboMobileLayout extends StatelessWidget {
  final LeagueMarketData market;
  final OddsStyle oddsStyle;

  final String homeTeamName;

  final String awayTeamName;

  final LeagueEventData? eventData;

  final LeagueData? leagueData;

  const ComboMobileLayout({
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
    final labeled = <(LeagueOddsData, String)>[];
    for (final odds in market.odds) {
      final label = MarketLayoutHelper.comboCellLabel(
        market.marketId,
        odds.points,
        homeName: homeTeamName,
        awayName: awayTeamName,
      );
      if (label != null) labeled.add((odds, label));
    }
    if (labeled.isEmpty) return const SizedBox.shrink();

    labeled.sort(
      (a, b) => MarketLayoutHelper.comboSortKey(a.$1.points)
          .compareTo(MarketLayoutHelper.comboSortKey(b.$1.points)),
    );

    final rows = <Widget>[];
    for (var i = 0; i < labeled.length; i += 2) {
      final left = labeled[i];
      final right = i + 1 < labeled.length ? labeled[i + 1] : null;
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildCell(left.$1, left.$2)),
              const SizedBox(width: 6),
              Expanded(
                child: right != null
                    ? _buildCell(right.$1, right.$2)
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(children: rows),
    );
  }

  Widget _buildCell(LeagueOddsData odds, String label) {
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
