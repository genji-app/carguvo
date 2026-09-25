import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

enum SecondaryButtonSize {
  xs(
    minimumSize: Size(28, 28),
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  ),
  sm(
    minimumSize: Size(36, 36),
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),
  md(
    minimumSize: Size(40, 40),
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
  ),
  lg(
    minimumSize: Size(44, 44),
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
  ),
  xl(
    minimumSize: Size(48, 48),
    padding: EdgeInsets.symmetric(horizontal: 28, vertical: 8),
  );

  const SecondaryButtonSize({required this.minimumSize, required this.padding});

  final Size minimumSize;
  final EdgeInsetsGeometry padding;

  TextStyle get textStyle => switch (this) {
    xs || sm => AppTextStyles.buttonSmall(),
    md || lg || xl => AppTextStyles.buttonMedium(),
  }.copyWith(height: 1.2);

  static BorderRadius borderRadius = BorderRadius.circular(100.0);
  static OutlinedBorder shape = RoundedRectangleBorder(
    borderRadius: borderRadius,
  );
}

enum SecondaryButtonTheme {
  yellow,
  gray;

  static const Color _disabledBackground = AppColorStyles.backgroundQuaternary;
  static const Color _disabledForeground = AppColorStyles.contentQuaternary;
  static const Color _focusBorderColor = AppColors.yellow500;

  WidgetStateProperty<Color?> get backgroundColorStates => switch (this) {
    yellow => WidgetStateProperty<Color?>.fromMap({
      WidgetState.disabled: _disabledBackground,
      WidgetState.pressed: AppColors.yellow300.withValues(alpha: 0.04),
      WidgetState.hovered: AppColors.yellow300.withValues(alpha: 0.12),
      WidgetState.focused: AppColors.yellow300.withValues(alpha: 0.12),
      WidgetState.any: AppColors.yellow300.withValues(alpha: 0.08),
    }),
    gray => const WidgetStateProperty<Color?>.fromMap({
      WidgetState.disabled: _disabledBackground,
      WidgetState.pressed: AppColors.gray600,
      WidgetState.hovered: AppColors.gray500,
      WidgetState.focused: AppColors.gray600,
      WidgetState.any: AppColors.gray600,
    }),
  };

  WidgetStateProperty<Color?> get foregroundColorStates => switch (this) {
    yellow => const WidgetStateProperty<Color?>.fromMap({
      WidgetState.disabled: _disabledForeground,
      WidgetState.any: AppColors.yellow200,
    }),
    gray => const WidgetStateProperty<Color?>.fromMap({
      WidgetState.disabled: _disabledForeground,
      WidgetState.any: AppColorStyles.contentPrimary,
    }),
  };

  WidgetStateProperty<BorderSide?> get borderSideStates =>
      const WidgetStateProperty<BorderSide?>.fromMap({
        WidgetState.focused: BorderSide(color: _focusBorderColor),
        WidgetState.any: BorderSide.none,
      });
}

class SecondaryButton extends StatelessWidget {

  const SecondaryButton.yellow({
    super.key,
    this.size = SecondaryButtonSize.md,
    this.onPressed,
    this.label,
    this.focusNode,
    this.autofocus = false,
    this.style,
  }) : theme = SecondaryButtonTheme.yellow;

  const SecondaryButton.gray({
    super.key,
    this.size = SecondaryButtonSize.md,
    this.onPressed,
    this.label,
    this.focusNode,
    this.autofocus = false,
    this.style,
  }) : theme = SecondaryButtonTheme.gray;

  final SecondaryButtonSize size;

  final VoidCallback? onPressed;
  final Widget? label;
  final FocusNode? focusNode;
  final bool autofocus;
  final SecondaryButtonTheme theme;

  final ButtonStyle? style;

  static double heightFor(SecondaryButtonSize size) => size.minimumSize.height;

  static Size minimumSizeFor(SecondaryButtonSize size) => size.minimumSize;

  static EdgeInsetsGeometry paddingFor(SecondaryButtonSize size) =>
      size.padding;

  static TextStyle textStyleFor(SecondaryButtonSize size) => size.textStyle;

