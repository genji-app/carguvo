import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';

class MiniEmptyZonePanGestureRecognizer extends PanGestureRecognizer {
  MiniEmptyZonePanGestureRecognizer({required this.contentBox});

  final RenderBox? Function() contentBox;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    if (_hitsInteractiveChild(event.position)) {
      return;
    }
    super.addAllowedPointer(event);
    resolve(GestureDisposition.accepted);
  }

  bool _hitsInteractiveChild(Offset globalPos) {
    final box = contentBox();
    if (box == null || !box.attached) return false;
    final result = BoxHitTestResult();
    box.hitTest(result, position: box.globalToLocal(globalPos));
    return result.path.any((entry) => entry.target is RenderPointerListener);
  }
}
