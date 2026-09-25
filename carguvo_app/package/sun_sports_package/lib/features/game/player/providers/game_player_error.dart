part of 'game_player_notifier.dart';

sealed class GamePlayerErrorType {
  const GamePlayerErrorType();

  const factory GamePlayerErrorType.network() = GamePlayerNetworkError;
  const factory GamePlayerErrorType.sessionExpired() =
      GamePlayerSessionExpiredError;
  const factory GamePlayerErrorType.comingSoon() = GamePlayerComingSoonError;
  const factory GamePlayerErrorType.unavailable() = GamePlayerUnavailableError;
  const factory GamePlayerErrorType.serverError() = GamePlayerServerError;
  const factory GamePlayerErrorType.maintenance() = GamePlayerMaintenanceError;
  const factory GamePlayerErrorType.loadTimeout() = GamePlayerLoadTimeoutError;
  const factory GamePlayerErrorType.missingGameUrl() =
      GamePlayerMissingGameUrlError;
  const factory GamePlayerErrorType.launchFailed([String? message]) =
      GamePlayerLaunchFailedError;
  const factory GamePlayerErrorType.orientationSetupFailed() =
      GamePlayerOrientationSetupFailedError;
  const factory GamePlayerErrorType.httpError(int statusCode) =
      GamePlayerHttpError;
  const factory GamePlayerErrorType.unknown([String? message]) =
      GamePlayerUnknownError;
  const factory GamePlayerErrorType.unsupportedBrowser() =
      GamePlayerUnsupportedBrowserError;

  String get errorCode;
}

class GamePlayerNetworkError extends GamePlayerErrorType {
  const GamePlayerNetworkError();

  @override
  String get errorCode => 'GP_NETWORK';
}

class GamePlayerSessionExpiredError extends GamePlayerErrorType {
  const GamePlayerSessionExpiredError();

  @override
  String get errorCode => 'GP_SESSION_EXPIRED';
}

class GamePlayerComingSoonError extends GamePlayerErrorType {
  const GamePlayerComingSoonError();

  @override
  String get errorCode => 'GP_COMING_SOON';
}

class GamePlayerUnavailableError extends GamePlayerErrorType {
  const GamePlayerUnavailableError();

  @override
  String get errorCode => 'GP_UNAVAILABLE';
}

class GamePlayerServerError extends GamePlayerErrorType {
  const GamePlayerServerError();

  @override
  String get errorCode => 'GP_SERVER_ERROR';
}

class GamePlayerMaintenanceError extends GamePlayerErrorType {
  const GamePlayerMaintenanceError();

  @override
  String get errorCode => 'GP_MAINTENANCE';
}

class GamePlayerLoadTimeoutError extends GamePlayerErrorType {
  const GamePlayerLoadTimeoutError();

  @override
  String get errorCode => 'GP_LOAD_TIMEOUT';
}

class GamePlayerMissingGameUrlError extends GamePlayerErrorType {
  const GamePlayerMissingGameUrlError();

  @override
  String get errorCode => 'GP_MISSING_URL';
}

class GamePlayerOrientationSetupFailedError extends GamePlayerErrorType {
  const GamePlayerOrientationSetupFailedError();

  @override
  String get errorCode => 'GP_ORIENTATION_FAILED';
}

class GamePlayerHttpError extends GamePlayerErrorType {
  final int statusCode;

  const GamePlayerHttpError(this.statusCode);

  @override
  String get errorCode => 'GP_HTTP_$statusCode';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GamePlayerHttpError &&
          runtimeType == other.runtimeType &&
          statusCode == other.statusCode;

  @override
  int get hashCode => statusCode.hashCode;

  @override
  String toString() => 'GamePlayerHttpError(statusCode: $statusCode)';
}

class GamePlayerUnknownError extends GamePlayerErrorType {
  final String? message;

  const GamePlayerUnknownError([this.message]);

  @override
  String get errorCode => 'GP_UNKNOWN';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GamePlayerUnknownError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() => 'GamePlayerUnknownError(message: $message)';
}

class GamePlayerUnsupportedBrowserError extends GamePlayerErrorType {
  const GamePlayerUnsupportedBrowserError();

  @override
  String get errorCode => 'GP_UNSUPPORTED_BROWSER';

  @override
  String toString() => 'GamePlayerUnsupportedBrowserError';
}

class GamePlayerLaunchFailedError extends GamePlayerErrorType {
  final String? message;

  const GamePlayerLaunchFailedError([this.message]);

  @override
  String get errorCode => 'GP_LAUNCH_FAILED';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GamePlayerLaunchFailedError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() => 'GamePlayerLaunchFailedError(message: $message)';
}
