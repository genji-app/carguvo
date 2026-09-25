import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';

class StyledPinput extends StatelessWidget {
  const StyledPinput({
    super.key,
    this.controller,
    this.length = 6,
    this.label,
    this.errorText,
    this.onChanged,
    this.onCompleted,
    this.validator,
    this.pinWidth,
    this.pinHeight,
    this.textStyle,
    this.backgroundColor,
    this.showCursor = true,
    this.enabled = true,
  });

  final TextEditingController? controller;

  final int length;

  final Widget? label;

  final String? errorText;

  final ValueChanged<String>? onChanged;

  final ValueChanged<String>? onCompleted;

  final FormFieldValidator<String>? validator;

  final double? pinWidth;

  final double? pinHeight;

  final TextStyle? textStyle;

  final Color? backgroundColor;

  final bool showCursor;

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = _StyledPinputTheme.createPinTheme(
      width: pinWidth,
      height: pinHeight,
      textStyle: textStyle,
      backgroundColor: backgroundColor,
    );

    final focusedPinTheme = _StyledPinputTheme.createFocusedPinTheme(
      defaultPinTheme,
    );

    final submittedPinTheme = defaultPinTheme;

    final errorPinTheme = _StyledPinputTheme.createErrorPinTheme(
      defaultPinTheme,
    );

    Widget? errorWidget;
    if (errorText != null && errorText!.isNotEmpty) {
      errorWidget = Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(errorText!, style: _StyledPinputTheme.errorTextStyle),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        if (label != null)
          DefaultTextStyle(style: _StyledPinputTheme.labelStyle, child: label!),
        Pinput(
          controller: controller,
          length: length,
          defaultPinTheme: defaultPinTheme,
          focusedPinTheme: focusedPinTheme,
          submittedPinTheme: submittedPinTheme,
          errorPinTheme: errorPinTheme,
          validator: validator,
          onCompleted: onCompleted,
          onChanged: onChanged,
          showCursor: showCursor,
          enabled: enabled,
          errorText: errorText,
          errorTextStyle: _StyledPinputTheme.errorTextStyle,
          cursor: showCursor ? _StyledPinputTheme.createCursor() : null,
        ),
        if (errorWidget != null) errorWidget,
      ],
    );
  }
}

class _StyledPinputTheme {
  _StyledPinputTheme._();

  static final borderRadius = BorderRadius.circular(12);

  static const borderColor = AppColorStyles.borderPrimary;

  static const errorColor = AppColors.red500;

  static const focusColor = AppColors.yellow300;

  static const surfaceColor = AppColorStyles.contentPrimary;

  static const backgroundColor = Colors.transparent;

  static TextStyle get labelStyle =>
      AppTextStyles.headingXXXSmall(color: surfaceColor);

  static TextStyle get inputTextStyle =>
      AppTextStyles.headingSmall(color: surfaceColor);

  static TextStyle get errorTextStyle =>
      AppTextStyles.paragraphMedium(color: errorColor);

  static PinTheme createPinTheme({
    double? width,
    double? height,
    TextStyle? textStyle,
    Color? backgroundColor,
  }) {
    return PinTheme(
      width: width ?? 56,
      height: height ?? 56,
      textStyle: textStyle ?? inputTextStyle,
      decoration: BoxDecoration(
        color: backgroundColor ?? _StyledPinputTheme.backgroundColor,
        border: Border.all(color: borderColor),
        borderRadius: borderRadius,
      ),
    );
  }

  static PinTheme createFocusedPinTheme(PinTheme baseTheme) {
    return baseTheme.copyWith(
      decoration: baseTheme.decoration?.copyWith(
        border: Border.all(color: focusColor, width: 2),
      ),
    );
  }

  static PinTheme createErrorPinTheme(PinTheme baseTheme) {
    return baseTheme.copyWith(
      decoration: baseTheme.decoration?.copyWith(
        border: Border.all(color: errorColor, width: 2),
      ),
    );
  }

  static Widget createCursor({double? width, double? height, Color? color}) {
    return Container(
      width: width ?? 2,
      height: height ?? 24,
      decoration: BoxDecoration(
        color: color ?? focusColor,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}
