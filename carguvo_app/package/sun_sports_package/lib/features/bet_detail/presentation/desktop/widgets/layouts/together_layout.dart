import 'package:flutter/material.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/bet_detail/domain/helpers/market_layout_helper.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';
import 'package:sun_sports/shared/widgets/bet_details/models/betting_popup_data.dart';
import 'package:sun_sports/shared/widgets/cards/bet_card.dart';

class TogetherLayout extends StatelessWidget {
  final List<LeagueMarketData> markets;
  final OddsStyle oddsStyle;
  final bool is4Columns;
  final List<String>? customHeaders;

  final LeagueEventData? eventData;

  final LeagueData? leagueData;

  const TogetherLayout({
    super.key,
    required this.markets,
    required this.oddsStyle,
    this.is4Columns = false,
    this.customHeaders,
    this.eventData,
    this.leagueData,
  });

  bool get _isCornerRange {
    if (markets.isEmpty) return false;
    return MarketLayoutHelper.isCornerRange(markets.first.marketId);
  }

  @override
  Widget build(BuildContext context) {
    if (markets.isEmpty) return const SizedBox.shrink();

    if (_isCornerRange) {
      return _buildCornerRangeGrid();
    }

    return _buildTotalScoreLayout();
  }

  Widget _buildCornerRangeGrid() {
    final market = markets.first;
    final odds = market.odds;

    if (odds.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 6,
          crossAxisSpacing: 8,
          childAspectRatio: 2.8,
        ),
        itemCount: odds.length,
        itemBuilder: (context, index) => _buildOddsCard(odds[index], market),
      ),
    );
  }

  Widget _buildTotalScoreLayout() {
    final headers = customHeaders ?? _getDefaultHeaders();

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _buildHeaderRow(headers),
          const SizedBox(height: 8),
          is4Columns ? _build4ColumnContent() : _build2ColumnContent(),
        ],
      ),
    );
  }

  List<String> _getDefaultHeaders() {
    if (is4Columns) {
      return ['Nhà FT', 'Khách FT', 'Nhà HT', 'Khách HT'];
    }
    return ['FT', 'HT'];
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

  Widget _build2ColumnContent() {
    final ftMarket =
        markets.where((m) => [14].contains(m.marketId)).firstOrNull ??
        (markets.isNotEmpty ? markets.first : null);
    final htMarket =
        markets.where((m) => [15].contains(m.marketId)).firstOrNull ??
        (markets.length > 1 ? markets[1] : null);

    final ftOdds = ftMarket?.odds ?? [];
    final htOdds = htMarket?.odds ?? [];
    final maxRows = [
      ftOdds.length,
      htOdds.length,
    ].reduce((a, b) => a > b ? a : b);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildOddsColumn(ftOdds, maxRows, ftMarket)),
        const SizedBox(width: 8),
        Expanded(child: _buildOddsColumn(htOdds, maxRows, htMarket)),
      ],
    );
  }

  Widget _build4ColumnContent() {
    final columnData = <(List<LeagueOddsData>, LeagueMarketData?)>[];

    for (final market in markets.take(4)) {
      columnData.add((market.odds, market));
    }

    while (columnData.length < 4) {
      columnData.add((<LeagueOddsData>[], null));
    }

    final maxRows = columnData
        .map((c) => c.$1.length)
        .reduce((a, b) => a > b ? a : b);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: columnData.map((data) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: _buildOddsColumn(data.$1, maxRows, data.$2),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOddsColumn(
    List<LeagueOddsData> odds,
    int maxRows,
    LeagueMarketData? market,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(maxRows, (index) {
        if (index >= odds.length) {
          return const SizedBox(height: 40);
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: _buildOddsCard(odds[index], market),
        );
      }),
    );
  }

  Widget _buildOddsCard(LeagueOddsData odds, LeagueMarketData? market) {
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

    final marketId = market?.marketId ?? 0;
    final String formattedPoints;
    if (MarketLayoutHelper.isCornerRange(marketId)) {
      formattedPoints = odds.points;
    } else if (MarketLayoutHelper.isTotalScore(marketId) ||
        MarketLayoutHelper.isExactGoals(marketId)) {
      formattedPoints = MarketLayoutHelper.totalScoreLabel(odds.points);
    } else {
      formattedPoints = PointsFormatter.format(odds.points);
    }

    BettingPopupData? bettingData;
    if (eventData != null && market != null) {
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
      label: formattedPoints,
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
