import 'package:flutter/material.dart';
import 'package:sun_sports/core/services/models/api_v2/event_model_v2_extensions.dart'
    show ftHandicapMarketIds;
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/sport/match/match_notice_rive_animation.dart';
import 'package:sun_sports/shared/widgets/live/live_consumers.dart';

class MobileStatisticsTableWidget extends StatelessWidget {
  final LeagueEventData eventData;
  final Animation<double>?
  pulseAnimation;
  final bool hideBottomBorderRadius;

  final String? leagueName;

  final MatchNoticeType? homeNotice;
  final MatchNoticeType? awayNotice;
  final int homeNoticeSeq;
  final int awayNoticeSeq;
  final VoidCallback? onHomeNoticeCompleted;
  final VoidCallback? onAwayNoticeCompleted;

  const MobileStatisticsTableWidget({
    super.key,
    required this.eventData,
    this.pulseAnimation,
    this.hideBottomBorderRadius = false,
    this.leagueName,
    this.homeNotice,
    this.awayNotice,
    this.homeNoticeSeq = 0,
    this.awayNoticeSeq = 0,
    this.onHomeNoticeCompleted,
    this.onAwayNoticeCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = hideBottomBorderRadius
        ? const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          )
        : BorderRadius.circular(16);

    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: AppColorStyles.backgroundTertiary,
          border: Border(
            top: BorderSide(
              color: const Color.fromRGBO(255, 255, 255, 0.12),
              width: 1.0,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leagueName != null && leagueName!.isNotEmpty) ...[
              _buildLeagueNameHeader(leagueName!),
              ImageHelper.load(
                path: AppIcons.hr,
                width: double.infinity,
                height: 2,
                fit: BoxFit.fill,
              ),
            ],
            Row(
              children: [
                Flexible(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            if (eventData.isLive && pulseAnimation != null)
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    AnimatedBuilder(
                                      animation: pulseAnimation!,
                                      builder: (context, child) {
                                        return Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFF5172)
                                                .withOpacity(
                                                  0.12 * pulseAnimation!.value,
                                                ),
                                            shape: BoxShape.circle,
                                          ),
                                        );
                                      },
                                    ),
                                    AnimatedBuilder(
                                      animation: pulseAnimation!,
                                      builder: (context, child) {
                                        return Container(
                                          width: 16,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFF5172)
                                                .withOpacity(
                                                  0.12 * pulseAnimation!.value,
                                                ),
                                            shape: BoxShape.circle,
                                          ),
                                        );
                                      },
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
                              )
                            else if (eventData.isLive)
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF5172),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            if (eventData.isLive) ...[
                              const SizedBox(width: 12),
                              Flexible(
                                child: LiveMatchTimeDisplay(
                                  eventId: eventData.eventId,
                                  initialMinute:
                                      eventData.minuteString.isNotEmpty
                                      ? eventData.minuteString
                                      : null,
                                  initialPeriod:
                                      eventData.gamePartEnum.displayName,
                                  style: AppTextStyles.paragraphSmall(
                                    color: AppColorStyles.contentSecondary,
                                  ),
                                  separator: const SizedBox(width: 12),
                                ),
                              ),
                            ],
                            if (!eventData.isLive) ...[
                              Text(
                                eventData.formattedTime,
                                style: AppTextStyles.paragraphSmall(
                                  color: AppColorStyles.contentSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      _buildTeamRow(
                        teamName: eventData.homeName,
                        logoUrl:
                            eventData.homeLogoFirst ??
                            eventData.homeLogoLast ??
                            '',
                        isUpperTeam: _ftHandicapPoints == 0
                            ? null
                            : _ftHandicapPoints < 0,
                        notice: homeNotice,
                        noticeSeq: homeNoticeSeq,
                        onNoticeCompleted: onHomeNoticeCompleted,
                      ),
                      _buildTeamRow(
                        teamName: eventData.awayName,
                        logoUrl:
                            eventData.awayLogoFirst ??
                            eventData.awayLogoLast ??
                            '',
                        isUpperTeam: _ftHandicapPoints == 0
                            ? null
                            : _ftHandicapPoints > 0,
                        notice: awayNotice,
                        noticeSeq: awayNoticeSeq,
                        onNoticeCompleted: onAwayNoticeCompleted,
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Row(
                    children: [
                      _buildStatColumn(
                        icon: ImageHelper.load(
                          path: AppIcons.phatGoc,
                          width: 20,
                          height: 20,
                        ),
                        homeValue: eventData.cornersHome,
                        awayValue: eventData.cornersAway,
                      ),
                      _buildStatColumn(
                        icon: ImageHelper.load(
                          path: AppIcons.iconYellowCard,
                          width: 20,
                          height: 20,
                        ),
                        homeValue: eventData.yellowCardsHome,
                        awayValue: eventData.yellowCardsAway,
                      ),
                      _buildStatColumn(
                        icon: ImageHelper.load(
                          path: AppIcons.iconRedCard,
                          width: 20,
                          height: 20,
                        ),
                        homeValue: eventData.redCardsHome,
                        awayValue: eventData.redCardsAway,
                      ),
                      _buildStatColumn(
                        icon: Text(
                          'H2',
                          style: AppTextStyles.labelXSmall(
                            color: AppColorStyles.contentPrimary,
                          ),
                        ),
                        homeValue: 0,
                        awayValue: 0,
                      ),
                      _buildStatColumn(
                        icon: ImageHelper.load(
                          path: AppIcons.iconSoccer,
                          width: 20,
                          height: 20,
                          fit: BoxFit.fill,
                        ),
                        homeValue: eventData.displayHomeScore,
                        awayValue: eventData.displayAwayScore,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeagueNameHeader(String leagueName) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.black,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      leagueName,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: AppTextStyles.paragraphXSmall(
        color: AppColorStyles.contentSecondary,
      ),
    ),
  );

  double get _ftHandicapPoints {
    for (final market in eventData.markets) {
      if (ftHandicapMarketIds.contains(market.marketId)) {
        return market.mainLineOdds?.pointsValue ?? 0;
      }
    }
    return 0;
  }

  Widget _buildTeamRow({
    required String teamName,
    required String logoUrl,
    bool? isUpperTeam,
    MatchNoticeType? notice,
    int noticeSeq = 0,
    VoidCallback? onNoticeCompleted,
  }) => Stack(
    alignment: Alignment.centerLeft,
    children: [
      Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: AppColorStyles.backgroundQuaternary),
        child: Row(
          children: [
            if (logoUrl.isNotEmpty)
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: ImageHelper.getSmallLogo(imageUrl: logoUrl, size: 28),
              )
            else
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: const Icon(
                  Icons.sports_soccer,
                  size: 20,
                  color: AppColorStyles.contentSecondary,
                ),
              ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                teamName,
                style: AppTextStyles.labelSmall(
                  color: isUpperTeam == true
                      ? AppColors.orange400
                      : AppColorStyles.contentPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      if (notice != null)
        Positioned.fill(
          child: MatchNoticeRiveAnimation(
            key: ValueKey('$notice-$noticeSeq'),
            type: notice,
            onCompleted: onNoticeCompleted,
          ),
        ),
    ],
  );

  Widget _buildStatColumn({
    required Widget icon,
    required int homeValue,
    required int awayValue,
  }) => Expanded(
    child: Container(
      color: AppColorStyles.backgroundTertiary,
      child: Column(
        children: [
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Center(child: icon),
          ),
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColorStyles.backgroundQuaternary,
            ),
            child: Center(
              child: Text(
                '$homeValue',
                style: AppTextStyles.labelSmall(
                  color: AppColorStyles.contentPrimary,
                ),
              ),
            ),
          ),
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColorStyles.backgroundQuaternary,
            ),
            child: Center(
              child: Text(
                '$awayValue',
                style: AppTextStyles.labelSmall(
                  color: AppColorStyles.contentPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
