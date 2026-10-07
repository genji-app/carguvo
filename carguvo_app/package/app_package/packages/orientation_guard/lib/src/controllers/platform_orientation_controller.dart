import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../models/orientation_apply_result.dart';
import '../models/orientation_policy.dart';
import '../strategies/orientation_strategy.dart';
import '../utils/orientation_log.dart';
import 'orientation_controller.dart';

class PlatformOrientationController extends ChangeNotifier implements OrientationController {
  PlatformOrientationController(this._strategy);

  final OrientationStrategy _strategy;

  OrientationPolicy? _lastAppliedPolicy;
  bool _isApplying = false;

  @override
  bool get isApplying => _isApplying;

  @override
  Future<OrientationApplyResult> apply(OrientationPolicy policy) async {
    if (_lastAppliedPolicy == policy) {
      orientationLog(
          '[OrientationController] apply: skipped (already active: ${policy.debugLabel ?? 'unnamed'})');
      return OrientationApplyResult.matched(policy);
    }

    final bool targetsAreIdentical = _lastAppliedPolicy != null &&
        listEquals(_lastAppliedPolicy!.targets, policy.targets);

    orientationLog('[OrientationController] apply: ${policy.debugLabel ?? 'unnamed'}');
    _isApplying = true;
    _lastAppliedPolicy = policy;
    _safeNotifyListeners();

    try {
      if (targetsAreIdentical) {
        orientationLog('[OrientationController] apply: platform strategy skipped (targets identical to previous)');
        return OrientationApplyResult.matched(policy);
      }
      final result = await _strategy.apply(policy);
      return result;
    } finally {
      _isApplying = false;
      _safeNotifyListeners();
    }
  }

  @override
  Future<OrientationApplyResult> restore([OrientationPolicy? previousPolicy]) async {
    if (_lastAppliedPolicy == previousPolicy && previousPolicy != null) {
      orientationLog(
          '[OrientationController] restore: skipped (already active: ${previousPolicy.debugLabel ?? 'none'})');
      return OrientationApplyResult.matched(previousPolicy);
    }

    final bool targetsAreIdentical = _lastAppliedPolicy != null &&
        previousPolicy != null &&
        listEquals(_lastAppliedPolicy!.targets, previousPolicy.targets);

    orientationLog(
        '[OrientationController] restore (previous: ${previousPolicy?.debugLabel ?? 'none'})');
    _isApplying = true;
    _lastAppliedPolicy = previousPolicy;
    _safeNotifyListeners();

    try {
      if (targetsAreIdentical) {
        orientationLog('[OrientationController] restore: platform strategy skipped (targets identical to previous)');
        return OrientationApplyResult.matched(previousPolicy);
      }
      final result = await _strategy.restore(previousPolicy);
      return result;
    } finally {
      _isApplying = false;
      _safeNotifyListeners();
    }
  }

  void _safeNotifyListeners() {
    if (!hasListeners) return;

    final scheduler = SchedulerBinding.instance;
    if (scheduler.schedulerPhase != SchedulerPhase.idle) {
      orientationLog('[OrientationController] deferring notifyListeners (phase: ${scheduler.schedulerPhase})');
      Future.microtask(() {
        if (hasListeners) notifyListeners();
      });
    } else {
      notifyListeners();
    }
  }

  @override
  bool isMatched({
    required OrientationPolicy policy,
    required Orientation currentOrientation,
  }) {
    return _strategy.isMatched(
      policy: policy,
      currentOrientation: currentOrientation,
    );
  }

  @override
  OrientationPolicy? get activePolicy => _lastAppliedPolicy;
}
