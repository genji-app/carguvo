import '../models/orientation_guard_config.dart';
import '../models/orientation_runtime_context.dart';
import '../strategies/orientation_strategy_resolver.dart';
import 'orientation_controller.dart';
import 'platform_orientation_controller.dart';

OrientationController createOrientationControllerV1({
  OrientationGuardConfig config = const OrientationGuardConfig(),
}) {
  final context = OrientationRuntimeContext.current();
  const resolver = OrientationStrategyResolver();
  final strategy = resolver.resolve(context, config: config);
  return PlatformOrientationController(strategy);
}
