enum GameUrlStatus {
  initial,

  loading,

  success,

  error,
}

enum GameUrlFailureKind {
  blocked,

  unavailable,

  unknown,
}

class GameUrlState {
  const GameUrlState({
    this.status = GameUrlStatus.initial,
    this.url,
    this.error,
    this.failureKind,
    this.nativeBundle,
  });

  static const Object _unset = Object();

  final GameUrlStatus status;
  final String? url;
  final String? error;
  final GameUrlFailureKind? failureKind;

  final String? nativeBundle;

  bool get isError => status == GameUrlStatus.error;
  bool get isInitial => status == GameUrlStatus.initial;
  bool get isLoading => status == GameUrlStatus.loading;
  bool get isSuccess => status == GameUrlStatus.success;

  bool get isNative => nativeBundle != null;

  GameUrlState copyWith({
    GameUrlStatus? status,
    Object? url = _unset,
    Object? error = _unset,
    Object? failureKind = _unset,
    Object? nativeBundle = _unset,
  }) {
    return GameUrlState(
      status: status ?? this.status,
      url: url == _unset ? this.url : url as String?,
      error: error == _unset ? this.error : error as String?,
      failureKind: failureKind == _unset
          ? this.failureKind
          : failureKind as GameUrlFailureKind?,
      nativeBundle: nativeBundle == _unset
          ? this.nativeBundle
          : nativeBundle as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameUrlState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          url == other.url &&
          error == other.error &&
          failureKind == other.failureKind &&
          nativeBundle == other.nativeBundle;

  @override
  int get hashCode =>
      status.hashCode ^
      url.hashCode ^
      error.hashCode ^
      failureKind.hashCode ^
      nativeBundle.hashCode;
}
