import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class GradientRadioButton extends StatelessWidget {
  const GradientRadioButton({
    this.onChanged,
    this.child,
    this.selected = false,
    super.key,
  });

  final ValueChanged<bool>? onChanged;
  final Widget? child;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(100);
    const padding = EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    const unselectedButtonColor = AppColorStyles.backgroundTertiary;
    final iconTheme = IconTheme.of(context);

    Color surfaceColor = AppColorStyles.contentPrimary;
    Widget icon = const UnCheckedIcon();
    VoidCallback? onPressed = onChanged != null
        ? () => onChanged?.call(!selected)
        : null;

    if (selected) {
      surfaceColor = AppColors.yellow200;
      icon = const CheckedIcon();
      onPressed = null;
    }

    return SizedBox(
      height: 48,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: unselectedButtonColor,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius,
          ),
        ),
        child: Stack(
          children: [
            if (selected)
              Positioned.fill(
                child: ImageHelper.load(
                  path: AppIcons.tabActive,
                  fit: BoxFit.fitWidth,
                ),
              ),

            Padding(
              padding: padding,
              child: IconTheme(
                data: iconTheme.copyWith(color: surfaceColor, size: 16),
                child: DefaultTextStyle(
                  style: AppTextStyles.buttonSmall(color: surfaceColor),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      icon,
                      DefaultTextStyle(
                        style: AppTextStyles.buttonSmall(color: surfaceColor),
                        child: Center(child: child),
                      ),
                      const SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox.expand(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: surfaceColor,
                  shape: RoundedRectangleBorder(borderRadius: borderRadius),
                ),
                onPressed: SoundTap.wrap(onPressed),
                child: const SizedBox.expand(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CheckedIcon extends StatelessWidget {
  const CheckedIcon({super.key});
  @override
  Widget build(BuildContext context) => Container(
    width: 16,
    height: 16,
    clipBehavior: Clip.antiAlias,
    decoration: ShapeDecoration(
      color: const Color(0xFFFAC414) ,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
    ),
    child: Stack(
      children: [
        Positioned(
          left: 5,
          top: 5,
          child: Container(
            width: 6,
            height: 6,
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: const Color(0xFF1B1A19) ,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class UnCheckedIcon extends StatelessWidget {
  const UnCheckedIcon({super.key});

  @override
  Widget build(BuildContext context) =>
      ImageHelper.load(path: AppIcons.checkboxBaseOutline);
}
