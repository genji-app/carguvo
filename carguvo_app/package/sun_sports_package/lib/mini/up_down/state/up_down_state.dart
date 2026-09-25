import 'package:intl/intl.dart';

import 'package:sun_sports/features/mini_game/messages/common/jackpot_data.dart';
import 'package:sun_sports/mini/up_down/state/up_down_card.dart';

const int kUpDownMaxAce = 3;

const int kUpDownRoundSeconds = 120;

class UpDownState {
  final int jackpot;

  final int upPayout;

  final int downPayout;

  final int credit;

  final int sessionId;

  final int remainingMs;

  final bool isJackpot;

  final List<JackpotData> jackpots;

  final List<int> history;

  final bool locked;

  final bool spinning;

  final int timerDeadlineMs;

  final int selectedBet;

  final int jackpotWin;

  final int cashoutWin;

  final int loseTick;

  const UpDownState({
    this.jackpot = 0,
    this.upPayout = 0,
    this.downPayout = 0,
    this.credit = 0,
    this.sessionId = 0,
    this.remainingMs = -1,
    this.isJackpot = false,
    this.jackpots = const [],
    this.history = const [],
    this.locked = false,
    this.spinning = false,
    this.timerDeadlineMs = 0,
    this.selectedBet = 1000,
    this.jackpotWin = 0,
    this.cashoutWin = 0,
    this.loseTick = 0,
  });

  UpDownCard? get currentCard =>
      history.isEmpty ? null : decodeCard(history.last);

  bool get canBetUp {
    final c = currentCard;
    return !locked && c != null && c.compareValue != 14;
  }

  bool get canBetDown {
    final c = currentCard;
    return !locked && c != null && c.compareValue != 2;
  }

  bool get canCashout => history.length > 1;

  int get numOfAce {
    var n = 0;
    for (final code in history) {
      if (decodeCard(code).isAce) n++;
    }
    return n > kUpDownMaxAce ? kUpDownMaxAce : n;
  }

  UpDownState copyWith({
    int? jackpot,
    int? upPayout,
    int? downPayout,
    int? credit,
    int? sessionId,
    int? remainingMs,
    bool? isJackpot,
    List<JackpotData>? jackpots,
    List<int>? history,
    bool? locked,
    bool? spinning,
    int? timerDeadlineMs,
    int? selectedBet,
    int? jackpotWin,
    int? cashoutWin,
    int? loseTick,
  }) {
    return UpDownState(
      jackpot: jackpot ?? this.jackpot,
      upPayout: upPayout ?? this.upPayout,
      downPayout: downPayout ?? this.downPayout,
      credit: credit ?? this.credit,
      sessionId: sessionId ?? this.sessionId,
      remainingMs: remainingMs ?? this.remainingMs,
      isJackpot: isJackpot ?? this.isJackpot,
      jackpots: jackpots ?? this.jackpots,
      history: history ?? this.history,
      locked: locked ?? this.locked,
      spinning: spinning ?? this.spinning,
      timerDeadlineMs: timerDeadlineMs ?? this.timerDeadlineMs,
      selectedBet: selectedBet ?? this.selectedBet,
      jackpotWin: jackpotWin ?? this.jackpotWin,
      cashoutWin: cashoutWin ?? this.cashoutWin,
      loseTick: loseTick ?? this.loseTick,
    );
  }
}

final NumberFormat _moneyFormat = NumberFormat('#,###');

String upDownMoney(int value) => _moneyFormat.format(value);

String upDownMoneyShort(int value) {
  final abs = value.abs();
  if (abs >= 1000000000) return '${_shortNum(value / 1000000000)}B';
  if (abs >= 1000000) return '${_shortNum(value / 1000000)}M';
  if (abs >= 1000) return '${_shortNum(value / 1000)}K';
  return '$value';
}

String _shortNum(double v) {
  final s = v.toStringAsFixed(1);
  return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
}
