import 'package:flutter/material.dart';

class SBDivider extends StatelessWidget {
  const SBDivider({
    super.key,
    this.height,
    this.endIndent,
    this.indent,
    this.thickness = 1,
    this.opacity = 0.2,
    this.colors,
  });

  const SBDivider.standard({
    super.key,
    this.height,
    this.endIndent = 12,
    this.indent = 12,
    this.thickness = 1,
    this.opacity = 0.2,
    this.colors,
  });

  const SBDivider.bottomNavigation({
    super.key,
    this.height = 0.5,
    this.endIndent = 14,
    this.indent = 14,
    this.thickness = 0.5,
    this.opacity = 0.1,
    this.colors,
  });

  const SBDivider.thin({
    super.key,
    this.height = 0.5,
    this.endIndent = 14,
    this.indent = 14,
    this.thickness = 0.5,
    this.opacity = 0.1,
    this.colors,
  });

  final double? height;
  final double? thickness;
  final double? indent;
  final double? endIndent;
  final double opacity;
  final List<Color>? colors;

  static final kColors = [Colors.white.withValues(alpha: 0.2), Colors.white];

  @override
  Widget build(BuildContext context) {
    final effectiveColors = colors ?? SBDivider.kColors;
    final shape = const RoundedRectangleBorder();
    final padding = EdgeInsetsDirectional.only(
      start: indent ?? 0,
      end: endIndent ?? 0,
    );

    return Container(
      height: height,
      padding: padding,
      child: Opacity(
        opacity: 0.2,
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: thickness,
                decoration: ShapeDecoration(
                  gradient: LinearGradient(colors: effectiveColors),
                  shape: shape,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: thickness,
                decoration: ShapeDecoration(
                  gradient: LinearGradient(
                    colors: effectiveColors.reversed.toList(),
                  ),
                  shape: shape,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
