import '../models/orientation_guard_config.dart';
import 'orientation_controller.dart';

OrientationController createOrientationControllerV1({
  OrientationGuardConfig config = const OrientationGuardConfig(),
}) =>
    throw UnsupportedError(
      'Cannot create OrientationController without dart:html or dart:io',
    );
