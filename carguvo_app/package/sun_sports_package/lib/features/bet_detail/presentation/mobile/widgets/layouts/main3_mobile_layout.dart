import 'package:flutter/material.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/bet_detail/domain/helpers/market_layout_helper.dart';
import 'package:sun_sports/features/sport/presentation/mobile/widgets/bet_card_mobile.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';
import 'package:sun_sports/shared/widgets/bet_details/models/betting_popup_data.dart';

class Main3MobileLayout extends StatelessWidget {
  final List<LeagueMarketData> markets;
  final OddsStyle oddsStyle;

  final LeagueEventData? eventData;

  final LeagueData? leagueData;

  static const ftMatchIds = [5, 3, 1];
  static const htMatchIds = [6, 4, 2];

  static const ftCornerIds = [19, 21, 17];
  static const htCornerIds = [20, 22, 18];

  static const ftBookingIds = [33, 31, 29];
  static const htBookingIds = [34, 32, 30];

  const Main3MobileLayout({
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

    final ftMarkets = _findMarketsForIds(ftIds);
    final htMarkets = _findMarketsForIds(htIds);

    final hasFT = ftMarkets.any((m) => m != null);
    final hasHT = htMarkets.any((m) => m != null);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          if (hasFT) ...[_buildSection('Toàn trận', ftMarkets)],
          if (hasHT) ...[
            if (hasFT) const SizedBox(height: 12),
            _buildSection('Hiệp 1', htMarkets),
          ],
        ],
      ),
    );
  }

  _MarketType _detectMarketType() {
    for (final m in markets) {
      if (ftMatchIds.contains(m.marketId) || htMatchIds.contains(m.marketId)) {
        return _MarketType.match;
      }
      if (ftCornerIds.contains(m.marketId) ||
          htCornerIds.contains(m.marketId)) {
        return _MarketType.corner;
      }
      if (ftBookingIds.contains(m.marketId) ||
          htBookingIds.contains(m.marketId)) {
        return _MarketType.booking;
      }
    }
    return _MarketType.match;
  }

  (List<int>, List<int>) _getMarketIds(_MarketType type) {
    switch (type) {
      case _MarketType.match:
        return (ftMatchIds, htMatchIds);
      case _MarketType.corner:
        return (ftCornerIds, htCornerIds);
      case _MarketType.booking:
        return (ftBookingIds, htBookingIds);
    }
  }

  List<LeagueMarketData?> _findMarketsForIds(List<int> ids) {
    return ids.map((id) {
      return markets.where((m) => m.marketId == id).firstOrNull;
    }).toList();
  }

  Widget _buildSection(String title, List<LeagueMarketData?> sectionMarkets) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            title,
            style: AppTextStyles.textStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFAAA49B),
            ),
          ),
        ),
        _buildHeaderRow(),
        const SizedBox(height: 6),
        _buildColumnsLayout(sectionMarkets),
      ],
    );
  }

  Widget _buildHeaderRow() {
    const headers = ['Kèo', 'Tài/Xỉu', '1X2'];

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
      children: List.generate(3, (colIndex) {
        final market = colIndex < columnMarkets.length
            ? columnMarkets[colIndex]
            : null;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: _buildSingleColumn(market, colIndex),
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
            marketId: market.marketId,
            marketData: market,
            oddsData: odds,
            oddsType: OddsType.home,
          ),
        );
      } else {
        widgets.add(const SizedBox(height: 36));
      }

      widgets.add(const SizedBox(height: 2));

      if (_hasValidOdds(odds.oddsDraw)) {
        widgets.add(
          _buildBetCard(
            label: 'X',
            oddsValue: odds.oddsDraw,
            selectionId: odds.selectionDrawId,
            marketId: market.marketId,
            marketData: market,
            oddsData: odds,
            oddsType: OddsType.draw,
          ),
        );
      } else {
        widgets.add(const SizedBox(height: 36));
      }

      widgets.add(const SizedBox(height: 2));

      if (_hasValidOdds(odds.oddsAway)) {
        widgets.add(
          _buildBetCard(
            label: '2',
            oddsValue: odds.oddsAway,
            selectionId: odds.selectionAwayId,
            marketId: market.marketId,
            marketData: market,
            oddsData: odds,
            oddsType: OddsType.away,
          ),
        );
      } else {
        widgets.add(const SizedBox(height: 36));
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
            marketId: market.marketId,
            marketData: market,
            oddsData: odds,
            oddsType: OddsType.home,
          ),
        );
      } else {
        widgets.add(const SizedBox(height: 36));
      }

      widgets.add(const SizedBox(height: 4));

      if (_hasValidOdds(odds.oddsAway)) {
        widgets.add(
          _buildBetCard(
            label: awayLabel,
            oddsValue: odds.oddsAway,
            selectionId: odds.selectionAwayId,
            marketId: market.marketId,
            marketData: market,
            oddsData: odds,
            oddsType: OddsType.away,
          ),
        );
      } else {
        widgets.add(const SizedBox(height: 36));
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
    int? marketId,
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

    return BetCardMobile(
      label: label,
      value: _getOddsValue(oddsValue, marketId),
      selectionId: selectionId ?? '',
      bettingPopupData: bettingData,
    );
  }

  bool _hasValidOdds(OddsValue oddsValue) {
    return oddsValue.decimal > 0 || oddsValue.malay != -100;
  }

  String _getOddsValue(OddsValue oddsValue, int? marketId) {
    if (marketId != null) {
      return MarketLayoutHelper.getOddsValue(oddsValue, marketId, oddsStyle);
    }
    if (oddsValue.decimal > 0) {
      return oddsValue.decimal.toStringAsFixed(2);
    }
    return '-';
  }
}

enum _MarketType { match, corner, booking }
