enum LogLevel {
  debug,
  info,
  warning,
  error,
}

abstract class Logger {
  void debug(String message, [Object? error, StackTrace? stackTrace]);
  void info(String message, [Object? error, StackTrace? stackTrace]);
  void warning(String message, [Object? error, StackTrace? stackTrace]);
  void error(String message, [Object? error, StackTrace? stackTrace]);
}

class ConsoleLogger implements Logger {
  final String tag;
  final LogLevel minLevel;

  const ConsoleLogger({
    this.tag = 'SportSocket',
    this.minLevel = LogLevel.info,
  });

  bool _shouldLog(LogLevel level) => level.index >= minLevel.index;

  String _formatMessage(LogLevel level, String message) {
    final timestamp = DateTime.now().toIso8601String();
    final levelName = level.name.toUpperCase();
    return '[$timestamp] [$tag] [$levelName] $message';
  }

  @override
  void debug(String message, [Object? error, StackTrace? stackTrace]) {
    if (_shouldLog(LogLevel.debug)) {
      // ignore: avoid_print
      print(_formatMessage(LogLevel.debug, message));
      if (error != null) {
        // ignore: avoid_print
        print('  Error: $error');
      }
    }
  }

  @override
  void info(String message, [Object? error, StackTrace? stackTrace]) {
    if (_shouldLog(LogLevel.info)) {
      // ignore: avoid_print
      print(_formatMessage(LogLevel.info, message));
      if (error != null) {
        // ignore: avoid_print
        print('  Error: $error');
      }
    }
  }

  @override
  void warning(String message, [Object? error, StackTrace? stackTrace]) {
    if (_shouldLog(LogLevel.warning)) {
      // ignore: avoid_print
      print(_formatMessage(LogLevel.warning, message));
      if (error != null) {
        // ignore: avoid_print
        print('  Error: $error');
      }
    }
  }

  @override
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (_shouldLog(LogLevel.error)) {
      // ignore: avoid_print
      print(_formatMessage(LogLevel.error, message));
      if (error != null) {
        // ignore: avoid_print
        print('  Error: $error');
      }
      if (stackTrace != null) {
        // ignore: avoid_print
        print('  StackTrace: $stackTrace');
      }
    }
  }
}

class NoOpLogger implements Logger {
  const NoOpLogger();

  @override
  void debug(String message, [Object? error, StackTrace? stackTrace]) {}

  @override
  void info(String message, [Object? error, StackTrace? stackTrace]) {}

  @override
  void warning(String message, [Object? error, StackTrace? stackTrace]) {}

  @override
  void error(String message, [Object? error, StackTrace? stackTrace]) {}
}
