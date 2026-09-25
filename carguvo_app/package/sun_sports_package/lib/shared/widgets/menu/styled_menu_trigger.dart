import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class StyledMenuTrigger extends StatelessWidget {
  const StyledMenuTrigger({
    required this.label,
    super.key,
    this.leadingIcon,
    this.trailingIcon,
    this.onPressed,
    this.isOpen = false,
    this.minWidth = 160.0,
    this.maxWidth,
    this.height = 40.0,
  });

  final String label;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final VoidCallback? onPressed;
  final bool isOpen;
  final double minWidth;
  final double? maxWidth;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: SoundTap.wrap(onPressed),
      child: Container(
        height: height ?? 40.0,
        constraints: BoxConstraints(
          minWidth: minWidth,
          maxWidth: maxWidth ?? minWidth,
        ),
        decoration: BoxDecoration(
          color: AppColorStyles.backgroundPrimary,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                layoutBuilder: (currentChild, previousChildren) {
                  return Stack(
                    alignment: Alignment.centerLeft,
                    children: <Widget>[
                      ...previousChildren,
                      if (currentChild != null) currentChild,
                    ],
                  );
                },
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: Row(
                  key: ValueKey<String>(label),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (leadingIcon != null) ...[leadingIcon!, const Gap(8)],
                    Flexible(
                      child: Text(
                        label,
                        style: AppTextStyles.labelSmall(
                          color: AppColorStyles.contentPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (trailingIcon != null) ...[const Gap(8), trailingIcon!],
            const Gap(8),
            AnimatedRotation(
              turns: isOpen ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: ImageHelper.load(
                path: AppIcons.chevronDown,
                width: 20,
                height: 20,
                color: AppColorStyles.contentSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
