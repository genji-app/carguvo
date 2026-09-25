import 'package:flutter/material.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/bet_detail/domain/models/market_drawer_data.dart';
import 'package:sun_sports/features/bet_detail/presentation/desktop/widgets/layouts/layouts.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class MarketDrawerWidget extends StatelessWidget {
  final MarketDrawerData drawer;
  final OddsStyle oddsStyle;
  final VoidCallback onToggle;

  final LeagueEventData? eventData;

  final LeagueData? leagueData;

  const MarketDrawerWidget({
    super.key,
    required this.drawer,
    required this.oddsStyle,
    required this.onToggle,
    this.eventData,
    this.leagueData,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color: const Color(0x0AFFF6E6),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DrawerHeader(
          title: MarketHelper.resolveTeamNamesInMarketName(
            drawer.name,
            homeName: eventData?.homeName,
            awayName: eventData?.awayName,
          ),
          isExpanded: drawer.isExpanded,
          onToggle: onToggle,
        ),
        if (drawer.isExpanded) ...[
          Container(
            width: double.infinity,
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0),
                  Colors.white.withOpacity(0.06),
                  Colors.white.withOpacity(0),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          _buildContent(),
        ],
      ],
    ),
  );

  Widget _buildContent() {
    if (drawer.markets.isEmpty) {
      return const SizedBox.shrink();
    }

    switch (drawer.poolType) {
      case MarketPoolType.main6:
        return Main6Layout(
          markets: drawer.markets,
          oddsStyle: oddsStyle,
          eventData: eventData,
          leagueData: leagueData,
        );

      case MarketPoolType.main:
        return _buildMain3Layout();

      case MarketPoolType.correctScore6:
        return CorrectScoreLayout(
          markets: drawer.markets,
          oddsStyle: oddsStyle,
          is6Columns: true,
          eventData: eventData,
          leagueData: leagueData,
        );

      case MarketPoolType.correctScore:
        return CorrectScoreLayout(
          markets: drawer.markets,
          oddsStyle: oddsStyle,
          is6Columns: false,
          eventData: eventData,
          leagueData: leagueData,
        );

      case MarketPoolType.only2x2:
        return Only2x2Layout(
          markets: drawer.markets,
          oddsStyle: oddsStyle,
          eventData: eventData,
          leagueData: leagueData,
        );

      case MarketPoolType.only3x2:
        return Only3x2Layout(
          markets: drawer.markets,
          oddsStyle: oddsStyle,
          eventData: eventData,
          leagueData: leagueData,
        );

      case MarketPoolType.only2:
        return Only2Layout(
          markets: drawer.markets,
          oddsStyle: oddsStyle,
          eventData: eventData,
          leagueData: leagueData,
        );

      case MarketPoolType.only3:
        return Only3Layout(
          markets: drawer.markets,
          oddsStyle: oddsStyle,
          eventData: eventData,
          leagueData: leagueData,
        );

      case MarketPoolType.only4:
        return Only4Layout(
          markets: drawer.markets,
          oddsStyle: oddsStyle,
          eventData: eventData,
          leagueData: leagueData,
        );

      case MarketPoolType.together4:
        return TogetherLayout(
          markets: drawer.markets,
          oddsStyle: oddsStyle,
          is4Columns: true,
          eventData: eventData,
          leagueData: leagueData,
        );

      case MarketPoolType.together:
        return TogetherLayout(
          markets: drawer.markets,
          oddsStyle: oddsStyle,
          is4Columns: false,
          eventData: eventData,
          leagueData: leagueData,
        );

      case MarketPoolType.market2:
        return Market2Layout(
          markets: drawer.markets,
          oddsStyle: oddsStyle,
          eventData: eventData,
          leagueData: leagueData,
        );
    }
  }

  Widget _buildMain3Layout() {
    return Main6Layout(
      markets: drawer.markets,
      oddsStyle: oddsStyle,
      eventData: eventData,
      leagueData: leagueData,
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  final String title;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _DrawerHeader({
    required this.title,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: SoundTap.wrap(onToggle),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.textStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFFFFCDB),
              ),
            ),
          ),
          Icon(
            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: const Color(0xB3FFFCDB),
            size: 24,
          ),
        ],
      ),
    ),
  );
}
