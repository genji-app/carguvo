import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

import 'package:sun_sports/core/utils/app_logger.dart';
import 'package:sun_sports/core/utils/extensions/rive_helper.dart';
import 'package:sun_sports/core/utils/styles/app_rive.dart';

enum MinipokerSuit {
  spade(1, 'Bích'),
  clubs(2, 'Tép'),
  diamond(3, 'Rô'),
  heart(4, 'Cơ');

  final int code;
  final String label;
  const MinipokerSuit(this.code, this.label);

  bool get isRed => this == heart || this == diamond;

  int get riveCode => code;

  static MinipokerSuit fromCode(int code) =>
      values.firstWhere((s) => s.code == code, orElse: () => heart);
}

@immutable
class MinipokerReelCard {
  final int rank;

  final MinipokerSuit suit;

  const MinipokerReelCard({required this.rank, this.suit = MinipokerSuit.heart});

  factory MinipokerReelCard.fromServer(int rank, int suitCode) =>
      MinipokerReelCard(rank: rank, suit: MinipokerSuit.fromCode(suitCode));

  static MinipokerReelCard? tryParse(String token) {
    final parts = token.split('/');
    if (parts.length != 2) return null;
    final rank = int.tryParse(parts[0].trim());
    final suit = int.tryParse(parts[1].trim());
    if (rank == null || suit == null) return null;
    return MinipokerReelCard.fromServer(rank, suit);
  }

  static List<MinipokerReelCard> parseList(String csv) => csv
      .split(',')
      .map((t) => tryParse(t))
      .whereType<MinipokerReelCard>()
      .toList(growable: false);

  String get rankLabel => switch (rank) {
    1 => 'A',
    11 => 'J',
    12 => 'Q',
    13 => 'K',
    _ => '$rank',
  };

  @override
  bool operator ==(Object other) =>
      other is MinipokerReelCard && other.rank == rank && other.suit == suit;

  @override
  int get hashCode => Object.hash(rank, suit);
}

class MinipokerReelsRive extends StatefulWidget {
  final List<MinipokerReelCard> entryCards;

  final List<MinipokerReelCard>? resultCards;

  final bool turbo;

  final int spinStartToken;

  final int resultToken;

  final bool roundInProgress;

  final VoidCallback? onRoundDone;

  final int jackpotToken;

  final rive.Fit fit;

  const MinipokerReelsRive({
    required this.entryCards,
    this.resultCards,
    this.turbo = false,
    this.spinStartToken = 0,
    this.resultToken = 0,
    this.roundInProgress = false,
    this.onRoundDone,
    this.jackpotToken = 0,
    this.fit = rive.Fit.contain,
    super.key,
  });

  @override
  State<MinipokerReelsRive> createState() => _MinipokerReelsRiveState();
}

base class _SpeedControlledRiveController extends rive.RiveWidgetController {
  _SpeedControlledRiveController(super.file, {super.artboardSelector});

  double speed = 1.0;

  @override
  bool advance(double elapsedSeconds) => super.advance(elapsedSeconds * speed);
}

class _MinipokerReelsRiveState extends State<MinipokerReelsRive> {
  static const int _reelCount = 5;

  static const String _kArtboard = 'Main';
  static const String _kReelPrefix = 'reel';
  static const String _kTargetCard = 'targetCard';
  static const String _kDisplayCard = 'displayCard';
  static const String _kSuit = 'suit';
  static const String _kRank = 'rank';
  static const String _kSpin = 'spin';
  static const String _kSkip = 'skip';
  static const String _kStart = 'start';
  static const String _kStop = 'stop';
  static const String _kRoundDone = 'rounddone';
  static const String _kIsJackpot = 'isJackpot';

  static const double _kTurboSpeed = 2.0;

  static const int _kStaggerGapMs = 100;
  static const int _kStaggerGapTurboMs = 50;

  static const int _kMinSpinMs = 900;
  static const int _kMinSpinTurboMs = 350;

  final Stopwatch _spinWatch = Stopwatch();

  _SpeedControlledRiveController? _controller;
  rive.ViewModelInstance? _mainVm;
  final List<rive.ViewModelInstance?> _reels = [];
  rive.ViewModelInstanceTrigger? _roundDoneTrigger;
  rive.ViewModelInstanceBoolean? _diagStopped;

  rive.ViewModelInstanceBoolean? _isJackpot;

  Timer? _jackpotTimer;

  bool _roundTurbo = false;

  int _seenSpinToken = 0;
  int _seenResultToken = 0;
  int _seenJackpotToken = 0;

  final List<Timer> _startTimers = [];

  final List<Timer> _stopTimers = [];

  Timer? _pump;

