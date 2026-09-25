import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

import 'package:sun_sports/core/utils/app_logger.dart';
import 'package:sun_sports/core/utils/extensions/rive_helper.dart';
import 'package:sun_sports/core/utils/styles/app_rive.dart';
import 'package:sun_sports/mini/dragon_ball/widgets/dragon_ball_symbols.dart';

class DragonBallReelsRive extends StatefulWidget {
  final List<int> entrySymbols;

  final List<int>? resultSymbols;

  final Set<int> winCells;

  final bool dimAll;

  final int winToken;

  final int jackpotToken;

  final bool turbo;

  final int spinStartToken;

  final int resultToken;

  final bool roundInProgress;

  final VoidCallback? onRoundDone;

  final rive.Fit fit;

  const DragonBallReelsRive({
    required this.entrySymbols,
    this.resultSymbols,
    this.winCells = const {},
    this.dimAll = false,
    this.winToken = 0,
    this.jackpotToken = 0,
    this.turbo = false,
    this.spinStartToken = 0,
    this.resultToken = 0,
    this.roundInProgress = false,
    this.onRoundDone,
    this.fit = rive.Fit.contain,
    super.key,
  });

  @override
  State<DragonBallReelsRive> createState() => _DragonBallReelsRiveState();
}

base class _SpeedControlledRiveController extends rive.RiveWidgetController {
  _SpeedControlledRiveController(super.file, {super.artboardSelector});

  double speed = 1.0;

  @override
  bool advance(double elapsedSeconds) => super.advance(elapsedSeconds * speed);
}

class _DragonBallReelsRiveState extends State<DragonBallReelsRive> {
  static const int _reelCount = 5;
  static const int _rowCount = 3;

  static const String _kArtboard = 'Main';

  static const List<String> _kReelNames = [
    'mainreel1',
    'mainreel2',
    'mainreel3',
    'multireel1',
    'multireel2',
  ];

  static const List<String> _kUnitNames = [
    'roundunit01',
    'roundunit02',
    'roundunit03',
  ];

  static const String _kRank = 'rank';
  static const String _kIsWin = 'iswin';

  static const String _kIsDisabled = 'isdisabled';

  static const String _kStart = 'start';
  static const String _kStop = 'stop';
  static const String _kRoundEnd = 'roundend';
  static const String _kSpin = 'spin';
  static const String _kRoundDone = 'rounddone';

  static const String _kJackpot = 'jackpot';

  static const int _kJackpotPumpMs = 5500;

  static const Set<int> _kMultiplierCountedCells = {8, 9};

  static const double _kTurboSpeed = 2.0;

  static const int _kStaggerGapMs = 100;
  static const int _kStaggerGapTurboMs = 50;

  static const int _kMinSpinMs = 900;
  static const int _kMinSpinTurboMs = 350;

  static const int _kSettleMs = 500;
  static const int _kSettleTurboMs = 250;

  final Stopwatch _spinWatch = Stopwatch();

  _SpeedControlledRiveController? _controller;
  rive.ViewModelInstance? _mainVm;

  final List<rive.ViewModelInstance?> _reels = [];

  final List<rive.ViewModelInstance?> _symbols =
      List<rive.ViewModelInstance?>.filled(_reelCount * _rowCount, null);

  rive.ViewModelInstanceTrigger? _roundDoneTrigger;

  bool _roundTurbo = false;

  int _seenSpinToken = 0;
  int _seenResultToken = 0;
  int _seenWinToken = 0;
  int _seenJackpotToken = 0;

  bool _jackpotPumping = false;
  Timer? _jackpotPumpTimer;

  final List<Timer> _startTimers = [];
  final List<Timer> _stopTimers = [];

  Timer? _roundDoneTimer;

  bool _roundDoneSent = true;

  bool _reelsSpinning = false;

