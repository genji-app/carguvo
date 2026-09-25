import 'package:flutter/material.dart';

import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class TaiXiuSquareButton extends StatelessWidget {
  final String? iconPath;
  final IconData? icon;
  final VoidCallback onTap;
  final double size;
  final double iconSize;

  const TaiXiuSquareButton({
    required this.onTap,
    this.iconPath,
    this.icon,
    this.size = 32,
    this.iconSize = 16,
    super.key,
  });

  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: SoundTap.wrap(onTap),
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColorStyles.backgroundTertiary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColorStyles.borderTertiary),
        ),
        child: iconPath != null
            ? ImageHelper.load(
                path: iconPath!,
                width: iconSize,
                height: iconSize,
                color: AppColorStyles.contentSecondary,
              )
            : Icon(icon, size: iconSize, color: AppColorStyles.contentSecondary),
      ),
    ),
  );
}
