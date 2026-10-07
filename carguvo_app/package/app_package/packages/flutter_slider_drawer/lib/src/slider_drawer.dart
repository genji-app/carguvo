import 'package:flutter/widgets.dart';
import 'package:flutter_slider_drawer/src/core/animation/animation_strategy.dart';
import 'package:flutter_slider_drawer/src/core/animation/slider_drawer_controller.dart';
import 'package:flutter_slider_drawer/src/core/appbar/slider_app_bar.dart';
import 'package:flutter_slider_drawer/src/core/slider_shadow.dart';
import 'package:flutter_slider_drawer/src/slider_shadow.dart';
import 'package:flutter_slider_drawer/src/slider_bar.dart';
import 'package:flutter_slider_drawer/src/slider_direction.dart';

class SliderDrawer extends StatefulWidget {
  final Widget slider;

  final Widget child;

  final int animationDuration;

  final double sliderOpenSize;

  final double sliderCloseSize;

  final bool isDraggable;

  final Widget? appBar;

  final SliderBoxShadow? sliderBoxShadow;

  final SlideDirection slideDirection;

  final Color? backgroundColor;

  const SliderDrawer(
      {Key? key,
      required this.slider,
      required this.child,
      this.isDraggable = true,
      this.animationDuration = 400,
      this.sliderOpenSize = 265,
      this.sliderCloseSize = 0,
      this.slideDirection = SlideDirection.leftToRight,
      this.sliderBoxShadow,
      this.appBar,
      this.backgroundColor})
      : super(key: key);

  @override
  SliderDrawerState createState() => SliderDrawerState();
}

class SliderDrawerState extends State<SliderDrawer>
    with TickerProviderStateMixin {
  late final SliderDrawerController _controller;
  late final Animation<double> _animation;
  late final AnimationStrategy _animationStrategy;

  bool get isDrawerOpen => _controller.animationController.isCompleted;

  AnimationController get animationController =>
      _controller.animationController;

  void toggle() => _controller.toggle();

  void openSlider() => _controller.openSlider();

  void closeSlider() => _controller.closeSlider();

  double get openSize => widget.sliderOpenSize;

  void startDragging() => _controller.startDragging();

  void updatePosition(double percent) => _controller.updatePosition(percent);

  void stopDragging() => _controller.stopDragging();

  @override
  void initState() {
    super.initState();
    _controller = SliderDrawerController(
      vsync: this,
      animationDuration: widget.animationDuration,
      slideDirection: widget.slideDirection,
    );

    _animation = Tween<double>(
      begin: widget.sliderCloseSize,
      end: widget.sliderOpenSize,
    ).animate(CurvedAnimation(
      parent: _controller.animationController,
      curve: Curves.decelerate,
      reverseCurve: Curves.decelerate,
    ));

    _animationStrategy = SliderAnimationStrategy();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            SliderBar(
              slideDirection: widget.slideDirection,
              sliderMenu: widget.slider,
              sliderMenuOpenSize: widget.sliderOpenSize,
            ),

            if (widget.sliderBoxShadow != null)
              SliderShadow(
                animationDrawerController: _controller.animationController,
                slideDirection: widget.slideDirection,
                sliderOpenSize: widget.sliderOpenSize,
                animation: _animation,
                sliderBoxShadow: widget.sliderBoxShadow!,
              ),

            AnimatedBuilder(
              animation: _controller.animationController,
              builder: (context, child) => Transform.translate(
                offset: _animationStrategy.getOffset(
                  widget.slideDirection,
                  _animation.value,
                ),
                child: child,
              ),
              child: GestureDetector(
                onHorizontalDragStart: widget.isDraggable
                    ? (details) => _handleDragStart(details)
                    : null,
                onHorizontalDragEnd: widget.isDraggable
                    ? (details) => _handleDragEnd(details)
                    : null,
                onHorizontalDragUpdate: widget.isDraggable
                    ? (details) => _handleDragUpdate(details, constraints)
                    : null,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: widget.backgroundColor ?? Color(0xFFFFFFFF),
                  child: Column(
                    children: [
                      AppBar(
                        slideDirection: widget.slideDirection,
                        animationDrawerController:
                            _controller.animationController,
                        appBar: widget.appBar,
                        onDrawerTap: _controller.toggle,
                      ),
                      Expanded(child: widget.child),
                    ],
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }

  void _handleDragStart(DragStartDetails details) {
    if (_animationStrategy.shouldStartDrag(
            details, context, widget.slideDirection) ||
        _controller.isDrawerOpen) {
      _controller.startDragging();
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    _controller.stopDragging();
  }

  void _handleDragUpdate(
      DragUpdateDetails details, BoxConstraints constraints) {
    _animationStrategy.handleDragUpdate(details, constraints, _controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
