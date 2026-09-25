import 'package:sentry_flutter/sentry_flutter.dart' show SentryLevel;
import 'package:sun_sports/core/perf/dart_stress.dart';
import 'package:sun_sports/core/perf/perf_flags.dart';
import 'package:sun_sports/core/services/monitoring/sentry_service.dart';

abstract final class PerfSentryReporter {
  static const int _minFrames = 50;
  static const int _maxEventsPerSession = 8;
  static const Duration _minGap = Duration(seconds: 20);

  static int _sent = 0;
  static DateTime? _lastSentAt;

  static void reportBurst({
    required double budgetMs,
    required int frames,
    required int slowFrames,
    required List<double> build,
    required List<double> raster,
    required String counters,
  }) {
    if (!PerfFlags.trace) return;
    if (frames < _minFrames || _sent >= _maxEventsPerSession) return;
    final now = DateTime.now();
    final last = _lastSentAt;
    if (last != null && now.difference(last) < _minGap) return;
    _lastSentAt = now;
    _sent++;

    SentryService.captureDiagnostic(
      'scroll-perf',
      {
        'budget_ms': budgetMs.toStringAsFixed(1),
        'frames': frames,
        'slow_frames': slowFrames,
        'slow_pct': (slowFrames * 100 / frames).toStringAsFixed(1),
        'build_p50': _p(build, .5),
        'build_p90': _p(build, .9),
        'build_max': _p(build, 1),
        'raster_p50': _p(raster, .5),
        'raster_p90': _p(raster, .9),
        'raster_max': _p(raster, 1),
        'counters': counters.isEmpty ? '-' : counters,
        'stress': DartStress.factor,
      },
      level: SentryLevel.info,
    );
  }

  static String _p(List<double> xs, double q) {
    if (xs.isEmpty) return '0';
    final sorted = [...xs]..sort();
    return sorted[((sorted.length - 1) * q).round()].toStringAsFixed(1);
  }
}
