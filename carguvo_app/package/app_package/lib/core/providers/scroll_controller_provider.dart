import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final mainScrollControllerProvider = Provider<ScrollController>((ref) {
  final controller = ScrollController();
  ref.onDispose(() => controller.dispose());
  return controller;
});

enum BottomNavVisibility { expanded, collapsed }

class BottomNavVisibilityNotifier extends Notifier<BottomNavVisibility> {
  static const double _velocityThreshold = 800.0;

  static const double _scrollDownThreshold = 50.0;

  static const int _debounceMs = 100;

  DateTime? _lastToggleTime;

  double _accumulatedScrollDown = 0.0;

  DateTime? _pauseUntil;

  static const int _pauseDurationMs = 500;

  @override
  BottomNavVisibility build() {
    _pauseUntil = DateTime.now().add(const Duration(milliseconds: 1000));
    return BottomNavVisibility.expanded;
  }

  void pauseDetection() {
    _pauseUntil = DateTime.now().add(
      const Duration(milliseconds: _pauseDurationMs),
    );
  }

  bool handleScrollNotification(ScrollNotification notification) {
    if (_pauseUntil != null && DateTime.now().isBefore(_pauseUntil!)) {
      return false;
    }

    if (notification.depth != 0) {
      return false;
    }

    if (notification is ScrollUpdateNotification) {
      final metrics = notification.metrics;
      final scrollDelta = notification.scrollDelta ?? 0;
      final now = DateTime.now();

      if (metrics.outOfRange) {
        return false;
      }

      final isAtBottom = metrics.pixels >= metrics.maxScrollExtent - 1;
      final isAtTop = metrics.pixels <= metrics.minScrollExtent + 1;

      if ((isAtBottom && scrollDelta < 0) || (isAtTop && scrollDelta > 0)) {
        return false;
      }

      final isScrollingUp = scrollDelta > 0;
      final isScrollingDown = scrollDelta < 0;

      final shouldDebounce =
          _lastToggleTime != null &&
          now.difference(_lastToggleTime!).inMilliseconds < _debounceMs;

      if (state == BottomNavVisibility.expanded) {
        if (isScrollingUp && !shouldDebounce) {
          final estimatedVelocity = scrollDelta.abs() * 60;

          if (estimatedVelocity > _velocityThreshold) {
            state = BottomNavVisibility.collapsed;
            _lastToggleTime = now;
            _accumulatedScrollDown = 0.0;
          }
        }
      } else {
        if (isScrollingDown) {
          _accumulatedScrollDown += scrollDelta.abs();

          if (_accumulatedScrollDown >= _scrollDownThreshold &&
              !shouldDebounce) {
            state = BottomNavVisibility.expanded;
            _lastToggleTime = now;
            _accumulatedScrollDown = 0.0;
          }
        } else if (isScrollingUp) {
          _accumulatedScrollDown = 0.0;
        }
      }
    }

    return false;
  }

  void expand() {
    state = BottomNavVisibility.expanded;
    _accumulatedScrollDown = 0.0;
  }

  void collapse() {
    state = BottomNavVisibility.collapsed;
    _accumulatedScrollDown = 0.0;
  }

  void toggle() {
    state = state == BottomNavVisibility.expanded
        ? BottomNavVisibility.collapsed
        : BottomNavVisibility.expanded;
    _accumulatedScrollDown = 0.0;
  }
}

final bottomNavVisibilityProvider =
    NotifierProvider<BottomNavVisibilityNotifier, BottomNavVisibility>(
      BottomNavVisibilityNotifier.new,
    );
