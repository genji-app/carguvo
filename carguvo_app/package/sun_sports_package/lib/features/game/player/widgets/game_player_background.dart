import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';

class GamePlayerBackground extends StatelessWidget {
  const GamePlayerBackground({
    required this.child,
    this.backgroundColor,
    super.key,
  });

  final Widget child;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor ?? AppColorStyles.backgroundPrimary,
      child: child,
    );
  }
}
