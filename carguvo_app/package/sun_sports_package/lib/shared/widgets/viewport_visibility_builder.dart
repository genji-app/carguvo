import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:sun_sports/core/utils/scroll_aware_controller.dart';

class ViewportVisibilityBuilder extends StatefulWidget {
  const ViewportVisibilityBuilder({required this.builder, super.key});

  final Widget Function(BuildContext context, bool visible) builder;

  @override
  State<ViewportVisibilityBuilder> createState() =>
      _ViewportVisibilityBuilderState();
}

class _ViewportVisibilityBuilderState extends State<ViewportVisibilityBuilder> {
  bool _visible = true;
  bool _checkScheduled = false;
  bool _pendingCheckAfterScroll = false;
  final List<ScrollPosition> _positions = [];
  ValueListenable<TickerModeData>? _tickerMode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    MediaQuery.maybeSizeOf(context);
    _listen();
    _scheduleCheck();
  }

  @override
  void dispose() {
    _unlisten();
    super.dispose();
  }

  void _listen() {
    _unlisten();
    var scrollable = Scrollable.maybeOf(context);
    while (scrollable != null) {
      final position = scrollable.position;
      position.addListener(_scheduleCheck);
      _positions.add(position);
      scrollable = Scrollable.maybeOf(scrollable.context);
    }
    _tickerMode = TickerMode.getValuesNotifier(context)
      ..addListener(_scheduleCheck);
    ScrollAwareController.instance.addListener(_onScrollAwareChanged);
  }

  void _unlisten() {
    for (final position in _positions) {
      position.removeListener(_scheduleCheck);
    }
    _positions.clear();
    _tickerMode?.removeListener(_scheduleCheck);
    _tickerMode = null;
    ScrollAwareController.instance.removeListener(_onScrollAwareChanged);
  }

  void _onScrollAwareChanged() {
    if (!ScrollAwareController.instance.isScrolling && _pendingCheckAfterScroll) {
      _pendingCheckAfterScroll = false;
      _scheduleCheck();
    }
  }

  void _scheduleCheck() {
    if (_checkScheduled || !mounted) return;
    if (ScrollAwareController.instance.isScrolling) {
      _pendingCheckAfterScroll = true;
      return;
    }
    _checkScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _checkScheduled = false;
      if (!mounted) return;
      final visible = _isOnScreen();
      if (visible != _visible) setState(() => _visible = visible);
    });
  }

  bool _isOnScreen() {
    if (_tickerMode?.value.enabled == false) return false;
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return false;
    final transform = box.getTransformTo(null);
    if (transform.determinant() == 0) return false;
    final rect = MatrixUtils.transformRect(transform, Offset.zero & box.size);
    final view = View.maybeOf(context);
    if (view == null) return true;
    final size = view.physicalSize / view.devicePixelRatio;
    return rect.right >= 0 &&
        rect.bottom >= 0 &&
        rect.left <= size.width &&
        rect.top <= size.height;
  }

  @override
  Widget build(BuildContext context) {
    _scheduleCheck();
    return widget.builder(context, _visible);
  }
}
