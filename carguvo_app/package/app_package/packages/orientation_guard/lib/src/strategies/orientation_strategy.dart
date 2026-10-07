import 'package:flutter/widgets.dart';

import '../models/orientation_apply_result.dart';
import '../models/orientation_policy.dart';

abstract class OrientationStrategy {
  Future<OrientationApplyResult> apply(OrientationPolicy policy);

  Future<OrientationApplyResult> restore([OrientationPolicy? previousPolicy]);

  bool isMatched({
    required OrientationPolicy policy,
    required Orientation currentOrientation,
  });
}
