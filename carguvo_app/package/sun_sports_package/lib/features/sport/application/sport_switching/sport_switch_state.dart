enum SportSwitchStatus {
  idle,

  preparing,

  switching,

  loading,

  ready,

  error,
}

class SportSwitchState {
  final SportSwitchStatus status;

  final int currentSportId;

  final int? targetSportId;

  final int requestVersion;

  final String? errorMessage;

  final DateTime? startedAt;

  const SportSwitchState({
    this.status = SportSwitchStatus.idle,
    this.currentSportId = 1,
    this.targetSportId,
    this.requestVersion = 0,
    this.errorMessage,
    this.startedAt,
  });

  factory SportSwitchState.initial({int sportId = 1}) =>
      SportSwitchState(status: SportSwitchStatus.idle, currentSportId: sportId);

  bool get isSwitching =>
      status == SportSwitchStatus.preparing ||
      status == SportSwitchStatus.switching ||
      status == SportSwitchStatus.loading;

  bool get isReady =>
      status == SportSwitchStatus.ready || status == SportSwitchStatus.idle;

  bool get hasError => status == SportSwitchStatus.error;

  int get displaySportId => targetSportId ?? currentSportId;

  SportSwitchState copyWith({
    SportSwitchStatus? status,
    int? currentSportId,
    int? targetSportId,
    int? requestVersion,
    String? errorMessage,
    DateTime? startedAt,
    bool clearTarget = false,
    bool clearError = false,
  }) {
    return SportSwitchState(
      status: status ?? this.status,
      currentSportId: currentSportId ?? this.currentSportId,
      targetSportId: clearTarget ? null : (targetSportId ?? this.targetSportId),
      requestVersion: requestVersion ?? this.requestVersion,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      startedAt: startedAt ?? this.startedAt,
    );
  }

  SportSwitchState toPreparing(int targetSportId) => copyWith(
    status: SportSwitchStatus.preparing,
    targetSportId: targetSportId,
    clearError: true,
  );

  SportSwitchState toSwitching(int newVersion) => copyWith(
    status: SportSwitchStatus.switching,
    requestVersion: newVersion,
    startedAt: DateTime.now(),
  );

  SportSwitchState toLoading() => copyWith(status: SportSwitchStatus.loading);

  SportSwitchState toReady(int sportId) => SportSwitchState(
    status: SportSwitchStatus.ready,
    currentSportId: sportId,
    requestVersion: requestVersion,
  );

  SportSwitchState toError(String message) => copyWith(
    status: SportSwitchStatus.error,
    errorMessage: message,
    clearTarget: true,
  );

  SportSwitchState toIdle() => copyWith(
    status: SportSwitchStatus.idle,
    clearTarget: true,
    clearError: true,
  );

  @override
  String toString() {
    return 'SportSwitchState(status: $status, current: $currentSportId, '
        'target: $targetSportId, version: $requestVersion)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SportSwitchState &&
        other.status == status &&
        other.currentSportId == currentSportId &&
        other.targetSportId == targetSportId &&
        other.requestVersion == requestVersion &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode {
    return Object.hash(
      status,
      currentSportId,
      targetSportId,
      requestVersion,
      errorMessage,
    );
  }
}