  static BorderRadius borderRadius = SecondaryButtonSize.borderRadius;

  static ButtonStyle styleFrom({
    Size? minimumSize,
    Size? maximumSize,
    Size? fixedSize,
    EdgeInsetsGeometry? padding,

    Color? backgroundColor,
    Color? foregroundColor,
    Color? disabledBackgroundColor,
    Color? disabledForegroundColor,
    Color? overlayColor,
    Color? shadowColor,
    Color? surfaceTintColor,

    BorderSide? side,

    OutlinedBorder? shape,
    double? elevation,

    TextStyle? textStyle,

    MouseCursor? enabledMouseCursor,
    MouseCursor? disabledMouseCursor,
    VisualDensity? visualDensity,
    MaterialTapTargetSize? tapTargetSize,
    Duration? animationDuration,
    bool? enableFeedback,
    AlignmentGeometry? alignment,
    InteractiveInkFeatureFactory? splashFactory,
  }) {
    return ButtonStyle(
      minimumSize: minimumSize != null
          ? WidgetStatePropertyAll<Size?>(minimumSize)
          : null,
      maximumSize: maximumSize != null
          ? WidgetStatePropertyAll<Size?>(maximumSize)
          : null,
      fixedSize: fixedSize != null
          ? WidgetStatePropertyAll<Size?>(fixedSize)
          : null,
      padding: padding != null
          ? WidgetStatePropertyAll<EdgeInsetsGeometry?>(padding)
          : null,
      backgroundColor: backgroundColor != null
          ? WidgetStatePropertyAll<Color?>(backgroundColor)
          : null,
      foregroundColor: foregroundColor != null
          ? WidgetStatePropertyAll<Color?>(foregroundColor)
          : null,
      overlayColor: overlayColor != null
          ? WidgetStatePropertyAll<Color?>(overlayColor)
          : null,
      shadowColor: shadowColor != null
          ? WidgetStatePropertyAll<Color?>(shadowColor)
          : null,
      surfaceTintColor: surfaceTintColor != null
          ? WidgetStatePropertyAll<Color?>(surfaceTintColor)
          : null,
      side: side != null ? WidgetStatePropertyAll<BorderSide?>(side) : null,
      shape: shape != null
          ? WidgetStatePropertyAll<OutlinedBorder?>(shape)
          : null,
      elevation: elevation != null
          ? WidgetStatePropertyAll<double?>(elevation)
          : null,
      textStyle: textStyle != null
          ? WidgetStatePropertyAll<TextStyle?>(textStyle)
          : null,
      mouseCursor: enabledMouseCursor != null || disabledMouseCursor != null
          ? WidgetStateProperty<MouseCursor?>.fromMap({
              WidgetState.disabled: disabledMouseCursor,
              WidgetState.any: enabledMouseCursor,
            })
          : null,
      visualDensity: visualDensity,
      tapTargetSize: tapTargetSize,
      animationDuration: animationDuration,
      enableFeedback: enableFeedback,
      alignment: alignment,
      splashFactory: splashFactory,
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultStyle = ButtonStyle(
      minimumSize: WidgetStatePropertyAll<Size?>(size.minimumSize),
      padding: WidgetStatePropertyAll<EdgeInsetsGeometry?>(size.padding),

      visualDensity: VisualDensity.standard,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      overlayColor: const WidgetStatePropertyAll<Color?>(Colors.transparent),
      shadowColor: const WidgetStatePropertyAll<Color?>(Colors.transparent),
      elevation: const WidgetStatePropertyAll<double?>(0),
      shape: WidgetStatePropertyAll<OutlinedBorder?>(SecondaryButtonSize.shape),
      textStyle: WidgetStatePropertyAll<TextStyle?>(size.textStyle),

      backgroundColor: theme.backgroundColorStates,
      foregroundColor: theme.foregroundColorStates,
      side: theme.borderSideStates,
    );

    final mergedStyle = defaultStyle.merge(style);

    return ElevatedButton(
      autofocus: autofocus,
      focusNode: focusNode,
      onPressed: SoundTap.wrap(onPressed),
      style: mergedStyle,
      child: label ?? const SizedBox.shrink(),
    );
  }
}
