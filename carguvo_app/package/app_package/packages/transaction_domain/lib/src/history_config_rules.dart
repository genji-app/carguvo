library;

class HistoryConfigRules {
  const HistoryConfigRules._();

  static const List<int> allowedOptions = [0, 2, 15, 60];

  static const int defaultMinutes = 15;

  static bool isValidOption(int minutes) => allowedOptions.contains(minutes);

  static int validatedOrDefault(int minutes) =>
      isValidOption(minutes) ? minutes : defaultMinutes;
}

class HistoryConfigUpdateResult {
  HistoryConfigUpdateResult({
    required this.success,
    required this.finalMinutes,
    required this.wasRolledBack,
  });

  final bool success;

  final int finalMinutes;

  final bool wasRolledBack;

  bool get shouldShowSuccess => success && !wasRolledBack;
}

HistoryConfigUpdateResult applyOptimisticUpdate({
  required int currentMinutes,
  required int newMinutes,
  bool? serverConfirmed,
}) {
  if (currentMinutes == newMinutes) {
    return HistoryConfigUpdateResult(
      success: true,
      finalMinutes: currentMinutes,
      wasRolledBack: false,
    );
  }

  if (serverConfirmed == true) {
    return HistoryConfigUpdateResult(
      success: true,
      finalMinutes: newMinutes,
      wasRolledBack: false,
    );
  }

  if (serverConfirmed == false) {
    return HistoryConfigUpdateResult(
      success: false,
      finalMinutes: currentMinutes,
      wasRolledBack: true,
    );
  }

  return HistoryConfigUpdateResult(
    success: true,
    finalMinutes: newMinutes,
    wasRolledBack: false,
  );
}
