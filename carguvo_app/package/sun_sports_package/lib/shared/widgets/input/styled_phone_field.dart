import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'styled_text_field.dart';

class StyledPhoneField extends StatelessWidget {
  const StyledPhoneField({
    super.key,
    this.isEnabled = true,
    this.controller,
    this.label,
    this.errorText,
    this.onChanged,
    this.validator,
    this.initialValue,
    this.hintText,
    this.obscureText = false,
    this.onFieldSubmitted,
  });

  final TextEditingController? controller;

  final bool isEnabled;

  final Widget? label;

  final String? errorText;

  final ValueChanged<String>? onChanged;

  final FormFieldValidator<String>? validator;

  final String? initialValue;

  final String? hintText;

  final bool obscureText;

  final void Function(String)? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return StyledTextField(
      controller: controller,
      initialValue: initialValue,
      label: label,
      hintText: hintText,
      errorText: errorText,
      obscureText: obscureText,
      enabled: isEnabled,
      onChanged: onChanged,
      onSubmitted: onFieldSubmitted,
      validator: validator,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      prefix: const SizedBox.square(dimension: 14),
    );
  }
}
