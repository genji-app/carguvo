import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/perf/perf_flags.dart';
import 'package:sun_sports/core/perf/perf_log.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';

abstract final class PerfProbe {
  static const int _rows = 200;
  static const double _extent = 160;
  static const int _steps = 40;
  static bool _done = false;

  static void maybeRun(GlobalKey<NavigatorState> navigatorKey) {
    if (!PerfFlags.trace || !PerfFlags.probe || _done) return;
    _done = true;
    Timer(const Duration(seconds: 12), () {
      final overlay = navigatorKey.currentState?.overlay;
      if (overlay == null) {
        PerfLog.write('probe skipped — no overlay');
        return;
      }
      unawaited(_runAll(overlay));
    });
  }

  static Future<void> _runAll(OverlayState overlay) async {
    PerfLog.write('probe start — $_rows rows, extent $_extent, $_steps steps');
    await _variant(overlay, 'empty', (_) => const SizedBox(height: _extent));
    await _variant(overlay, 'widgets', (i) => _WidgetVolumeRow(seed: i));
    await _variant(overlay, 'appwidgets', (i) => _AppWidgetRow(seed: i));
    await _variant(overlay, 'riverpod', (i) => _RiverpodRow(seed: i));
    await _variant(overlay, 'images', (i) => _ImageRow(seed: i));
    PerfLog.write('probe done');
  }

  static Future<void> _variant(
    OverlayState overlay,
    String name,
    Widget Function(int index) itemBuilder,
  ) async {
    final controller = ScrollController();
    final entry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Material(
          color: const Color(0xFF101010),
          child: ListView.builder(
            controller: controller,
            itemExtent: _extent,
            itemCount: _rows,
            itemBuilder: (context, i) => itemBuilder(i),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    await _frames(4);

    final builds = <double>[];
    void collect(List<FrameTiming> timings) {
      for (final t in timings) {
        builds.add(t.buildDuration.inMicroseconds / 1000);
      }
    }

    SchedulerBinding.instance.addTimingsCallback(collect);
    for (var step = 1; step <= _steps; step++) {
      if (!controller.hasClients) break;
      controller.jumpTo(step * _extent);
      await _frames(1);
    }
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    SchedulerBinding.instance.removeTimingsCallback(collect);
    entry.remove();
    controller.dispose();
    await _frames(2);

    PerfLog.write('probe $name ${_summary(builds)}');
  }

  static Future<void> _frames(int count) async {
    for (var i = 0; i < count; i++) {
      SchedulerBinding.instance.scheduleFrame();
      await SchedulerBinding.instance.endOfFrame;
    }
  }

  static String _summary(List<double> builds) {
    if (builds.isEmpty) return 'no frames';
    final sorted = [...builds]..sort();
    String at(double q) =>
        sorted[((sorted.length - 1) * q).round()].toStringAsFixed(1);
    final sum = builds.fold<double>(0, (a, b) => a + b);
    return 'frames=${builds.length} build p50=${at(.5)} p90=${at(.9)} '
        'max=${at(1)} sum=${sum.toStringAsFixed(0)}ms';
  }
}

class _WidgetVolumeRow extends StatelessWidget {
  const _WidgetVolumeRow({required this.seed});

  final int seed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: PerfProbe._extent,
      child: Column(
        children: [
          for (var r = 0; r < 10; r++)
            Expanded(
              child: Row(
                children: [
                  for (var c = 0; c < 7; c++)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(1),
                        child: SizedBox(
                          height: 10,
                          child: Text(
                            '$seed.$r.$c',
                            style: const TextStyle(fontSize: 6),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _AppWidgetRow extends StatelessWidget {
  const _AppWidgetRow({required this.seed});

  final int seed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: PerfProbe._extent,
      child: Column(
        children: [
          for (var r = 0; r < 10; r++)
            Expanded(
              child: Row(
                children: [
                  for (var c = 0; c < 7; c++)
                    Expanded(child: _ProbeLeaf(label: '$seed.$r.$c')),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ProbeLeaf extends StatelessWidget {
  const _ProbeLeaf({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 10,
      child: Text(label, style: const TextStyle(fontSize: 6)),
    );
  }
}

final _probeA = StateProvider<int>((ref) => 0);
final _probeB = StateProvider<int>((ref) => 0);
final _probeC = StateProvider<int>((ref) => 0);
final _probeD = StateProvider<int>((ref) => 0);

class _RiverpodRow extends StatelessWidget {
  const _RiverpodRow({required this.seed});

  final int seed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: PerfProbe._extent,
      child: Row(
        children: [
          for (var c = 0; c < 7; c++)
            Expanded(
              child: Consumer(
                builder: (context, ref, _) {
                  ref.watch(_probeA);
                  ref.watch(_probeB);
                  ref.watch(_probeC);
                  return Consumer(
                    builder: (context, ref2, __) {
                      ref2.watch(_probeD);
                      return const SizedBox.expand();
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _ImageRow extends StatelessWidget {
  const _ImageRow({required this.seed});

  final int seed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: PerfProbe._extent,
      child: Row(
        children: [
          for (var i = 0; i < 8; i++)
            Expanded(
              child: ImageHelper.load(
                path: AppIcons.iconCurrencyUnit,
                width: 16,
                height: 16,
                fit: BoxFit.contain,
              ),
            ),
        ],
      ),
    );
  }
}
