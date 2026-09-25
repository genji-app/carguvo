import 'package:flutter/widgets.dart';

mixin CarouselNavigationMixin {
  late final ValueNotifier<int> currentPageNotifier = ValueNotifier<int>(0);

  void handleScroll(double offset, double itemWidth, int itemCount) {
    if (itemWidth <= 0.0) return;
    final newPage = (offset / itemWidth).round().clamp(0, itemCount - 1);
    if (newPage != currentPageNotifier.value) {
      currentPageNotifier.value = newPage;
    }
  }

  void navigateToPage({
    required ScrollController controller,
    required int targetPage,
    required double itemWidth,
    required int itemCount,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    if (itemWidth <= 0.0 || !controller.hasClients) return;
    final clampedTarget = targetPage.clamp(0, itemCount - 1);
    controller.animateTo(
      clampedTarget * itemWidth,
      duration: duration,
      curve: curve,
    );
  }

  bool canGoNext({
    required int currentPage,
    required int itemCount,
    required double columns,
  }) {
    return currentPage < itemCount - columns;
  }

  bool canGoPrev({required int currentPage}) {
    return currentPage > 0;
  }
}
