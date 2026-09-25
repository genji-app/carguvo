import 'package:sun_sports/core/perf/perf_flags.dart';
import 'package:sun_sports/core/perf/stall_monitor.dart';

abstract final class DartStress {
  static int factor = PerfFlags.dartStress < 1 ? 1 : PerfFlags.dartStress;

  static bool get enabled => PerfFlags.trace && factor > 1;

  static T timed<T>(String label, T Function() body) {
    if (!PerfFlags.trace) return body();
    final sw = Stopwatch()..start();
    final result = body();
    if (enabled) burnMicros(sw.elapsedMicroseconds * (factor - 1));
    PerfWork.add(label, sw.elapsedMicroseconds);
    return result;
  }

  static Future<T> timedAsync<T>(String label, Future<T> Function() body) async {
    if (!PerfFlags.trace) return body();
    final sw = Stopwatch()..start();
    final result = await body();
    PerfWork.add(label, sw.elapsedMicroseconds);
    return result;
  }

  static void burnMicros(int micros) {
    if (micros <= 0) return;
    final sw = Stopwatch()..start();
    var x = 0;
    while (sw.elapsedMicroseconds < micros) {
      x = (x * 1103515245 + 12345) & 0x7fffffff;
    }
  }
}
