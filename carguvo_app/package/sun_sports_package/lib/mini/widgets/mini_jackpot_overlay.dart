import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/utils/app_logger.dart';
import 'package:sun_sports/core/utils/extensions/rive_helper.dart';
import 'package:sun_sports/core/utils/sound_effects.dart';
import 'package:sun_sports/core/utils/styles/app_audios.dart';
import 'package:sun_sports/core/utils/styles/app_rive.dart';

class MiniJackpotOverlay extends StatefulWidget {
  final int amount;

  final VoidCallback onClose;

  final bool auto;

  final BorderRadius borderRadius;

  final Widget Function(BuildContext context, int value) amountBuilder;

  const MiniJackpotOverlay({
    required this.amount,
    required this.onClose,
    required this.amountBuilder,
    this.auto = false,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    super.key,
  });

  @override
  State<MiniJackpotOverlay> createState() => _MiniJackpotOverlayState();
}

class _MiniJackpotOverlayState extends State<MiniJackpotOverlay>
    with TickerProviderStateMixin {
  static const String _kArtboard = 'Jackpot';
  static const String _kTrigger = 'triggerJackpot';

  static const Duration _dismissDelay = Duration(milliseconds: 2500);

  static const Duration _highlightHideDelay = Duration(milliseconds: 6300);

  static const Duration _highlightFade = Duration(milliseconds: 200);

  static const Duration _exitDuration = Duration(milliseconds: 400);

  static const double _exitScale = 1.9;

  static const Size _kArtboardSize = Size(360, 740);

  static const Size _kNumberBox = Size(200, 54);

  static const Duration _effectEndDelay = Duration(milliseconds: 6800);

  static const Duration _closeFade = Duration(milliseconds: 400);

  static const Duration _numberRevealDelay = Duration(milliseconds: 800);

  static const Duration _countDuration = Duration(milliseconds: 1000);

  late final AnimationController _count = AnimationController(
    vsync: this,
    duration: _countDuration,
  );

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..repeat(reverse: true);
  late final Animation<double> _pulseScale = Tween<double>(
    begin: 0.92,
    end: 1.10,
  ).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));

  rive.RiveWidgetController? _controller;
  rive.ViewModelInstance? _vmi;

  Timer? _pump;
  Timer? _enableTimer;
  Timer? _highlightTimer;
  Timer? _autoCloseTimer;
  Timer? _closeTimer;
  Timer? _revealTimer;
  bool _canClose = false;
  bool _closed = false;

  bool _showNumber = false;

  bool _hideHighlight = false;

  bool _closing = false;

  final Stopwatch _clock = Stopwatch()..start();

  int get _ms => _clock.elapsedMilliseconds;

  @override
  void initState() {
    super.initState();
    AppLoggers.ui.d('[Jackpot] OPEN amount=${widget.amount} @0ms');
    SoundEffects.instance.playMiniGame(MiniGameSound.jackpot);
    _loadRive();
    _revealTimer = Timer(_numberRevealDelay, () {
      if (!mounted) return;
      AppLoggers.ui.d('[Jackpot] NUMBER ON (reveal) @${_ms}ms');
      setState(() => _showNumber = true);
      _count.forward();
    });
    _enableTimer = Timer(_dismissDelay, () {
      if (mounted) setState(() => _canClose = true);
    });
    _highlightTimer = Timer(_highlightHideDelay, () {
      if (!mounted) return;
      AppLoggers.ui.d('[Jackpot] HIDE number+scrim (khớp Rive thu chữ) @${_ms}ms');
      setState(() => _hideHighlight = true);
    });
    _autoCloseTimer = Timer(_effectEndDelay, () {
      AppLoggers.ui.d('[Jackpot] EFFECT END → dispose @${_ms}ms');
      _closeNow();
    });
  }

  void _onRiveSettled() {
    if (!mounted || _closed || _closing) return;
    AppLoggers.ui.d('[Jackpot] RIVE SETTLE (off) @${_ms}ms (auto-close tắt)');
  }

  void _onRivePlayStart() {
    AppLoggers.ui.d('[Jackpot] RIVE PLAY START (on) @${_ms}ms');
  }

  void _closeNow() {
    if (_closed || !mounted) return;
    _closed = true;
    AppLoggers.ui.d('[Jackpot] DISPOSE (Rive + số tắt) @${_ms}ms');
    widget.onClose();
  }

  void _beginClose() {
    if (_closed || _closing || !mounted) return;
    AppLoggers.ui.d('[Jackpot] FADE-CLOSE start @${_ms}ms');
    setState(() => _closing = true);
    _closeTimer = Timer(_closeFade, () {
      if (mounted) _closeNow();
    });
  }

  Future<void> _loadRive() async {
    try {
      final file = await RiveHelper.getFile(AppRive.jackpotMiniGame);
      if (file == null || !mounted) return;

      _JackpotRiveController controller;
      try {
        controller = _JackpotRiveController(
          file,
          artboardSelector: rive.ArtboardSelector.byName(_kArtboard),
        );
      } catch (_) {
        controller = _JackpotRiveController(file);
      }
      controller.onSettled = _onRiveSettled;
      controller.onPlayStart = _onRivePlayStart;
      controller.onPlayingChanged = (playing, advMs) => AppLoggers.ui
          .d('[Jackpot] rive playing=$playing @${_ms}ms (advElapsed=${advMs}ms)');

      try {
        final vmi = controller.dataBind(rive.DataBind.auto());
        _vmi = vmi;
        vmi.trigger(_kTrigger)?.trigger();
        AppLoggers.ui.d('[Jackpot] rive ready + trigger fired @${_ms}ms');
      } catch (_) {
      }

      if (!mounted) {
        controller.dispose();
        return;
      }
      setState(() => _controller = controller);
      _startPump();
    } catch (_) {
    }
  }

  void _startPump() {
    _pump?.cancel();
    _pump = Timer.periodic(const Duration(milliseconds: 16), (_) {
      _controller?.scheduleRepaint();
    });
  }

  @override
  void dispose() {
    AppLoggers.ui.d('[Jackpot] DISPOSE (overlay gỡ khỏi cây) @${_ms}ms');
    _clock.stop();
    _enableTimer?.cancel();
    _highlightTimer?.cancel();
    _autoCloseTimer?.cancel();
    _closeTimer?.cancel();
    _revealTimer?.cancel();
    _pump?.cancel();
    _count.dispose();
    _pulse.dispose();
    _vmi?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  void _tryClose() {
    if (!_canClose) return;
    AppLoggers.ui.d('[Jackpot] TAP close @${_ms}ms');
    _beginClose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return AnimatedOpacity(
      opacity: _closing ? 0 : 1,
      duration: _closeFade,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _tryClose,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedOpacity(
              opacity: _hideHighlight ? 0 : 1,
              duration: _highlightFade,
              child: const ColoredBox(color: Color(0x66000000)),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final scale = math.min(
                  constraints.maxWidth / _kArtboardSize.width,
                  constraints.maxHeight / _kArtboardSize.height,
                );
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    if (controller != null)
                      rive.RiveWidget(
                        controller: controller,
                        fit: rive.Fit.contain,
                      ),
                    Center(
                      child: SizedBox(
                        width: _kArtboardSize.width * scale,
                        height: _kArtboardSize.height * scale,
                        child: Align(
                          alignment: const Alignment(0, -0.095),
                          child: Transform.scale(
                            scale: scale,
                            child: _buildNumber(),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            Align(
              alignment: const Alignment(0, 0.88),
              child: AnimatedOpacity(
                opacity: (_canClose && !_hideHighlight) ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                child: const Text(
                  I18n.mgTapToContinue,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumber() {
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: (_showNumber && !_hideHighlight) ? 1 : 0,
        duration: _hideHighlight ? _exitDuration : const Duration(milliseconds: 200),
        child: AnimatedScale(
          scale: _hideHighlight ? _exitScale : (_showNumber ? 1.0 : 0.6),
          duration: _hideHighlight ? _exitDuration : const Duration(milliseconds: 320),
          curve: _hideHighlight ? Curves.easeOut : Curves.easeOutBack,
          child: AnimatedBuilder(
            animation: _pulseScale,
            builder: (context, child) => Transform.scale(
              scale: _hideHighlight ? 1.0 : _pulseScale.value,
              child: child,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [Color(0x99000000), Color(0x00000000)],
                  radius: 0.75,
                ),
              ),
              child: SizedBox.fromSize(
                size: _kNumberBox,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: AnimatedBuilder(
                    animation: _count,
                    builder: (context, _) {
                      final v = (widget.amount * _count.value).floor();
                      return widget.amountBuilder(context, v);
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

base class _JackpotRiveController extends rive.RiveWidgetController {
  _JackpotRiveController(super.file, {super.artboardSelector});

  VoidCallback? onSettled;

  VoidCallback? onPlayStart;

  void Function(bool playing, int advMs)? onPlayingChanged;

  double _elapsed = 0;

  int _idleFrames = 0;
  bool _fired = false;
  bool _started = false;
  bool? _wasPlaying;

  static const double _minPlaySeconds = 3.0;

  static const int _idleFramesToSettle = 5;

  @override
  bool advance(double elapsedSeconds) {
    final playing = super.advance(elapsedSeconds);
    _elapsed += elapsedSeconds;
    final advMs = (_elapsed * 1000).round();

    if (playing && !_started) {
      _started = true;
      onPlayStart?.call();
    }
    if (_wasPlaying != playing) {
      _wasPlaying = playing;
      onPlayingChanged?.call(playing, advMs);
    }

    if (playing) {
      _idleFrames = 0;
    } else {
      _idleFrames++;
    }
    if (!_fired &&
        _elapsed >= _minPlaySeconds &&
        _idleFrames >= _idleFramesToSettle) {
      _fired = true;
      onSettled?.call();
    }
    return playing;
  }
}
