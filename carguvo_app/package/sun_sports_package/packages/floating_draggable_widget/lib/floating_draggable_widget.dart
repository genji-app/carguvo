library floating_draggable_widget;

import 'package:flutter/material.dart';
enum AlignmentType {onlyRight, onlyLeft, both}
class FloatingDraggableWidget extends StatefulWidget {
  FloatingDraggableWidget({
    Key? key,
    required this.mainScreenWidget,
    required this.floatingWidget,
    required this.floatingWidgetWidth,
    required this.floatingWidgetHeight,
    this.onDragEvent,
    this.autoAlignType = AlignmentType.both,
    this.disableBounceAnimation = false,
    this.dy,
    this.dx,
    this.screenHeight,
    this.screenWidth,
    this.speed,
    this.deleteWidget,
    this.onDeleteWidget,
    this.bottom,
    this.right,
    this.dragActivationDelay = Duration.zero,
    this.isDraggable = true,
    this.autoAlign = false,
    this.deleteWidgetAlignment = Alignment.bottomCenter,
    this.deleteWidgetAnimationDuration = 200,
    this.hasDeleteWidgetAnimationDuration = 300,
    this.deleteWidgetAnimationCurve = Curves.easeIn,
    this.deleteWidgetHeight = 50,
    this.deleteWidgetWidth = 50,
    this.isCollidingDeleteWidgetHeight = 70,
    this.isCollidingDeleteWidgetWidth = 70,
    this.deleteWidgetDecoration,
    this.deleteWidgetPadding = const EdgeInsets.only(bottom: 8),
    this.resizeToAvoidBottomInset = true,
    this.backgroundColor,
    this.disablePositionAnimation = false,
    this.onDragging,
    this.widgetWhenDragging,
  }) : super(key: key);

  final Widget mainScreenWidget;
  final double floatingWidgetWidth;
  final double floatingWidgetHeight;
  final Widget floatingWidget;
  final double? dy;
  final double? dx;
  final double? bottom;

  final double? right;

  final Duration dragActivationDelay;
  final double? screenHeight;
  final double? screenWidth;
  final double? speed;
  final bool isDraggable;
  final bool autoAlign;
  final Widget? deleteWidget;
  final Function()? onDeleteWidget;
  final AlignmentGeometry deleteWidgetAlignment;
  final Curve deleteWidgetAnimationCurve;
  final int deleteWidgetAnimationDuration;
  final int hasDeleteWidgetAnimationDuration;
  final double deleteWidgetHeight;
  final double deleteWidgetWidth;
  final double isCollidingDeleteWidgetHeight;
  final double isCollidingDeleteWidgetWidth;
  final EdgeInsets? deleteWidgetPadding;
  final BoxDecoration? deleteWidgetDecoration;
  final AlignmentType autoAlignType;

  final bool disableBounceAnimation;

  Function(double dx, double dy)? onDragEvent;

  final Function(bool)? onDragging;

  final Widget? widgetWhenDragging;

  final bool disablePositionAnimation;

  final Color? backgroundColor;

  bool resizeToAvoidBottomInset;

  @override
  State<FloatingDraggableWidget> createState() =>
      _FloatingDraggableWidgetState();
}

