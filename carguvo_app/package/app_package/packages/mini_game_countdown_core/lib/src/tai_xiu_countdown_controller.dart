library;

import 'dart:async';

import 'package:clock/clock.dart' as clk;
import 'package:mini_game_protocol/mini_game_protocol.dart'
    show
        TaiXiuShowResult,
        TaiXiuShowResultX,
        TaiXiuStartGame,
        TaiXiuSubscribeInfo;

import 'nan_flags.dart';

const Duration kTraTienCanKeoDelay = Duration(seconds: 3);

const Duration kDiceSpinDuration = Duration(milliseconds: 3000);

final Duration kTxResultRevealDelay = kTraTienCanKeoDelay + kDiceSpinDuration;

class TaiXiuCountdownState {
  final int? taiXiuSec;

  final bool? taiXiuIsTai;

  final bool taiXiuAwaitingResult;

  const TaiXiuCountdownState({
    this.taiXiuSec,
    this.taiXiuIsTai,
    this.taiXiuAwaitingResult = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaiXiuCountdownState &&
          runtimeType == other.runtimeType &&
          taiXiuSec == other.taiXiuSec &&
          taiXiuIsTai == other.taiXiuIsTai &&
          taiXiuAwaitingResult == other.taiXiuAwaitingResult;

  @override
  int get hashCode =>
      taiXiuSec.hashCode ^ taiXiuIsTai.hashCode ^ taiXiuAwaitingResult.hashCode;

  @override
  String toString() =>
      'TaiXiuCountdownState(sec: $taiXiuSec, isTai: $taiXiuIsTai, '
      'awaiting: $taiXiuAwaitingResult)';
}

class TaiXiuCountdownController {
  TaiXiuCountdownController({
    required void Function(TaiXiuCountdownState state) onStateChanged,
    DateTime Function()? clockFn,
    Duration? revealDelay,
  })  : _onStateChanged = onStateChanged,
        _clock = clockFn ?? clk.clock.now,
        _revealDelay = revealDelay ?? kTxResultRevealDelay;

  final void Function(TaiXiuCountdownState state) _onStateChanged;

  final DateTime Function() _clock;

  final Duration _revealDelay;

  TaiXiuCountdownState _state = const TaiXiuCountdownState();

  TaiXiuCountdownState get state => _state;

  Timer? _revealTimer;

  int? _sec;
  DateTime? _secAt;
  bool? _isTai;
  bool _awaiting = false;

  bool _nanArmed = false;

  bool? _pendingIsTai;

  int _bettingWindow = 0;

  void onTick() => _emit();

  void onSubscribeInfo(TaiXiuSubscribeInfo message) {
    _bettingWindow = message.timeForBettingSec.round();
    final nanHolding = message.gameState == 3 &&
        (_pendingIsTai != null ||
            (_nanArmed && (_revealTimer?.isActive ?? false))) &&
        !TaiXiuNanFlags.bowlOpened;
    if (nanHolding) {
      _pendingIsTai = _lastResultIsTai(message.history) ?? _pendingIsTai;
      _sec = null;
      _secAt = null;
      _isTai = null;
      _awaiting = true;
    } else {
      _revealTimer?.cancel();
      _awaiting = false;
      if (message.gameState == 2) {
        _sec = message.remainingTimeSec.toInt();
        _secAt = _clock();
        _isTai = null;
      } else {
        _sec = null;
        _secAt = null;
        _isTai = message.gameState == 3
            ? _lastResultIsTai(message.history)
            : null;
      }
    }
    _emit();
  }

  void onStartGame(TaiXiuStartGame message) {
    _revealTimer?.cancel();
    _awaiting = false;
    _isTai = null;
    _nanArmed = false;
    _pendingIsTai = null;
    TaiXiuNanFlags.bowlOpened = false;
    if (_bettingWindow > 0) {
      _sec = _bettingWindow;
      _secAt = _clock();
    }
    _emit();
  }

  void onShowResult(TaiXiuShowResult message) {
    _sec = null;
    _secAt = null;
    final isTai = message.isTai;
    _revealTimer?.cancel();
    _nanArmed = TaiXiuNanFlags.active;
    _awaiting = true;
    _revealTimer = Timer(_revealDelay, () {
      if (_nanArmed && !TaiXiuNanFlags.bowlOpened) {
        _pendingIsTai = isTai;
      } else {
        _awaiting = false;
        _isTai = isTai;
      }
      _emit();
    });
    _emit();
  }

  void onBowlOpened() {
    if (_pendingIsTai == null) return;
    _awaiting = false;
    _isTai = _pendingIsTai;
    _pendingIsTai = null;
    _emit();
  }

  void dispose() {
    _revealTimer?.cancel();
    _revealTimer = null;
  }

  void _emit() {
    int? now;
    final sec = _sec;
    final at = _secAt;
    if (sec != null && at != null) {
      final elapsed = _clock().difference(at).inSeconds;
      now = (sec - elapsed).clamp(0, sec);
    }
    _state = TaiXiuCountdownState(
      taiXiuSec: now,
      taiXiuIsTai: _isTai,
      taiXiuAwaitingResult: _awaiting,
    );
    _onStateChanged(_state);
  }

  static bool? _lastResultIsTai(List<dynamic> raw) {
    for (final item in raw.reversed) {
      if (item is! Map) continue;
      final d1 = (item['d1'] as num?)?.toInt();
      final d2 = (item['d2'] as num?)?.toInt();
      final d3 = (item['d3'] as num?)?.toInt();
      if (d1 == null || d2 == null || d3 == null) continue;
      return d1 + d2 + d3 > 10;
    }
    return null;
  }
}
