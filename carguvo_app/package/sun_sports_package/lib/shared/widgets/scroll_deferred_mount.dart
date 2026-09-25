import 'dart:collection';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:sun_sports/core/perf/frame_monitor.dart';
import 'package:sun_sports/core/perf/perf_flags.dart';
import 'package:sun_sports/core/utils/scroll_aware_controller.dart';

class ScrollDeferredMount extends StatefulWidget {
  const ScrollDeferredMount({
    required this.child,
    this.placeholder = const SizedBox.expand(),
    super.key,
  });

  final Widget child;
  final Widget placeholder;

  @override
  State<ScrollDeferredMount> createState() => _ScrollDeferredMountState();
}

class _ScrollDeferredMountState extends State<ScrollDeferredMount> {
  bool _ready = true;

  @override
  void initState() {
    super.initState();
    if (ScrollAwareController.instance.isScrolling) {
      _ready = false;
      _DeferredMountQueue.enqueue(this);
    }
  }

  void _mount() {
    if (!mounted || _ready) return;
    if (PerfFlags.trace) PerfCounters.hit('defer.mount');
    setState(() => _ready = true);
  }

  @override
  void dispose() {
    if (!_ready) {
      if (PerfFlags.trace) PerfCounters.hit('defer.skip');
      _DeferredMountQueue.remove(this);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _ready ? widget.child : widget.placeholder;
}

abstract final class _DeferredMountQueue {
  static const int perFrame = 1;
  static const int maxWaitFrames = 3;

  static final LinkedHashMap<_ScrollDeferredMountState, int> _pending =
      LinkedHashMap();
  static int _frame = 0;
  static int? _drainCallbackId;
  static bool _listening = false;

  static void enqueue(_ScrollDeferredMountState state) {
    if (PerfFlags.trace) PerfCounters.hit('defer.queue');
    _pending[state] = _frame;
    if (!_listening) {
      _listening = true;
      ScrollAwareController.instance.addListener(_onScrollChanged);
    }
    _scheduleDrain();
  }

  static void remove(_ScrollDeferredMountState state) {
    _pending.remove(state);
    _cancelDrainIfIdle();
  }

  static void _scheduleDrain() {
    if (_drainCallbackId != null || _pending.isEmpty) return;
    _drainCallbackId = SchedulerBinding.instance.scheduleFrameCallback((_) {
      _drainCallbackId = null;
      _drain();
    });
  }

  static void _cancelDrainIfIdle() {
    final id = _drainCallbackId;
    if (id == null || _pending.isNotEmpty) return;
    SchedulerBinding.instance.cancelFrameCallbackWithId(id);
    _drainCallbackId = null;
  }

  static void _drain() {
    _frame++;
    var mountedThisFrame = 0;
    while (_pending.isNotEmpty) {
      final entry = _pending.entries.first;
      final waited = _frame - entry.value;
      if (mountedThisFrame >= perFrame && waited < maxWaitFrames) break;
      _pending.remove(entry.key);
      entry.key._mount();
      mountedThisFrame++;
    }
    _scheduleDrain();
  }

  static void _onScrollChanged() {
    if (ScrollAwareController.instance.isScrolling || _pending.isEmpty) return;
    if (PerfFlags.trace) PerfCounters.hit('defer.flush');
    final states = _pending.keys.toList();
    _pending.clear();
    _cancelDrainIfIdle();
    for (final state in states) {
      state._mount();
    }
  }
}
