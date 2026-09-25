import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:sun_sports/core/utils/network_manger.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';

import '../../common/volta_colors.dart';
import '../../common/volta_music.dart';
import 'volta_live_preloader.dart';

class VoltaLivePlayer extends StatefulWidget {
  const VoltaLivePlayer({
    required this.url,
    required this.startSecond,
    super.key,
  });

  final String url;

  final int startSecond;

  @override
  State<VoltaLivePlayer> createState() => _VoltaLivePlayerState();
}

enum _LiveAttempt {
  full,

  noSeek,

  plain;

  bool get seek => this == _LiveAttempt.full;
  bool get mixAudio => this != _LiveAttempt.plain;

  _LiveAttempt? get next => switch (this) {
    _LiveAttempt.full => _LiveAttempt.noSeek,
    _LiveAttempt.noSeek => _LiveAttempt.plain,
    _LiveAttempt.plain => null,
  };
}

class _VoltaLivePlayerState extends State<VoltaLivePlayer>
    with WidgetsBindingObserver {
  VideoPlayerController? _controller;

  bool _suspended = false;
  bool _offline = false;

  DateTime? _leftAt;
  static const Duration _resyncAfter = Duration(seconds: 2);

  StreamSubscription<NetworkManagerEvent>? _netSub;

  int _generation = 0;

  bool _ready = false;
  bool _failed = false;
  bool _muted = true;

  _LiveAttempt _attempt = _LiveAttempt.full;

  bool _verdictPrinted = false;

  bool _errorPrinted = false;

  VoidCallback? _errorHook;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _netSub = NetworkManager.instance.stream.listen(_onNetwork);
    unawaited(_open());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        final DateTime? leftAt = _leftAt;
        _leftAt = null;
        if (_suspended) {
          _suspended = false;
          if (!_offline) _resync();
        } else if (leftAt != null &&
            DateTime.now().difference(leftAt) >= _resyncAfter) {
          _resync();
        }
      case AppLifecycleState.inactive:
        _leftAt ??= DateTime.now();
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _leftAt ??= DateTime.now();
        _suspend();
    }
  }

  void _onNetwork(NetworkManagerEvent event) {
    switch (event) {
      case NetworkManagerEvent.connectionLost:
        _offline = true;
        _suspend();
      case NetworkManagerEvent.connectionRestored:
        _offline = false;
        final bool foreground = WidgetsBinding.instance.lifecycleState ==
            AppLifecycleState.resumed;
        if (!foreground) {
          if (mounted) setState(() {});
          return;
        }
        _suspended = false;
        _resync();
    }
  }

  void _suspend() {
    if (_suspended) {
      if (mounted) setState(() {});
      return;
    }
    _suspended = true;
    _watchdog?.cancel();
    _watchdog = null;
    unawaited(_close());
    if (mounted) setState(() => _ready = false);
  }

  void _resync() {
    if (!mounted || _suspended) return;
    _attempt = _LiveAttempt.full;
    _verdictPrinted = false;
    unawaited(_restart());
  }

  @override
  void didUpdateWidget(VoltaLivePlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      unawaited(_close());
      unawaited(_open());
    }
  }

  Future<void> _open() async {
    final int gen = ++_generation;
    final Uri? uri = Uri.tryParse(widget.url);
    if (uri == null || !uri.hasScheme) {
      if (kDebugMode) {
        debugPrint('[VoltaLive] link KHÔNG hợp lệ: "${widget.url}"');
      }
      if (mounted) setState(() => _failed = true);
      return;
    }
    if (kDebugMode) debugPrint('[VoltaLive] mở (lượt $gen): ${widget.url}');

    final Stopwatch clock = Stopwatch()..start();

    final VideoPlayerController? warm = _attempt == _LiveAttempt.full
        ? await VoltaLivePreloader.instance.take(widget.url)
        : null;
    if (!mounted || gen != _generation) {
      await warm?.dispose();
      return;
    }

    final bool preloaded = warm != null;
    final VideoPlayerController controller =
        warm ??
        VideoPlayerController.networkUrl(
          uri,
          videoPlayerOptions: VideoPlayerOptions(
            mixWithOthers: _attempt.mixAudio,
          ),
        );
    _controller = controller;

    try {
      if (!preloaded) {
        await controller.initialize();
        if (!mounted || gen != _generation) {
          await controller.dispose();
          return;
        }
        await controller.setVolume(0);
        await controller.setLooping(false);
      }

      await controller.play();
      if (!_muted) await controller.setVolume(1);
      if (!mounted || gen != _generation) return;
      final Duration skip = _attempt.seek
          ? _syncToLive(controller, controller.value, force: true)
          : Duration.zero;

      if (!mounted || gen != _generation) return;
      if (kDebugMode) {
        debugPrint(
          '[VoltaLive] chạy sau ${clock.elapsedMilliseconds}ms · '
          'nấc ${_attempt.name} · ${preloaded ? 'NẠP SẴN' : 'dựng mới'} · '
          'tua ${skip.inSeconds}s · trộn audio ${_attempt.mixAudio} · '
          'dài ${controller.value.duration.inSeconds}s',
        );
      }
      setState(() => _ready = true);
      VoltaMusic.instance.setDucked(true);
      _listenForError(controller);
      _startWatchdog();
    } on Object catch (e, st) {
      if (kDebugMode) {
        debugPrint(
          '[VoltaLive] LỖI sau ${clock.elapsedMilliseconds}ms '
          '(nấc ${_attempt.name}) — $e',
        );
        debugPrintStack(stackTrace: st, maxFrames: 6);
      }
      if (mounted && gen == _generation) setState(() => _failed = true);
    }
  }

  static const Duration _watchdogTick = Duration(seconds: 2);

  static const int _stuckTicks = 3;

  Timer? _watchdog;
  Duration _lastPosition = Duration.zero;
  int _stuckCount = 0;

  void _listenForError(VideoPlayerController controller) {
    _errorPrinted = false;
    void hook() {
      if (!kDebugMode || _errorPrinted) return;
      final VideoPlayerValue v = controller.value;
      if (!v.hasError) return;
      _errorPrinted = true;
      debugPrint('[VoltaLive] ⚠ PLAYER BÁO LỖI — ${v.errorDescription}');
    }

    _errorHook = hook;
    controller.addListener(hook);
  }

  static const Duration _driftTolerance = Duration(seconds: 4);

  static const Duration _syncCooldown = Duration(seconds: 10);

  DateTime? _lastSyncAt;

  Duration _syncToLive(
    VideoPlayerController controller,
    VideoPlayerValue value, {
    bool force = false,
  }) {
    if (widget.startSecond <= 0) return Duration.zero;
    if (!force && (!value.isPlaying || value.isBuffering)) {
      return Duration.zero;
    }
    final DateTime now = DateTime.now();
    final DateTime? last = _lastSyncAt;
    if (!force && last != null && now.difference(last) < _syncCooldown) {
      return Duration.zero;
    }

    final Duration expected = Duration(
      milliseconds: now.millisecondsSinceEpoch - widget.startSecond * 1000,
    );
    if (expected <= Duration.zero) return Duration.zero;
    Duration target = expected;
    final Duration total = value.duration;
    if (!force && total > Duration.zero && target > total) {
      target = total - const Duration(seconds: 1);
    }
    final Duration drift = target - value.position;
    if (!force && drift.abs() < _driftTolerance) return Duration.zero;

    _lastSyncAt = now;
    if (kDebugMode) {
      debugPrint(
        '[VoltaLive] ${force ? 'mở — tua tới live' : 'lệch live'} '
        '${drift.inMilliseconds}ms (đang ${value.position.inSeconds}s, '
        'live ${expected.inSeconds}s, dài ${total.inSeconds}s) — tua về '
        '${target.inSeconds}s',
      );
    }
    unawaited(controller.seekTo(target));
    return target;
  }

  void _startWatchdog() {
    _watchdog?.cancel();
    _lastPosition = Duration.zero;
    _stuckCount = 0;
    _watchdog = Timer.periodic(_watchdogTick, (_) => _checkAlive());
  }

  void _checkAlive() {
    final VideoPlayerController? controller = _controller;
    if (!mounted || controller == null) return;
    final VideoPlayerValue value = controller.value;
    if (!value.isInitialized) return;

    if (value.position != _lastPosition) {
      final bool wasFirstMove = _lastPosition == Duration.zero;
      _lastPosition = value.position;
      _stuckCount = 0;
      if (kDebugMode &&
          !wasFirstMove &&
          !_verdictPrinted &&
          _attempt != _LiveAttempt.full) {
        _verdictPrinted = true;
        debugPrint(
          '[VoltaLive] ✓ nấc ${_attempt.name} CHẠY ĐƯỢC ⇒ thủ phạm là '
          '${_attempt == _LiveAttempt.noSeek ? 'seekTo' : 'mixWithOthers'}',
        );
      }
      _syncToLive(controller, value);
      return;
    }

    _stuckCount++;
    if (_stuckCount < _stuckTicks) return;
    _stuckCount = 0;

    final _LiveAttempt? next = _attempt.next;
    if (next == null) {
      _watchdog?.cancel();
      _watchdog = null;
      if (kDebugMode) {
        debugPrint(
          '[VoltaLive] đứng tại ${value.position.inSeconds}s ở nấc cuối '
          '(${_attempt.name}, đệm: ${value.isBuffering}, lỗi: '
          '${value.errorDescription ?? 'không'}) — hết nấc để thử. '
          'Cả ba cấu hình đều tắc ⇒ vấn đề KHÔNG nằm ở tham số player.',
        );
      }
      return;
    }

    if (kDebugMode) {
      debugPrint(
        '[VoltaLive] đứng ${_stuckTicks * _watchdogTick.inSeconds}s tại '
        '${value.position.inSeconds}s (nấc ${_attempt.name}, đệm: '
        '${value.isBuffering}, lỗi: ${value.errorDescription ?? 'không'}) — '
        'hạ xuống nấc ${next.name}',
      );
    }
    _attempt = next;
    unawaited(_restart());
  }

  Future<void> _restart() async {
    _watchdog?.cancel();
    _watchdog = null;
    await _close();
    if (!mounted || _suspended) return;
    setState(() {
      _ready = false;
      _failed = false;
    });
    unawaited(_open());
  }

  Future<void> _close() async {
    _generation++;
    final VideoPlayerController? controller = _controller;
    final VoidCallback? hook = _errorHook;
    _errorHook = null;
    if (hook != null) controller?.removeListener(hook);
    _controller = null;
    _ready = false;
    await controller?.dispose();
  }

  void _toggleMute() {
    final VideoPlayerController? controller = _controller;
    if (controller == null) return;
    setState(() => _muted = !_muted);
    unawaited(controller.setVolume(_muted ? 0 : 1));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_netSub?.cancel());
    _netSub = null;
    _watchdog?.cancel();
    _watchdog = null;
    unawaited(_close());
    VoltaMusic.instance.setDucked(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final VideoPlayerController? controller = _controller;
    if (_offline) {
      return const _LiveFallback(
        message: 'Mất kết nối — sẽ quay lại trực tiếp khi có mạng',
      );
    }
    if (_failed) return const _LiveFallback(message: 'Không tải được video');
    if (!_ready || controller == null) {
      return const _LiveFallback(message: 'Đang kết nối video…', spinner: true);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _toggleMute,
      child: ColoredBox(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            RepaintBoundary(
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: controller.value.size.width,
                  height: controller.value.size.height,
                  child: VideoPlayer(controller),
                ),
              ),
            ),
            if (_muted)
              const Positioned(
                right: 8,
                bottom: 8,
                child: _MuteBadge(),
              ),
          ],
        ),
      ),
    );
  }
}

class _MuteBadge extends StatelessWidget {
  const _MuteBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.volume_off,
              size: 14,
              color: VoltaColors.contentPrimary,
            ),
            const SizedBox(width: 5),
            Text(
              'Chạm để bật tiếng',
              style: AppTextStyles.labelXSmall(
                color: VoltaColors.contentPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveFallback extends StatelessWidget {
  const _LiveFallback({required this.message, this.spinner = false});

  final String message;
  final bool spinner;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (spinner)
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Icon(
              Icons.sports_soccer,
              size: 36,
              color: VoltaColors.contentPrimary.withAlpha(160),
            ),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppTextStyles.labelXSmall(
              color: VoltaColors.contentSecondary,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
