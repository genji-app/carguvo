import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/core/services/models/api_v2/v2_to_legacy_adapter.dart';
import 'package:sun_sports/features/sport/presentation/providers/league_provider.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/home/domain/entities/hot_match_entity.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';
import 'package:sun_sports/shared/widgets/cards/inner_shadow_card.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class HotMatchCard extends ConsumerWidget {
  final HotMatchEventV2 match;
  final VoidCallback? onTap;
  final void Function(LeagueOddsData odds, bool isHome, int marketId)?
  onOddsTap;

  const HotMatchCard({
    super.key,
    required this.match,
    this.onTap,
    this.onOddsTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sportId = ref.watch(currentSportIdProvider);
    final oddsStyle = ref.watch(oddsStyleProvider);

    final handicapMarket = match.getHandicapMarket(sportId);
    final overUnderMarket = match.getOverUnderMarket(sportId);
    final handicapOdds = handicapMarket?.mainLineOdds?.toLegacy();
    final overUnderOdds = overUnderMarket?.mainLineOdds?.toLegacy();

    return GestureDetector(
      onTap: SoundTap.wrap(onTap),
      child: InnerShadowCard(
        borderRadius: 12,
        child: Container(
          width: 280,
          decoration: BoxDecoration(
            color: AppColorStyles.backgroundTertiary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLeagueHeader(),

              const Gap(8),

              _buildOddsSection(
                handicapOdds: handicapOdds,
                overUnderOdds: overUnderOdds,
                oddsStyle: oddsStyle,
                handicapMarketId: handicapMarket?.marketId ?? 5,
                overUnderMarketId: overUnderMarket?.marketId ?? 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeagueHeader() => Container(
    height: 32,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: AppColorStyles.backgroundQuaternary,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      ),
    ),
    child: Row(
      children: [
        if (match.leagueLogo.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: ImageHelper.load(
              path: match.leagueLogo,
              width: 20,
              height: 20,
              cacheWidth: 40,
              cacheHeight: 40,
              fit: BoxFit.contain,
              maxRetries: 1,
            ),
          )
        else
          ImageHelper.load(
            path: AppIcons.iconSoccer,
            width: 20,
            height: 20,
            cacheWidth: 40,
            cacheHeight: 40,
            maxRetries: 1,
          ),
        const Gap(6),
        Expanded(
          child: Text(
            match.leagueName,
            style: AppTextStyles.paragraphXXSmall(
              color: AppColorStyles.contentSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );

  Widget _buildTeamsSection() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    child: Row(
      children: [
        Expanded(
          child: _buildTeamInfo(
            name: match.homeName,
            logo: match.homeLogo,
            isHome: true,
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: _buildTimeOrScore(),
        ),

        Expanded(
          child: _buildTeamInfo(
            name: match.awayName,
            logo: match.awayLogo,
            isHome: false,
          ),
        ),
      ],
    ),
  );

  Widget _buildTeamInfo({
    required String name,
    required String logo,
    required bool isHome,
  }) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColorStyles.backgroundQuaternary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: logo.isNotEmpty
              ? ImageHelper.load(
                  path: logo,
                  width: 40,
                  height: 40,
                  cacheWidth: 80,
                  cacheHeight: 80,
                  fit: BoxFit.contain,
                  maxRetries: 1,
                )
              : Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: AppTextStyles.labelMedium(
                      color: AppColorStyles.contentSecondary,
                    ),
                  ),
                ),
        ),
      ),
      const Gap(4),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 80),
        child: Text(
          name,
          style: AppTextStyles.labelXSmall(
            color: AppColorStyles.contentPrimary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ),
    ],
  );

  Widget _buildTimeOrScore() {
    if (match.isLive) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFFF5172).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF5172),
                    shape: BoxShape.circle,
                  ),
                ),
                const Gap(4),
                Text(
                  'Live',
                  style: AppTextStyles.paragraphXXSmall(
                    color: const Color(0xFFFF5172),
                  ),
                ),
              ],
            ),
          ),
          const Gap(4),
          Text(
            match.scoreString,
            style: AppTextStyles.labelLarge(
              color: AppColorStyles.contentPrimary,
            ),
          ),
        ],
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            match.formattedTime.split(' - ').first,
            style: AppTextStyles.labelSmall(
              color: AppColorStyles.contentPrimary,
            ),
          ),
          const Gap(2),
          Text(
            match.formattedDate,
            style: AppTextStyles.paragraphXXSmall(
              color: AppColorStyles.contentTertiary,
            ),
          ),
        ],
      );
    }
  }

  Widget _buildOddsSection({
    required LeagueOddsData? handicapOdds,
    required LeagueOddsData? overUnderOdds,
    required OddsStyle oddsStyle,
    required int handicapMarketId,
    required int overUnderMarketId,
  }) => Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: AppColorStyles.backgroundQuaternary.withValues(alpha: 0.5),
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(12),
        bottomRight: Radius.circular(12),
      ),
    ),
    child: Row(
      children: [
        Expanded(
          child: _buildOddsColumn(
            title: 'Kèo chấp',
            odds: handicapOdds,
            oddsStyle: oddsStyle,
            marketId: handicapMarketId,
          ),
        ),
        Container(width: 1, height: 50, color: AppColorStyles.borderSecondary),
        Expanded(
          child: _buildOddsColumn(
            title: 'Tài Xỉu',
            odds: overUnderOdds,
            oddsStyle: oddsStyle,
            marketId: overUnderMarketId,
            isOverUnder: true,
          ),
        ),
      ],
    ),
  );

  Widget _buildOddsColumn({
    required String title,
    required LeagueOddsData? odds,
    required OddsStyle oddsStyle,
    required int marketId,
    bool isOverUnder = false,
  }) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(
        title,
        style: AppTextStyles.paragraphXXSmall(
          color: AppColorStyles.contentTertiary,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      const Gap(4),
      if (odds != null) ...[
        Text(
          PointsFormatter.format(odds.points),
          style: AppTextStyles.labelXSmall(
            color: AppColorStyles.contentSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const Gap(4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: _buildOddsButton(
                value: odds.getHomeOdds(oddsStyle),
                label: isOverUnder ? 'T' : null,
                onTap: () => onOddsTap?.call(odds, true, marketId),
              ),
            ),
            const Gap(4),
            Flexible(
              child: _buildOddsButton(
                value: odds.getAwayOdds(oddsStyle),
                label: isOverUnder ? 'X' : null,
                onTap: () => onOddsTap?.call(odds, false, marketId),
              ),
            ),
          ],
        ),
      ] else
        Text(
          '-',
          style: AppTextStyles.labelSmall(
            color: AppColorStyles.contentTertiary,
          ),
        ),
    ],
  );

  Widget _buildOddsButton({
    required double value,
    String? label,
    VoidCallback? onTap,
  }) {
    final isValid = value != -100 && value != 0;
    final isNegative = value < 0;

    return GestureDetector(
      onTap: SoundTap.wrap(isValid ? onTap : null),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColorStyles.backgroundTertiary,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColorStyles.borderSecondary, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label != null) ...[
              Text(
                label,
                style: AppTextStyles.paragraphXXSmall(
                  color: AppColorStyles.contentTertiary,
                ),
              ),
              const Gap(2),
            ],
            Text(
              isValid ? value.toStringAsFixed(2) : '-',
              style: AppTextStyles.labelXSmall(
                color: isNegative
                    ? const Color(0xFFFF5172)
                    : AppColorStyles.contentPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
