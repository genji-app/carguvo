import 'package:flutter/material.dart';
import 'package:sun_sports/core/services/models/api_v2/sport_constants.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/scroll_aware_controller.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/scroll_deferred_mount.dart';
import 'package:sun_sports/shared/widgets/sport/match/match_notice_rive_animation.dart';

class TeamDisplay extends StatelessWidget {
  final String teamName;
  final String? teamLogo;
  final bool isHome;

  final String? otherTeamLogo;

  final int? sportId;

  final bool? isUpperTeam;

  final MatchNoticeType? notice;

  final int noticeSeq;

  final VoidCallback? onNoticeCompleted;

  const TeamDisplay({
    super.key,
    required this.teamName,
    this.teamLogo,
    this.otherTeamLogo,
    this.sportId,
    this.isHome = true,
    this.isUpperTeam,
    this.notice,
    this.noticeSeq = 0,
    this.onNoticeCompleted,
  });

  Widget _buildLogoSlot() {
    if (teamLogo?.isNotEmpty ?? false) {
      final logo = ImageHelper.getSmallLogo(
        imageUrl: teamLogo!,
        size: 28,
        borderRadius: 1000,
      );
      if (ScrollAwareController.instance.isScrolling &&
          !ImageHelper.isSmallLogoCached(imageUrl: teamLogo!, size: 28)) {
        return ScrollDeferredMount(
          placeholder: const SizedBox(width: 28, height: 28),
          child: logo,
        );
      }
      return logo;
    }
    if (!(otherTeamLogo?.isNotEmpty ?? false)) return const SizedBox.shrink();
    final iconPath = SportType.fromId(sportId ?? 0)?.iconPath ?? '';
    return SizedBox(
      width: 28,
      height: 28,
      child: iconPath.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.all(3),
              child: ImageHelper.load(path: iconPath, fit: BoxFit.contain),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              _buildLogoSlot(),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  teamName,
                  style: AppTextStyles.textStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: switch (isUpperTeam) {
                      true => AppColors.orange400,
                      false => AppColorStyles.contentPrimary,
                      null => const Color(0xFFFFFDE6),
                    },
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
              type: notice!,
              onCompleted: onNoticeCompleted,
            ),
          ),
      ],
    );
  }
}
