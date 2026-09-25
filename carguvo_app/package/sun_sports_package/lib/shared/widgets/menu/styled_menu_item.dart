import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class StyledMenuItem extends StatelessWidget {
  const StyledMenuItem({
    super.key,
    this.leadingIcon,
    this.trailingIcon,
    this.child,
    this.onPressed,
    this.selected = false,
    this.minWidth = 160.0,
  });

  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final Widget? child;
  final VoidCallback? onPressed;
  final bool selected;
  final double minWidth;

  @override
  Widget build(BuildContext context) {
    return MenuItemButton(
      onPressed: SoundTap.wrap(onPressed),
      style: ButtonStyle(
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        ),
        minimumSize: WidgetStatePropertyAll(Size(minWidth, 0)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        foregroundColor: const WidgetStatePropertyAll(
          AppColorStyles.contentPrimary,
        ),
        backgroundColor: selected
            ? const WidgetStatePropertyAll(AppColorStyles.backgroundQuaternary)
            : null,
      ),
      leadingIcon: leadingIcon,
      trailingIcon: trailingIcon != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [trailingIcon!, const Gap(64)],
            )
          : null,
      child: child,
    );
  }
}
