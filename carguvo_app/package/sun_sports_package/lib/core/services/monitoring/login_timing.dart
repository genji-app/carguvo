import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:sentry_flutter/sentry_flutter.dart' show SentryLevel;
import 'package:sun_sports/core/services/monitoring/sentry_service.dart';
import 'package:sun_sports/core/utils/app_logger.dart';

class LoginTiming {
  LoginTiming._(this.source, this._clock, this._sink) : _startedAt = _clock();

  static const Duration slowThreshold = Duration(seconds: 5);

  static LoginTiming? current;

  final String source;
  final DateTime Function() _clock;
  final void Function(LoginTimingReport report) _sink;
  final DateTime _startedAt;

  final Map<String, int> _steps = <String, int>{};
  final Map<String, DateTime> _stepStarts = <String, DateTime>{};
  final Map<String, Object?> _details = <String, Object?>{};
  String? _openStep;
  DateTime? _openedAt;
  bool _finished = false;

  static LoginTiming start(
    String source, {
    @visibleForTesting DateTime Function()? clock,
    @visibleForTesting void Function(LoginTimingReport report)? sink,
  }) {
    current?.finish('abandoned');
    return current = LoginTiming._(
      source,
      clock ?? DateTime.now,
      sink ?? LoginTimingReport.publish,
    );
  }

  void step(String name) {
    if (_finished) return;
    _closeStep();
    _openStep = name;
    _openedAt = _clock();
    _stepStarts.putIfAbsent(name, () => _openedAt!);
  }

  void note(String key, Object? value) {
    if (_finished) return;
    _details[key] = value;
  }

  LoginTimingReport? finish(String outcome) {
    if (_finished) return null;
    _finished = true;
    _closeStep();
    if (identical(current, this)) current = null;
    final report = LoginTimingReport(
      source: source,
      outcome: outcome,
      startedAt: _startedAt,
      totalMs: _clock().difference(_startedAt).inMilliseconds,
      steps: Map.unmodifiable(_steps),
      stepStarts: Map.unmodifiable(_stepStarts),
      details: Map.unmodifiable(_details),
    );
    _sink(report);
    return report;
  }

  void _closeStep() {
    final name = _openStep;
    final openedAt = _openedAt;
    if (name == null || openedAt == null) return;
    _steps[name] =
        (_steps[name] ?? 0) + _clock().difference(openedAt).inMilliseconds;
    _openStep = null;
    _openedAt = null;
  }
}

class LoginTimingReport {
  const LoginTimingReport({
    required this.source,
    required this.outcome,
    required this.startedAt,
    required this.totalMs,
    required this.steps,
    required this.stepStarts,
    required this.details,
  });

  final String source;
  final String outcome;

  final DateTime startedAt;
  final int totalMs;

  final Map<String, int> steps;

  final Map<String, DateTime> stepStarts;

  final Map<String, Object?> details;

  bool get isSlow => totalMs >= LoginTiming.slowThreshold.inMilliseconds;

  MapEntry<String, int>? get slowest {
    MapEntry<String, int>? best;
    for (final entry in steps.entries) {
      if (best == null || entry.value > best.value) best = entry;
    }
    return best;
  }

  String get stepsSummary =>
      steps.entries.map((e) => '${e.key}=${e.value}').join(' ');

  String get stepStartsSummary => stepStarts.entries
      .map((e) => '${e.key}@${_utc(e.value)}')
      .join(' ');

  String get detailsSummary =>
      details.entries.map((e) => '${e.key}: ${e.value}').join('; ');

  static String _utc(DateTime t) => t.toUtc().toIso8601String();

  static void publish(LoginTimingReport report) {
    final line = 'login timing: $report';
    if (report.isSlow) {
      AppLoggers.auth.w(line);
      SentryService.captureDiagnostic(
        'login-slow',
        {
          'source': report.source,
          'outcome': report.outcome,
          'started_at': _utc(report.startedAt),
          'total_ms': report.totalMs,
          'slowest_step': report.slowest?.key,
          'slowest_ms': report.slowest?.value,
          'steps': report.stepsSummary,
          'steps_at': report.stepStartsSummary,
          ...report.details,
        },
        level: SentryLevel.warning,
      );
    } else {
      AppLoggers.auth.i(line);
    }
  }

  @override
  String toString() {
    final buffer = StringBuffer(
      '$outcome source=$source started=${_utc(startedAt)} total=${totalMs}ms',
    );
    if (steps.isNotEmpty) buffer.write(' $stepsSummary [$stepStartsSummary]');
    if (details.isNotEmpty) buffer.write(' {$detailsSummary}');
    return buffer.toString();
  }
}
