import 'package:flutter/widgets.dart';

import 'adaptive_overlay.dart';
import 'adaptive_overlay_controller.dart';

extension AdaptiveOverlayContextX on BuildContext {
  AdaptiveOverlayController? get adaptiveOverlayController =>
      AdaptiveOverlay.maybeOf(this);

  void openAdaptiveOverlay() => adaptiveOverlayController?.open();

  void closeAdaptiveOverlay() => adaptiveOverlayController?.close();

  void toggleAdaptiveOverlay() => adaptiveOverlayController?.toggle();
}
