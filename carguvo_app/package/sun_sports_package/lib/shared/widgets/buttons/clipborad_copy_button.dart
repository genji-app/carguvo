import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class ClipboradCopyField extends StatelessWidget {
  const ClipboradCopyField({
    required this.copyvalue,
    super.key,
    this.style,
    this.child,
    this.spacing = 0.0,
  }) : _showLabel = true;

  const ClipboradCopyField.withLabel({
    required this.copyvalue,
    Widget? label,
    super.key,
    this.style,
    this.spacing = 12.0,
  }) : _showLabel = true,
       child = label;

  const ClipboradCopyField.iconButton({
    required this.copyvalue,
    super.key,
    this.style,
    this.child,
    this.spacing = 12.0,
  }) : _showLabel = false;

  final TextStyle? style;
  final Widget? child;
  final double spacing;
  final String copyvalue;
  final bool _showLabel;

  @override
  Widget build(BuildContext context) {
    Future<void> onPressed() async {
      if (copyvalue.isEmpty) return;
      try {
        await Clipboard.setData(ClipboardData(text: copyvalue));
        if (!context.mounted) return;
        await AppToast.showSuccess(
          context,
          message: 'Đã sao chép vào clipboard',
        );
      } catch (_) {
      }
    }

    final copyButton = _ClipboradCopyButton(onPressed: onPressed);
    if (!_showLabel) return copyButton;

    final color = AppColorStyles.contentPrimary;
    final defaultStyle = AppTextStyles.labelMedium(color: color);
    final effectiveStyle = style != null
        ? style!.merge(defaultStyle)
        : defaultStyle;

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: spacing,
      children: [
        if (child != null)
          DefaultTextStyle(
            style: effectiveStyle,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            child: child!,
          ),
        copyButton,
      ],
    );
  }
}

class _ClipboradCopyButton extends StatelessWidget {
  const _ClipboradCopyButton({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    );

    return SizedBox.square(
      dimension: 28,
      child: IconButton(
        onPressed: SoundTap.wrap(onPressed),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        color: AppColorStyles.contentSecondary,
        icon: ImageHelper.load(path: AppIcons.icCopy),
        style: IconButton.styleFrom(
          backgroundColor: AppColorStyles.backgroundQuaternary,
          shape: shape,
          iconSize: 16,
        ),
      ),
    );
  }
}