  Timer? _pumpTimeout;
  static const Duration _kPumpMaxDuration = Duration(seconds: 8);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      AppLoggers.ui.d('[MPReels] load url=${AppRive.mpAnimReels3}');
      final file = await RiveHelper.getFile(AppRive.mpAnimReels3);
      if (file == null) {
        AppLoggers.ui.w('[MPReels] file NULL (load fail)');
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
        ..addAll([
          for (var i = 0; i < _reelCount; i++)
            vmi.viewModel('$_kReelPrefix${i + 1}'),
        ]);
      _roundDoneTrigger = vmi.trigger(_kRoundDone)?..addListener(_onRoundDone);
      _isJackpot = vmi.boolean(_kIsJackpot);
      _diagStopped = _reels.first?.boolean('stopped')
        ?..addListener(_onDiagStopped);
      AppLoggers.ui.d(
        '[MPReels] bound OK artboard=${controller.artboard.name} '
        'sm=${controller.stateMachine.name} '
        'reels=${_reels.where((r) => r != null).length}/5 '
        'rounddone=${_roundDoneTrigger != null} '
        'reel1.stopped=${_diagStopped != null}',
      );
      setState(() {
        _controller = controller;
        _mainVm = vmi;
      });
      _showInstant(widget.entryCards);
      if (widget.roundInProgress) {
        _syncTokens();
      } else {
        _seenSpinToken = widget.spinStartToken;
        _seenResultToken = widget.resultToken;
        _seenJackpotToken = widget.jackpotToken;
      }
    } catch (e, s) {
      AppLoggers.ui.e('[MPReels] load FAILED', error: e, stackTrace: s);
    }
  }

  @override
  void didUpdateWidget(MinipokerReelsRive oldWidget) {
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
    if (_seenJackpotToken != widget.jackpotToken) {
      _seenJackpotToken = widget.jackpotToken;
      _fireJackpot();
    }
  }

  void _fireJackpot() {
    _isJackpot?.value = true;
    _startPump();
    _jackpotTimer?.cancel();
    _jackpotTimer = Timer(const Duration(milliseconds: 5500), () {
      _isJackpot?.value = false;
      _controller?.scheduleRepaint();
    });
    AppLoggers.ui.d('[MPReels] fireJackpot (isJackpot=true) '
        'token=${widget.jackpotToken} bound=${_isJackpot != null}');
  }

  void _startSpin() {
    _clearTimers();
    _jackpotTimer?.cancel();
    _isJackpot?.value = false;
    _roundTurbo = widget.turbo;
    _controller?.speed = _roundTurbo ? _kTurboSpeed : 1.0;
    final spin = _mainVm?.trigger(_kSpin);
    spin?.trigger();
    final gap = _roundTurbo ? _kStaggerGapTurboMs : _kStaggerGapMs;
    var startCount = 0;
    for (var i = 0; i < _reelCount; i++) {
      final reel = _reels[i];
      if (reel == null) continue;
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
    _spinWatch
      ..reset()
      ..start();
    AppLoggers.ui.d('[MPReels] startSpin token=${widget.spinStartToken} '
        'turbo=$_roundTurbo reel.start=$startCount/5 spin=${spin != null}');
    _startPump();
  }

  void _resolve() {
    final cards = widget.resultCards;
    if (cards == null) return;
    _clearStopTimers();
    for (var i = 0; i < _reelCount; i++) {
      _setTarget(i, _cardAt(cards, i));
    }
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
          reel.trigger(_kStop)?.trigger();
          _controller?.scheduleRepaint();
        }),
      );
    }
    _startPump();
    AppLoggers.ui.d('[MPReels] resolve token=${widget.resultToken} '
        'reel.stop=$stopCount/5 base=${base}ms '
        'cards=${cards.map((c) => '${c.rankLabel}${c.suit.label}').join(',')}');
  }

  void _showInstant(List<MinipokerReelCard>? cards) {
    if (cards == null || _mainVm == null) return;
    _clearTimers();
    for (var i = 0; i < _reelCount; i++) {
      final card = _cardAt(cards, i);
      _setCardVm(i, _kDisplayCard, card);
      _setCardVm(i, _kTargetCard, card);
    }
    _mainVm?.trigger(_kSkip)?.trigger();
    _controller?.scheduleRepaint();
  }

  void _setTarget(int i, MinipokerReelCard? card) =>
      _setCardVm(i, _kTargetCard, card);

  void _setCardVm(int i, String vmName, MinipokerReelCard? card) {
    if (card == null) return;
    final cardVm = _reels[i]?.viewModel(vmName);
    if (i == 0 && vmName == _kTargetCard) {
      AppLoggers.ui.d(
        '[MPReels] setTarget reel1 '
        'targetCard=${cardVm != null} '
        'suit=${cardVm?.number(_kSuit) != null} rank=${cardVm?.number(_kRank) != null}',
      );
    }
    cardVm?.number(_kSuit)?.value = card.suit.riveCode.toDouble();
    cardVm?.number(_kRank)?.value = card.rank.toDouble();
  }

  void _onRoundDone(bool _) {
    AppLoggers.ui.d('[MPReels] rounddone');
    _stopPump();
    final cards = widget.resultCards;
    if (cards != null) {
      for (var i = 0; i < _reelCount; i++) {
        _setCardVm(i, _kDisplayCard, _cardAt(cards, i));
      }
    }
    widget.onRoundDone?.call();
  }

  void _onDiagStopped(bool v) => AppLoggers.ui.d('[MPReels] reel1.stopped=$v');

  void _startPump() {
    _pump ??= Timer.periodic(const Duration(milliseconds: 16), (_) {
      _controller?.scheduleRepaint();
    });
    _pumpTimeout?.cancel();
    _pumpTimeout = Timer(_kPumpMaxDuration, _stopPump);
  }

  void _stopPump() {
    _pump?.cancel();
    _pump = null;
    _pumpTimeout?.cancel();
    _pumpTimeout = null;
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
  }

  static MinipokerReelCard? _cardAt(List<MinipokerReelCard>? cards, int i) =>
      (cards != null && i < cards.length) ? cards[i] : null;

  @override
  void dispose() {
    _clearTimers();
    _jackpotTimer?.cancel();
    _stopPump();
    _roundDoneTrigger?.removeListener(_onRoundDone);
    _diagStopped?.removeListener(_onDiagStopped);
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
