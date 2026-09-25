import 'package:flutter/material.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/bet_detail/domain/models/market_drawer_data.dart';
import 'package:sun_sports/features/bet_detail/presentation/mobile/widgets/layouts/layouts.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class MarketDrawerMobileWidget extends StatelessWidget {
  final MarketDrawerData drawer;
  final OddsStyle oddsStyle;
  final VoidCallback onToggle;

  final LeagueEventData? eventData;

  final LeagueData? leagueData;

  const MarketDrawerMobileWidget({
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
          title: drawer.name,
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
      case MarketPoolType.main:
        return Main3MobileLayout(
          markets: drawer.markets,
          oddsStyle: oddsStyle,
          eventData: eventData,
          leagueData: leagueData,
        );

      case MarketPoolType.correctScore6:
      case MarketPoolType.correctScore:
        return CorrectScoreMobileLayout(
          markets: drawer.markets,
          oddsStyle: oddsStyle,
          eventData: eventData,
          leagueData: leagueData,
        );

      case MarketPoolType.only2x2:
        return Only2MobileLayout(
          markets: drawer.markets,
          oddsStyle: oddsStyle,
          eventData: eventData,
          leagueData: leagueData,
        );

      case MarketPoolType.only3x2:
        return Only3MobileLayout(
          markets: drawer.markets,
          oddsStyle: oddsStyle,
          eventData: eventData,
          leagueData: leagueData,
        );

      case MarketPoolType.only2:
        return Only2MobileLayout(
          markets: drawer.markets,
          oddsStyle: oddsStyle,
          eventData: eventData,
          leagueData: leagueData,
        );

      case MarketPoolType.only3:
        return Only3MobileLayout(
          markets: drawer.markets,
          oddsStyle: oddsStyle,
          eventData: eventData,
          leagueData: leagueData,
        );

      case MarketPoolType.only4:
        return Only4MobileLayout(
          markets: drawer.markets,
          oddsStyle: oddsStyle,
          eventData: eventData,
          leagueData: leagueData,
        );

      case MarketPoolType.together4:
        return TogetherMobileLayout(
          markets: drawer.markets,
          oddsStyle: oddsStyle,
          eventData: eventData,
          leagueData: leagueData,
        );

      case MarketPoolType.together:
        return TogetherMobileLayout(
          markets: drawer.markets,
          oddsStyle: oddsStyle,
          eventData: eventData,
          leagueData: leagueData,
        );

      case MarketPoolType.market2:
        return Market2MobileLayout(
          markets: drawer.markets,
          oddsStyle: oddsStyle,
          eventData: eventData,
          leagueData: leagueData,
        );
    }
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.textStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFFFFCDB),
              ),
            ),
          ),
          Icon(
            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: const Color(0xB3FFFCDB),
            size: 20,
          ),
        ],
      ),
    ),
  );
}
