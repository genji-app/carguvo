import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';

class StyledTextField extends StatelessWidget {
  const StyledTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.label,
    this.hintText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.prefix,
    this.suffix,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.textStyle,
    this.contentPadding = const EdgeInsets.symmetric(vertical: 8),
    this.filled = false,
    this.fillColor,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.autofocus = false,
    this.focusNode,
    this.hoverColor,
    this.borderRadius,
    this.inputFormatters,
    this.isDense = false,
  });

  final TextEditingController? controller;

  final String? initialValue;

  final Widget? label;

  final String? hintText;

  final String? errorText;

  final Widget? prefixIcon;

  final Widget? suffixIcon;

  final Widget? prefix;

  final Widget? suffix;

  final bool obscureText;

  final bool enabled;

  final bool readOnly;

  final int? maxLines;

  final int? minLines;

  final TextStyle? textStyle;

  final EdgeInsetsGeometry? contentPadding;

  final bool filled;

  final Color? fillColor;

  final ValueChanged<String>? onChanged;

  final ValueChanged<String>? onSubmitted;

  final VoidCallback? onTap;

  final FormFieldValidator<String>? validator;

  final TextInputType? keyboardType;

  final TextInputAction? textInputAction;

  final bool autofocus;

  final FocusNode? focusNode;

  final Color? hoverColor;

  final BorderRadius? borderRadius;

  final List<TextInputFormatter>? inputFormatters;

  final bool isDense;

  @override
  Widget build(BuildContext context) {
    Widget? errorWidget;
    if (errorText != null && errorText!.isNotEmpty) {
      errorWidget = Container(
        margin: const EdgeInsets.only(top: 8),
        child: Text(errorText!, style: _StyledTextFieldTheme.errorTextStyle),
      );
    }

    final decoration = _StyledTextFieldTheme.createTextFieldDecoration(
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      prefix: prefix,
      suffix: suffix,
      contentPadding: contentPadding,
      filled: filled,
      fillColor: fillColor,
      hoverColor: hoverColor,
      borderRadius: borderRadius,
      isDense: isDense,
    ).copyWith(error: errorWidget);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        if (label != null)
          DefaultTextStyle(
            style: _StyledTextFieldTheme.labelStyle,
            child: label!,
          ),
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          focusNode: focusNode,
          autofocus: autofocus,
          enabled: enabled,
          readOnly: readOnly,
          obscureText: obscureText,
          obscuringCharacter: '●',
          maxLines: maxLines,
          minLines: minLines,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          cursorColor: _StyledTextFieldTheme.surfaceColor,
          style: textStyle ?? _StyledTextFieldTheme.inputTextStyle,
          decoration: decoration,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          onTap: onTap,
          inputFormatters: inputFormatters,
        ),
        if (errorWidget != null) errorWidget,
      ],
    );
  }
}

class _StyledTextFieldTheme {
  _StyledTextFieldTheme._();

  static final borderRadius = BorderRadius.circular(12);

  static const borderColor = AppColorStyles.borderPrimary;

  static const errorColor = AppColors.red500;

  static const focusColor = AppColors.yellow300;

  static const surfaceColor = AppColorStyles.contentPrimary;

  static const backgroundColor = Colors.transparent;

  static TextStyle get labelStyle =>
      AppTextStyles.headingXXXSmall(color: surfaceColor);

  static TextStyle get inputTextStyle =>
      AppTextStyles.paragraphMedium(color: surfaceColor);

  static TextStyle get errorTextStyle =>
      AppTextStyles.paragraphMedium(color: errorColor);

  static TextStyle get hintTextStyle =>
      AppTextStyles.paragraphMedium(color: AppColorStyles.contentTertiary);

  static InputDecoration createTextFieldDecoration({
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    Widget? prefix,
    Widget? suffix,
    EdgeInsetsGeometry? contentPadding,
    bool filled = false,
    Color? fillColor,
    Color? hoverColor,
    BorderRadius? borderRadius,
    bool isDense = false,
  }) {
    const borderSide = BorderSide(color: borderColor);
    final border = OutlineInputBorder(
      borderSide: borderSide,
      borderRadius: borderRadius ?? _StyledTextFieldTheme.borderRadius,
    );

    final errorSide = borderSide.copyWith(color: errorColor, width: 2);
    final focusedSide = borderSide.copyWith(color: focusColor, width: 2);

    final errorBorder = border.copyWith(borderSide: errorSide);
    final focusedBorder = border.copyWith(borderSide: focusedSide);

    return InputDecoration(
      contentPadding: contentPadding,
      isDense: isDense,
      fillColor: fillColor ?? backgroundColor,
      filled: filled,
      errorStyle: errorTextStyle,
      hoverColor: hoverColor ?? (filled ? fillColor : focusColor),
      focusColor: focusColor,
      border: border,
      enabledBorder: border,
      focusedBorder: focusedBorder,
      errorBorder: errorBorder,
      focusedErrorBorder: errorBorder,
      hintText: hintText,
      hintStyle: hintTextStyle,
      iconColor: surfaceColor,
      prefixIconColor: surfaceColor,
      suffixIconColor: surfaceColor,
      prefixIcon: prefixIcon != null
          ? Padding(
              padding: const EdgeInsets.only(left: 14, right: 8),
              child: prefixIcon,
            )
          : null,
      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      suffixIcon: suffixIcon != null
          ? Padding(
              padding: const EdgeInsets.only(left: 8, right: 14),
              child: suffixIcon,
            )
          : null,
      suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      prefix: prefix ?? (prefixIcon == null ? const SizedBox(width: 14) : null),
      suffix: suffix ?? (suffixIcon == null ? const SizedBox(width: 14) : null),
    );
  }
}
