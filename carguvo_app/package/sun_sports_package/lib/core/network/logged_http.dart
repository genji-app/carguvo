import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:sun_sports/core/services/monitoring/login_timing.dart';
import 'package:sun_sports/core/utils/app_logger.dart';

class LoggedHttp {
  LoggedHttp._();

  static final _log = AppLogger(tag: 'AuthApi');

  static const int _maxBodyLog = 600;

  static const Duration requestTimeout = Duration(seconds: 20);

  static const Set<String> _sensitiveParams = {
    'refreshtoken',
    'token',
    'password',
    'hash',
  };

  static Future<http.Response> post(
    Uri url, {
    required String action,
    Map<String, String>? headers,
    Object? body,
  }) {
    return _run(
      action: action,
      method: 'POST',
      url: url,
      send: () => http.post(url, headers: headers, body: body),
    );
  }

  static Future<http.Response> get(
    Uri url, {
    required String action,
    Map<String, String>? headers,
  }) {
    return _run(
      action: action,
      method: 'GET',
      url: url,
      send: () => http.get(url, headers: headers),
    );
  }

  static Future<http.Response> _run({
    required String action,
    required String method,
    required Uri url,
    required Future<http.Response> Function() send,
  }) async {
    final stopwatch = Stopwatch()..start();
    final sentAt = DateTime.now().toUtc();

    final http.Response response;
    try {
      response = await send().timeout(requestTimeout);
    } catch (e, st) {
      stopwatch.stop();
      final ex = ApiRequestException(
        action: action,
        method: method,
        url: redactUrl(url),
        sentAt: sentAt,
        elapsedMs: stopwatch.elapsedMilliseconds,
        connectivity: await _connectivity(),
        cause: e,
      );
      _noteLoginTiming(action, ex.requestSummary);
      _log.e(
        e is TimeoutException
            ? 'API FAILED (no response within ${requestTimeout.inSeconds}s): $ex'
            : 'API FAILED (no HTTP response — browser chặn: CORS/offline/DNS; '
                  'devops check log OPTIONS preflight phía gateway): $ex',
        error: e,
        stackTrace: st,
      );
      throw ex;
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      stopwatch.stop();
      final ex = ApiRequestException(
        action: action,
        method: method,
        url: redactUrl(url),
        statusCode: response.statusCode,
        responseBody: _decodeBody(response),
        sentAt: sentAt,
        elapsedMs: stopwatch.elapsedMilliseconds,
        connectivity: await _connectivity(),
      );
      _noteLoginTiming(action, ex.requestSummary);
      _log.e('API FAILED (HTTP ${response.statusCode}): $ex');
      throw ex;
    }

    stopwatch.stop();
    _noteLoginTiming(
      action,
      'sent=${sentAt.toIso8601String()} status=${response.statusCode} '
      'elapsed=${stopwatch.elapsedMilliseconds}ms',
    );
    return response;
  }

  static void _noteLoginTiming(String action, String summary) {
    LoginTiming.current?.note('req_$action', summary);
  }

  static String _decodeBody(http.Response response) {
    try {
      final body = utf8.decode(response.bodyBytes, allowMalformed: true);
      if (body.length <= _maxBodyLog) return body;
      return '${body.substring(0, _maxBodyLog)}…(${body.length} chars)';
    } catch (_) {
      return '<không decode được body>';
    }
  }

  static String redactUrl(Uri url) {
    if (url.queryParameters.isEmpty) return url.toString();
    final redacted = url.queryParameters.map(
      (key, value) => MapEntry(
        key,
        _sensitiveParams.contains(key.toLowerCase()) ? '<redacted>' : value,
      ),
    );
    return url.replace(queryParameters: redacted).toString();
  }

  static Future<String> _connectivity() async {
    try {
      final results = await Connectivity().checkConnectivity().timeout(
        const Duration(seconds: 2),
      );
      if (results.isEmpty) return 'none';
      return results.map((r) => r.name).join('+');
    } catch (_) {
      return 'unknown';
    }
  }
}

class ApiRequestException implements Exception {
  ApiRequestException({
    required this.action,
    required this.method,
    required this.url,
    required this.sentAt,
    required this.elapsedMs,
    required this.connectivity,
    this.statusCode,
    this.responseBody,
    this.cause,
  });

  final String action;
  final String method;
  final String url;

  final DateTime sentAt;
  final int elapsedMs;
  final String connectivity;
  final int? statusCode;
  final String? responseBody;
  final Object? cause;

  bool get isNetworkLayerFailure => statusCode == null;

  String get requestSummary {
    final status =
        statusCode?.toString() ?? 'none(network-layer: CORS/offline/DNS)';
    final body = responseBody == null ? '' : ' body=$responseBody';
    final causeText = cause == null ? '' : ' cause=$cause';
    return 'sent=${sentAt.toIso8601String()} status=$status$body '
        'elapsed=${elapsedMs}ms net=$connectivity$causeText';
  }

  @override
  String toString() =>
      'ApiRequestException(action=$action $method $url $requestSummary)';
}
