library;

class SingleBetRules {
  SingleBetRules._();

  static const int stakeUnitMultiplier = 1000;

  static int minStakeActual(int minStakeRaw) =>
      minStakeRaw * stakeUnitMultiplier;

  static int maxStakeActual(int maxStakeRaw) =>
      maxStakeRaw * stakeUnitMultiplier;

  static bool isStakeValid(int stake, int minStakeRaw, int maxStakeRaw) =>
      stake >= minStakeActual(minStakeRaw) &&
      stake <= maxStakeActual(maxStakeRaw);

  static bool canPlaceBet(
    int stake,
    int minStakeRaw,
    int maxStakeRaw, {
    bool isCalculating = false,
    bool isDisabled = false,
  }) =>
      stake > 0 &&
      isStakeValid(stake, minStakeRaw, maxStakeRaw) &&
      !isCalculating &&
      !isDisabled;

  static String betTimeIso(int startTimeMs) {
    if (startTimeMs == 0) return '';
    return DateTime.fromMillisecondsSinceEpoch(
      startTimeMs,
      isUtc: true,
    ).toIso8601String();
  }
}
