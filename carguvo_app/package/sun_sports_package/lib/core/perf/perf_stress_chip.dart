import 'package:flutter/widgets.dart';
import 'package:sun_sports/core/perf/dart_stress.dart';
import 'package:sun_sports/core/perf/perf_log.dart';
import 'package:sun_sports/core/perf/stress_binding.dart';

class PerfStressChip extends StatefulWidget {
  const PerfStressChip({required this.child, super.key});

  final Widget child;

  @override
  State<PerfStressChip> createState() => _PerfStressChipState();
}

class _PerfStressChipState extends State<PerfStressChip> {
  static const List<int> _levels = [1, 2, 3, 5];

  void _cycle() {
    final i = _levels.indexOf(DartStress.factor);
    final next = _levels[(i + 1) % _levels.length];
    setState(() => DartStress.factor = next);
    PerfLog.write('stress factor → ×$next');
  }

  @override
  Widget build(BuildContext context) {
    if (!StressWidgetsBinding.installed) return widget.child;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          widget.child,
          Positioned(
            top: 64,
            right: 6,
            child: GestureDetector(
              onTap: _cycle,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: DartStress.factor > 1
                      ? const Color(0xCCD32F2F)
                      : const Color(0x99000000),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '×${DartStress.factor}',
                  style: const TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
