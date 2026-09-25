import 'package:meta/meta.dart';

import 'volta_models.dart';
import 'volta_rules.dart';

class VoltaBetRules {
  const VoltaBetRules._();

  static VoltaMyStake carryOver(VoltaMyStake placed) {
    if (placed.home > 0 && placed.away > 0) return VoltaMyStake.empty;
    return placed;
  }

  static bool _base({
    required bool canBet,
    required bool submitting,
    required bool hasBetThisRound,
    required int previousTotal,
  }) =>
      canBet && !submitting && !hasBetThisRound && previousTotal > 0;

  static bool canRebet({
    required bool canBet,
    required bool submitting,
    required bool hasBetThisRound,
    required int previousTotal,
    required int balance,
  }) =>
      _base(
        canBet: canBet,
        submitting: submitting,
        hasBetThisRound: hasBetThisRound,
        previousTotal: previousTotal,
      ) &&
      previousTotal <= balance &&
      previousTotal < VoltaRules.rebetCeiling;

  static bool canDouble({
    required bool canBet,
    required bool submitting,
    required bool hasBetThisRound,
    required int previousTotal,
    required int balance,
  }) {
    final int needed = previousTotal * 2;
    return _base(
          canBet: canBet,
          submitting: submitting,
          hasBetThisRound: hasBetThisRound,
          previousTotal: previousTotal,
        ) &&
        needed <= balance &&
        needed < VoltaRules.rebetCeiling;
  }

  static List<VoltaBetLeg> legsFor(VoltaMyStake previous, int multiplier) =>
      <VoltaBetLeg>[
        if (previous.home > 0)
          VoltaBetLeg(VoltaSide.home, previous.home * multiplier),
        if (previous.away > 0)
          VoltaBetLeg(VoltaSide.away, previous.away * multiplier),
      ];
}

class VoltaBetLeg {
  const VoltaBetLeg(this.side, this.stake);

  final VoltaSide side;
  final int stake;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoltaBetLeg && other.side == side && other.stake == stake;

  @override
  int get hashCode => Object.hash(side, stake);

  @override
  String toString() => 'VoltaBetLeg(${side.name}, $stake)';
}

@immutable
class VoltaBetOutcome {
  const VoltaBetOutcome._(this.kind, this.message, this.placed);

  const VoltaBetOutcome.ok({int placed = 1})
    : this._(VoltaBetOutcomeKind.ok, 'Đặt cược thành công', placed);

  const VoltaBetOutcome.rejected(String message, {int placed = 0})
    : this._(VoltaBetOutcomeKind.rejected, message, placed);

  const VoltaBetOutcome.uncertain({int placed = 0, String? message})
    : this._(
        VoltaBetOutcomeKind.uncertain,
        message ?? 'Chưa nhận được xác nhận, đang kiểm tra lại số dư giúp bạn',
        placed,
      );

  const VoltaBetOutcome.notice(String message)
    : this._(VoltaBetOutcomeKind.notice, message, 0);

  const VoltaBetOutcome.busy()
    : this._(VoltaBetOutcomeKind.busy, '', 0);

  final VoltaBetOutcomeKind kind;

  final String message;

  final int placed;

  bool get isOk => kind == VoltaBetOutcomeKind.ok;

  @override
  String toString() => 'VoltaBetOutcome(${kind.name}, placed: $placed)';
}

enum VoltaBetOutcomeKind { ok, rejected, uncertain, notice, busy }
