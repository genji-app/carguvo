import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:sun_sports/core/providers/slider_drawer_provider.dart';
import 'package:sun_sports/core/utils/scroll_aware_controller.dart';
import 'package:sun_sports/core/utils/tab_swipe_activity.dart';
import 'package:sun_sports/shared/widgets/slivers/sliver_tab_pager.dart';

const Duration kTabPagerSettle = Duration(milliseconds: 220);

const Curve kTabPagerCurve = Curves.easeOutCubic;

const double kTabPagerCommitRatio = 0.28;

const double kTabPagerFlingVelocity = 350;

const double kTabPagerFlingDistance = 56;

const double kTabPagerEdgeZone = 24;

const double kTabPagerRubber = 0.3;

const Set<PointerDeviceKind> _kDevices = <PointerDeviceKind>{
  PointerDeviceKind.touch,
  PointerDeviceKind.stylus,
  PointerDeviceKind.invertedStylus,
};

const double _kDirectionSlop = 1;

abstract class TabPagerEdgeSwipe {
  bool begin();

  void update(double dx);

  void end();

  void cancel();
}

class DrawerEdgeSwipe implements TabPagerEdgeSwipe {
  const DrawerEdgeSwipe();

  SliderDrawerState? get _state => sliderDrawerKey.currentState;

  @override
  bool begin() {
    final SliderDrawerState? state = _state;
    if (state == null || state.isDrawerOpen || state.openSize <= 0) {
      return false;
    }
    state.startDragging();
    return true;
  }

  @override
  void update(double dx) {
    final SliderDrawerState? state = _state;
    if (state == null) return;
    state.updatePosition((dx / state.openSize).clamp(0.0, 1.0));
  }

  @override
  void end() => _state?.stopDragging();

  @override
  void cancel() {
    final SliderDrawerState? state = _state;
    if (state == null) return;
    state.updatePosition(0);
    state.stopDragging();
  }
}

class TabPagerController extends ChangeNotifier {
  TabPagerController({
    required TickerProvider vsync,
    int index = 0,
    int count = 1,
  }) : _index = index,
       _count = count {
    _anim = AnimationController(vsync: vsync, duration: kTabPagerSettle)
      ..addListener(_tick)
      ..addStatusListener(_onStatus);
  }

  late final AnimationController _anim;

  final ValueNotifier<double> offset = ValueNotifier<double>(0);

  int _index;

  int get index => _index;

  int _count;
  int get count => _count;

  int? _neighbour;

  int? get neighbour => _neighbour;

  double _width = 0;
  bool _dragging = false;

  TabPagerEdgeSwipe? edgeSwipe;

  bool _edgeMode = false;
  int? _pendingCommit;
  double _animFrom = 0;
  double _animTo = 0;
  bool _disposed = false;

  bool get isActive => _dragging || _anim.isAnimating;

  bool get isDragging => _dragging;

  double get position {
    if (_width <= 0) return _index.toDouble();
    return _index - offset.value / _width;
  }

  ValueChanged<int>? onCommit;

  void _setActive({required bool active}) {
    TabSwipeActivity.update(this, active: active);
    if (active) {
      ScrollAwareController.instance.onScrollStart();
    } else {
      ScrollAwareController.instance.onScrollEnd();
    }
  }

  void setCount(int value) {
    if (_count == value) return;
    _count = value;
    if (_index >= _count) {
      _index = _count > 0 ? _count - 1 : 0;
      notifyListeners();
    }
  }

  void setWidth(double value) {
    if (value > 0) _width = value;
  }

  void syncIndex(int value) {
    final bool wasActive = isActive;
    if (_index == value && _neighbour == null && !wasActive) return;
    _anim.stop();
    _dragging = false;
    _pendingCommit = null;
    _index = value;
    _neighbour = null;
    offset.value = 0;
    notifyListeners();
    if (wasActive) _setActive(active: false);
  }

  bool beginDrag() {
    if (isActive || _count < 2 || _width <= 0) return false;
    _dragging = true;
    _neighbour = null;
    offset.value = 0;
    _setActive(active: true);
    return true;
  }

