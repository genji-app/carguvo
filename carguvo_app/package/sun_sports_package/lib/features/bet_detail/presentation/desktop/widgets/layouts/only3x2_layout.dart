import 'package:flutter/material.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';
import 'package:sun_sports/shared/widgets/bet_details/models/betting_popup_data.dart';
import 'package:sun_sports/shared/widgets/cards/bet_card.dart';

class Only3x2Layout extends StatelessWidget {
  final List<LeagueMarketData> markets;
  final OddsStyle oddsStyle;

  final LeagueEventData? eventData;

  final LeagueData? leagueData;

  const Only3x2Layout({
    super.key,
    required this.markets,
    required this.oddsStyle,
    this.eventData,
    this.leagueData,
  });

  @override
  Widget build(BuildContext context) {
    if (markets.isEmpty) return const SizedBox.shrink();

    final headers = ['1X', 'X2', '12', '1X H1', 'X2 H1', '12 H1'];

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
    final ftMarket = markets.where((m) => m.marketId == 12).firstOrNull;
    final htMarket = markets.where((m) => m.marketId == 13).firstOrNull;

    final cells = <Widget>[];

    if (ftMarket != null && ftMarket.odds.isNotEmpty) {
      final odds = ftMarket.odds.first;
      cells.add(
        _buildCell(
          odds.oddsHome,
          odds.selectionHomeId,
          ftMarket,
          odds,
          OddsType.home,
        ),
      );
      cells.add(
        _buildCell(
          odds.oddsDraw,
          odds.selectionDrawId,
          ftMarket,
          odds,
          OddsType.draw,
        ),
      );
      cells.add(
        _buildCell(
          odds.oddsAway,
          odds.selectionAwayId,
          ftMarket,
          odds,
          OddsType.away,
        ),
      );
    } else {
      cells.addAll([
        const SizedBox(height: 36),
        const SizedBox(height: 36),
        const SizedBox(height: 36),
      ]);
    }

    if (htMarket != null && htMarket.odds.isNotEmpty) {
      final odds = htMarket.odds.first;
      cells.add(
        _buildCell(
          odds.oddsHome,
          odds.selectionHomeId,
          htMarket,
          odds,
          OddsType.home,
        ),
      );
      cells.add(
        _buildCell(
          odds.oddsDraw,
          odds.selectionDrawId,
          htMarket,
          odds,
          OddsType.draw,
        ),
      );
      cells.add(
        _buildCell(
          odds.oddsAway,
          odds.selectionAwayId,
          htMarket,
          odds,
          OddsType.away,
        ),
      );
    } else {
      cells.addAll([
        const SizedBox(height: 36),
        const SizedBox(height: 36),
        const SizedBox(height: 36),
      ]);
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

  Widget _buildCell(
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
    if (oddsValue.decimal > 0) {
      return oddsValue.decimal.toStringAsFixed(2);
    }
    return '-';
  }
}