class _FloatingDraggableWidgetState extends State<FloatingDraggableWidget>
    with SingleTickerProviderStateMixin {
  late double top, left;
  double? right = 20;
  double? bottom = 20;

  bool isTabbed = false;

  double appBarHeight = AppBar().preferredSize.height;

  bool isDragging = false;

  bool isDragEnable = true;

  late double width;
  late double height;

  bool isColliding = true;

  bool isRemoved = false;

  DateTime? _pressedAt;

  Offset? _grabOffset;

  bool get _dragAllowed =>
      widget.dragActivationDelay == Duration.zero ||
      (_pressedAt != null &&
          DateTime.now().difference(_pressedAt!) >=
              widget.dragActivationDelay);
  bool hasCollision(GlobalKey<State<StatefulWidget>> key1,
      GlobalKey<State<StatefulWidget>> key2) {
    final box1 = key1.currentContext?.findRenderObject() as RenderBox?;
    final box2 = key2.currentContext?.findRenderObject() as RenderBox?;
    if (box1 != null && box2 != null) {
      final position1 = box1.localToGlobal(Offset.zero);
      final position2 = box2.localToGlobal(Offset.zero);
      return position1.dx < position2.dx + box2.size.width &&
          position1.dx + box1.size.width > position2.dx &&
          position1.dy < position2.dy + box2.size.height &&
          position1.dy + box1.size.height > position2.dy;
    }
    return false;
  }

  @override
  void initState() {
    top = widget.dy ?? -1;
    left = widget.dx ?? -1;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    width = widget.screenWidth ?? MediaQuery.of(context).size.width;
    height = widget.screenHeight ?? MediaQuery.of(context).size.height;

    if (left != -1) {
      final maxLeft =
          (width - widget.floatingWidgetWidth).clamp(0.0, double.infinity);
      if (left > maxLeft) left = maxLeft;
      if (left < 0) left = 0;
    }
    if (top != -1) {
      final maxTop =
          (height - widget.floatingWidgetHeight).clamp(0.0, double.infinity);
      if (top > maxTop) top = maxTop;
      if (top < 0) top = 0;
    }

    final hasDeleteWidget = widget.deleteWidget != null;
    final containerKey1 = GlobalKey();
    final containerKey2 = GlobalKey();

    return Scaffold(
      backgroundColor: widget.backgroundColor,
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
      body: SizedBox(
          height: height,
          width: width,
          child: isRemoved
              ? widget.mainScreenWidget
              : Stack(
                  children: [
                    widget.mainScreenWidget,
                    if (hasDeleteWidget)
                      AnimatedSlide(
                        duration: Duration(
                          milliseconds: widget.hasDeleteWidgetAnimationDuration,
                        ),
                        offset: isDragging ? Offset.zero : const Offset(0, 2),
                        child: AnimatedOpacity(
                          opacity: isDragging ? 1.0 : 0.0,
                          duration: Duration(
                            milliseconds:
                                widget.hasDeleteWidgetAnimationDuration,
                          ),
                          child: Container(
                            padding: widget.deleteWidgetPadding,
                            decoration: widget.deleteWidgetDecoration,
                            alignment: widget.deleteWidgetAlignment,
                            child: AnimatedSize(
                              curve: widget.deleteWidgetAnimationCurve,
                              duration: Duration(
                                milliseconds:
                                    widget.deleteWidgetAnimationDuration,
                              ),
                              child: SizedBox(
                                key: containerKey1,
                                height: isColliding
                                    ? widget.isCollidingDeleteWidgetHeight
                                    : widget.deleteWidgetWidth,
                                width: isColliding
                                    ? widget.isCollidingDeleteWidgetWidth
                                    : widget.deleteWidgetWidth,
                                child: widget.deleteWidget,
                              ),
                            ),
                          ),
                        ),
                      ),
                    AnimatedPositioned(
                      top: top == -1 ? null : top,
                      left: left == -1 ? null : left,
                      right: left == -1 && top == -1
                          ? (widget.right ?? 20)
                          : null,
                      bottom: left == -1 && top == -1
                          ? (widget.bottom ?? 20)
                          : null,
                      duration: Duration(
                        milliseconds:
                            isDragging || widget.disablePositionAnimation
                            ? 0
                            : 700,
                      ),

                      curve: top >= (height - widget.floatingWidgetHeight) ||
                              left >= (width - widget.floatingWidgetWidth) ||
                              top <= widget.floatingWidgetHeight ||
                              left <= 1
                          ? !widget.disableBounceAnimation? Curves.bounceOut : Curves.ease
                          : Curves.ease,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isTabbed = true;
                          });
                        },

                        onLongPress: () {
                          setState(() {
                            isTabbed = true;
                          });
                        },

                        onPanDown: (value) {
                          _pressedAt = DateTime.now();
                          final box = containerKey2.currentContext
                              ?.findRenderObject();
                          final rootBox = context.findRenderObject();
                          if (box is RenderBox &&
                              box.attached &&
                              rootBox is RenderBox) {
                            final localDown =
                                rootBox.globalToLocal(value.globalPosition);
                            final widgetTopLeft = box.localToGlobal(
                              Offset.zero,
                              ancestor: rootBox,
                            );
                            _grabOffset = localDown - widgetTopLeft;
                          } else {
                            _grabOffset = null;
                          }
                        },

                        onPanStart: (value) {
                          setState(() {
                            isTabbed = true;
                            if (_dragAllowed) {
                              isDragging = true;
                              if(widget.onDragging != null){
                                widget.onDragging!(true);
                              }
                            }
                          });
                        },

                        onPanUpdate: (value) {
                          setState(() {
                            if (isTabbed && isDragEnable && _dragAllowed) {
                              if (!isDragging) {
                                isDragging = true;
                                widget.onDragging?.call(true);
                              }
                              isColliding = hasDeleteWidget &&
                                  hasCollision(containerKey1, containerKey2);
                              final rootBox =
                                  context.findRenderObject() as RenderBox?;
                              final local = rootBox != null
                                  ? rootBox.globalToLocal(value.globalPosition)
                                  : value.globalPosition;
                              final grab = _grabOffset ??
                                  Offset(widget.floatingWidgetWidth / 2,
                                      widget.floatingWidgetHeight / 2);
                              top = _getDy(local.dy - grab.dy, height);
                              left = _getDx(local.dx - grab.dx, width);
                              if(widget.onDragEvent != null){
                                widget.onDragEvent!(left, top);
                              }
                            }
                          });
                        },

                        onPanEnd: (value) {
                          widget.onDragging?.call(false);
                          _pressedAt = null;
                          setState(() {
                            if (isTabbed && isDragEnable && isDragging) {
                              isDragging = false;
                              left = _getDx(
                                  left +
                                      value.velocity.pixelsPerSecond.dx /
                                          (widget.speed ?? 50.0).toDouble(),
                                  width);
                              top = _getDy(
                                  top +
                                      value.velocity.pixelsPerSecond.dy /
                                          (widget.speed ?? 50.0).toDouble(),
                                  height);
                              if(widget.onDragEvent != null){
                                widget.onDragEvent!(left, top);
                              }

                            }
                            if (hasDeleteWidget && isColliding) {
                              isRemoved = true;
                              widget.onDeleteWidget?.call();
                            }
                          });

                          if (widget.autoAlign) {
                            if(widget.autoAlignType == AlignmentType.onlyLeft){
                              setState(() {
                                left = 0;
                              });
                            }
                            else if(widget.autoAlignType == AlignmentType.onlyRight){
                              setState(() {
                                left = width - widget.floatingWidgetWidth;
                              });
                            }
                            else{
                              if (left >= width / 2) {
                                setState(() {
                                  left = width - widget.floatingWidgetWidth;
                                });
                              } else {
                                setState(() {
                                  left = 0;
                                });
                              }
                            }
                          }
                        },

                        child: isDragging && widget.widgetWhenDragging != null
                            ? SizedBox(
                                key: containerKey2,
                                child: RepaintBoundary(
                                  child: widget.widgetWhenDragging,
                                ),
                              )
                            : SizedBox(
                                key: containerKey2,
                                width: widget.floatingWidgetWidth,
                                height: widget.floatingWidgetHeight,
                                child: RepaintBoundary(
                                  child: widget.floatingWidget,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    isDragEnable = widget.isDraggable;

    final old = oldWidget as FloatingDraggableWidget;
    if (widget.dx != null && widget.dx != old.dx) left = widget.dx!;
    if (widget.dy != null && widget.dy != old.dy) top = widget.dy!;
  }

  double _getDy(double dy, double totalHeight) {
    double currentTop;
    if (dy >= (totalHeight - widget.floatingWidgetHeight)) {
      currentTop = (totalHeight - widget.floatingWidgetHeight);
    } else {
      if (dy <= 0) {
        currentTop = 0;
      } else {
        currentTop = dy;
      }
    }

    return currentTop;
  }

  double _getDx(double dx, double totalWidth) {
    double currentLeft;
    if (dx >= (totalWidth - widget.floatingWidgetWidth)) {
      currentLeft = (totalWidth - widget.floatingWidgetWidth);
    } else {
      if (dx <= 0) {
        currentLeft = 0;
      } else {
        currentLeft = dx;
      }
    }

    return currentLeft;
  }
}
