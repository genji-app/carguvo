import 'package:flutter/material.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/features/bet_detail/domain/helpers/market_layout_helper.dart';
import 'package:sun_sports/features/sport/presentation/mobile/widgets/bet_card_mobile.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';
import 'package:sun_sports/shared/widgets/bet_details/models/betting_popup_data.dart';

class Only3MobileLayout extends StatelessWidget {
  final List<LeagueMarketData> markets;
  final OddsStyle oddsStyle;
  final List<String>? customHeaders;

  final LeagueEventData? eventData;

  final LeagueData? leagueData;

  const Only3MobileLayout({
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

    if ([12, 13].contains(firstMarketId)) {
      return ['1X', 'X2', '12'];
    }

    if ([7, 97].contains(firstMarketId)) {
      return ['Nhà', 'Không có', 'Khách'];
    }

    return ['Nhà', 'Hoà', 'Khách'];
  }

  Widget _buildContent(List<String> headers) {
    final market = markets.first;
    if (market.odds.isEmpty) {
      return const Row(
        children: [
          Expanded(child: SizedBox(height: 36)),
          SizedBox(width: 6),
          Expanded(child: SizedBox(height: 36)),
          SizedBox(width: 6),
          Expanded(child: SizedBox(height: 36)),
        ],
      );
    }

    if (market.odds.length > 1) {
      return Column(
        children: [
          for (final odds in market.odds)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: _buildLineRow(headers, market, odds),
            ),
        ],
      );
    }

    return _buildLineRow(headers, market, market.odds.first);
  }

  Widget _buildLineRow(
    List<String> headers,
    LeagueMarketData market,
    LeagueOddsData odds,
  ) {
    final multiLine = market.odds.length > 1;
    String cellLabel(int i) {
      final base = headers.length > i ? headers[i] : '';
      if (!multiLine) return base;
      final line = PointsFormatter.format(odds.points);
      return line.isEmpty ? base : '$base ($line)';
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildCell(
            cellLabel(0),
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
            cellLabel(1),
            odds.oddsDraw,
            odds.selectionDrawId,
            market,
            odds,
            OddsType.draw,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _buildCell(
            cellLabel(2),
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
