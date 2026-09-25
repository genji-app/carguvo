import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/scroll_aware_controller.dart';

class ScrollBlockedTap extends StatelessWidget {
  const ScrollBlockedTap({
    super.key,
    required this.onTap,
    required this.child,
    this.behavior = HitTestBehavior.deferToChild,
    this.showClickCursor = false,
  });

  final VoidCallback? onTap;
  final Widget child;
  final HitTestBehavior behavior;

  final bool showClickCursor;

  @override
  Widget build(BuildContext context) {
    final tap = onTap;
    Widget result;
    if (tap == null) {
      result = GestureDetector(behavior: behavior, child: child);
    } else {
      result = RawGestureDetector(
        behavior: behavior,
        gestures: <Type, GestureRecognizerFactory>{
          _ScrollAwareTapRecognizer: GestureRecognizerFactoryWithHandlers<
              _ScrollAwareTapRecognizer>(
            () => _ScrollAwareTapRecognizer(debugOwner: this),
            (instance) => instance.onTap = tap,
          ),
        },
        child: child,
      );
    }
    if (showClickCursor) {
      result = MouseRegion(cursor: SystemMouseCursors.click, child: result);
    }
    return result;
  }
}

class _ScrollAwareTapRecognizer extends TapGestureRecognizer {
  _ScrollAwareTapRecognizer({super.debugOwner});

  @override
  bool isPointerAllowed(PointerDownEvent event) {
    if (ScrollAwareController.instance.isScrollActivityActive) return false;
    return super.isPointerAllowed(event);
  }
}
