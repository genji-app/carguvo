import 'package:flutter/material.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/bet_detail/domain/helpers/market_layout_helper.dart';
import 'package:sun_sports/features/sport/presentation/mobile/widgets/bet_card_mobile.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';
import 'package:sun_sports/shared/widgets/bet_details/models/betting_popup_data.dart';

class CleanSheetMobileLayout extends StatelessWidget {
  final List<LeagueMarketData> markets;
  final OddsStyle oddsStyle;

  final LeagueEventData? eventData;

  final LeagueData? leagueData;

  final String homeTeamName;

  final String awayTeamName;

  const CleanSheetMobileLayout({
    super.key,
    required this.markets,
    required this.oddsStyle,
    required this.homeTeamName,
    required this.awayTeamName,
    this.eventData,
    this.leagueData,
  });

  @override
  Widget build(BuildContext context) {
    if (markets.isEmpty) return const SizedBox.shrink();

    final homeMarket = markets
        .where((m) => m.marketId == 83 || m.marketId == 1001)
        .firstOrNull;
    final awayMarket = markets
        .where((m) => m.marketId == 84 || m.marketId == 1002)
        .firstOrNull;

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          _buildHeaderRow(),
          const SizedBox(height: 6),
          _buildOddsRow('Có', homeMarket, awayMarket, isYes: true),
          const SizedBox(height: 4),
          _buildOddsRow('Không', homeMarket, awayMarket, isYes: false),
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      children: [
        Expanded(
          child: Text(
            homeTeamName,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.textStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFAAA49B),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            awayTeamName,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.textStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFAAA49B),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOddsRow(
    String label,
    LeagueMarketData? homeMarket,
    LeagueMarketData? awayMarket, {
    required bool isYes,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildCell(label: label, market: homeMarket, isYes: isYes),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _buildCell(label: label, market: awayMarket, isYes: isYes),
        ),
      ],
    );
  }

  Widget _buildCell({
    required String label,
    LeagueMarketData? market,
    required bool isYes,
  }) {
    if (market == null || market.odds.isEmpty) {
      return const SizedBox(height: 36);
    }

    final odds = market.odds.first;
    final oddsValue = isYes ? odds.oddsHome : odds.oddsAway;
    final selectionId = isYes ? odds.selectionHomeId : odds.selectionAwayId;
    final oddsType = isYes ? OddsType.home : OddsType.away;

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
