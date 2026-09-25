import 'package:flutter/material.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';
import 'package:sun_sports/shared/widgets/bet_details/models/betting_popup_data.dart';
import 'package:sun_sports/shared/widgets/cards/bet_card.dart';

class Main6Layout extends StatelessWidget {
  final List<LeagueMarketData> markets;
  final OddsStyle oddsStyle;

  final LeagueEventData? eventData;

  final LeagueData? leagueData;

  static const ftMarketIds = [5, 3, 1];
  static const htMarketIds = [6, 4, 2];

  static const cornerFtIds = [19, 21, 17];
  static const cornerHtIds = [20, 22, 18];

  static const bookingFtIds = [33, 31, 29];
  static const bookingHtIds = [34, 32, 30];

  const Main6Layout({
    super.key,
    required this.markets,
    required this.oddsStyle,
    this.eventData,
    this.leagueData,
  });

  @override
  Widget build(BuildContext context) {
    final marketType = _detectMarketType();
    final (ftIds, htIds) = _getMarketIds(marketType);

    final columnMarkets = <LeagueMarketData?>[];
    for (final id in [...ftIds, ...htIds]) {
      final market = markets.where((m) => m.marketId == id).firstOrNull;
      columnMarkets.add(market);
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _buildHeaderRow(),
          const SizedBox(height: 8),
          _buildColumnsLayout(columnMarkets),
        ],
      ),
    );
  }

  _MarketType _detectMarketType() {
    for (final m in markets) {
      if (ftMarketIds.contains(m.marketId) ||
          htMarketIds.contains(m.marketId)) {
        return _MarketType.match;
      }
      if (cornerFtIds.contains(m.marketId) ||
          cornerHtIds.contains(m.marketId)) {
        return _MarketType.corner;
      }
      if (bookingFtIds.contains(m.marketId) ||
          bookingHtIds.contains(m.marketId)) {
        return _MarketType.booking;
      }
    }
    return _MarketType.match;
  }

  (List<int>, List<int>) _getMarketIds(_MarketType type) {
    switch (type) {
      case _MarketType.match:
        return (ftMarketIds, htMarketIds);
      case _MarketType.corner:
        return (cornerFtIds, cornerHtIds);
      case _MarketType.booking:
        return (bookingFtIds, bookingHtIds);
    }
  }

  Widget _buildHeaderRow() {
    final headers = ['Kèo', 'Tài/Xỉu', '1X2', 'Kèo H1', 'T/X H1', '1X2 H1'];

    return Row(
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
  }

  Widget _buildColumnsLayout(List<LeagueMarketData?> columnMarkets) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(6, (colIndex) {
        final colType = colIndex % 3;
        final market = columnMarkets[colIndex];

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: _buildSingleColumn(market, colType),
          ),
        );
      }),
    );
  }

  Widget _buildSingleColumn(LeagueMarketData? market, int colType) {
    if (market == null || market.odds.isEmpty) {
      return const SizedBox.shrink();
    }

    if (colType == 2) {
      return _build1X2Column(market);
    }

    return _buildHandicapOUColumn(market, colType);
  }

  Widget _build1X2Column(LeagueMarketData market) {
    final widgets = <Widget>[];

    for (final odds in market.odds) {
      if (_hasValidOdds(odds.oddsHome)) {
        widgets.add(
          _buildBetCard(
            label: '1',
            oddsValue: odds.oddsHome,
            selectionId: odds.selectionHomeId,
            marketData: market,
            oddsData: odds,
            oddsType: OddsType.home,
          ),
        );
      } else {
        widgets.add(const SizedBox(height: 32));
      }

      widgets.add(const SizedBox(height: 2));

      if (_hasValidOdds(odds.oddsDraw)) {
        widgets.add(
          _buildBetCard(
            label: 'X',
            oddsValue: odds.oddsDraw,
            selectionId: odds.selectionDrawId,
            marketData: market,
            oddsData: odds,
            oddsType: OddsType.draw,
          ),
        );
      } else {
        widgets.add(const SizedBox(height: 32));
      }

      widgets.add(const SizedBox(height: 2));

      if (_hasValidOdds(odds.oddsAway)) {
        widgets.add(
          _buildBetCard(
            label: '2',
            oddsValue: odds.oddsAway,
            selectionId: odds.selectionAwayId,
            marketData: market,
            oddsData: odds,
            oddsType: OddsType.away,
          ),
        );
      } else {
        widgets.add(const SizedBox(height: 32));
      }

      if (market.odds.length > 1 && odds != market.odds.last) {
        widgets.add(const SizedBox(height: 4));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widgets,
    );
  }

  Widget _buildHandicapOUColumn(LeagueMarketData market, int colType) {
    final widgets = <Widget>[];
    final isOverUnder = colType == 1;
    final isHandicap = colType == 0;

    for (int i = 0; i < market.odds.length; i++) {
      final odds = market.odds[i];
      final isLastOdds = i == market.odds.length - 1;

      final pointsValue = odds.pointsValue;
      final formattedPoints = PointsFormatter.format(pointsValue.abs());

      String homeLabel;
      String awayLabel;

      if (isHandicap) {
        homeLabel = PointsFormatter.formatSigned(pointsValue);
        awayLabel = PointsFormatter.formatSigned(-pointsValue);
      } else if (isOverUnder) {
        homeLabel = formattedPoints;
        awayLabel = 'U';
      } else {
        homeLabel = formattedPoints;
        awayLabel = formattedPoints;
      }

      if (_hasValidOdds(odds.oddsHome)) {
        widgets.add(
          _buildBetCard(
            label: homeLabel,
            oddsValue: odds.oddsHome,
            selectionId: odds.selectionHomeId,
            marketData: market,
            oddsData: odds,
            oddsType: OddsType.home,
          ),
        );
      } else {
        widgets.add(const SizedBox(height: 32));
      }

      widgets.add(const SizedBox(height: 4));

      if (_hasValidOdds(odds.oddsAway)) {
        widgets.add(
          _buildBetCard(
            label: awayLabel,
            oddsValue: odds.oddsAway,
            selectionId: odds.selectionAwayId,
            marketData: market,
            oddsData: odds,
            oddsType: OddsType.away,
          ),
        );
      } else {
        widgets.add(const SizedBox(height: 32));
      }

      if (!isLastOdds) {
        widgets.add(
          const Padding(
            padding: EdgeInsets.only(top: 8, bottom: 8),
            child: Divider(height: 1, thickness: 1, color: AppColors.yellow300),
          ),
        );
      } else {
        widgets.add(const SizedBox(height: 4));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widgets,
    );
  }

  Widget _buildBetCard({
    required String label,
    required OddsValue oddsValue,
    String? selectionId,
    LeagueMarketData? marketData,
    LeagueOddsData? oddsData,
    OddsType? oddsType,
  }) {
    BettingPopupData? bettingData;
    if (oddsData != null &&
        marketData != null &&
        oddsType != null &&
        eventData != null) {
      bettingData = BettingPopupData(
        oddsData: oddsData,
        marketData: marketData,
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

  bool _hasValidOdds(OddsValue oddsValue) {
    return oddsValue.decimal > 0 || oddsValue.malay != -100;
  }

  String _getOddsValue(OddsValue oddsValue) {
    if (oddsValue.decimal > 0) {
      return oddsValue.decimal.toStringAsFixed(2);
    }
    return '-';
  }
}

enum _MarketType { match, corner, booking }
