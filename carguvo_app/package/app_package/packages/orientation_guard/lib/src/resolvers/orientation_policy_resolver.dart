import 'package:flutter/widgets.dart';

import '../models/orientation_policy.dart';

abstract class OrientationPolicyResolver<T> {
  const OrientationPolicyResolver();

  OrientationPolicy resolve(BuildContext context, T model);
}
