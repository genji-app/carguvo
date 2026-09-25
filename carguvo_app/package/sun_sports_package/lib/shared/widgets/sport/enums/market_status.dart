enum MarketStatus {
  active(0),

  suspended(1),

  hidden(2),

  autoSuspended(3),

  autoHidden(4);

  final int value;
  const MarketStatus(this.value);

  bool get canBet => this == MarketStatus.active;

  bool get isSuspended =>
      this == MarketStatus.suspended || this == MarketStatus.autoSuspended;

  bool get isHidden =>
      this == MarketStatus.hidden || this == MarketStatus.autoHidden;

  bool get isVisible => !isHidden;

  static MarketStatus fromValue(int? value) {
    return MarketStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MarketStatus.active,
    );
  }

  static MarketStatus fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'ACTIVE':
        return MarketStatus.active;
      case 'SUSPENDED':
        return MarketStatus.suspended;
      case 'HIDDEN':
        return MarketStatus.hidden;
      case 'AUTO_SUSPENDED':
      case 'AUTOSUSPENDED':
        return MarketStatus.autoSuspended;
      case 'AUTO_HIDDEN':
      case 'AUTOHIDDEN':
        return MarketStatus.autoHidden;
      default:
        return MarketStatus.active;
    }
  }
}