  Timer? _pump;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      AppLoggers.ui.d('[DGReels] load url=${AppRive.dgReels}');
      final file = await RiveHelper.getFile(AppRive.dgReels);
      if (file == null) {
        AppLoggers.ui.w('[DGReels] file NULL (load fail)');
        return;
      }
      if (!mounted) return;
      final controller = _SpeedControlledRiveController(
        file,
        artboardSelector: rive.ArtboardSelector.byName(_kArtboard),
      );
      final vmi = controller.dataBind(rive.DataBind.auto());
      _reels
        ..clear()
        ..addAll([for (final name in _kReelNames) vmi.viewModel(name)]);
      for (var col = 0; col < _reelCount; col++) {
        final reel = _reels[col];
        for (var row = 0; row < _rowCount; row++) {
          _symbols[row * _reelCount + col] =
              reel?.viewModel(_kUnitNames[row]);
        }
      }
      _roundDoneTrigger = vmi.trigger(_kRoundDone)?..addListener(_onRoundDone);
      final boundSymbols = _symbols.where((s) => s != null).length;
      AppLoggers.ui.d(
        '[DGReels] bound OK artboard=${controller.artboard.name} '
        'sm=${controller.stateMachine.name} '
        'reels=${_reels.where((r) => r != null).length}/5 '
        'symbols=$boundSymbols/15 rounddone=${_roundDoneTrigger != null}',
      );
      setState(() {
        _controller = controller;
        _mainVm = vmi;
      });
      _showInstant(widget.entrySymbols);
      if (widget.roundInProgress) {
        _syncTokens();
      } else {
        _seenSpinToken = widget.spinStartToken;
        _seenResultToken = widget.resultToken;
        _seenWinToken = widget.winToken;
        _seenJackpotToken = widget.jackpotToken;
        if (widget.winCells.isNotEmpty || widget.dimAll) _applyWin();
      }
    } catch (e, s) {
      AppLoggers.ui.e('[DGReels] load FAILED', error: e, stackTrace: s);
    }
  }

  @override
  void didUpdateWidget(DragonBallReelsRive oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncTokens();
  }

  void _syncTokens() {
    if (_mainVm == null) return;
    if (_seenSpinToken != widget.spinStartToken) {
      _seenSpinToken = widget.spinStartToken;
      _startSpin();
    }
    if (_seenResultToken != widget.resultToken) {
      _seenResultToken = widget.resultToken;
      _resolve();
    }
    if (_seenWinToken != widget.winToken) {
      _seenWinToken = widget.winToken;
      _applyWin();
    }
    if (_seenJackpotToken != widget.jackpotToken) {
      _seenJackpotToken = widget.jackpotToken;
      _fireJackpot();
    }
  }

  void _fireJackpot() {
    _mainVm?.trigger(_kJackpot)?.trigger();
    _jackpotPumping = true;
    _ensurePump();
    _jackpotPumpTimer?.cancel();
    _jackpotPumpTimer = Timer(const Duration(milliseconds: _kJackpotPumpMs), () {
      _jackpotPumping = false;
      if (widget.winCells.isEmpty && !widget.dimAll) _stopPump();
    });
    AppLoggers.ui.d('[DGReels] fireJackpot token=${widget.jackpotToken}');
  }

  void _startSpin() {
    _clearTimers();
    _roundTurbo = widget.turbo;
    _controller?.speed = _roundTurbo ? _kTurboSpeed : 1.0;
    _clearAllWin();
    _mainVm?.trigger(_kSpin)?.trigger();
    final gap = _roundTurbo ? _kStaggerGapTurboMs : _kStaggerGapMs;
    var startCount = 0;
    for (var i = 0; i < _reelCount; i++) {
      final reel = _reels[i];
      if (reel == null) continue;
      reel.boolean(_kRoundEnd)?.value = false;
      if (reel.trigger(_kStart) != null) startCount++;
      if (i == 0) {
        reel.trigger(_kStart)?.trigger();
        continue;
      }
      _startTimers.add(
        Timer(Duration(milliseconds: gap * i), () {
          if (!mounted) return;
          reel.trigger(_kStart)?.trigger();
          _controller?.scheduleRepaint();
        }),
      );
    }
    _reelsSpinning = true;
    _roundDoneSent = true;
    _spinWatch
      ..reset()
      ..start();
    AppLoggers.ui.d('[DGReels] startSpin token=${widget.spinStartToken} '
        'turbo=$_roundTurbo reel.start=$startCount/5');
    _ensurePump();
  }

  void _resolve() {
    final board = widget.resultSymbols;
    if (board == null) return;
    if (!_reelsSpinning) {
      _showInstant(board);
      return;
    }
    _clearStopTimers();
    _roundDoneSent = false;
    final gap = _roundTurbo ? _kStaggerGapTurboMs : _kStaggerGapMs;
    final minSpin = _roundTurbo ? _kMinSpinTurboMs : _kMinSpinMs;
    final elapsed = _spinWatch.isRunning ? _spinWatch.elapsedMilliseconds : 0;
    final base = (minSpin - elapsed) > 0 ? (minSpin - elapsed) : 0;
    var stopCount = 0;
    for (var i = 0; i < _reelCount; i++) {
      final reel = _reels[i];
      if (reel == null) continue;
      if (reel.trigger(_kStop) != null) stopCount++;
      _stopTimers.add(
        Timer(Duration(milliseconds: base + gap * i), () {
          if (!mounted) return;
          for (var row = 0; row < _rowCount; row++) {
            final index = row * _reelCount + i;
            _setRank(index, _codeAt(board, index));
          }
          reel.trigger(_kStop)?.trigger();
          reel.boolean(_kRoundEnd)?.value = true;
          _controller?.scheduleRepaint();
        }),
      );
    }
    final settle = _roundTurbo ? _kSettleTurboMs : _kSettleMs;
    final doneAtMs = base + gap * (_reelCount - 1) + settle;
    _roundDoneTimer?.cancel();
    _roundDoneTimer = Timer(Duration(milliseconds: doneAtMs), () {
      if (!mounted) return;
      _reportRoundDone('timer');
    });
    _ensurePump();
    AppLoggers.ui.d('[DGReels] resolve token=${widget.resultToken} '
        'reel.stop=$stopCount/5 base=${base}ms doneAt=${doneAtMs}ms');
  }

  void _reportRoundDone(String source) {
    if (_roundDoneSent) return;
    _roundDoneSent = true;
    _reelsSpinning = false;
    AppLoggers.ui.d('[DGReels] roundDone via=$source token=${widget.resultToken}');
    widget.onRoundDone?.call();
  }

  void _applyWin() {
    final dimAll = widget.dimAll;
    final hasWin = widget.winCells.isNotEmpty || dimAll;
    for (var i = 0; i < _symbols.length; i++) {
      final win = widget.winCells.contains(i);
      final bright =
          !dimAll && (win || _kMultiplierCountedCells.contains(i));
      _symbols[i]?.boolean(_kIsWin)?.value = win;
      _symbols[i]?.boolean(_kIsDisabled)?.value = hasWin && !bright;
    }
    if (hasWin || _jackpotPumping) {
      _ensurePump();
    } else {
      _stopPump();
    }
    _controller?.scheduleRepaint();
    AppLoggers.ui.d('[DGReels] applyWin token=${widget.winToken} '
        'cells=${widget.winCells.length}${dimAll ? ' dimAll' : ''}');
  }

  void _showInstant(List<int>? board) {
    if (board == null || _mainVm == null) return;
    _clearTimers();
    _reelsSpinning = false;
    for (var i = 0; i < _symbols.length; i++) {
      _setRank(i, _codeAt(board, i));
      _symbols[i]?.boolean(_kIsWin)?.value = false;
      _symbols[i]?.boolean(_kIsDisabled)?.value = false;
    }
    for (final reel in _reels) {
      reel?.boolean(_kRoundEnd)?.value = true;
    }
    _controller?.scheduleRepaint();
  }

  void _setRank(int index, int? serverCode) {
    if (serverCode == null) return;
    _symbols[index]?.number(_kRank)?.value =
        _rankForServerCode(serverCode).toDouble();
  }

  int _rankForServerCode(int serverCode) => dragonBallDecodeSymbol(serverCode);

  void _clearAllWin() {
    for (final s in _symbols) {
      s?.boolean(_kIsWin)?.value = false;
      s?.boolean(_kIsDisabled)?.value = false;
    }
  }

  void _onRoundDone(bool _) => _reportRoundDone('rive');

  void _ensurePump() {
    _pump ??= Timer.periodic(const Duration(milliseconds: 16), (_) {
      _controller?.scheduleRepaint();
    });
  }

  void _stopPump() {
    _pump?.cancel();
    _pump = null;
  }

  void _clearTimers() {
    for (final t in _startTimers) {
      t.cancel();
    }
    _startTimers.clear();
    _clearStopTimers();
  }

  void _clearStopTimers() {
    for (final t in _stopTimers) {
      t.cancel();
    }
    _stopTimers.clear();
    _roundDoneTimer?.cancel();
    _roundDoneTimer = null;
  }

  static int? _codeAt(List<int>? board, int i) =>
      (board != null && i < board.length) ? board[i] : null;

  @override
  void dispose() {
    _clearTimers();
    _jackpotPumpTimer?.cancel();
    _stopPump();
    _roundDoneTrigger?.removeListener(_onRoundDone);
    _mainVm?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  final GlobalKey _riveLayerKey = GlobalKey();

  @override
  Widget build(BuildContext context) => _controller == null
      ? const SizedBox.shrink()
      : RepaintBoundary(
          key: _riveLayerKey,
          child: rive.RiveWidget(controller: _controller!, fit: widget.fit),
        );
}