  void updateDrag(double dx) {
    if (!_dragging) return;

    if (_edgeMode) {
      edgeSwipe!.update(dx);
      return;
    }

    if (_neighbour == null && dx.abs() >= _kDirectionSlop) {
      final int candidate = dx < 0 ? _index + 1 : _index - 1;
      if (candidate >= 0 && candidate < _count) {
        _neighbour = candidate;
        notifyListeners();
      } else if (dx > 0 && _index == 0 && (edgeSwipe?.begin() ?? false)) {
        _edgeMode = true;
        edgeSwipe!.update(dx);
        return;
      }
    }

    final int? nb = _neighbour;
    double d;
    if (nb == null) {
      d = dx * kTabPagerRubber;
    } else if (nb > _index) {
      d = dx.clamp(-_width, 0.0).toDouble();
    } else {
      d = dx.clamp(0.0, _width).toDouble();
    }
    offset.value = d;
  }

  void endDrag(double velocityX) {
    if (!_dragging) return;
    _dragging = false;

    if (_edgeMode) {
      _edgeMode = false;
      edgeSwipe!.end();
      _setActive(active: false);
      return;
    }

    final int? nb = _neighbour;
    final double d = offset.value;
    if (nb == null || d == 0) {
      _animateTo(0.0, null);
      return;
    }

    final bool far = d.abs() >= _width * kTabPagerCommitRatio;
    final bool flung =
        velocityX.abs() >= kTabPagerFlingVelocity &&
        d.abs() >= kTabPagerFlingDistance &&
        velocityX.sign == d.sign;

    final bool commit = far || flung;
    _animateTo(
      commit ? (nb > _index ? -_width : _width) : 0.0,
      commit ? nb : null,
    );
  }

  void cancelDrag() {
    if (!_dragging) return;
    _dragging = false;
    if (_edgeMode) {
      _edgeMode = false;
      edgeSwipe!.cancel();
      _setActive(active: false);
      return;
    }
    _animateTo(0.0, null);
  }

  bool slideTo(int target) {
    if (isActive) return false;
    if (target == _index || target < 0 || target >= _count) return false;
    if (_width <= 0) return false;

    _neighbour = target;
    offset.value = 0;
    notifyListeners();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_disposed || _neighbour != target) return;
      _animateTo(target > _index ? -_width : _width, target);
    });
    return true;
  }

  void _animateTo(double target, int? commitIndex) {
    _pendingCommit = commitIndex;
    _animFrom = offset.value;
    _animTo = target;
    if ((_animTo - _animFrom).abs() < 0.5) {
      offset.value = target;
      _finish();
      return;
    }
    _setActive(active: true);
    _anim.forward(from: 0);
  }

  void _tick() {
    final double t = kTabPagerCurve.transform(_anim.value);
    offset.value = _animFrom + (_animTo - _animFrom) * t;
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) _finish();
  }

  void _finish() {
    final int? commit = _pendingCommit;
    _pendingCommit = null;
    _neighbour = null;
    offset.value = 0;
    if (commit != null && commit != _index) {
      _index = commit;
      notifyListeners();
      onCommit?.call(commit);
    } else {
      notifyListeners();
    }
    _setActive(active: false);
  }

  @override
  void dispose() {
    if (_edgeMode) {
      _edgeMode = false;
      edgeSwipe?.cancel();
    }
    _disposed = true;
    if (TabSwipeActivity.isOwnedBy(this)) _setActive(active: false);
    _anim
      ..removeListener(_tick)
      ..removeStatusListener(_onStatus)
      ..dispose();
    offset.dispose();
    super.dispose();
  }
}

class TabPagerScope extends InheritedNotifier<TabPagerController> {
  const TabPagerScope({
    required TabPagerController super.notifier,
    required super.child,
    super.key,
  });

  static TabPagerController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<TabPagerScope>()
        ?.notifier;
  }

  static TabPagerController? readOf(BuildContext context) {
    final InheritedElement? element = context
        .getElementForInheritedWidgetOfExactType<TabPagerScope>();
    return (element?.widget as TabPagerScope?)?.notifier;
  }
}

class TabPagerHost extends StatefulWidget {
  const TabPagerHost({
    required this.index,
    required this.count,
    required this.onCommit,
    required this.child,
    super.key,
    this.enabled = true,
    this.slideOnExternalChange = true,
    this.edgeExclusion = kTabPagerEdgeZone,
    this.drawerOnFirstTab = true,
  });

  final int index;

