import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/utils/scroll_aware_controller.dart';

class ScrollHideNotifier {
  static const double headerHeight = 68.0;
  static const double minVisibleHeight = 1.0;
  static const double maxOffset = headerHeight - minVisibleHeight;
  static const double snapThreshold = 0.5;
  static const Duration snapDuration = Duration(milliseconds: 240);
  static const Duration _startupPause = Duration(milliseconds: 1000);

  static const double flipThreshold = 8.0;

  final ValueNotifier<double> progress = ValueNotifier(0.0);
  DateTime? _pauseUntil;

  double _accum = 0.0;

  double? _animTarget;

  Ticker? _snapTicker;

  ScrollableState? _primaryScrollable;

  void _cancelSnap() {
    _snapTicker?.dispose();
    _snapTicker = null;
    _animTarget = null;
  }

  ScrollHideNotifier() {
    _pauseUntil = DateTime.now().add(_startupPause);
  }

  void handleScrollMetricsNotification(ScrollMetricsNotification notification) {
    _rememberPrimaryScrollable(
      notification.depth,
      notification.metrics,
      notification.context,
    );
    if (_isBeforePauseUntil()) return;
    if (notification.depth != 0) return;
    ensureRevealableOrShow(notification.metrics);
  }

  void _rememberPrimaryScrollable(
    int depth,
    ScrollMetrics metrics,
    BuildContext? context,
  ) {
    if (depth != 0 || metrics.axis != Axis.vertical || context == null) return;
    if (!context.mounted) return;
    final scrollable = Scrollable.maybeOf(context);
    if (scrollable == null) return;
    final current = _primaryScrollable;
    if (current != null &&
        current.mounted &&
        !identical(current, scrollable) &&
        metrics.hasViewportDimension &&
        current.position.hasViewportDimension &&
        metrics.viewportDimension < current.position.viewportDimension) {
      return;
    }
    _primaryScrollable = scrollable;
  }

  bool ensureRevealableOrShow(ScrollMetrics metrics) {
    final scrollRange = metrics.maxScrollExtent - metrics.minScrollExtent;
    if (scrollRange < maxOffset && progress.value != 0.0) {
      _accum = 0.0;
      _animateSnapTo(0.0);
      return true;
    }
    return false;
  }

  void handleScrollNotification(ScrollNotification notification) {
    _rememberPrimaryScrollable(
      notification.depth,
      notification.metrics,
      notification.context,
    );
    if (_isBeforePauseUntil()) return;
    if (notification.depth != 0) return;

    if (notification is ScrollUpdateNotification) {
      final delta = notification.scrollDelta ?? 0.0;
      final metrics = notification.metrics;

      final canScroll = metrics.maxScrollExtent > metrics.minScrollExtent;
      if (!canScroll) {
        _accum = 0.0;
        if (progress.value != 0.0) {
          _cancelSnap();
          progress.value = 0.0;
        }
        return;
      }

      if (metrics.outOfRange) return;

      if (delta > 0 && metrics.pixels >= metrics.maxScrollExtent) return;
      if (delta < 0 && metrics.pixels <= metrics.minScrollExtent) return;

      if (delta == 0.0) return;
      if ((delta > 0) != (_accum > 0)) _accum = 0.0;
      _accum += delta;
      if (_accum.abs() < flipThreshold) return;
      _accum = 0.0;
      _setHidden(delta > 0);
    }

    if (notification is ScrollEndNotification) {
      _accum = 0.0;
    }
  }

  void _setHidden(bool hidden) {
    final target = hidden ? 1.0 : 0.0;
    if (_animTarget == target) return;
    if (_animTarget == null && progress.value == target) return;
    _animateSnapTo(target);
  }

  void _animateSnapTo(double target) {
    _cancelSnap();
    final start = progress.value;
    _animTarget = target;

    _snapTicker = Ticker((elapsed) {
      final t = (elapsed.inMilliseconds / snapDuration.inMilliseconds).clamp(
        0.0,
        1.0,
      );

      if (t >= 1.0) {
        progress.value = target;
        _animTarget = null;
        _snapTicker?.stop();
        return;
      }

      final eased = 1.0 - (1.0 - t) * (1.0 - t);
      progress.value = start + (target - start) * eased;
    })..start();
  }

  bool hide() {
    final scrollable = _primaryScrollable;
    if (scrollable == null || !scrollable.mounted) {
      _primaryScrollable = null;
      return false;
    }
    final position = scrollable.position;
    if (!position.hasContentDimensions || !position.hasPixels) return false;

    final range = position.maxScrollExtent - position.minScrollExtent;
    if (range < maxOffset) return false;

    _accum = 0.0;
    _setHidden(true);

    final minPixels = position.minScrollExtent + maxOffset;
    if (position.pixels < minPixels) {
      position.animateTo(
        minPixels,
        duration: snapDuration,
        curve: const _EaseOutQuad(),
      );
    }
    return true;
  }

  void show() {
    _cancelSnap();
    _accum = 0.0;
    progress.value = 0.0;
  }

  void pauseDetection([Duration duration = const Duration(milliseconds: 500)]) {
    _pauseUntil = DateTime.now().add(duration);
  }

  bool _isBeforePauseUntil() {
    if (_pauseUntil == null) return false;
    if (DateTime.now().isBefore(_pauseUntil!)) return true;
    _pauseUntil = null;
    return false;
  }

  void dispose() {
    _cancelSnap();
    progress.dispose();
  }
}

final scrollHideProvider = Provider<ScrollHideNotifier>((ref) {
  final notifier = ScrollHideNotifier();
  ref.onDispose(() => notifier.dispose());
  return notifier;
});

class _EaseOutQuad extends Curve {
  const _EaseOutQuad();

  @override
  double transformInternal(double t) => 1.0 - (1.0 - t) * (1.0 - t);
}
