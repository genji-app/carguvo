import 'package:flutter/material.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/bet_detail/domain/helpers/market_layout_helper.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';
import 'package:sun_sports/shared/widgets/bet_details/models/betting_popup_data.dart';
import 'package:sun_sports/shared/widgets/cards/bet_card.dart';

class CorrectScoreLayout extends StatelessWidget {
  final List<LeagueMarketData> markets;
  final OddsStyle oddsStyle;
  final bool is6Columns;

  final LeagueEventData? eventData;

  final LeagueData? leagueData;

  const CorrectScoreLayout({
    super.key,
    required this.markets,
    required this.oddsStyle,
    this.is6Columns = false,
    this.eventData,
    this.leagueData,
  });

  @override
  Widget build(BuildContext context) {
    if (markets.isEmpty) return const SizedBox.shrink();

    final ftMarket = markets.where((m) => m.marketId == 10).firstOrNull;
    final htMarket = markets.where((m) => m.marketId == 11).firstOrNull;

    final ftGroups = ftMarket != null
        ? CorrectScoreHelper.groupOdds(ftMarket.odds)
        : null;
    final htGroups = htMarket != null
        ? CorrectScoreHelper.groupOdds(htMarket.odds)
        : null;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _buildHeaderRow(),
          const SizedBox(height: 8),
          _buildContent(ftGroups, htGroups, ftMarket, htMarket),
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    final headers = is6Columns
        ? [
            'Đội Nhà',
            'Hoà',
            'Đội Khách',
            'Đội Nhà H1',
            'Hoà H1',
            'Đội Khách H1',
          ]
        : ['Đội Nhà', 'Hoà', 'Đội Khách'];

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

  Widget _buildContent(
    CorrectScoreGroups? ftGroups,
    CorrectScoreGroups? htGroups,
    LeagueMarketData? ftMarket,
    LeagueMarketData? htMarket,
  ) {
    if (is6Columns && ftGroups != null && htGroups != null) {
      return _build6ColumnContent(ftGroups, htGroups, ftMarket, htMarket);
    }

    final groups = ftGroups ?? htGroups;
    final market = ftMarket ?? htMarket;
    if (groups == null) return const SizedBox.shrink();

    return _build3ColumnContent(groups, market);
  }

  Widget _build3ColumnContent(
    CorrectScoreGroups groups,
    LeagueMarketData? market,
  ) {
    final maxRows = groups.maxRows;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildColumn(groups.home, maxRows, market)),
        const SizedBox(width: 8),
        Expanded(child: _buildColumn(groups.draw, maxRows, market)),
        const SizedBox(width: 8),
        Expanded(child: _buildColumn(groups.away, maxRows, market)),
      ],
    );
  }

  Widget _build6ColumnContent(
    CorrectScoreGroups ftGroups,
    CorrectScoreGroups htGroups,
    LeagueMarketData? ftMarket,
    LeagueMarketData? htMarket,
  ) {
    final maxRows = [
      ftGroups.maxRows,
      htGroups.maxRows,
    ].reduce((a, b) => a > b ? a : b);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildColumn(ftGroups.home, maxRows, ftMarket)),
        const SizedBox(width: 4),
        Expanded(child: _buildColumn(ftGroups.draw, maxRows, ftMarket)),
        const SizedBox(width: 4),
        Expanded(child: _buildColumn(ftGroups.away, maxRows, ftMarket)),
        const SizedBox(width: 8),
        Expanded(child: _buildColumn(htGroups.home, maxRows, htMarket)),
        const SizedBox(width: 4),
        Expanded(child: _buildColumn(htGroups.draw, maxRows, htMarket)),
        const SizedBox(width: 4),
        Expanded(child: _buildColumn(htGroups.away, maxRows, htMarket)),
      ],
    );
  }

  Widget _buildColumn(
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
          child: _buildScoreCard(odds[index], market),
        );
      }),
    );
  }

  Widget _buildScoreCard(LeagueOddsData odds, LeagueMarketData? market) {
    final oddsValue = odds.oddsHome;

    final selectionId = odds.selectionHomeId ?? '';

    final displayLabel = CorrectScoreHelper.getDisplayText(odds.points);

    BettingPopupData? bettingData;
    if (eventData != null && market != null) {
      bettingData = BettingPopupData(
        oddsData: odds,
        marketData: market,
        eventData: eventData!,
        oddsType: OddsType.home,
        leagueData: leagueData,
        oddsStyle: oddsStyle,
      );
    }

    return BetCard(
      label: displayLabel,
      value: _getOddsValue(oddsValue),
      selectionId: selectionId,
      bettingPopupData: bettingData,
    );
  }

  String _getOddsValue(OddsValue oddsValue) {
    if (oddsValue.decimal > 0 && oddsValue.decimal != -100) {
      return oddsValue.decimal.toStringAsFixed(2);
    }
    return '-';
  }
}
