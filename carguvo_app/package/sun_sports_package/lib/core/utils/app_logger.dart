import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart' show SentryLevel;
import 'package:sun_sports/core/services/monitoring/sentry_service.dart';

class AppLogger {
  final Logger _logger;
  final String? tag;

  AppLogger({this.tag})
    : _logger = Logger(
        printer: PrettyPrinter(
          methodCount: kDebugMode ? 2 : 0,
          errorMethodCount: 8,
          lineLength: 120,
          colors: true,
          printEmojis: true,
          printTime: kDebugMode,
        ),
        level: kDebugMode
            ? Level.debug
            : Level.warning,
      );

  void v(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      _logger.t(_formatMessage(message), error: error, stackTrace: stackTrace);
    }
  }

  void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      _logger.d(_formatMessage(message), error: error, stackTrace: stackTrace);
    }
  }

  void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    final formatted = _formatMessage(message);
    _logger.i(formatted, error: error, stackTrace: stackTrace);
    SentryService.addBreadcrumb(formatted, level: SentryLevel.info, category: tag);
  }

  void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    final formatted = _formatMessage(message);
    _logger.w(formatted, error: error, stackTrace: stackTrace);
    SentryService.addBreadcrumb(
      formatted,
      level: SentryLevel.warning,
      category: tag,
    );
  }

  void e(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    final formatted = _formatMessage(message);
    _logger.e(formatted, error: error, stackTrace: stackTrace);
    SentryService.captureLog(
      formatted,
      level: SentryLevel.error,
      error: error,
      stackTrace: stackTrace,
      category: tag,
    );
  }

  void f(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    final formatted = _formatMessage(message);
    _logger.f(formatted, error: error, stackTrace: stackTrace);
    SentryService.captureLog(
      formatted,
      level: SentryLevel.fatal,
      error: error,
      stackTrace: stackTrace,
      category: tag,
    );
  }

  String _formatMessage(dynamic message) {
    if (tag != null) {
      return '[$tag] $message';
    }
    return message.toString();
  }
}

class AppLoggers {
  static final websocket = AppLogger(tag: 'WebSocket');
  static final api = AppLogger(tag: 'API');
  static final auth = AppLogger(tag: 'Auth');
  static final ui = AppLogger(tag: 'UI');
  static final general = AppLogger();
}
