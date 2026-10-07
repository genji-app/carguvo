import 'package:meta/meta.dart';
import 'volta_platform.dart';

import 'volta_bet_rules.dart';
import 'volta_fairness.dart';
import 'volta_round_clock.dart';
import 'volta_models.dart';

enum VoltaTab { history, results, headToHead }

extension VoltaTabX on VoltaTab {
  String get label => switch (this) {
    VoltaTab.history => 'Thống kê',
    VoltaTab.results => 'Kết quả',
    VoltaTab.headToHead => 'Đối đầu',
  };
}

enum VoltaMusicCue {
  idle,

  playing,

  won,

  lost,
}

enum VoltaLink { connecting, ready, down }

@immutable
class VoltaState {
  final VoltaLink link;
  final VoltaRound? round;

  final int secondsRemaining;

  final VoltaMyStake myStake;

  final VoltaMyStake previousStake;

  final int chipIndex;

  final List<VoltaHistoryCell> history;

  final VoltaTab tab;

  final int balance;

  final VoltaMatchResult? lastResult;

  final VoltaHeadToHead? headToHead;

  final List<VoltaMatchResult> results;

  final bool submitting;

  final int historyHomePercent;
  final int historyAwayPercent;

  final String? betEventId;

  const VoltaState({
    this.link = VoltaLink.connecting,
    this.round,
    this.secondsRemaining = 0,
    this.myStake = VoltaMyStake.empty,
    this.previousStake = VoltaMyStake.empty,
    this.chipIndex = VoltaChip.defaultIndex,
    this.history = const <VoltaHistoryCell>[],
    this.tab = VoltaTab.history,
    this.balance = 0,
    this.lastResult,
    this.headToHead,
    this.results = const <VoltaMatchResult>[],
    this.submitting = false,
    this.betEventId,
    this.historyHomePercent = 50,
    this.historyAwayPercent = 50,
  });

  VoltaChip get chip => VoltaChip.defaults[
      chipIndex.clamp(0, VoltaChip.defaults.length - 1)];

  VoltaRoundPhase get phase => round?.phase ?? VoltaRoundPhase.idle;

  VoltaMusicCue get musicCue {
    if (phase == VoltaRoundPhase.idle) return VoltaMusicCue.idle;
    if (phase != VoltaRoundPhase.result) return VoltaMusicCue.playing;

    final VoltaWinner winner = lastResult?.winner ?? VoltaWinner.unknown;
    if (winner == VoltaWinner.unknown || myStake.isEmpty) {
      return VoltaMusicCue.playing;
    }
    final VoltaSide side = winner == VoltaWinner.home
        ? VoltaSide.home
        : VoltaSide.away;
    return myStake.of(side) > 0 ? VoltaMusicCue.won : VoltaMusicCue.lost;
  }

  int get homePercent {
    final r = round;
    if (r == null) return 50;
    final total = r.homeStake + r.awayStake;
    if (total <= 0) return 50;
    return ((r.homeStake / total) * 100).round().clamp(0, 100);
  }

  int get awayPercent => 100 - homePercent;

  bool get canBet =>
      link == VoltaLink.ready &&
      round != null &&
      VoltaRoundClock.acceptsBets(phase, secondsRemaining) &&
      !submitting;

  bool get hasBetThisRound =>
      betEventId != null && betEventId == round?.eventId;

  bool get canRebet => VoltaBetRules.canRebet(
    canBet: canBet,
    submitting: submitting,
    hasBetThisRound: hasBetThisRound,
    previousTotal: previousStake.total,
    balance: balance,
  );

  bool get canDouble => VoltaBetRules.canDouble(
    canBet: canBet,
    submitting: submitting,
    hasBetThisRound: hasBetThisRound,
    previousTotal: previousStake.total,
    balance: balance,
  );

  VoltaMd5View get md5View {
    final VoltaRound? r = round;
    final bool isResult = phase == VoltaRoundPhase.result;
    final String? resultCode = r?.resultCode;
    if (isResult && resultCode != null && resultCode.isNotEmpty) {
      return VoltaMd5View(
        label: 'Mã kết quả',
        code: VoltaFairness.forDisplay(
          VoltaFairness.decodeUnicodeEscape(resultCode),
        ),
        copyMessage: 'Đã copy Mã Kết Quả',
        verdict: r?.fairness ?? VoltaFairnessVerdict.unknown,
      );
    }
    return VoltaMd5View(
      label: 'MD5 Code',
      code: r?.md5Code?.toLowerCase(),
      copyMessage: 'Đã copy Mã MD5',
      verdict: VoltaFairnessVerdict.unknown,
    );
  }

  VoltaState copyWith({
    VoltaLink? link,
    VoltaRound? round,
    bool clearRound = false,
    int? secondsRemaining,
    VoltaMyStake? myStake,
    VoltaMyStake? previousStake,
    int? chipIndex,
    List<VoltaHistoryCell>? history,
    VoltaTab? tab,
    int? balance,
    VoltaMatchResult? lastResult,
    VoltaHeadToHead? headToHead,
    List<VoltaMatchResult>? results,
    bool clearHeadToHead = false,
    bool? submitting,
    String? betEventId,
    bool clearBetEventId = false,
    int? historyHomePercent,
    int? historyAwayPercent,
  }) => VoltaState(
    link: link ?? this.link,
    round: clearRound ? null : (round ?? this.round),
    secondsRemaining: secondsRemaining ?? this.secondsRemaining,
    myStake: myStake ?? this.myStake,
    previousStake: previousStake ?? this.previousStake,
    chipIndex: chipIndex ?? this.chipIndex,
    history: history ?? this.history,
    tab: tab ?? this.tab,
    balance: balance ?? this.balance,
    lastResult: lastResult ?? this.lastResult,
    headToHead: clearHeadToHead ? null : (headToHead ?? this.headToHead),
    results: results ?? this.results,
    submitting: submitting ?? this.submitting,
    betEventId: clearBetEventId ? null : (betEventId ?? this.betEventId),
    historyHomePercent: historyHomePercent ?? this.historyHomePercent,
    historyAwayPercent: historyAwayPercent ?? this.historyAwayPercent,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoltaState &&
          other.link == link &&
          other.round == round &&
          other.secondsRemaining == secondsRemaining &&
          other.myStake == myStake &&
          other.previousStake == previousStake &&
          other.chipIndex == chipIndex &&
          voltaListEquals(other.history, history) &&
          voltaListEquals(other.results, results) &&
          other.tab == tab &&
          other.balance == balance &&
          other.lastResult == lastResult &&
          other.headToHead == headToHead &&
          other.submitting == submitting &&
          other.betEventId == betEventId &&
          other.historyHomePercent == historyHomePercent &&
          other.historyAwayPercent == historyAwayPercent;

  @override
  int get hashCode => Object.hash(
    link,
    round,
    secondsRemaining,
    myStake,
    previousStake,
    chipIndex,
    Object.hashAll(history),
    Object.hashAll(results),
    tab,
    balance,
    lastResult,
    headToHead,
    submitting,
    betEventId,
    historyHomePercent,
    historyAwayPercent,
  );
}

@immutable
class VoltaMd5View {
  const VoltaMd5View({
    required this.label,
    required this.code,
    required this.copyMessage,
    required this.verdict,
  });

  final String label;

  final String? code;

  final String copyMessage;

  final VoltaFairnessVerdict verdict;

  bool get hasCode => code != null && code!.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoltaMd5View &&
          other.label == label &&
          other.code == code &&
          other.copyMessage == copyMessage &&
          other.verdict == verdict;

  @override
  int get hashCode => Object.hash(label, code, copyMessage, verdict);
}
