import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

class MiniGameOpenTrace {
  const MiniGameOpenTrace._();

  static Stopwatch? _clock;
  static TimingsCallback? _frameHook;

  static Timer? _beat;
  static int _lastBeatMs = 0;
  static int _worstGapMs = 0;
  static int _beatCount = 0;
  static const int _beatEveryMs = 20;

  static int _worstBuildMs = 0;
  static int _worstRasterMs = 0;

  static const Duration _keepWatching = Duration(seconds: 3);
  static Timer? _tail;

  static const int _interestingMs = 250;

  static void tap() {
    if (!kDebugMode) return;
    stop();
    _clock = Stopwatch()..start();
    debugPrint('[MiniGameOpen] chạm FAB');
    _frameHook = _onFrames;
    SchedulerBinding.instance.addTimingsCallback(_frameHook!);

    _lastBeatMs = 0;
    _worstGapMs = 0;
    _beatCount = 0;
    _worstBuildMs = 0;
    _worstRasterMs = 0;
    _beat = Timer.periodic(
      const Duration(milliseconds: _beatEveryMs),
      (_) => _onBeat(),
    );
  }

  static void _onBeat() {
    final Stopwatch? clock = _clock;
    if (clock == null) return;
    final int now = clock.elapsedMilliseconds;
    final int gap = now - _lastBeatMs;
    if (gap > _worstGapMs) _worstGapMs = gap;
    _lastBeatMs = now;
    _beatCount++;
  }

  static void mark(String label, {bool last = false}) {
    final Stopwatch? clock = _clock;
    if (clock == null) return;
    debugPrint(
      '[MiniGameOpen]   +${clock.elapsedMilliseconds}ms  · $label'
      '${last ? '  ⟵ TỔNG' : ''}',
    );
    if (!last) return;

    final int total = clock.elapsedMilliseconds;
    if (total < _interestingMs) {
      stop();
      return;
    }
    debugPrint('[MiniGameOpen]   (giữ đồ đo thêm ${_keepWatching.inSeconds}s '
        'để đợi số liệu raster)');
    if (_beatCount < 2) {
      debugPrint(
        '[MiniGameOpen]   ⇒ nhịp Dart: chỉ $_beatCount mẫu — KHÔNG đủ để kết '
        'luận. (Lượt này chậm nhưng nhịp tim không kịp chạy.)',
      );
      _tail = Timer(_keepWatching, _finish);
      return;
    }

    final bool stalled = _worstGapMs > _beatEveryMs * 3;
    debugPrint(
      stalled
          ? '[MiniGameOpen]   ⇒ nhịp Dart: NGHẼN ${_worstGapMs}ms '
                '($_beatCount mẫu) — luồng Dart BẬN, tìm hàm đồng bộ chạy lâu.'
          : '[MiniGameOpen]   ⇒ nhịp Dart: tick đều, trễ nhất ${_worstGapMs}ms '
                '($_beatCount mẫu) — luồng Dart RẢNH, nghẽn ở luồng platform.',
    );
    _tail = Timer(_keepWatching, _finish);
  }

  static void stop() {
    _tail?.cancel();
    _tail = null;
    _beat?.cancel();
    _beat = null;
    final TimingsCallback? hook = _frameHook;
    if (hook != null) {
      SchedulerBinding.instance.removeTimingsCallback(hook);
      _frameHook = null;
    }
    _clock = null;
  }

  static const int _slowFrameMs = 100;

  static void _onFrames(List<FrameTiming> timings) {
    final Stopwatch? clock = _clock;
    if (clock == null) return;
    for (final FrameTiming t in timings) {
      final int build = t.buildDuration.inMilliseconds;
      final int raster = t.rasterDuration.inMilliseconds;
      if (build > _worstBuildMs) _worstBuildMs = build;
      if (raster > _worstRasterMs) _worstRasterMs = raster;
      if (build + raster < _slowFrameMs) continue;
      debugPrint(
        '[MiniGameOpen]   +${clock.elapsedMilliseconds}ms  · KHUNG CHẬM: '
        'dựng ${build}ms · raster ${raster}ms',
      );
    }
  }

  static void _finish() {
    debugPrint(
      '[MiniGameOpen]   ⇒ khung nặng nhất: dựng ${_worstBuildMs}ms · '
      'raster ${_worstRasterMs}ms',
    );
    if (_worstRasterMs > _worstBuildMs * 3 && _worstRasterMs > _slowFrameMs) {
      debugPrint(
        '[MiniGameOpen]   ⇒ nghẽn ở RASTER — GPU/texture/shader, không phải '
        'code Dart. Isolate không giúp gì ở đây.',
      );
    }
    stop();
  }
}
