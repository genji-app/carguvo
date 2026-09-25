import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/services/repositories/repositories.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class BetSlipCardFooter extends StatelessWidget {
  const BetSlipCardFooter({
    required this.betTime,
    required this.sport,
    this.onViewMatchTap,
    super.key,
  });

  final DateTime betTime;

  final SportType? sport;

  final VoidCallback? onViewMatchTap;

  static const String dateTimeFormat = 'HH:mm - dd/MM/yyyy';
  static String formatTimeTxt(DateTime time) =>
      DateFormat(dateTimeFormat).format(time);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: AppColorStyles.backgroundTertiary,
      child: Row(
        children: [
          Expanded(
            child: Text(
              formatTimeTxt(betTime),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.paragraphXSmall(
                color: AppColorStyles.contentTertiary,
              ),
            ),
          ),
          if (onViewMatchTap != null) ...[
            const Gap(8),
            _ViewMatchLink(onTap: onViewMatchTap!),
            const Gap(6),
            _SportIcon(sport: sport),
          ],
        ],
      ),
    );
  }
}

class _ViewMatchLink extends StatelessWidget {
  const _ViewMatchLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: SoundTap.wrap(onTap),
        behavior: HitTestBehavior.opaque,
        child: Text(
          I18n.txtViewMatch,
          maxLines: 1,
          softWrap: false,
          style: AppTextStyles.labelXSmall(color: AppColors.yellow300).copyWith(
            decoration: TextDecoration.underline,
            decorationColor: AppColors.yellow300,
          ),
        ),
      ),
    );
  }
}

class _SportIcon extends StatelessWidget {
  const _SportIcon({required this.sport});

  final SportType? sport;

  @override
  Widget build(BuildContext context) {
    final path = switch (sport) {
      SportType.basketball => AppIcons.iconBasketball,
      SportType.tennis => AppIcons.iconTennis,
      SportType.volleyball => AppIcons.iconVolleyball,
      SportType.tableTennis => AppIcons.iconTableTennis,
      SportType.badminton => AppIcons.iconBadminton,
      _ => AppIcons.iconSoccer,
    };
    return SizedBox.square(
      dimension: 16,
      child: ImageHelper.load(path: path),
    );
  }
}
