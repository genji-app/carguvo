import 'package:flutter/material.dart';

import 'package:sun_sports/core/utils/extensions/currency_helper.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';

class CurrencyText extends StatelessWidget {
  const CurrencyText(
    this.text, {
    super.key,
    this.prefixText,
    this.prefix,
    this.suffix,
    this.amountColor,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.iconSize = 24.0,
    this.spacing = 4.0,
  });

  CurrencyText.fromNumber(
    num amount, {
    super.key,
    this.prefixText,
    this.prefix,
    this.suffix,
    this.amountColor,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.iconSize = 24.0,
    this.spacing = 4.0,
  }) : text = formatCurrency(amount);

  static Widget defaultSuffix({double size = 24.0}) =>
      CurrencySymbol(size: size);

  static const double defaultIconSize = 24.0;

  static const double defaultSpacing = 4.0;

  static String formatCurrency(num amount) =>
      CurrencyHelper.formatCurrencyNoUnit(amount);

  static String formatCurrencyWithUnit(num amount) {
    if (amount is int) {
      return CurrencyHelper.formatCurrencyInt(amount);
    }
    return CurrencyHelper.formatCurrencyDouble(amount.toDouble());
  }

  static String formatCurrencyString(String amount) =>
      CurrencyHelper.formatCurrency(amount);

  final String text;

  final String? prefixText;

  final Widget? prefix;

  final Widget? suffix;

  final Color? amountColor;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  final double iconSize;

  final double spacing;

  @override
  Widget build(BuildContext context) {
    final themeStyle = DefaultTextStyle.of(context).style;

    final effectiveSuffix = suffix ?? CurrencySymbol(size: iconSize);

    return Row(
      spacing: spacing,
      mainAxisSize: MainAxisSize.min,

      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (prefix != null) prefix!,

        Flexible(
          child: Text.rich(
            TextSpan(
              children: [
                if (prefixText != null) TextSpan(text: prefixText),
                TextSpan(text: text),
              ],
            ),

            style: themeStyle
                .merge(AppTextStyles.labelSmall(color: amountColor))
                .merge(style),
            maxLines: maxLines,
            textAlign: textAlign,
            overflow: overflow,
          ),
        ),

        effectiveSuffix,
      ],
    );
  }
}

class CurrencySymbol extends StatelessWidget {
  const CurrencySymbol({super.key, this.size = 24.0});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: ImageHelper.load(path: AppIcons.iconCurrencyUnit),
    );
  }
}
