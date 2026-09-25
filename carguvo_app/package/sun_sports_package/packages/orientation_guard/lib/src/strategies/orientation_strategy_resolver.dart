import 'package:flutter/foundation.dart';

import '../models/orientation_guard_config.dart';
import '../models/orientation_runtime_context.dart';
import 'direct_apply_strategy.dart';
import 'ios_orientation_strategy.dart';
import 'orientation_strategy.dart';
import 'web_noop_strategy.dart';

class OrientationStrategyResolver {
  const OrientationStrategyResolver({this.strategyOverride});

  final OrientationStrategy? strategyOverride;

  OrientationStrategy resolve(
    OrientationRuntimeContext context, {
    OrientationGuardConfig config = const OrientationGuardConfig(),
  }) {
    if (strategyOverride != null) return strategyOverride!;

    if (context.isWeb) {
      return WebNoopStrategy(config: config);
    }

    switch (context.platform) {
      case TargetPlatform.iOS:
        return const IosOrientationStrategy();
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        return const DirectApplyStrategy();
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return WebNoopStrategy(config: config);
    }
  }
}
