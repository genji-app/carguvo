import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientation_guard/orientation_guard.dart';

const orientationGuardConfig = OrientationGuardConfig(
  forceEnforcementOnDesktopWeb: false,
);

final orientationControllerProvider = Provider<OrientationController>((ref) {
  return createOrientationControllerV1(config: orientationGuardConfig);
});
