import 'package:flutter/widgets.dart';
import 'package:sport_socket/sport_socket.dart' show SportSocketPerfHooks;
import 'package:sun_sports/core/perf/dart_stress.dart';
import 'package:sun_sports/core/perf/perf_flags.dart';
import 'package:sun_sports/core/perf/stall_monitor.dart';

class StressWidgetsBinding extends WidgetsFlutterBinding {
  StressBuildOwner? _stressOwner;

  static bool installed = false;

  static WidgetsBinding ensureInitialized() {
    final existing = _existingBinding();
    if (existing == null) {
      StressWidgetsBinding();
      installed = true;
    }
    SportSocketPerfHooks.wrap = DartStress.timed;
    return WidgetsBinding.instance;
  }

  static WidgetsBinding? _existingBinding() {
    try {
      return WidgetsBinding.instance;
    } catch (_) {
      return null;
    }
  }

  @override
  BuildOwner? get buildOwner => _stressOwner ?? super.buildOwner;

  @override
  void initInstances() {
    super.initInstances();
    final base = super.buildOwner!;
    _stressOwner = StressBuildOwner(
      onBuildScheduled: base.onBuildScheduled,
      focusManager: base.focusManager,
    );
  }
}

class StressBuildOwner extends BuildOwner {
  StressBuildOwner({super.onBuildScheduled, super.focusManager});

  @override
  void buildScope(Element context, [VoidCallback? callback]) {
    if (!PerfFlags.trace) return super.buildScope(context, callback);
    final sw = Stopwatch()..start();
    super.buildScope(context, callback);
    final elapsed = sw.elapsedMicroseconds;
    PerfWork.add('build.total', elapsed);
    if (DartStress.enabled) {
      DartStress.burnMicros(elapsed * (DartStress.factor - 1));
    }
  }
}
