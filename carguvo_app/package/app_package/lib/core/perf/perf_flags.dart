abstract final class PerfFlags {
  static const bool trace = bool.fromEnvironment('PERF_TRACE');

  static const int dartStress =
      int.fromEnvironment('DART_STRESS', defaultValue: 1);

  static const bool probe = bool.fromEnvironment('PERF_PROBE');

  static const int stallMs =
      int.fromEnvironment('PERF_STALL_MS', defaultValue: 250);
}
