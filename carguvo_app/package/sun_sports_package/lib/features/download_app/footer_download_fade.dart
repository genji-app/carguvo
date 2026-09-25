import 'package:flutter/foundation.dart';

class FooterDownloadFade {
  FooterDownloadFade._();

  static final FooterDownloadFade instance = FooterDownloadFade._();

  static const double fadeDistance = 200;

  static const double floatingButtonInsetBottom = 60;

  static const double hitTestThreshold = 0.35;

  final ValueNotifier<double> opacity = ValueNotifier<double>(1);

  void report(double distance) {
    final next = (distance / fadeDistance).clamp(0.0, 1.0);
    if ((next - opacity.value).abs() < 0.005) return;
    opacity.value = next;
  }

  void reset() {
    if (opacity.value != 1) opacity.value = 1;
  }
}
