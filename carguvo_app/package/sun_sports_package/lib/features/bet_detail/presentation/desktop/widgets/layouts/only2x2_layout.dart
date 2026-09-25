import 'package:flutter/material.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';
import 'package:sun_sports/shared/widgets/bet_details/models/betting_popup_data.dart';
import 'package:sun_sports/shared/widgets/cards/bet_card.dart';

class Only2x2Layout extends StatelessWidget {
  final List<LeagueMarketData> markets;
  final OddsStyle oddsStyle;
  final List<String>? customHeaders;

  final LeagueEventData? eventData;

  final LeagueData? leagueData;

  const Only2x2Layout({
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
      return ['Lẻ', 'Chẵn', 'Lẻ H1', 'Chẵn H1'];
    }

    if ([16, 17, 35].contains(firstMarketId)) {
      return ['Nhà', 'Khách', 'Nhà H1', 'Khách H1'];
    }

    if ([54, 55].contains(firstMarketId)) {
      return ['Nhà', 'Khách', 'Nhà H1', 'Khách H1'];
    }

    if ([83, 84].contains(firstMarketId)) {
      return ['Nhà Có', 'Nhà Không', 'Khách Có', 'Khách Không'];
    }

    return ['Nhà', 'Khách', 'Nhà H1', 'Khách H1'];
  }

  Widget _buildHeaderRow(List<String> headers) => Row(
    children: headers.take(4).map((title) {
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
    final ftMarket = _getFTMarket();
    final htMarket = _getHTMarket();

    final cells = <Widget>[];

    cells.add(_buildCell(ftMarket, true));
    cells.add(_buildCell(ftMarket, false));
    cells.add(_buildCell(htMarket, true));
    cells.add(_buildCell(htMarket, false));

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

  LeagueMarketData? _getFTMarket() {
    final oddEvenFT = markets.where((m) => m.marketId == 8).firstOrNull;
    if (oddEvenFT != null) return oddEvenFT;

    final dnbFT = markets.where((m) => m.marketId == 16).firstOrNull;
    if (dnbFT != null) return dnbFT;

    return markets.isNotEmpty ? markets.first : null;
  }

  LeagueMarketData? _getHTMarket() {
    final oddEvenHT = markets.where((m) => m.marketId == 9).firstOrNull;
    if (oddEvenHT != null) return oddEvenHT;

    final dnbHT = markets
        .where((m) => [17, 35].contains(m.marketId))
        .firstOrNull;
    if (dnbHT != null) return dnbHT;

    return markets.length > 1 ? markets[1] : null;
  }

  Widget _buildCell(LeagueMarketData? market, bool isHome) {
    if (market == null || market.odds.isEmpty) {
      return const SizedBox(height: 36);
    }

    final odds = market.odds.first;
    final oddsValue = isHome ? odds.oddsHome : odds.oddsAway;
    final selectionId = isHome ? odds.selectionHomeId : odds.selectionAwayId;
    final oddsType = isHome ? OddsType.home : OddsType.away;

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
