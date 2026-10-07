enum JackpotLogLevel { debug, warning, error }

typedef JackpotLogHandler =
    void Function(
      JackpotLogLevel level,
      String message, {
      Object? error,
      StackTrace? stackTrace,
    });

class JackpotLogger {
  const JackpotLogger([this.onLog]);

  final JackpotLogHandler? onLog;

  void log(String message) =>
      onLog?.call(JackpotLogLevel.debug, message);

  void warning(String message, [Object? error, StackTrace? stackTrace]) =>
      onLog?.call(
        JackpotLogLevel.warning,
        message,
        error: error,
        stackTrace: stackTrace,
      );

  void error(String message, [Object? error, StackTrace? stackTrace]) =>
      onLog?.call(
        JackpotLogLevel.error,
        message,
        error: error,
        stackTrace: stackTrace,
      );
}
