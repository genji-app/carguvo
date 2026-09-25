import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class PasswordInputField extends ConsumerStatefulWidget {
  const PasswordInputField({
    super.key,
    this.isEnabled = true,
    this.controller,
    this.label,
    this.errorText,
    this.onChanged,
    this.validator,
    this.initialValue,
  });

  final TextEditingController? controller;
  final bool isEnabled;
  final Widget? label;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final String? initialValue;

  @override
  ConsumerState<PasswordInputField> createState() => _PasswordInputFieldState();
}

class _PasswordInputFieldState extends ConsumerState<PasswordInputField> {
  bool _obscureText = true;

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    const verticalPadding = EdgeInsets.symmetric(vertical: 8);

    const backgroundColor = AppColorStyles.backgroundSecondary;

    const surfaceColor = AppColorStyles.contentPrimary;

    final labelStyle = AppTextStyles.headingXXXSmall(color: surfaceColor);
    final borderRadius = BorderRadius.circular(12);
    final icon = !_obscureText
        ? Icons.visibility_off_outlined
        : Icons.visibility_outlined;

    const borderColor = AppColorStyles.borderSecondary;
    const errorColor = AppColors.red500;
    const focusColor = AppColors.yellow300;

    const borderSide = BorderSide(color: borderColor);
    final border = OutlineInputBorder(
      borderSide: borderSide,
      borderRadius: borderRadius,
    );

    final errorSide = borderSide.copyWith(color: errorColor, width: 2);
    final focusedSide = borderSide.copyWith(color: focusColor, width: 2);

    final errorBorder = border.copyWith(borderSide: errorSide);
    final focusedBorder = border.copyWith(borderSide: focusedSide);

    Widget? errorWidget;
    if (widget.errorText != null) {
      errorWidget = Container(
        margin: const EdgeInsets.only(top: 8),
        child: Text(widget.errorText!),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        if (widget.label != null)
          DefaultTextStyle(style: labelStyle, child: widget.label!),
        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          obscureText: _obscureText,
          cursorColor: surfaceColor,
          onChanged: widget.onChanged,
          validator: widget.validator,
          style: AppTextStyles.paragraphMedium(color: surfaceColor),
          obscuringCharacter: '●',
          decoration: InputDecoration(
            contentPadding: verticalPadding,

            fillColor: backgroundColor,
            filled: false,

            errorStyle: AppTextStyles.paragraphMedium(color: errorColor),
            error: errorWidget,

            hoverColor: focusColor,
            focusColor: focusColor,

            border: border,
            enabledBorder: border,
            focusedBorder: focusedBorder,
            errorBorder: errorBorder,
            focusedErrorBorder: errorBorder,

            hintStyle: AppTextStyles.paragraphMedium(
              color: AppColorStyles.contentTertiary,
            ),

            iconColor: surfaceColor,
            prefixIconColor: surfaceColor,
            suffixIconColor: surfaceColor,
            prefix: const SizedBox.square(dimension: 14),
            suffixIcon: IconButton(
              icon: Icon(icon, size: 20),
              onPressed: SoundTap.wrap(_toggleObscureText),
            ),
          ),
        ),
      ],
    );
  }
}
