library;

class StakeDraft {
  const StakeDraft(this.value, {this.selectAll = false});

  final int value;
  final bool selectAll;

  @override
  String toString() => 'StakeDraft($value${selectAll ? ', selected' : ''})';
}

sealed class StakeKey {
  const StakeKey();
}

final class StakeDigitsKey extends StakeKey {
  const StakeDigitsKey(this.digits);
  final String digits;
}

final class StakeBackspaceKey extends StakeKey {
  const StakeBackspaceKey();
}

final class StakeAddKey extends StakeKey {
  const StakeAddKey(this.delta);
  final int delta;
}

final class StakeMaxKey extends StakeKey {
  const StakeMaxKey();
}

final class StakeDoneKey extends StakeKey {
  const StakeDoneKey();
}

abstract final class StakeKeypadMath {
  static const int maxDigits = 12;
  static const int _cap = 999999999999;

  static StakeDraft apply(
    StakeDraft draft,
    StakeKey key, {
    required int maxStake,
    required int balance,
  }) {
    return switch (key) {
      StakeDigitsKey(:final digits) => typeDigits(draft, digits),
      StakeBackspaceKey() => backspace(draft),
      StakeAddKey(:final delta) => add(draft, delta),
      StakeMaxKey() => max(draft, maxStake: maxStake, balance: balance),
      StakeDoneKey() => StakeDraft(draft.value),
    };
  }

  static StakeDraft typeDigits(StakeDraft draft, String digits) {
    final base = draft.selectAll || draft.value == 0 ? '' : '${draft.value}';
    final joined = (base + digits).replaceFirst(RegExp(r'^0+'), '');
    if (joined.length > maxDigits) return StakeDraft(draft.value);
    return StakeDraft(joined.isEmpty ? 0 : int.parse(joined));
  }

  static StakeDraft backspace(StakeDraft draft) =>
      StakeDraft(draft.selectAll ? 0 : draft.value ~/ 10);

  static StakeDraft add(StakeDraft draft, int delta) {
    final next = draft.value + delta;
    return StakeDraft(next > _cap ? draft.value : next);
  }

  static StakeDraft max(
    StakeDraft draft, {
    required int maxStake,
    required int balance,
  }) {
    final floored = balance > 0 ? (balance ~/ 1000) * 1000 : 0;
    if (maxStake <= 0 && floored <= 0) return draft;
    if (maxStake <= 0) return StakeDraft(floored);
    if (floored <= 0) return StakeDraft(maxStake);
    return StakeDraft(maxStake < floored ? maxStake : floored);
  }
}
