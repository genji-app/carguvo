// ignore_for_file: unused_element
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sun_sports/core/utils/extensions/log_helper.dart';

class DioLoggerInterceptor extends Interceptor with LoggerMixin {
  DioLoggerInterceptor({
    this.enableRequestLogging = true,
    this.enableResponseLogging = true,
    this.enableErrorLogging = true,
    this.logRequestHeaders = false,
    this.logResponseHeaders = false,
    this.maxResponseBodyLength = 1000,
  });

  final bool enableRequestLogging;

  final bool enableResponseLogging;

  final bool enableErrorLogging;

  final bool logRequestHeaders;

  final bool logResponseHeaders;

  final int maxResponseBodyLength;

  @override
  String get logTag => 'HTTP';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode && enableRequestLogging) {
      _logRequest(options);
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (kDebugMode && enableResponseLogging) {
      _logResponse(response);
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode && enableErrorLogging) {
      _logDioError(err);
    }
    super.onError(err, handler);
  }

  void _logRequest(RequestOptions options) {

  }

  void _logResponse(Response<dynamic> response) {

  }

  void _logDioError(DioException err) {
    final buffer = StringBuffer();

    buffer.writeln('');
    buffer.writeln(
      '┌──────────────────────────────────────────────────────────────',
    );
    buffer.writeln('│ ❌ ERROR');
    buffer.writeln(
      '├──────────────────────────────────────────────────────────────',
    );
    buffer.writeln(
      '│ ${err.requestOptions.method.toUpperCase()} ${err.requestOptions.uri}',
    );
    buffer.writeln('│ Type: ${err.type.name}');
    buffer.writeln('│ Message: ${err.message ?? 'No message'}');
    buffer.writeln('│');

    if (err.response != null) {
      buffer.writeln('│ 📥 Response:');
      buffer.writeln(
        '│   Status: ${err.response?.statusCode} ${err.response?.statusMessage ?? ''}',
      );
      if (err.response?.data != null) {
        buffer.writeln('│   Body:');
        final bodyStr = _formatBody(err.response?.data, truncate: true);
        for (final line in bodyStr.split('\n')) {
          buffer.writeln('│     $line');
        }
      }
    }

    buffer.writeln(
      '└──────────────────────────────────────────────────────────────',
    );

    super.logError(buffer.toString());
  }

  String _formatBody(dynamic data, {bool truncate = false}) {
    if (data == null) return 'null';

    try {
      String result;

      if (data is String) {
        try {
          final parsed = jsonDecode(data);
          result = const JsonEncoder.withIndent('  ').convert(parsed);
        } catch (_) {
          result = data;
        }
      } else if (data is Map || data is List) {
        result = const JsonEncoder.withIndent('  ').convert(data);
      } else {
        result = data.toString();
      }

      if (truncate && result.length > maxResponseBodyLength) {
        return '${result.substring(0, maxResponseBodyLength)}\n... [truncated ${result.length - maxResponseBodyLength} chars]';
      }

      return result;
    } catch (e) {
      return data.toString();
    }
  }

  String _maskSensitiveHeader(String key, String value) {
    final sensitiveHeaders = [
      'authorization',
      'token',
      'x-token',
      'cookie',
      'set-cookie',
    ];

    if (sensitiveHeaders.contains(key.toLowerCase())) {
      if (value.length > 10) {
        return '${value.substring(0, 6)}...${value.substring(value.length - 4)}';
      }
      return '****';
    }
    return value;
  }

  String _getStatusEmoji(int statusCode) {
    if (statusCode >= 200 && statusCode < 300) return '✅';
    if (statusCode >= 300 && statusCode < 400) return '↪️';
    if (statusCode >= 400 && statusCode < 500) return '⚠️';
    if (statusCode >= 500) return '🔥';
    return '❓';
  }

  int? _calculateDuration(RequestOptions options) {
    final startTime = options.extra['_startTime'] as DateTime?;
    if (startTime != null) {
      return DateTime.now().difference(startTime).inMilliseconds;
    }
    return null;
  }
}

class RequestTimingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['_startTime'] = DateTime.now();
    super.onRequest(options, handler);
  }
}
