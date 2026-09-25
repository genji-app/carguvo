import 'package:flutter/material.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';
import 'package:sun_sports/shared/widgets/bet_details/models/betting_popup_data.dart';
import 'package:sun_sports/shared/widgets/cards/bet_card.dart';

class Only2Layout extends StatelessWidget {
  final List<LeagueMarketData> markets;
  final OddsStyle oddsStyle;
  final List<String>? customHeaders;

  final LeagueEventData? eventData;

  final LeagueData? leagueData;

  const Only2Layout({
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
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _buildHeaderRow(headers),
          const SizedBox(height: 8),
          _buildContent(),
        ],
      ),
    );
  }

  List<String> _getDefaultHeaders() {
    final firstMarketId = markets.isNotEmpty ? markets.first.marketId : 0;

    if ([8, 9].contains(firstMarketId)) {
      return ['Lẻ', 'Chẵn'];
    }

    if ([61, 64].contains(firstMarketId)) {
      return ['Nhà', 'Khách'];
    }

    return ['Nhà', 'Khách'];
  }

  Widget _buildHeaderRow(List<String> headers) => Row(
    children: headers.take(2).map((title) {
      return Expanded(
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: AppTextStyles.textStyle(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: const Color(0xFFAAA49B),
          ),
        ),
      );
    }).toList(),
  );

  Widget _buildContent() {
    final market = markets.first;
    if (market.odds.isEmpty) {
      return Row(
        children: [
          const Expanded(child: SizedBox(height: 36)),
          const SizedBox(width: 8),
          const Expanded(child: SizedBox(height: 36)),
        ],
      );
    }

    final odds = market.odds.first;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildCell(
            oddsValue: odds.oddsHome,
            selectionId: odds.selectionHomeId,
            market: market,
            odds: odds,
            oddsType: OddsType.home,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildCell(
            oddsValue: odds.oddsAway,
            selectionId: odds.selectionAwayId,
            market: market,
            odds: odds,
            oddsType: OddsType.away,
          ),
        ),
      ],
    );
  }

  Widget _buildCell({
    required OddsValue oddsValue,
    String? selectionId,
    required LeagueMarketData market,
    required LeagueOddsData odds,
    required OddsType oddsType,
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

    return BetCard(
      label: '',
      value: _getOddsValue(oddsValue),
      selectionId: selectionId ?? '',
      bettingPopupData: bettingData,
    );
  }

  bool _hasValidOdds(OddsValue oddsValue) =>
      oddsValue.decimal > 0 || oddsValue.malay != -100;

  String _getOddsValue(OddsValue oddsValue) {
    switch (oddsStyle) {
      case OddsStyle.malay:
        return oddsValue.malay.toStringAsFixed(2);
      case OddsStyle.indo:
        return oddsValue.indo.toStringAsFixed(2);
      case OddsStyle.decimal:
        return oddsValue.decimal.toStringAsFixed(2);
      case OddsStyle.hongKong:
        return oddsValue.hongKong.toStringAsFixed(2);
    }
  }
}
