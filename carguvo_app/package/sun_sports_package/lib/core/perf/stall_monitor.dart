import 'dart:async';
import 'dart:io' show ProcessInfo;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sport_socket/sport_socket.dart' show SportSocketPerfHooks;
import 'package:sun_sports/core/perf/dart_stress.dart';
import 'package:sun_sports/core/perf/perf_flags.dart';
import 'package:sun_sports/core/perf/perf_log.dart';

abstract final class StallMonitor {
  static const Duration _tick = Duration(milliseconds: 50);
  static const int _thresholdMs = PerfFlags.stallMs;
  static const Duration _period = Duration(seconds: 5);
  static const int _periodMinMicros = 50000;

  static bool _started = false;
  static final Stopwatch _sinceTick = Stopwatch();
  static final Stopwatch _sincePeriod = Stopwatch();
  static final Map<String, _Work> _periodWork = {};

  static void start() {
    if (!PerfFlags.trace || _started) return;
    _started = true;
    SportSocketPerfHooks.wrap ??= DartStress.timed;
    _sinceTick.start();
    _sincePeriod.start();
    Timer.periodic(_tick, (_) => _onTick());
  }

  static void _onTick() {
    final elapsed = _sinceTick.elapsedMilliseconds;
    _sinceTick.reset();
    final work = PerfWork._take();
    if (elapsed - _tick.inMilliseconds >= _thresholdMs) {
      PerfLog.write('stall ${elapsed}ms ${_format(work)}$_rss');
      PerfLog.flush();
    }
    work.forEach((label, w) => (_periodWork[label] ??= _Work()).merge(w));
    if (_sincePeriod.elapsed < _period) return;
    final total = _periodWork.values.fold<int>(0, (sum, w) => sum + w.micros);
    if (total >= _periodMinMicros) {
      PerfLog.write(
        'work ${_sincePeriod.elapsedMilliseconds}ms ${_format(_periodWork)}',
      );
      PerfLog.flush();
    }
    _periodWork.clear();
    _sincePeriod.reset();
  }

  static String get _rss {
    if (kIsWeb) return '';
    try {
      return ' rss=${ProcessInfo.currentRss >> 20}mb';
    } catch (_) {
      return '';
    }
  }

  static String _format(Map<String, _Work> work) {
    if (work.isEmpty) return '[work=-]';
    final entries = work.entries.toList()
      ..sort((a, b) => b.value.micros.compareTo(a.value.micros));
    return '[${entries.map((e) => '${e.key}=${e.value}').join(' ')}]';
  }
}

abstract final class PerfWork {
  static final Map<String, _Work> _window = {};

  static void add(String label, int micros) {
    final w = _window[label] ??= _Work();
    w.micros += micros;
    w.count++;
  }

  static T time<T>(String label, T Function() body) {
    if (!PerfFlags.trace) return body();
    final sw = Stopwatch()..start();
    final result = body();
    add(label, sw.elapsedMicroseconds);
    return result;
  }

  static Map<String, _Work> _take() {
    if (_window.isEmpty) return const {};
    final taken = Map<String, _Work>.of(_window);
    _window.clear();
    return taken;
  }
}

class _Work {
  int micros = 0;
  int count = 0;

  void merge(_Work other) {
    micros += other.micros;
    count += other.count;
  }

  @override
  String toString() => '${(micros / 1000).toStringAsFixed(0)}ms/$count';
}
