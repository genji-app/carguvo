import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class ProfileActionButton extends StatelessWidget {
  const ProfileActionButton({
    required this.icon,
    required this.label,
    super.key,
    this.onPressed,
    this.isHighlighted = false,
  });

  final Widget icon;
  final Widget label;
  final VoidCallback? onPressed;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(12);
    final Color contentColor = isHighlighted
        ? AppColors.orange200
        : AppColorStyles.contentSecondary;
    final BorderSide side = isHighlighted
        ? const BorderSide(color: Color(0x33F9DBAF), width: 1)
        : BorderSide.none;

    bool isHovered(Set<WidgetState> states) {
      return states.any(
        (s) => [
          WidgetState.hovered,
          WidgetState.focused,
          WidgetState.pressed,
          WidgetState.selected,
        ].contains(s),
      );
    }

    final ButtonStyle buttonStyle =
        ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: borderRadius, side: side),
          backgroundColor: AppColorStyles.backgroundTertiary,
          fixedSize: const Size.fromHeight(74),
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          elevation: 0,
          side: side,
          foregroundColor: contentColor,
        ).copyWith(
          side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
            if (isHovered(states)) return side;
            return null;
          }),
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (isHovered(states)) return AppColorStyles.backgroundQuaternary;
            return null;
          }),
        );

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.12),
            offset: const Offset(0, 0.5),
            blurRadius: 0.5,
            blurStyle: BlurStyle.inner,
          ),
        ],
      ),
      child: ElevatedButton(
        style: buttonStyle,
        onPressed: SoundTap.wrap(onPressed),
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            if (isHighlighted) ...[
              Positioned.fill(
                child: ImageHelper.load(
                  path: AppImages.profileActionBg,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: borderRadius,
                  child: ImageHelper.load(
                    path: AppImages.activatedglow,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 2,
                children: [
                  icon,
                  DefaultTextStyle(
                    style: AppTextStyles.paragraphMedium(color: contentColor),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    child: label,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
