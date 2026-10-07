import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../axis_lock_horizontal_scroll.dart';
import '../snap_scroll_physics.dart';

abstract class CarouselInteractionStrategy {
  const CarouselInteractionStrategy();

  Widget wrapContainer(BuildContext context, {required Widget child});

  ScrollPhysics getScrollPhysics(double itemFullWidth);

  Widget wrapItem(Widget card, {required ScrollGestureAxisLock wheelAxisLock});

  Widget wrapCarousel({
    required Widget listView,
    required ScrollController controller,
    required double height,
  });

  bool get showNavigationControls;
}

class PointerDrivenCarouselStrategy extends CarouselInteractionStrategy {
  const PointerDrivenCarouselStrategy();

  @override
  Widget wrapContainer(BuildContext context, {required Widget child}) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(
        context,
      ).copyWith(dragDevices: PointerDeviceKind.values.toSet()),
      child: child,
    );
  }

  @override
  ScrollPhysics getScrollPhysics(double itemFullWidth) {
    return SnapScrollPhysics(
      itemWidth: itemFullWidth,
      parent: const BouncingScrollPhysics(),
    );
  }

  @override
  Widget wrapItem(Widget card, {required ScrollGestureAxisLock wheelAxisLock}) {
    return VerticalWheelForwarder(axisLock: wheelAxisLock, child: card);
  }

  @override
  Widget wrapCarousel({
    required Widget listView,
    required ScrollController controller,
    required double height,
  }) {
    return SizedBox(height: height, child: listView);
  }

  @override
  bool get showNavigationControls => true;
}

class GestureDrivenCarouselStrategy extends CarouselInteractionStrategy {
  const GestureDrivenCarouselStrategy();

  @override
  Widget wrapContainer(BuildContext context, {required Widget child}) {
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(double itemFullWidth) {
    return NeverScrollableScrollPhysics(
      parent: SnapScrollPhysics(
        itemWidth: itemFullWidth,
        parent: const ClampingScrollPhysics(),
      ),
    );
  }

  @override
  Widget wrapItem(Widget card, {required ScrollGestureAxisLock wheelAxisLock}) {
    return card;
  }

  @override
  Widget wrapCarousel({
    required Widget listView,
    required ScrollController controller,
    required double height,
  }) {
    return NotificationListener<ScrollNotification>(
      onNotification: (_) => true,
      child: SizedBox(
        height: height,
        child: AxisLockHorizontalScroll(
          controller: controller,
          child: listView,
        ),
      ),
    );
  }

  @override
  bool get showNavigationControls => true;
}
