import 'package:flutter/material.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/bet_detail/domain/helpers/market_layout_helper.dart';
import 'package:sun_sports/features/sport/presentation/mobile/widgets/bet_card_mobile.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';
import 'package:sun_sports/shared/widgets/bet_details/models/betting_popup_data.dart';

class OverExactlyUnderMobileLayout extends StatelessWidget {
  final LeagueMarketData market;
  final OddsStyle oddsStyle;

  final LeagueEventData? eventData;

  final LeagueData? leagueData;

  const OverExactlyUnderMobileLayout({
    super.key,
    required this.market,
    required this.oddsStyle,
    this.eventData,
    this.leagueData,
  });

  @override
  Widget build(BuildContext context) {
    if (market.odds.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          _buildHeaderRow(),
          const SizedBox(height: 6),
          ..._buildOddsRows(),
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      children: const ['Tài', 'Chính xác', 'Xỉu'].map((title) {
        return Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.textStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFAAA49B),
            ),
          ),
        );
      }).toList(),
    );
  }

  List<Widget> _buildOddsRows() {
    final rows = <Widget>[];

    for (final odds in market.odds) {
      final formattedPoints = PointsFormatter.format(odds.points);

      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildCell(
                  label: formattedPoints,
                  oddsValue: odds.oddsHome,
                  selectionId: odds.selectionHomeId,
                  odds: odds,
                  oddsType: OddsType.home,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildCell(
                  label: formattedPoints,
                  oddsValue: odds.oddsDraw,
                  selectionId: odds.selectionDrawId,
                  odds: odds,
                  oddsType: OddsType.draw,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildCell(
                  label: formattedPoints,
                  oddsValue: odds.oddsAway,
                  selectionId: odds.selectionAwayId,
                  odds: odds,
                  oddsType: OddsType.away,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return rows;
  }

  Widget _buildCell({
    required String label,
    required OddsValue oddsValue,
    String? selectionId,
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
