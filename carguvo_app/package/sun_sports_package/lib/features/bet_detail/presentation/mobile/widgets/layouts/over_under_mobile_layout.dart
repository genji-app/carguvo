import 'package:flutter/material.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/features/bet_detail/domain/helpers/market_layout_helper.dart';
import 'package:sun_sports/features/sport/presentation/mobile/widgets/bet_card_mobile.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';
import 'package:sun_sports/shared/widgets/bet_details/models/betting_popup_data.dart';

class OverUnderMobileLayout extends StatelessWidget {
  final LeagueMarketData market;
  final OddsStyle oddsStyle;

  final LeagueEventData? eventData;

  final LeagueData? leagueData;

  final List<String>? customHeaders;

  const OverUnderMobileLayout({
    super.key,
    required this.market,
    required this.oddsStyle,
    this.eventData,
    this.leagueData,
    this.customHeaders,
  });

  @override
  Widget build(BuildContext context) {
    if (market.odds.isEmpty) return const SizedBox.shrink();

    final sideLabels = customHeaders ?? const ['Tài', 'Xỉu'];

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(children: _buildOddsRows(sideLabels)),
    );
  }

  String _sideLabel(String side, String formattedPoints) =>
      formattedPoints.isEmpty ? side : '$side $formattedPoints';

  List<Widget> _buildOddsRows(List<String> sideLabels) {
    final rows = <Widget>[];
    final overSide = sideLabels.isNotEmpty ? sideLabels[0] : 'Tài';
    final underSide = sideLabels.length > 1 ? sideLabels[1] : 'Xỉu';

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
                  label: _sideLabel(overSide, formattedPoints),
                  oddsValue: odds.oddsHome,
                  selectionId: odds.selectionHomeId,
                  odds: odds,
                  oddsType: OddsType.home,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildCell(
                  label: _sideLabel(underSide, formattedPoints),
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
