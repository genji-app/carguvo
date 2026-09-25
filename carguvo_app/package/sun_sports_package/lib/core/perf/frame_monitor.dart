import 'dart:async';
import 'dart:ui' show FramePhase, FrameTiming, PlatformDispatcher;

import 'package:flutter/foundation.dart' show FlutterError, FlutterErrorDetails, kDebugMode;
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart' show debugOnRebuildDirtyWidget;
import 'package:sun_sports/core/perf/dart_stress.dart';
import 'package:sun_sports/core/perf/perf_flags.dart';
import 'package:sun_sports/core/perf/perf_log.dart';
import 'package:sun_sports/core/perf/perf_sentry_reporter.dart';
import 'package:sun_sports/core/perf/stall_monitor.dart';
import 'package:sun_sports/core/utils/scroll_aware_controller.dart';

abstract final class FrameMonitor {
  static bool _started = false;
  static final List<double> _build = [];
  static final List<double> _raster = [];
  static int _slow = 0;
  static Timer? _flushTimer;
  static bool _wasScrolling = false;
  static const Duration _quietGap = Duration(milliseconds: 1500);
  static final VsyncIntervalEstimator _interval = VsyncIntervalEstimator();

  static void start() {
    if (!PerfFlags.trace || _started) return;
    _started = true;
    StallMonitor.start();
    if (kDebugMode) {
      debugOnRebuildDirtyWidget = (element, _) =>
          PerfCounters.hit('w:${element.widget.runtimeType}');
    }
    SchedulerBinding.instance.addTimingsCallback(_onTimings);
    ScrollAwareController.instance.addListener(_onScrollChanged);
    _hookErrors();
    PerfLog.write(
      'frames monitor on — display reports ${_displayHz.toStringAsFixed(0)}Hz, '
      'budget taken from real vsync spacing, stress ×${DartStress.factor}',
    );
  }

  static double get _displayHz {
    final views = PlatformDispatcher.instance.views;
    final hz = views.isEmpty ? 60.0 : views.first.display.refreshRate;
    return hz > 0 ? hz : 60;
  }

  static double get _budgetMs => _interval.intervalMs ?? 1000 / _displayHz;

  static void _hookErrors() {
    final prevFlutter = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      PerfLog.write(
        'error flutter ${details.exceptionAsString()} '
        '@ ${_stackHead(details.stack)}',
      );
      prevFlutter?.call(details);
    };
    final prevPlatform = PlatformDispatcher.instance.onError;
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      PerfLog.write('error zone $error @ ${_stackHead(stack)}');
      return prevPlatform?.call(error, stack) ?? false;
    };
  }

  static String _stackHead(StackTrace? stack) {
    if (stack == null) return '-';
    final lines = stack.toString().split('\n').where((l) => l.trim().isNotEmpty);
    return lines.take(5).map((l) => l.trim()).join(' | ');
  }

  static void _onScrollChanged() {
    final scrolling = ScrollAwareController.instance.isScrolling;
    if (scrolling && !_wasScrolling && _build.isEmpty) {
      final idle = PerfCounters._takeWindow();
      if (idle != null) PerfLog.write('idle $idle');
    }
    _wasScrolling = scrolling;
  }

  static void _onTimings(List<FrameTiming> timings) {
    final batch = PerfCounters._takeBatch();
    var batchPrinted = false;
    _interval.maxDisplayHz = _displayHz;
    for (final t in timings) {
      final previous = _interval.intervalMs;
      final measured = _interval.add(
        t.timestampInMicroseconds(FramePhase.vsyncStart),
      );
      if (measured != null &&
          (previous == null || (measured - previous).abs() > previous * .05)) {
        PerfLog.write(
          'frames budget → ${measured.toStringAsFixed(1)}ms '
          '(vsync spacing; display reports ${_displayHz.toStringAsFixed(0)}Hz)',
        );
      }
      final budget = _budgetMs;
      final build = t.buildDuration.inMicroseconds / 1000;
      final raster = t.rasterDuration.inMicroseconds / 1000;
      _build.add(build);
      _raster.add(raster);
      if (build + raster > budget) {
        _slow++;
        PerfLog.write(
          'frame SLOW build=${build.toStringAsFixed(1)} '
          'raster=${raster.toStringAsFixed(1)} '
          'budget=${budget.toStringAsFixed(1)}'
          '${batchPrinted ? '' : ' $batch'}',
        );
        batchPrinted = true;
      }
    }
    if (!_burstClock.isRunning) _burstClock.start();
    _flushTimer?.cancel();
    if (_burstClock.elapsed >= _maxBurst) {
      _flush();
    } else {
      _flushTimer = Timer(_quietGap, _flush);
    }
  }

  static const Duration _maxBurst = Duration(seconds: 10);
  static final Stopwatch _burstClock = Stopwatch();

  static void _flush() {
    _burstClock
      ..stop()
      ..reset();
    if (_build.isEmpty) return;
    final counters = PerfCounters._takeWindow() ?? '';
    PerfLog.write(
      'frames burst ×${DartStress.factor} '
      'budget=${_budgetMs.toStringAsFixed(1)} n=${_build.length} slow=$_slow '
      'build p50=${_p(_build, .5)} p90=${_p(_build, .9)} max=${_p(_build, 1)} '
      'raster p50=${_p(_raster, .5)} p90=${_p(_raster, .9)} '
      'max=${_p(_raster, 1)} | ${counters.isEmpty ? '-' : counters}',
    );
    PerfSentryReporter.reportBurst(
      budgetMs: _budgetMs,
      frames: _build.length,
      slowFrames: _slow,
      build: _build,
      raster: _raster,
      counters: counters,
    );
    PerfLog.flush();
    _build.clear();
    _raster.clear();
    _slow = 0;
  }

  static String _p(List<double> xs, double q) {
    final s = [...xs]..sort();
    final i = ((s.length - 1) * q).round();
    return s[i].toStringAsFixed(1);
  }
}

