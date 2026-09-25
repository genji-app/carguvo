import 'package:flutter/material.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';
import 'package:sun_sports/shared/widgets/bet_details/models/betting_popup_data.dart';
import 'package:sun_sports/shared/widgets/cards/bet_card.dart';

class Only4Layout extends StatelessWidget {
  final List<LeagueMarketData> markets;
  final OddsStyle oddsStyle;

  final LeagueEventData? eventData;

  final LeagueData? leagueData;

  const Only4Layout({
    super.key,
    required this.markets,
    required this.oddsStyle,
    this.eventData,
    this.leagueData,
  });

  @override
  Widget build(BuildContext context) {
    if (markets.isEmpty) return const SizedBox.shrink();

    final headers = ['Không ai', 'Nhà', 'Khách', 'Cả hai'];

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

  Widget _buildHeaderRow(List<String> headers) => Row(
    children: headers.map((title) {
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

    final cells = <Widget>[];

    if (market.odds.isEmpty) {
      return Row(
        children: List.generate(
          4,
          (_) => const Expanded(child: SizedBox(height: 36)),
        ),
      );
    }

    for (var i = 0; i < 4; i++) {
      if (i < market.odds.length) {
        final odds = market.odds[i];
        cells.add(_buildCell(odds, market));
      } else {
        cells.add(const SizedBox(height: 36));
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: cells.map((cell) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: cell,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCell(LeagueOddsData odds, LeagueMarketData market) {
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

    return BetCard(
      label: odds.points,
      value: _getOddsValue(oddsValue),
      selectionId: selectionId,
      bettingPopupData: bettingData,
    );
  }

  bool _hasValidOdds(OddsValue oddsValue) =>
      oddsValue.decimal > 0 || oddsValue.malay != -100;

  String _getOddsValue(OddsValue oddsValue) {
    if (oddsValue.decimal > 0) {
      return oddsValue.decimal.toStringAsFixed(2);
    }
    return '-';
  }
}
