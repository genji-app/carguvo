// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _maxScrollExtentThreshold = 200;

const _scrollDirectionThreshold = 15;

class ScrollDirectionListener extends ConsumerStatefulWidget {
  const ScrollDirectionListener({required this.child, this.depth, super.key});

  final Widget child;

  final int? depth;

  @override
  ConsumerState<ScrollDirectionListener> createState() =>
      _ScrollDirectionListenerState();
}

class _ScrollDirectionListenerState
    extends ConsumerState<ScrollDirectionListener>
    with RouteAware {
  double _scrollValue = 0;

  double _scrollStart = 0;

  ScrollDirection _direction = ScrollDirection.idle;

  ScrollDirection _directionInterim = ScrollDirection.idle;

  @override
  void didPopNext() => _set(ScrollDirection.forward);

  @override
  void didPushNext() => _set(ScrollDirection.forward);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

  }

  @override
  void dispose() {

    super.dispose();
  }

  bool _onNotification(ScrollNotification notification) {
    if (widget.depth != null && notification.depth != widget.depth) {
      return false;
    }

    final metrics = notification.metrics;

    if (mounted && metrics.maxScrollExtent > _maxScrollExtentThreshold) {
      final scrollValue = metrics.pixels;
      final scrollDirection = scrollValue == 0 || scrollValue - _scrollValue < 0
          ? ScrollDirection.forward
          : ScrollDirection.reverse;

      if (_directionInterim != scrollDirection) {
        _directionInterim = scrollDirection;
        _scrollStart = scrollValue;
      }

      if (_direction != scrollDirection) {
        if ((scrollValue - _scrollStart).abs() > _scrollDirectionThreshold) {
          _set(scrollDirection);
        }
      }

      _scrollValue = scrollValue;
    }

    return false;
  }

  void _set(ScrollDirection direction) {
    if (mounted) setState(() => _direction = direction);
  }

  @override
  Widget build(BuildContext context) =>
      NotificationListener<ScrollNotification>(
        onNotification: _onNotification,
        child: UserScrollDirection(
          direction: _direction,
          idle: () => _set(ScrollDirection.idle),
          forward: () => _set(ScrollDirection.forward),
          reverse: () => _set(ScrollDirection.reverse),
          child: widget.child,
        ),
      );
}

class UserScrollDirection extends InheritedWidget {
  const UserScrollDirection({
    required super.child,
    required this.direction,
    required this.idle,
    required this.reverse,
    required this.forward,
    super.key,
  });

  final ScrollDirection direction;
  final VoidCallback idle;
  final VoidCallback reverse;
  final VoidCallback forward;

  static UserScrollDirection? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<UserScrollDirection>();

  static ScrollDirection? scrollDirectionOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<UserScrollDirection>()
      ?.direction;

  @override
  bool updateShouldNotify(covariant UserScrollDirection oldWidget) =>
      oldWidget.direction != direction;
}
