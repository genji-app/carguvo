import 'package:flutter/material.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';
import 'package:sun_sports/shared/widgets/bet_details/models/betting_popup_data.dart';
import 'package:sun_sports/shared/widgets/cards/bet_card.dart';

class Market2Layout extends StatelessWidget {
  final List<LeagueMarketData> markets;
  final OddsStyle oddsStyle;
  final List<String>? customHeaders;

  final LeagueEventData? eventData;

  final LeagueData? leagueData;

  const Market2Layout({
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

    final headers = customHeaders ?? ['Over', 'Under'];

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _buildHeaderRow(headers),
          const SizedBox(height: 8),
          ..._buildMarketRows(),
        ],
      ),
    );
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

  List<Widget> _buildMarketRows() {
    final rows = <Widget>[];

    for (final market in markets) {
      if (markets.length > 1 && market.marketName.isNotEmpty) {
        rows.add(
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Text(
              market.marketName,
              style: AppTextStyles.textStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xB3FFFCDB),
              ),
            ),
          ),
        );
      }

      for (final odds in market.odds) {
        rows.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: _buildOddsRow(odds, market),
          ),
        );
      }
    }

    return rows;
  }

  Widget _buildOddsRow(LeagueOddsData odds, LeagueMarketData market) {
    final formattedPoints = PointsFormatter.format(odds.points);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildCell(
            label: 'O $formattedPoints',
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
            label: 'U $formattedPoints',
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
    required String label,
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
      label: label,
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
