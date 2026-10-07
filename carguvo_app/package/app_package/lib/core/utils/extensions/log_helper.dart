import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class LogHelper {
  static final LogServiceImpl _logService = LogServiceImpl.instance;

  static void verbose(dynamic message) {
    if (kDebugMode) {
      _logService.logger.t(message);
    }
  }

  static void debug(dynamic message) {
    if (kDebugMode) {
      _logService.logger.d(message);
    }
  }

  static void info(dynamic message) {
    if (kDebugMode) {
      _logService.logger.i(message);
    }
  }

  static void warning(dynamic message) {
    if (kDebugMode) {
      _logService.logger.w(message);
    }
  }

  static void error(dynamic message) {
    if (kDebugMode) {
      _logService.logger.e(message);
    }
  }

  static void fatal(dynamic message) {
    if (kDebugMode) {
      _logService.logger.f(message);
    }
  }
}

class LogServiceImpl {
  static final instance = LogServiceImpl._();
  LogServiceImpl._();

  final logger = Logger(printer: MyPrinter());
}

class MyPrinter extends LogPrinter {
  static final levelEmojis = {
    Level.trace: '🙂',
    Level.debug: '😍😍😍',
    Level.info: '💡',
    Level.warning: '❓',
    Level.error: '⛔',
    Level.fatal: '🤬',
  };

  @override
  List<String> log(LogEvent event) {
    final icon = levelEmojis[event.level]!;
    final msg = event.message;
    final time = DateFormat.jms().format(DateTime.now());
    return ['[$time] $icon $msg'];
  }
}

mixin LoggerMixin {
  String get logTag => runtimeType.toString();

  void logVerbose(String message, [dynamic error, StackTrace? stackTrace]) {
    LogHelper.verbose(_formatMessage(message));
    if (error != null) LogHelper.verbose('Error: $error');
    if (stackTrace != null) LogHelper.verbose('StackTrace: $stackTrace');
  }

  void logDebug(String message, [dynamic error, StackTrace? stackTrace]) {
    LogHelper.debug(_formatMessage(message));
    if (error != null) LogHelper.debug('Error: $error');
    if (stackTrace != null) LogHelper.debug('StackTrace: $stackTrace');
  }

  void logInfo(String message, [dynamic error, StackTrace? stackTrace]) {
    LogHelper.info(_formatMessage(message));
    if (error != null) LogHelper.info('Error: $error');
    if (stackTrace != null) LogHelper.info('StackTrace: $stackTrace');
  }

  void logWarning(String message, [dynamic error, StackTrace? stackTrace]) {
    LogHelper.warning(_formatMessage(message));
    if (error != null) LogHelper.warning('Error: $error');
    if (stackTrace != null) LogHelper.warning('StackTrace: $stackTrace');
  }

  void logError(String message, [dynamic error, StackTrace? stackTrace]) {
    LogHelper.error(_formatMessage(message));
    if (error != null) LogHelper.error('Error: $error');
    if (stackTrace != null) LogHelper.error('StackTrace: $stackTrace');
  }

  void logFatal(String message, [dynamic error, StackTrace? stackTrace]) {
    LogHelper.fatal(_formatMessage(message));
    if (error != null) LogHelper.fatal('Error: $error');
    if (stackTrace != null) LogHelper.fatal('StackTrace: $stackTrace');
  }

  String _formatMessage(String message) => '[$logTag] $message';
}
