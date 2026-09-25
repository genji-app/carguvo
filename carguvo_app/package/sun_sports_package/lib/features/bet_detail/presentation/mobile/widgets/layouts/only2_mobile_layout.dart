import 'package:flutter/material.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/features/bet_detail/domain/helpers/market_layout_helper.dart';
import 'package:sun_sports/features/sport/presentation/mobile/widgets/bet_card_mobile.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';
import 'package:sun_sports/shared/widgets/bet_details/models/betting_popup_data.dart';

class Only2MobileLayout extends StatelessWidget {
  final List<LeagueMarketData> markets;
  final OddsStyle oddsStyle;
  final List<String>? customHeaders;

  final LeagueEventData? eventData;

  final LeagueData? leagueData;

  const Only2MobileLayout({
    super.key,
    required this.markets,
    required this.oddsStyle,
    this.customHeaders,
    this.eventData,
    this.leagueData,
  });

  @override
  Widget build(BuildContext context) {
    if (markets.isEmpty) return const SizedBox.shrink();

    final headers = customHeaders ?? _getDefaultHeaders();

    return Padding(
      padding: const EdgeInsets.all(10),
      child: _buildContent(headers),
    );
  }

  List<String> _getDefaultHeaders() {
    final firstMarketId = markets.isNotEmpty ? markets.first.marketId : 0;

    if ([8, 9, 56, 57, 76, 77, 86].contains(firstMarketId)) {
      return ['Lẻ', 'Chẵn'];
    }

    if ([83, 84].contains(firstMarketId)) {
      return ['Có', 'Không'];
    }

    return ['Nhà', 'Khách'];
  }

  Widget _buildContent(List<String> headers) {
    final market = markets.first;
    if (market.odds.isEmpty) {
      return const Row(
        children: [
          Expanded(child: SizedBox(height: 36)),
          SizedBox(width: 6),
          Expanded(child: SizedBox(height: 36)),
        ],
      );
    }

    final odds = market.odds.first;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildCell(
            headers.isNotEmpty ? headers[0] : '',
            odds.oddsHome,
            odds.selectionHomeId,
            market,
            odds,
            OddsType.home,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _buildCell(
            headers.length > 1 ? headers[1] : '',
            odds.oddsAway,
            odds.selectionAwayId,
            market,
            odds,
            OddsType.away,
          ),
        ),
      ],
    );
  }

  Widget _buildCell(
    String label,
    OddsValue oddsValue,
    String? selectionId,
    LeagueMarketData market,
    LeagueOddsData odds,
    OddsType oddsType,
  ) {
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
