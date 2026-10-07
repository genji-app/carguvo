import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'orientation_guard_config.dart';

enum OrientationExperience {
  mobile,

  tablet,

  largeTablet,

  desktop;

  bool get canRotate => this != desktop;

  bool get usesResize => !canRotate;
}

class OrientationExperienceClassifier {
  const OrientationExperienceClassifier({
    this.mobileBreakpoint = 600.0,
    this.tabletBreakpoint = 1000.0,
    this.desktopBreakpoint = 1300.0,
  });

  static const standard = OrientationExperienceClassifier();

  final double mobileBreakpoint;

  final double tabletBreakpoint;

  final double desktopBreakpoint;

  OrientationExperience classify(BuildContext context, [OrientationGuardConfig? config]) {
    final override = config?.systemType ?? OrientationSystemType.auto;
    if (override != OrientationSystemType.auto) {
      switch (override) {
        case OrientationSystemType.mobile:
          return OrientationExperience.mobile;
        case OrientationSystemType.tablet:
          return OrientationExperience.tablet;
        case OrientationSystemType.desktop:
          return OrientationExperience.desktop;
        default:
          break;
      }
    }

    final shortestSide = MediaQuery.sizeOf(context).shortestSide;
    return classifyFromSize(shortestSide);
  }

  OrientationExperience classifyFromSize(double shortestSide) {
    if (shortestSide < mobileBreakpoint) {
      return OrientationExperience.mobile;
    }
    if (shortestSide < tabletBreakpoint) {
      return OrientationExperience.tablet;
    }
    if (shortestSide < desktopBreakpoint) {
      return OrientationExperience.largeTablet;
    }
    return OrientationExperience.desktop;
  }
}

bool isDesktopWebPlatform([OrientationGuardConfig? config]) {
  final override = config?.systemType ?? OrientationSystemType.auto;
  if (override != OrientationSystemType.auto) {
    return override == OrientationSystemType.desktop;
  }

  return defaultTargetPlatform != TargetPlatform.iOS &&
      defaultTargetPlatform != TargetPlatform.android;
}
