enum UpdateFlowStatus {
  idle,
  checking,
  downloading,
  upToDate,
  restartRequired,
  error,
}

class UpdateState {
  const UpdateState({this.status = UpdateFlowStatus.idle, this.message});

  final UpdateFlowStatus status;
  final String? message;

  bool get isLoading =>
      status == UpdateFlowStatus.checking ||
      status == UpdateFlowStatus.downloading;

  UpdateState copyWith({
    UpdateFlowStatus? status,
    String? message,
  }) {
    return UpdateState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }
}

