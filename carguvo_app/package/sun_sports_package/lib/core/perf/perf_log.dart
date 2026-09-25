import 'dart:io' show Directory, File, FileMode;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sun_sports/core/perf/perf_flags.dart';

abstract final class PerfLog {
  static final Stopwatch clock = Stopwatch()..start();

  static File? _file;
  static bool _fileOpened = false;

  static void write(String line) {
    if (!PerfFlags.trace) return;
    final msg = '[PERF +${clock.elapsedMilliseconds}ms] $line';
    // ignore: avoid_print
    print(msg);
    if (kIsWeb) return;
    try {
      if (!_fileOpened) {
        _fileOpened = true;
        _file = File('${Directory.systemTemp.path}/perf_trace.log')
          ..writeAsStringSync('');
      }
      _file?.writeAsStringSync('$msg\n', mode: FileMode.append);
    } catch (_) {
      _file = null;
    }
  }

  static void flush() {}
}

abstract final class StartupTrace {
  static final List<({String name, int start, int end})> _spans = [];
  static final Map<String, int> _open = {};
  static bool _finished = false;

  static void begin() {
    if (!PerfFlags.trace) return;
    PerfLog.clock;
    PerfLog.write('startup main()');
  }

  static void mark(String name) {
    if (!PerfFlags.trace || _finished) return;
    final now = PerfLog.clock.elapsedMilliseconds;
    _spans.add((name: name, start: now, end: now));
    PerfLog.write('startup • $name');
  }

  static void start(String name) {
    if (!PerfFlags.trace || _finished) return;
    _open.putIfAbsent(name, () => PerfLog.clock.elapsedMilliseconds);
  }

  static void end(String name) {
    if (!PerfFlags.trace || _finished) return;
    final start = _open.remove(name);
    if (start == null) return;
    final now = PerfLog.clock.elapsedMilliseconds;
    _spans.add((name: name, start: start, end: now));
    PerfLog.write('startup ■ $name ${now - start}ms (from +${start}ms)');
  }

  static Future<T> time<T>(String name, Future<T> Function() body) async {
    if (!PerfFlags.trace || _finished) return body();
    start(name);
    try {
      return await body();
    } finally {
      end(name);
    }
  }

  static void finish(String name) {
    if (!PerfFlags.trace || _finished) return;
    mark(name);
    _finished = true;
    final sorted = [..._spans]..sort((a, b) => a.start.compareTo(b.start));
    final buf = StringBuffer('startup WATERFALL\n');
    for (final s in sorted) {
      final dur = s.end - s.start;
      buf.writeln(
        '  ${s.start.toString().padLeft(6)}ms '
        '${dur == 0 ? '     •' : '${dur.toString().padLeft(5)}ms'}  ${s.name}',
      );
    }
    PerfLog.write(buf.toString());
    PerfLog.flush();
  }
}
