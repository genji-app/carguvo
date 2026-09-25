import 'package:flutter/material.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/bet_detail/domain/helpers/market_layout_helper.dart';
import 'package:sun_sports/features/sport/presentation/mobile/widgets/bet_card_mobile.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';
import 'package:sun_sports/shared/widgets/bet_details/models/betting_popup_data.dart';

class TogetherMobileLayout extends StatelessWidget {
  final List<LeagueMarketData> markets;
  final OddsStyle oddsStyle;
  final List<String>? customHeaders;

  final LeagueEventData? eventData;

  final LeagueData? leagueData;

  const TogetherMobileLayout({
    super.key,
    required this.markets,
    required this.oddsStyle,
    this.customHeaders,
    this.eventData,
    this.leagueData,
  });

  bool get _isCornerRange {
    if (markets.isEmpty) return false;
    return MarketLayoutHelper.isCornerRange(markets.first.marketId);
  }

  bool get _isExactGoals {
    if (markets.isEmpty) return false;
    return MarketLayoutHelper.isExactGoals(markets.first.marketId);
  }

  @override
  Widget build(BuildContext context) {
    if (markets.isEmpty) return const SizedBox.shrink();

    if (_isCornerRange || _isExactGoals) {
      return _buildCornerRangeGrid();
    }

    return _buildTotalScoreLayout();
  }

  Widget _buildCornerRangeGrid() {
    final market = markets.first;
    final odds = market.odds;

    if (odds.isEmpty) return const SizedBox.shrink();

    final sortedOdds = List<LeagueOddsData>.from(odds)
      ..sort(
        (a, b) =>
            _parseRangeStart(a.points).compareTo(_parseRangeStart(b.points)),
      );

    return Padding(
      padding: const EdgeInsets.all(10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth =
              (constraints.maxWidth - 8) / 3;
          final itemHeight = 36.0;

          return Wrap(
            spacing: 4,
            runSpacing: 4,
            children: sortedOdds.map((odd) {
              return SizedBox(
                width: itemWidth,
                height: itemHeight,
                child: _buildOddsCard(odd, market),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  int _parseRangeStart(String range) {
    final cleaned = range.replaceAll('+', '').split(RegExp(r'[-:]')).first;
    return int.tryParse(cleaned) ?? 0;
  }

  Widget _buildTotalScoreLayout() {
    if (markets.length == 1) {
      return _buildSingleColumnLayout(markets.first);
    }

    final headers = customHeaders ?? ['FT', 'HT'];

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          _buildHeaderRow(headers),
          const SizedBox(height: 6),
          _build2ColumnContent(),
        ],
      ),
    );
  }

  Widget _buildSingleColumnLayout(LeagueMarketData market) {
    final odds = market.odds;
    if (odds.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final odd in odds)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: _buildOddsCard(odd, market),
            ),
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
        const SizedBox(width: 6),
        Expanded(child: _buildOddsColumn(htOdds, maxRows, htMarket)),
      ],
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
          return const SizedBox(height: 36);
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
    } else if (MarketLayoutHelper.isExactGoals(marketId) ||
        MarketLayoutHelper.isTotalScore(marketId)) {
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

    return BetCardMobile(
      label: formattedPoints,
      value: MarketLayoutHelper.getOddsValue(
        oddsValue,
        market?.marketId ?? 14,
        oddsStyle,
      ),
      selectionId: selectionId,
      bettingPopupData: bettingData,
    );
  }

  bool _hasValidOdds(OddsValue oddsValue) =>
      oddsValue.decimal > 0 || oddsValue.malay != -100;
}
