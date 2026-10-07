import 'package:flutter/widgets.dart';

import '../models/orientation_policy.dart';
import 'orientation_policy_resolver.dart';

class OrientationAdaptiveResolver extends OrientationPolicyResolver<void> {
  const OrientationAdaptiveResolver();

  static const double mobileBreakpoint = 600.0;

  static const double desktopBreakpoint = 900.0;

  static const mobilePortrait = OrientationPolicy(
    targets: DeviceOrientations.portrait,
    blockOnMismatch: true,
    debugLabel: 'AdaptiveDefaultPortrait',
  );

  static const both = OrientationPolicy(
    targets: DeviceOrientations.both,
    blockOnMismatch: false,
    debugLabel: 'AdaptiveDefaultBoth',
  );

  static const fallback = OrientationPolicy(
    targets: DeviceOrientations.both,
    blockOnMismatch: false,
    debugLabel: 'AdaptiveFallback',
  );

  @override
  OrientationPolicy resolve(BuildContext context, [void input]) {
    final mediaQuery = MediaQuery.maybeOf(context);
    if (mediaQuery == null) {
      return fallback;
    }

    final shortestSide = mediaQuery.size.shortestSide;
    final isMobile = shortestSide < mobileBreakpoint;

    return isMobile ? mobilePortrait : both;
  }
}
