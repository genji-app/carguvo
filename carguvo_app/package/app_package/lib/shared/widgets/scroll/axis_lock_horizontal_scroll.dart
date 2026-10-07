import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

class AxisLockHorizontalScroll extends StatefulWidget {
  const AxisLockHorizontalScroll({
    required this.controller,
    required this.child,
    super.key,
  });

  final ScrollController controller;

  final Widget child;

  @override
  State<AxisLockHorizontalScroll> createState() =>
      _AxisLockHorizontalScrollState();
}

class _AxisLockHorizontalScrollState extends State<AxisLockHorizontalScroll> {
  Drag? _drag;

  void _handleDragStart(DragStartDetails details) {
    if (!widget.controller.hasClients) return;
    _drag = widget.controller.position.drag(details, _disposeDrag);
  }

  void _handleDragUpdate(DragUpdateDetails details) => _drag?.update(details);

  void _handleDragEnd(DragEndDetails details) => _drag?.end(details);

  void _handleDragCancel() => _drag?.cancel();

  void _disposeDrag() => _drag = null;

  @override
  Widget build(BuildContext context) {
    final gestureSettings = MediaQuery.maybeOf(context)?.gestureSettings;
    return RawGestureDetector(
      behavior: HitTestBehavior.opaque,
      gestures: <Type, GestureRecognizerFactory>{
        _ConeHorizontalDragGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<
              _ConeHorizontalDragGestureRecognizer
            >(() => _ConeHorizontalDragGestureRecognizer(debugOwner: this), (
              instance,
            ) {
              instance
                ..onStart = _handleDragStart
                ..onUpdate = _handleDragUpdate
                ..onEnd = _handleDragEnd
                ..onCancel = _handleDragCancel
                ..gestureSettings = gestureSettings;
            }),
      },
      child: widget.child,
    );
  }
}

class _ConeHorizontalDragGestureRecognizer
    extends HorizontalDragGestureRecognizer {
  _ConeHorizontalDragGestureRecognizer({super.debugOwner});

  Offset _accumulatedDelta = Offset.zero;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    _accumulatedDelta = Offset.zero;
    super.addAllowedPointer(event);
  }

  @override
  void addAllowedPointerPanZoom(PointerPanZoomStartEvent event) {
    _accumulatedDelta = Offset.zero;
    super.addAllowedPointerPanZoom(event);
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerMoveEvent) {
      _accumulatedDelta += event.localDelta;
    } else if (event is PointerPanZoomUpdateEvent) {
      _accumulatedDelta += event.localPanDelta;
    }
    super.handleEvent(event);
  }

  @override
  bool hasSufficientGlobalDistanceToAccept(
    PointerDeviceKind pointerDeviceKind,
    double? deviceTouchSlop,
  ) {
    if (_accumulatedDelta.dx.abs() <= _accumulatedDelta.dy.abs()) {
      return false;
    }
    return super.hasSufficientGlobalDistanceToAccept(
      pointerDeviceKind,
      deviceTouchSlop,
    );
  }
}

class ScrollGestureAxisLock {
  static const Duration _idleReset = Duration(milliseconds: 120);

  Axis? _axis;
  Duration _lastEventTs = Duration.zero;

  bool isVertical(Offset delta, Duration eventTs) {
    if (eventTs - _lastEventTs > _idleReset) _axis = null;
    _lastEventTs = eventTs;
    _axis ??= delta.dx.abs() > delta.dy.abs() ? Axis.horizontal : Axis.vertical;
    return _axis == Axis.vertical;
  }
}

class VerticalWheelForwarder extends StatelessWidget {
  const VerticalWheelForwarder({required this.child, this.axisLock, super.key});

  final Widget child;

  final ScrollGestureAxisLock? axisLock;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (event) {
        if (event is! PointerScrollEvent) return;
        final delta = event.scrollDelta;
        final isVertical =
            axisLock?.isVertical(delta, event.timeStamp) ??
            (delta.dy.abs() > delta.dx.abs());
        if (!isVertical) return;

        final vertical = _nearestVerticalScrollable(context);
        if (vertical == null) return;

        GestureBinding.instance.pointerSignalResolver.register(event, (_) {
          final position = vertical.position;
          final target = (position.pixels + delta.dy).clamp(
            position.minScrollExtent,
            position.maxScrollExtent,
          );
          if (target != position.pixels) position.jumpTo(target);
        });
      },
      child: child,
    );
  }

  static ScrollableState? _nearestVerticalScrollable(BuildContext context) {
    ScrollableState? result;
    context.visitAncestorElements((element) {
      final widget = element.widget;
      if (widget is Scrollable &&
          axisDirectionToAxis(widget.axisDirection) == Axis.vertical) {
        final state = (element as StatefulElement).state as ScrollableState;
        final pos = state.position;
        if (pos.hasContentDimensions && pos.maxScrollExtent > 0) {
          result = state;
          return false;
        }
      }
      return true;
    });
    return result;
  }
}
