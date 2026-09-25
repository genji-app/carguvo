import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sun_sports/core/utils/scroll_aware_controller.dart';

class ScrollHold {
  ScrollHold._(this._controller) {
    _controller.addListener(_onScrollStateChanged);
  }

  static final instance = ScrollHold._(ScrollAwareController.instance);

  final ScrollAwareController _controller;
  final List<void Function()> _onRelease = [];
  final List<void Function()> _onReleaseLate = [];

  static const Duration maxHold = Duration(seconds: 5);
  Timer? _valve;

  bool get active => _controller.isScrolling;

  @visibleForTesting
  int get pendingReleases => _onRelease.length + _onReleaseLate.length;

  void onRelease(void Function() flush, {bool late = false}) {
    final lane = late ? _onReleaseLate : _onRelease;
    if (lane.contains(flush)) return;
    lane.add(flush);
    _valve ??= Timer(maxHold, force);
  }

  void cancel(void Function() flush) {
    _onRelease.remove(flush);
    _onReleaseLate.remove(flush);
  }

  void force() => _release();

  void _onScrollStateChanged() {
    if (!active) _release();
  }

  void _release() {
    _valve?.cancel();
    _valve = null;
    if (_onRelease.isEmpty && _onReleaseLate.isEmpty) return;
    final flushes = [..._onRelease, ..._onReleaseLate];
    _onRelease.clear();
    _onReleaseLate.clear();
    for (final flush in flushes) {
      flush();
    }
  }
}
