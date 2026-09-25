import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';

class AppTheme {
  static ThemeData light() => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColorStyles.backgroundPrimary,
    ),
    useMaterial3: true,
    brightness: Brightness.light,
  );

  static ThemeData dark() => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColorStyles.backgroundPrimary,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
    brightness: Brightness.dark,
  );
}
