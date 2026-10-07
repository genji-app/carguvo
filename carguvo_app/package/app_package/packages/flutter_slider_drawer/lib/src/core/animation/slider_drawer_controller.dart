import 'package:flutter/widgets.dart';
import 'package:flutter_slider_drawer/src/slider_direction.dart';

class SliderDrawerController extends ChangeNotifier {
  final AnimationController animationController;
  final SlideDirection slideDirection;

  final double openThreshold;

  final double closeThreshold;

  bool _isDragging = false;
  double _percent = 0.0;

  double _dragStartPercent = 0.0;

  SliderDrawerController({
    required TickerProvider vsync,
    required int animationDuration,
    required this.slideDirection,
    this.openThreshold = 0.3,
    this.closeThreshold = 0.2,
  }) : animationController = AnimationController(
            vsync: vsync, duration: Duration(milliseconds: animationDuration));

  bool get isDragging => _isDragging;

  bool get isDrawerOpen => animationController.isCompleted;

  bool get isHorizontalSlide =>
      slideDirection == SlideDirection.leftToRight ||
      slideDirection == SlideDirection.rightToLeft;

  void toggle() => isDrawerOpen ? closeSlider() : openSlider();

  void openSlider() => animationController.forward();

  void closeSlider() => animationController.reverse();

  void startDragging() {
    _isDragging = true;
    _dragStartPercent = animationController.value;
    notifyListeners();
  }

  void stopDragging() {
    if (!_isDragging) return;
    _isDragging = false;
    final startedOpen = _dragStartPercent > 0.5;
    final snapOpen = startedOpen
        ? _percent > (1.0 - closeThreshold)
        : _percent > openThreshold;
    snapOpen ? openSlider() : closeSlider();
    notifyListeners();
  }

  void updatePosition(double percent) {
    _percent = percent;
    animationController.value = percent;
    notifyListeners();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}
