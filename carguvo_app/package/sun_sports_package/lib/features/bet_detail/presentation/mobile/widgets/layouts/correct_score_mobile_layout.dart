import 'package:flutter/material.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/bet_detail/domain/helpers/market_layout_helper.dart';
import 'package:sun_sports/features/sport/presentation/mobile/widgets/bet_card_mobile.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';
import 'package:sun_sports/shared/widgets/bet_details/models/betting_popup_data.dart';

class CorrectScoreMobileLayout extends StatelessWidget {
  final List<LeagueMarketData> markets;
  final OddsStyle oddsStyle;

  final LeagueEventData? eventData;

  final LeagueData? leagueData;

  const CorrectScoreMobileLayout({
    super.key,
    required this.markets,
    required this.oddsStyle,
    this.eventData,
    this.leagueData,
  });

  @override
  Widget build(BuildContext context) {
    if (markets.isEmpty) return const SizedBox.shrink();

    final ftMarket = markets.where((m) => m.marketId == 10).firstOrNull;
    final htMarket = markets.where((m) => m.marketId == 11).firstOrNull;

    final extraMarkets = [
      for (final m in markets)
        if (m.marketId != 10 && m.marketId != 11 && m.odds.isNotEmpty) m,
    ];

    final ftHasOdds = ftMarket != null && ftMarket.odds.isNotEmpty;
    final htHasOdds = htMarket != null && htMarket.odds.isNotEmpty;

    if (!ftHasOdds && !htHasOdds && extraMarkets.isEmpty) {
      return const SizedBox.shrink();
    }

    final sections = <Widget>[];

    if (ftMarket != null && ftMarket.odds.isNotEmpty) {
      sections.add(_buildSection('Toàn trận', ftMarket));
    }

    if (htMarket != null && htMarket.odds.isNotEmpty) {
      if (sections.isNotEmpty) {
        sections.add(const SizedBox(height: 16));
      }
      sections.add(_buildSection('Hiệp 1', htMarket));
    }

    for (final market in extraMarkets) {
      if (sections.isNotEmpty) {
        sections.add(const SizedBox(height: 16));
      }
      sections.add(_buildSection('', market));
    }

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sections,
      ),
    );
  }

  Widget _buildSection(String title, LeagueMarketData market) {
    final groups = CorrectScoreHelper.groupOdds(
      market.odds,
      marketId: market.marketId,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeaderRow(hasDraw: groups.draw.isNotEmpty),
        const SizedBox(height: 6),
        _build3ColumnContent(groups, market),
      ],
    );
  }

  Widget _buildHeaderRow({bool hasDraw = true}) {
    final homeName = (eventData?.homeName.isNotEmpty ?? false)
        ? eventData!.homeName
        : 'Đội Nhà';
    final awayName = (eventData?.awayName.isNotEmpty ?? false)
        ? eventData!.awayName
        : 'Đội Khách';
    final headers = hasDraw ? [homeName, 'Hoà', awayName] : [homeName, awayName];

    return Row(
      children: headers.map((title) {
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

  Widget _build3ColumnContent(
    CorrectScoreGroups groups,
    LeagueMarketData market,
  ) {
    final maxRows = groups.maxRows;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildColumn(groups.home, maxRows, market)),
        if (groups.draw.isNotEmpty) ...[
          const SizedBox(width: 6),
          Expanded(child: _buildColumn(groups.draw, maxRows, market)),
        ],
        const SizedBox(width: 6),
        Expanded(child: _buildColumn(groups.away, maxRows, market)),
      ],
    );
  }

  Widget _buildColumn(
    List<LeagueOddsData> odds,
    int maxRows,
    LeagueMarketData market,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(maxRows, (index) {
        if (index >= odds.length) {
          return const SizedBox(height: 36);
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: _buildScoreCard(odds[index], market),
        );
      }),
    );
  }

  Widget _buildScoreCard(LeagueOddsData odds, LeagueMarketData market) {
    final oddsValue = odds.oddsHome;
    final selectionId = odds.selectionHomeId ?? '';
    final displayLabel = CorrectScoreHelper.getDisplayText(
      odds.points,
      marketId: market.marketId,
    );

    BettingPopupData? bettingData;
    if (eventData != null) {
      bettingData = BettingPopupData(
        oddsData: odds,
        marketData: market,
        eventData: eventData!,
        oddsType: OddsType.home,
        leagueData: leagueData,
        oddsStyle: oddsStyle,
      );
    }

    return BetCardMobile(
      label: displayLabel,
      value: MarketLayoutHelper.getOddsValue(
        oddsValue,
        market.marketId,
        oddsStyle,
      ),
      selectionId: selectionId,
      bettingPopupData: bettingData,
    );
  }
}