class VsyncIntervalEstimator {
  VsyncIntervalEstimator({this.confirmations = 3});

  static const double minPlausibleMs = 4;
  static const List<double> _standardHz = [144, 120, 90, 60, 30];
  static const double _tolerance = .1;

  final int confirmations;

  double? maxDisplayHz;

  int? _lastVsyncMicros;
  double? _intervalMs;
  double? _pendingMs;
  int _pendingHits = 0;

  double? get intervalMs => _intervalMs;

  double? add(int vsyncMicros) {
    final last = _lastVsyncMicros;
    _lastVsyncMicros = vsyncMicros;
    if (last == null) return _intervalMs;
    final raw = (vsyncMicros - last) / 1000;
    if (raw < minPlausibleMs) return _intervalMs;
    final hz = maxDisplayHz;
    final floor = hz != null && hz > 0 ? 1000 / hz : 0.0;
    final spacingMs = floor > 0 && raw < floor ? floor : _snap(raw);
    final current = _intervalMs;
    if (current == null) return _intervalMs = spacingMs;
    if (spacingMs >= current * (1 - _tolerance)) return current;
    final pending = _pendingMs;
    if (pending != null && (spacingMs - pending).abs() <= pending * _tolerance) {
      _pendingHits++;
    } else {
      _pendingMs = spacingMs;
      _pendingHits = 1;
    }
    if (_pendingHits >= confirmations) {
      _intervalMs = _pendingMs;
      _pendingMs = null;
      _pendingHits = 0;
    }
    return _intervalMs;
  }

  static double _snap(double ms) {
    for (final hz in _standardHz) {
      final standard = 1000 / hz;
      if ((ms - standard).abs() <= standard * _tolerance) return standard;
    }
    return ms;
  }
}

abstract final class PerfCounters {
  static final Map<String, int> _batch = {};
  static final Map<String, int> _window = {};
  static final Stopwatch _windowClock = Stopwatch()..start();

  static void hit(String key) {
    if (!PerfFlags.trace) return;
    _batch[key] = (_batch[key] ?? 0) + 1;
    _window[key] = (_window[key] ?? 0) + 1;
  }

  static String _format(Map<String, int> counts) {
    final entries = counts.entries.toList()
      ..sort((a, b) {
        final aw = a.key.startsWith('w:');
        final bw = b.key.startsWith('w:');
        if (aw != bw) return aw ? 1 : -1;
        return b.value.compareTo(a.value);
      });
    return '[${entries.take(24).map((e) => '${e.key}=${e.value}').join(' ')}]';
  }

  static String _takeBatch() {
    if (_batch.isEmpty) return '';
    final s = _format(_batch);
    _batch.clear();
    return s;
  }

  static String? _takeWindow() {
    final ms = _windowClock.elapsedMilliseconds;
    _windowClock.reset();
    if (_window.isEmpty) return null;
    final s = '${ms}ms ${_format(_window)}';
    _window.clear();
    return s;
  }
}
