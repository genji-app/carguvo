import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

class VoltaLivePreloader {
  VoltaLivePreloader._();

  static final VoltaLivePreloader instance = VoltaLivePreloader._();

  String? _url;
  Future<VideoPlayerController?>? _pending;

  void warm(String url) {
    if (url.isEmpty || url == _url) return;

    unawaited(_disposePending());

    _url = url;
    _pending = _create(url);
    if (kDebugMode) debugPrint('[VoltaLive] nạp sẵn: $url');
  }

  Future<VideoPlayerController?> take(String url) async {
    if (url.isEmpty || url != _url) return null;
    final Future<VideoPlayerController?>? pending = _pending;
    if (pending == null) return null;

    _url = null;
    _pending = null;
    final VideoPlayerController? controller = await pending;
    if (kDebugMode) {
      debugPrint(
        controller == null
            ? '[VoltaLive] nạp sẵn hỏng — dựng lại từ đầu'
            : '[VoltaLive] dùng controller đã nạp sẵn ✓',
      );
    }
    return controller;
  }

  Future<void> clear() {
    _url = null;
    return _disposePending();
  }

  Future<VideoPlayerController?> _create(String url) async {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) return null;

    final VideoPlayerController controller = VideoPlayerController.networkUrl(
      uri,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    final Stopwatch clock = Stopwatch()..start();
    try {
      await controller.initialize();
      await controller.setVolume(0);
      await controller.setLooping(false);
      if (kDebugMode) {
        debugPrint(
          '[VoltaLive] nạp sẵn xong sau ${clock.elapsedMilliseconds}ms · '
          'cỡ ${controller.value.size.width.toInt()}×'
          '${controller.value.size.height.toInt()} · '
          'dài ${controller.value.duration.inSeconds}s',
        );
      }
      return controller;
    } on Object catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[VoltaLive] nạp sẵn LỖI sau ${clock.elapsedMilliseconds}ms — $e',
        );
      }
      await controller.dispose();
      return null;
    }
  }

  Future<void> _disposePending() async {
    final Future<VideoPlayerController?>? pending = _pending;
    _pending = null;
    if (pending == null) return;
    try {
      final VideoPlayerController? controller = await pending;
      await controller?.dispose();
    } on Object {
    }
  }
}
