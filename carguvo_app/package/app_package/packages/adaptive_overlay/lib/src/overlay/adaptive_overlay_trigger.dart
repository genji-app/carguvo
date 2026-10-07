import 'package:flutter/widgets.dart';

import 'adaptive_overlay.dart';
import 'adaptive_overlay_controller.dart';

class AdaptiveOverlayTrigger extends StatelessWidget {
  const AdaptiveOverlayTrigger({required this.builder, super.key});

  final AdaptiveOverlayBuilder builder;

  @override
  Widget build(BuildContext context) {
    final controller = AdaptiveOverlay.of(context);

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => builder(context, controller),
    );
  }
}
