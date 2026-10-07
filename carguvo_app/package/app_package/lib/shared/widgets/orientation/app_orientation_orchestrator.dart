import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientation_guard/orientation_guard.dart';

import 'app_orientation_mismatch_view.dart';
import 'app_orientation_provider.dart';

class AppOrientationOrchestrator extends ConsumerWidget {
  const AppOrientationOrchestrator({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(orientationControllerProvider);
    final shortestSide = MediaQuery.sizeOf(context).shortestSide;
    final isMobile = shortestSide < 600.0;

    final isPortraitOnly = !kIsWeb || isMobile;
    final targets = isPortraitOnly
        ? DeviceOrientations.portrait
        : DeviceOrientations.both;

    final blockOnMismatch = kIsWeb;

    final defaultPolicy = OrientationPolicy(
      targets: targets,
      blockOnMismatch: blockOnMismatch,
      debugLabel: isPortraitOnly ? 'AppDefaultPortrait' : 'AppDefaultBoth',
    );

    return OrientationScope.root(
      controller: controller,
      blockOnMismatch: blockOnMismatch,
      defaultPolicy: defaultPolicy,
      config: orientationGuardConfig,
      mismatchBuilder: (context) =>
          AppOrientationMismatchView(policy: defaultPolicy),
      child: child,
    );
  }
}
