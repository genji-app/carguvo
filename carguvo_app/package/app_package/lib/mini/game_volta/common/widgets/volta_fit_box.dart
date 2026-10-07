import 'package:flutter/material.dart';

class VoltaFitBox extends StatelessWidget {
  const VoltaFitBox({
    required this.designHeight,
    required this.child,
    this.aspectBlockRatio = 0,
    this.minScale = 0.75,
    super.key,
  });

  static const double noScroll = 0;

  final double designHeight;

  final double aspectBlockRatio;

  final double minScale;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double available = constraints.maxHeight;
        final double width = constraints.maxWidth;
        if (!available.isFinite || !width.isFinite) return child;

        final double scale = aspectBlockRatio <= 0
            ? available / designHeight
            : (available - aspectBlockRatio * width) / designHeight;

        final bool scrolls = scale < minScale;
        final double effScale = scale.clamp(minScale, 1.0);

        final double contentHeight = scrolls
            ? designHeight * minScale + aspectBlockRatio * width
            : available;

        return SizedBox(
          width: width,
          height: available,
          child: SingleChildScrollView(
            physics: scrolls
                ? const ClampingScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            child: SizedBox(
              width: width,
              height: contentHeight,
              child: FittedBox(
                fit: BoxFit.contain,
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: width / effScale,
                  height: contentHeight / effScale,
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
