import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/services/models/api_v2/event_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/score_model_v2.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/bet_detail/presentation/providers/bet_detail_v2_provider.dart';
import 'package:sun_sports/shared/widgets/live/live_consumers.dart';
import 'package:sun_sports/shared/widgets/sport/match/match_row_shared_v2.dart';

class StatisticsTableBadminton extends ConsumerWidget {
  final LeagueEventData eventData;
  final Animation<double> pulseAnimation;
  final bool isDesktop;

  const StatisticsTableBadminton({
    required this.eventData,
    required this.pulseAnimation,
    this.isDesktop = true,
    super.key,
  });

  static const _labels = ['G1', 'G2', 'G3'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventV2 = ref.watch(selectedEventV2Provider);
    final score = eventV2?.score;
    final badm = score is BadmintonScoreModelV2 ? score : null;

    final homeScores = <String>[];
    final awayScores = <String>[];
    for (var i = 0; i < 3; i++) {
      final s = badm?.liveScores.elementAtOrNull(i);
      if (s != null && s.homeScore.isNotEmpty) {
        homeScores.add(s.homeScore);
        awayScores.add(s.awayScore);
      } else {
        homeScores.add('-');
        awayScores.add('-');
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColorStyles.backgroundTertiary,
        ),
        child: Row(
          children: [
            Flexible(child: _buildLeftColumn(context, eventV2)),
            for (var i = 0; i < _labels.length; i++)
              _buildScoreColumn(
                label: _labels[i],
                homeValue: homeScores[i],
                awayValue: awayScores[i],
              ),
            _buildTotalColumn(
              homeValue: badm?.homeTotalPoint.toString() ?? '-',
              awayValue: badm?.awayTotalPoint.toString() ?? '-',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeftColumn(BuildContext context, EventModelV2? eventV2) {
    return Column(
      children: [
        Container(
          height: 44,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              if (eventData.isLive) ...[
                _buildPulsingDot(),
                const SizedBox(width: 12),
                Flexible(
                  child: LiveMatchTimeDisplay(
                    eventId: eventData.eventId,
                    initialMinute: eventData.minuteString.isNotEmpty
                        ? eventData.minuteString
                        : null,
                    initialPeriod: eventData.gamePartEnum.displayName,
                    sportId: 7,
                    initialCurrentSet: badm(eventV2),
                    initialSetScore: eventV2 != null
                        ? extractSetScore(eventV2)
                        : null,
                    style: AppTextStyles.paragraphSmall(
                      color: AppColorStyles.contentSecondary,
                    ),
                    separator: const SizedBox(width: 12),
                  ),
                ),
              ],
              if (!eventData.isLive)
                Text(
                  eventData.formattedTime,
                  style: AppTextStyles.paragraphSmall(
                    color: AppColorStyles.contentSecondary,
                  ),
                ),
            ],
          ),
        ),
        _buildTeamRow(
          teamName: eventData.homeName,
          logoUrl: eventData.homeLogoFirst ?? eventData.homeLogoLast ?? '',
        ),
        _buildTeamRow(
          teamName: eventData.awayName,
          logoUrl: eventData.awayLogoFirst ?? eventData.awayLogoLast ?? '',
        ),
      ],
    );
  }

  int? badm(EventModelV2? eventV2) {
    if (eventV2 == null) return null;
    final score = eventV2.score;
    if (score is BadmintonScoreModelV2) return score.currentSet;
    return null;
  }

  Widget _buildPulsingDot() {
    return SizedBox(
      width: 20,
      height: 20,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: pulseAnimation,
            builder: (context, child) => Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(
                  0xFFFF5172,
                ).withValues(alpha: 0.12 * pulseAnimation.value),
                shape: BoxShape.circle,
              ),
            ),
          ),
          AnimatedBuilder(
            animation: pulseAnimation,
            builder: (context, child) => Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: const Color(
                  0xFFFF5172,
                ).withValues(alpha: 0.12 * pulseAnimation.value),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFFFF5172),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamRow({required String teamName, required String logoUrl}) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: AppColorStyles.backgroundQuaternary),
      child: Row(
        children: [
          if (logoUrl.isNotEmpty && logoUrl != '')
            SizedBox(
              width: 28,
              height: 28,
              child: ImageHelper.getSmallLogo(imageUrl: logoUrl, size: 28),
            )
          else
            const SizedBox.shrink(),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              teamName,
              style: AppTextStyles.labelSmall(
                color: AppColorStyles.contentPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreColumn({
    required String label,
    required String homeValue,
    required String awayValue,
  }) {
    return SizedBox(
      width: 40,
      child: Column(
        children: [
          Container(
            height: 44,
            color: AppColorStyles.backgroundTertiary,
            alignment: Alignment.center,
            child: Text(
              label,
              style: AppTextStyles.paragraphXSmall(
                color: AppColorStyles.contentSecondary,
              ),
            ),
          ),
          Container(
            height: 44,
            color: AppColorStyles.backgroundQuaternary,
            alignment: Alignment.center,
            child: Text(
              homeValue,
              style: AppTextStyles.labelSmall(
                color: AppColorStyles.contentPrimary,
              ),
            ),
          ),
          Container(
            height: 44,
            color: AppColorStyles.backgroundQuaternary,
            alignment: Alignment.center,
            child: Text(
              awayValue,
              style: AppTextStyles.labelSmall(
                color: AppColorStyles.contentPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalColumn({
    required String homeValue,
    required String awayValue,
  }) {
    return SizedBox(
      width: 44,
      child: Column(
        children: [
          Container(
            height: 44,
            color: AppColorStyles.backgroundTertiary,
            alignment: Alignment.center,
            child: ImageHelper.load(
              path: AppIcons.iconBadminton,
              width: 20,
              height: 20,
            ),
          ),
          Stack(
            children: [
              Column(
                children: [
                  Container(
                    height: 44,
                    color: AppColorStyles.backgroundQuaternary,
                    alignment: Alignment.center,
                    child: Text(
                      homeValue,
                      style: AppTextStyles.labelSmall(
                        color: AppColorStyles.contentPrimary,
                      ),
                    ),
                  ),
                  Container(
                    height: 44,
                    color: AppColorStyles.backgroundQuaternary,
                    alignment: Alignment.center,
                    child: Text(
                      awayValue,
                      style: AppTextStyles.labelSmall(
                        color: AppColorStyles.contentPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 4,
                right: 4,
                top: 4,
                bottom: 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0x14FFFFFF),
                    border: Border.all(color: AppColors.gray500, width: 2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
