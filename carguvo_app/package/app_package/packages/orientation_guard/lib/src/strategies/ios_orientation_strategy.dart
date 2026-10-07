import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../models/orientation_apply_result.dart';
import '../models/orientation_policy.dart';
import 'orientation_strategy.dart';

class IosOrientationStrategy implements OrientationStrategy {
  const IosOrientationStrategy();

  @override
  Future<OrientationApplyResult> apply(OrientationPolicy policy) async {
    try {
      final targets = policy.targets.isEmpty ? DeviceOrientation.values : policy.targets;

      await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final isTransitioningToPortrait = targets.contains(DeviceOrientation.portraitUp) &&
          !targets.contains(DeviceOrientation.landscapeLeft);

      if (isTransitioningToPortrait) {
        await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }

      await SystemChrome.setPreferredOrientations(targets);

      return OrientationApplyResult.matched(policy);
    } catch (e) {
      return OrientationApplyResult(
        status: OrientationResultStatus.failed,
        policy: policy,
        canControlPlatform: true,
        message: e.toString(),
      );
    }
  }

  @override
  Future<OrientationApplyResult> restore([OrientationPolicy? previousPolicy]) async {
    if (previousPolicy != null) {
      return apply(previousPolicy);
    }

    final allOrientations = OrientationPolicy(
      targets: DeviceOrientation.values,
      debugLabel: 'Restore All',
    );
    return apply(allOrientations);
  }

  @override
  bool isMatched({
    required OrientationPolicy policy,
    required Orientation currentOrientation,
  }) {
    if (policy.targets.isEmpty) return true;

    if (currentOrientation == Orientation.portrait) {
      return policy.allowsPortrait;
    } else {
      return policy.allowsLandscape;
    }
  }
}
