import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sun_sports/core/constants/breakpoints.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';

class AppTextStyles {
  AppTextStyles._();

  static const double _scaleMobile = 1.0;
  static const double _scaleTablet = 1.5;
  static const double _scaleDesktop = 1.1;

  static double _fontScale(BuildContext? context) {
    if (context == null) return _scaleMobile;
    final w = MediaQuery.sizeOf(context).width;
    if (w >= Breakpoints.desktop) return _scaleDesktop;
    if (w >= Breakpoints.mobile) return _scaleTablet;
    return _scaleMobile;
  }

  static double _fontSize(BuildContext? context, double base) =>
      base * _fontScale(context);

  static final Map<FontWeight, TextStyle> _fontByWeight = {};

  static TextStyle _base({
    required double fontSize,
    required FontWeight fontWeight,
    double? height,
    Color? color,
    double? letterSpacing,
    TextDecoration? decoration,
  }) {
    final base = _fontByWeight.putIfAbsent(
      fontWeight,
      () => GoogleFonts.plusJakartaSans(fontWeight: fontWeight),
    );
    return base.copyWith(
      fontSize: fontSize,
      height: height,
      color: color ?? AppColorStyles.backgroundPrimary,
      letterSpacing: letterSpacing ?? 0,
      decoration: decoration,
    );
  }

  static final Map<FontWeight, TextStyle> _interFontByWeight = {};

  static TextStyle inter({
    required double fontSize,
    required FontWeight fontWeight,
    BuildContext? context,
    double? height,
    Color? color,
    double? letterSpacing,
    TextDecoration? decoration,
  }) {
    final base = _interFontByWeight.putIfAbsent(
      fontWeight,
      () => GoogleFonts.inter(fontWeight: fontWeight),
    );
    return base.copyWith(
      fontSize: _fontSize(context, fontSize),
      height: height,
      color: color ?? AppColorStyles.backgroundPrimary,
      letterSpacing: letterSpacing ?? 0,
      decoration: decoration,
    );
  }

  static TextStyle headingXXLarge({
    BuildContext? context,
    Color? color,
    double? letterSpacing,
  }) => _base(
    fontSize: _fontSize(context, 48),
    height: 56 / 48,
    fontWeight: FontWeight.bold,
    color: color ?? AppColorStyles.backgroundPrimary,
    letterSpacing: letterSpacing ?? 0,
  );

  static TextStyle headingXLarge({
    BuildContext? context,
    Color? color,
    double? letterSpacing,
  }) => _base(
    fontSize: _fontSize(context, 40),
    height: 48 / 40,
    fontWeight: FontWeight.bold,
    color: color ?? AppColorStyles.backgroundPrimary,
    letterSpacing: letterSpacing ?? 0,
  );

  static TextStyle headingLarge({
    BuildContext? context,
    Color? color,
    double? letterSpacing,
  }) => _base(
    fontSize: _fontSize(context, 32),
    height: 40 / 32,
    fontWeight: FontWeight.bold,
    color: color ?? AppColorStyles.backgroundPrimary,
    letterSpacing: letterSpacing ?? 0,
  );

  static TextStyle headingMedium({
    BuildContext? context,
    Color? color,
    double? letterSpacing,
  }) => _base(
    fontSize: _fontSize(context, 28),
    height: 36 / 28,
    fontWeight: FontWeight.bold,
    color: color ?? AppColorStyles.backgroundPrimary,
    letterSpacing: letterSpacing ?? 0,
  );

  static TextStyle headingSmall({
    BuildContext? context,
    Color? color,
    double? letterSpacing,
  }) => _base(
    fontSize: _fontSize(context, 24),
    height: 32 / 24,
    fontWeight: FontWeight.bold,
    color: color ?? AppColorStyles.backgroundPrimary,
    letterSpacing: letterSpacing ?? 0,
  );

  static TextStyle headingXSmall({
    BuildContext? context,
    Color? color,
    double? letterSpacing,
  }) => _base(
    fontSize: _fontSize(context, 20),
    height: 28 / 20,
    fontWeight: FontWeight.bold,
    color: color ?? AppColorStyles.backgroundPrimary,
    letterSpacing: letterSpacing ?? 0,
  );

  static TextStyle headingXXSmall({
    BuildContext? context,
    Color? color,
    double? letterSpacing,
  }) => _base(
    fontSize: _fontSize(context, 18),
    height: 28 / 18,
    fontWeight: FontWeight.bold,
    color: color ?? AppColorStyles.backgroundPrimary,
    letterSpacing: letterSpacing ?? 0,
  );

  static TextStyle headingXXXSmall({
    BuildContext? context,
    Color? color,
    double? letterSpacing,
  }) => _base(
    fontSize: _fontSize(context, 16),
    height: 20 / 16,
    fontWeight: FontWeight.bold,
    color: color ?? AppColorStyles.backgroundPrimary,
    letterSpacing: letterSpacing ?? 0,
  );

  static TextStyle labelLarge({
    BuildContext? context,
    Color? color,
    double? letterSpacing,
  }) => _base(
    fontSize: _fontSize(context, 18),
    height: 28 / 18,
    fontWeight: FontWeight.bold,
    color: color ?? AppColorStyles.backgroundPrimary,
    letterSpacing: letterSpacing ?? 0,
  );

