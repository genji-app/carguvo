import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';

enum ShineButtonSize { small, medium, large, xl }

enum ShineButtonStyle {
  primaryGray(
    defaultColor: AppColors.gray950,
    hoverColor: AppColors.gray800,
    pressedColor: AppColors.gray700,
  ),

  primaryYellow(
    defaultColor: AppColors.yellow700,
    hoverColor: AppColors.yellow800,
    pressedColor: AppColors.yellow900,
  ),

  primaryYellowDark(
    defaultColor: AppColors.yellow950,
    hoverColor: AppColors.yellow900,
    pressedColor: AppColors.yellow950,
  ),

  primaryRed(
    defaultColor: AppColors.red700,
    hoverColor: AppColors.red800,
    pressedColor: AppColors.red900,
  ),

  primaryPurple(
    defaultColor: Color(0xFF692B69),
    hoverColor: Color(0xFF5A245A),
    pressedColor: Color(0xFF4A1D4A),
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFD161D2),
        Color(0xFF974297),
        Color(0xFF692B69),
        Color(0xFF561D53),
        Color(0xFF9A1D85),
      ],
      stops: [0, 0.25, 0.5, 0.75, 1],
    ),
  ),

  minigameGold(
    defaultColor: Color(0xFF554732),
    hoverColor: Color(0xFF493D2B),
    pressedColor: Color(0xFF3D3324),
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFBFA687),
        Color(0xFF7B6650),
        Color(0xFF554732),
        Color(0xFF463422),
        Color(0xFF886038),
      ],
      stops: [0, 0.25, 0.5, 0.75, 1],
    ),
  ),

  minigameRed(
    defaultColor: Color(0xFF783236),
    hoverColor: Color(0xFF682B2E),
    pressedColor: Color(0xFF572427),
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFCE8791),
        Color(0xFF985056),
        Color(0xFF783236),
        Color(0xFF6B2227),
        Color(0xFF95384C),
      ],
      stops: [0, 0.25, 0.5, 0.75, 1],
    ),
  );

  final Color defaultColor;
  final Color hoverColor;
  final Color pressedColor;

  final LinearGradient? gradient;

  const ShineButtonStyle({
    required this.defaultColor,
    required this.hoverColor,
    required this.pressedColor,
    this.gradient,
  });
}