  final int count;

  final ValueChanged<int> onCommit;

  final bool enabled;

  final bool slideOnExternalChange;

  final double edgeExclusion;

  final bool drawerOnFirstTab;
  final Widget child;

  @override
  State<TabPagerHost> createState() => _TabPagerHostState();
}

class _TabPagerHostState extends State<TabPagerHost>
    with SingleTickerProviderStateMixin {
  late final TabPagerController _controller;
  double _hostWidth = 0;
  double _dx = 0;
  bool _rejected = false;

  @override
  void initState() {
    super.initState();
    _controller = TabPagerController(
      vsync: this,
      index: widget.index,
      count: widget.count,
    )..onCommit = _handleCommit;
    if (widget.drawerOnFirstTab) {
      _controller.edgeSwipe = const DrawerEdgeSwipe();
    }
  }

  @override
  void didUpdateWidget(TabPagerHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.setCount(widget.count);
    if (widget.index != _controller.index) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final int target = widget.index;
        if (target == _controller.index) return;
        if (!widget.enabled ||
            !widget.slideOnExternalChange ||
            !_controller.slideTo(target)) {
          _controller.syncIndex(target);
        }
      });
    }
  }

  void _handleCommit(int index) => widget.onCommit(index);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDown(DragDownDetails details) {
    _dx = 0;
    final double x = details.localPosition.dx;
    _rejected =
        x <= widget.edgeExclusion ||
        (_hostWidth > 0 && x >= _hostWidth - widget.edgeExclusion);
  }

  void _handleStart(DragStartDetails details) {
    if (_rejected) return;
    if (!_controller.beginDrag()) _rejected = true;
  }

  void _handleUpdate(DragUpdateDetails details) {
    if (_rejected) return;
    _dx += details.delta.dx;
    _controller.updateDrag(_dx);
  }

  void _handleEnd(DragEndDetails details) {
    if (_rejected) return;
    _controller.endDrag(details.velocity.pixelsPerSecond.dx);
  }

  void _handleCancel() {
    if (_rejected) return;
    _controller.cancelDrag();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth.isFinite && constraints.maxWidth > 0) {
          _hostWidth = constraints.maxWidth;
          _controller.setWidth(constraints.maxWidth);
        }

        final Widget scoped = TabPagerScope(
          notifier: _controller,
          child: widget.child,
        );

        if (!widget.enabled) return scoped;

        return RawGestureDetector(
          behavior: HitTestBehavior.opaque,
          gestures: <Type, GestureRecognizerFactory>{
            HorizontalDragGestureRecognizer:
                GestureRecognizerFactoryWithHandlers<
                  HorizontalDragGestureRecognizer
                >(
                  () => HorizontalDragGestureRecognizer(
                    debugOwner: this,
                    supportedDevices: _kDevices,
                  ),
                  (HorizontalDragGestureRecognizer instance) {
                    instance
                      ..onDown = _handleDown
                      ..onStart = _handleStart
                      ..onUpdate = _handleUpdate
                      ..onEnd = _handleEnd
                      ..onCancel = _handleCancel
                      ..gestureSettings = MediaQuery.maybeOf(
                        context,
                      )?.gestureSettings;
                  },
                ),
          },
          child: scoped,
        );
      },
    );
  }
}

class TabPagerPanel extends StatelessWidget {
  const TabPagerPanel({
    required this.panelBuilder,
    required this.fallbackIndex,
    super.key,
  });

  final Widget Function(BuildContext context, int index) panelBuilder;

  final int fallbackIndex;

  @override
  Widget build(BuildContext context) {
    final TabPagerController? controller = TabPagerScope.maybeOf(context);
    if (controller == null) return panelBuilder(context, fallbackIndex);

    final int index = controller.index;
    final int? neighbour = controller.neighbour;

    return SliverTabPager(
      offset: controller.offset,
      neighbourOnRight: neighbour != null && neighbour > index,
      onCrossAxisExtent: controller.setWidth,
      children: <Widget>[
        KeyedSubtree(
          key: ValueKey<int>(index),
          child: panelBuilder(context, index),
        ),
        if (neighbour != null)
          KeyedSubtree(
            key: ValueKey<int>(neighbour),
            child: panelBuilder(context, neighbour),
          ),
      ],
    );
  }
}
