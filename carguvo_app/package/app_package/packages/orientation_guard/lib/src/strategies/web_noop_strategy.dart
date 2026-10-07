import 'package:flutter/widgets.dart';

import '../models/orientation_apply_result.dart';
import '../models/orientation_experience.dart';
import '../models/orientation_guard_config.dart';
import '../models/orientation_policy.dart';
import '../utils/orientation_log.dart';
import 'orientation_strategy.dart';

class WebNoopStrategy implements OrientationStrategy {
  const WebNoopStrategy({
    this.config = const OrientationGuardConfig(),
  });

  final OrientationGuardConfig config;

  @override
  Future<OrientationApplyResult> apply(OrientationPolicy policy) async {
    return OrientationApplyResult.unsupported(
      policy,
      message: 'Orientation locking is not supported on Web.',
    );
  }

  @override
  Future<OrientationApplyResult> restore([OrientationPolicy? previousPolicy]) async {
    return OrientationApplyResult.unsupported(
      previousPolicy ?? const OrientationPolicy(targets: []),
      message: 'Orientation restoration is not supported on Web.',
    );
  }

  @override
  bool isMatched({
    required OrientationPolicy policy,
    required Orientation currentOrientation,
  }) {
    final isDesktop = isDesktopWebPlatform(config);

    final skipDesktop =
        isDesktop && policy.ignoreMismatchOnDesktop && !config.forceEnforcementOnDesktopWeb;

    orientationLog(
      '[WebNoopStrategy] isMatched: ${policy.debugLabel ?? 'unnamed'}, '
      'orientation: $currentOrientation, '
      'isDesktop: $isDesktop, '
      'forceEnforcement: ${config.forceEnforcementOnDesktopWeb}, '
      'skipDesktop: $skipDesktop',
    );

    if (skipDesktop) {
      return true;
    }

    final result = policy.targets.any((target) {
      if (target.isPortrait) {
        return currentOrientation == Orientation.portrait;
      }
      if (target.isLandscape) {
        return currentOrientation == Orientation.landscape;
      }
      return false;
    });

    orientationLog('[WebNoopStrategy] result: $result for policy: ${policy.debugLabel}');
    return result;
  }
}
