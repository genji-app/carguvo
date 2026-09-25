import 'package:flutter/widgets.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';

abstract final class ShellBottomMetrics {
  static const double navHeightFallback = 74.0;

  static const double floatingGap = 40.0;

  static final ValueNotifier<double> navHeight = ValueNotifier<double>(
    navHeightFallback,
  );

  static final ValueNotifier<double> navTopFromCanvasBottom =
      ValueNotifier<double>(navHeightFallback);

  static bool hasBottomNav(BuildContext context) =>
      !ResponsiveBuilder.isDesktop(context);

  static void publish({
    required double height,
    required double topFromCanvasBottom,
  }) {
    if (height > 0 && (height - navHeight.value).abs() > 0.5) {
      navHeight.value = height;
    }
    if (topFromCanvasBottom > 0 &&
        (topFromCanvasBottom - navTopFromCanvasBottom.value).abs() > 0.5) {
      navTopFromCanvasBottom.value = topFromCanvasBottom;
    }
  }
}
