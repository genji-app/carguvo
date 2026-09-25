import 'package:flutter/material.dart';
import 'package:sun_sports/core/services/models/api_v2/event_model_v2_extensions.dart'
    show ftHandicapMarketIds;
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/wallet/inner_shadow.dart';
import 'package:sun_sports/shared/widgets/bet_details/models/betting_popup_data.dart';
import 'package:sun_sports/shared/widgets/live/live_consumers.dart';

class MatchStatsTable extends StatelessWidget {
  final BettingPopupData? data;
  final bool isVibrating;

  const MatchStatsTable({super.key, this.data, this.isVibrating = false});

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InnerShadow(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColorStyles.backgroundTertiary,
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: isVibrating
                        ? null
                        : BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(4),
                          ),
                    child: Text(
                      data?.leagueData?.leagueName ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.paragraphXSmall(
                        color: AppColorStyles.contentSecondary,
                      ),
                    ),
                  ),
                  ImageHelper.load(
                    path: AppIcons.hr,
                    width: double.infinity,
                    height: 2,
                    fit: BoxFit.fill,
                  ),
                  Row(
                    children: [
                      Flexible(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  if (data?.isLive == true) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: AppColors.red500,
                                      ),
                                      child: Text(
                                        'Trực tiếp',
                                        style:
                                            AppTextStyles.labelXXSmall(
                                              color:
                                                  AppColorStyles.contentPrimary,
                                            ).copyWith(
                                              fontWeight: FontWeight.w600,
                                              height: 1.50,
                                              fontSize: 12,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Flexible(
                                      child: LiveMatchTimeDisplay(
                                        eventId: data!.eventData.eventId,
                                        sportId: data!.sportId,
                                        initialMinute:
                                            data!.eventData.minuteString.isNotEmpty
                                            ? data!.eventData.minuteString
                                            : null,
                                        initialPeriod:
                                            data!.eventData.gamePartEnum.displayName,
                                        style: AppTextStyles.paragraphSmall(
                                          color: AppColorStyles.contentSecondary,
                                        ),
                                        separator: const SizedBox(width: 6),
                                      ),
                                    ),
                                  ] else
                                    Text(
                                      data!.eventData.formattedTime,
                                      style: AppTextStyles.paragraphSmall(
                                        color: AppColorStyles.contentSecondary,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            _buildTeamRow(
                              teamName: data?.getHomeName() ?? 'Home',
                              logoPath: data?.homeLogo,
                              isUpperTeam: _ftHandicapPoints == 0
                                  ? null
                                  : _ftHandicapPoints < 0,
                              stats: [
                                data?.cornersHome ?? 0,
                                data?.yellowCardsHome ?? 0,
                                data?.redCardsHome ?? 0,
                                data?.eventData.homeScore ?? 0,
                              ],
                            ),
                            _buildTeamRow(
                              teamName: data?.getAwayName() ?? 'Away',
                              logoPath: data?.awayLogo,
                              isUpperTeam: _ftHandicapPoints == 0
                                  ? null
                                  : _ftHandicapPoints > 0,
                              stats: [
                                data?.cornersAway ?? 0,
                                data?.yellowCardsAway ?? 0,
                                data?.redCardsAway ?? 0,
                                data?.eventData.awayScore ?? 0,
                              ],
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: Row(
                          children: [
                            _buildStatColumn(
                              icon: _buildCornerKickIcon(),
                              values: [
                                data?.cornersHome ?? 0,
                                data?.cornersAway ?? 0,
                              ],
                            ),
                            _buildStatColumn(
                              icon: _buildYellowCardIcon(),
                              values: [
                                data?.yellowCardsHome ?? 0,
                                data?.yellowCardsAway ?? 0,
                              ],
                            ),
                            _buildStatColumn(
                              icon: _buildRedCardIcon(),
                              values: [
                                data?.redCardsHome ?? 0,
                                data?.redCardsAway ?? 0,
                              ],
                            ),
                            _buildStatColumn(
                              icon: _buildFootballIcon(),
                              values: [
                                data?.eventData.homeScore ?? 0,
                                data?.eventData.awayScore ?? 0,
                              ],
                              highlighted: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  double get _ftHandicapPoints {
    for (final market in data?.eventData.markets ?? const <LeagueMarketData>[]) {
      if (ftHandicapMarketIds.contains(market.marketId)) {
        return market.mainLineOdds?.pointsValue ?? 0;
      }
    }
    return 0;
  }

  Widget _buildTeamRow({
    required String teamName,
    required List<int> stats,
    String? logoPath,
    bool? isUpperTeam,
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(color: AppColorStyles.backgroundQuaternary),
    child: Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: logoPath != null && logoPath.isNotEmpty
              ? ImageHelper.load(
                  path: logoPath,
                  width: 28,
                  height: 28,
                  fit: BoxFit.cover,
                )
              : const SizedBox(width: 28, height: 28),
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
  );

  Widget _buildStatColumn({
    required Widget icon,
    required List<int> values,
    bool highlighted = false,
  }) => Expanded(
    child: Container(
      color: AppColorStyles.backgroundTertiary,
      child: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                child: Center(child: icon),
              ),
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColorStyles.backgroundQuaternary,
                ),
                child: Center(
                  child: Text(
                    '${values[0]}',
                    style: AppTextStyles.labelSmall(
                      color: AppColorStyles.contentPrimary,
                    ),
                  ),
                ),
              ),
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColorStyles.backgroundQuaternary,
                ),
                child: Center(
                  child: Text(
                    '${values[1]}',
                    style: AppTextStyles.labelSmall(
                      color: AppColorStyles.contentPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (highlighted)
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: IgnorePointer(
                    child: Container(
                      width: 28,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        border: Border.all(color: AppColors.gray500, width: 2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );

  Widget _buildCornerKickIcon() =>
      ImageHelper.load(path: AppIcons.phatGoc, width: 20, height: 20);

  Widget _buildYellowCardIcon() =>
      ImageHelper.load(path: AppIcons.iconYellowCard, width: 20, height: 20);

  Widget _buildRedCardIcon() =>
      ImageHelper.load(path: AppIcons.iconRedCard, width: 20, height: 20);

  Widget _buildFootballIcon() =>
      ImageHelper.load(path: AppIcons.iconSoccer, width: 20, height: 20);
}