  static TextStyle labelMedium({
    BuildContext? context,
    Color? color,
    double? letterSpacing,
  }) => _base(
    fontSize: _fontSize(context, 16),
    height: 24 / 16,
    fontWeight: FontWeight.bold,
    color: color ?? AppColorStyles.backgroundPrimary,
    letterSpacing: letterSpacing ?? 0,
  );

  static TextStyle labelSmall({
    BuildContext? context,
    Color? color,
    double? letterSpacing,
  }) => _base(
    fontSize: _fontSize(context, 14),
    height: 20 / 14,
    fontWeight: FontWeight.bold,
    color: color ?? AppColorStyles.backgroundPrimary,
    letterSpacing: letterSpacing ?? 0,
  );

  static TextStyle labelXSmall({
    BuildContext? context,
    Color? color,
    double? letterSpacing,
  }) => _base(
    fontSize: _fontSize(context, 12),
    height: 18 / 12,
    fontWeight: FontWeight.bold,
    color: color ?? AppColorStyles.backgroundPrimary,
    letterSpacing: letterSpacing ?? 0,
  );

  static TextStyle labelXXSmall({
    BuildContext? context,
    Color? color,
    double? letterSpacing,
  }) => _base(
    fontSize: _fontSize(context, 10),
    height: 16 / 10,
    fontWeight: FontWeight.bold,
    color: color ?? AppColorStyles.backgroundPrimary,
    letterSpacing: letterSpacing ?? 0,
  );

  static TextStyle paragraphLarge({
    BuildContext? context,
    Color? color,
    double? letterSpacing,
  }) => _base(
    fontSize: _fontSize(context, 18),
    height: 28 / 18,
    fontWeight: FontWeight.w500,
    color: color ?? AppColorStyles.backgroundPrimary,
    letterSpacing: letterSpacing ?? 0,
  );

  static TextStyle paragraphMedium({
    BuildContext? context,
    Color? color,
    double? letterSpacing,
  }) => _base(
    fontSize: _fontSize(context, 16),
    height: 24 / 16,
    fontWeight: FontWeight.w500,
    color: color ?? AppColorStyles.backgroundPrimary,
    letterSpacing: letterSpacing ?? 0,
  );

  static TextStyle paragraphSmall({
    BuildContext? context,
    Color? color,
    double? letterSpacing,
  }) => _base(
    fontSize: _fontSize(context, 14),
    height: 20 / 14,
    fontWeight: FontWeight.w500,
    color: color ?? AppColorStyles.backgroundPrimary,
    letterSpacing: letterSpacing ?? 0,
  );

  static TextStyle paragraphXSmall({
    BuildContext? context,
    Color? color,
    double? letterSpacing,
  }) => _base(
    fontSize: _fontSize(context, 12),
    height: 18 / 12,
    fontWeight: FontWeight.w500,
    color: color ?? AppColorStyles.backgroundPrimary,
    letterSpacing: letterSpacing ?? 0,
  );

  static TextStyle paragraphXXSmall({
    BuildContext? context,
    Color? color,
    double? letterSpacing,
  }) => _base(
    fontSize: _fontSize(context, 10),
    height: 16 / 10,
    fontWeight: FontWeight.w500,
    color: color ?? AppColorStyles.backgroundPrimary,
    letterSpacing: letterSpacing ?? 0,
  );

  static TextStyle buttonLarge({
    BuildContext? context,
    Color? color,
    double? letterSpacing,
  }) => _base(
    fontSize: _fontSize(context, 18),
    height: 24 / 18,
    fontWeight: FontWeight.bold,
    color: color ?? AppColorStyles.backgroundPrimary,
    letterSpacing: letterSpacing ?? 0,
  );

  static TextStyle buttonMedium({
    BuildContext? context,
    Color? color,
    double? letterSpacing,
  }) => _base(
    fontSize: _fontSize(context, 16),
    height: 24 / 16,
    fontWeight: FontWeight.bold,
    color: color ?? AppColorStyles.backgroundPrimary,
    letterSpacing: letterSpacing ?? 0,
  );

  static TextStyle buttonSmall({
    BuildContext? context,
    Color? color,
    double? letterSpacing,
  }) => _base(
    fontSize: _fontSize(context, 14),
    height: 20 / 14,
    fontWeight: FontWeight.bold,
    color: color ?? AppColorStyles.backgroundPrimary,
    letterSpacing: letterSpacing ?? 0,
  );

  static TextStyle textStyle({
    BuildContext? context,
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    TextDecoration? decoration,
    double? letterSpacing,
  }) => _base(
    height: height,
    fontSize: fontSize != null
        ? _fontSize(context, fontSize)
        : _fontSize(context, 12),
    decoration: decoration,
    color: color,
    fontWeight: fontWeight ?? FontWeight.w500,
    letterSpacing: letterSpacing,
  );

  static TextStyle displayStyle({
    BuildContext? context,
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    TextDecoration? decoration,
    double? letterSpacing,
  }) => _base(
    height: height,
    fontSize: fontSize != null
        ? _fontSize(context, fontSize)
        : _fontSize(context, 12),
    decoration: decoration,
    color: color,
    fontWeight: fontWeight ?? FontWeight.w500,
    letterSpacing: letterSpacing,
  );
}
