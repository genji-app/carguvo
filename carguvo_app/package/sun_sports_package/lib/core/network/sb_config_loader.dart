import 'dart:async';
import 'dart:math';
import 'package:brand_config/brand_config.dart';
import 'package:dio/dio.dart';
import 'package:sun_sports/core/network/sb_config_cache.dart';

class SbConfigLoader {
  SbConfigLoader._();

  static const int _maxAttemptsPerUrl = 2;

  /// Build với `--dart-define=GITHUB_PAT=...`. Không hardcode token.
  static const String _githubToken = String.fromEnvironment('GITHUB_PAT');

  static Future<T> _withRetry<T>(
    List<String> candidates,
    Future<T> Function(String url) fetch,
    Future<T> Function(String url)? fetchWithAuth,
  ) async {
    Object? lastError;
    String? githubUrl;

    for (final candidate in candidates) {
      final isGithub = isGithubConfigUrl(candidate);
      if(isGithub) {
        githubUrl ??= candidate;
      }
      final attempts = isGithub ? 1 : _maxAttemptsPerUrl;

      for (var attempt = 0; attempt < attempts; attempt++) {
        try {
          return await fetch(candidate);
        } catch (e) {
          lastError = e;
          await Future<void>.delayed(
            Duration(milliseconds: 250 * (1 << attempt)),
          );
        }
      }
    }

    if (githubUrl != null && fetchWithAuth != null) {
      try {
        return await fetchWithAuth(githubUrl);
      } catch (_) {
      }
    }

    throw Exception('Failed to load config after retries: $lastError');
  }

  static Future<Map<String, dynamic>> getConfig(
    String url, {
    List<String>? fallbackUrls,
  }) {
    return _loadWithCache(url, () {
      return _withRetry(
        configCandidates(url, extraFallbacks: fallbackUrls),
        _fetchBase64Config,
        _fetchBase64ConfigWithAuth,
      );
    });
  }

  static Future<Map<String, dynamic>> _fetchBase64Config(String url) =>
      _fetchUrl(url, parse: _parseConfigResponse);

  static Future<Map<String, dynamic>> _fetchBase64ConfigWithAuth(String url) =>
      _fetchUrl(url, withAuth: true, parse: _parseConfigResponse);

  static Map<String, dynamic> _parseConfigResponse(String data) =>
      decodeConfigBody(data);

  static Future<Map<String, dynamic>> getConfigJson(
    String url, {
    List<String>? fallbackUrls,
  }) {
    return _loadWithCache(url, () {
      return _withRetry(
        configCandidates(url, extraFallbacks: fallbackUrls),
        _fetchJsonConfig,
        _fetchGithubConfigWithAuth,
      );
    });
  }

  static Future<Map<String, dynamic>> _fetchJsonConfig(String url) =>
      _fetchUrl(url, parse: _parseJsonResponse);

  static Future<Map<String, dynamic>> _fetchGithubConfigWithAuth(String url) =>
      _fetchUrl(url, withAuth: true, parse: _parseJsonResponse);

  static Map<String, String>? get _githubAuthHeaders {
    if (_githubToken.isEmpty) return null;
    return {
      'Authorization': 'token $_githubToken',
      'Accept': 'application/vnd.github.v3.raw',
    };
  }

  static Dio _dio() => Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

  static Future<Map<String, dynamic>> _fetchUrl(
    String url, {
    required Map<String, dynamic> Function(String data) parse,
    bool withAuth = false,
  }) async {
    final randomParam = '?r=${Random().nextDouble()}';
    final response = await _dio().get<String>(
      url + randomParam,
      options: Options(
        responseType: ResponseType.plain,
        headers: withAuth ? _githubAuthHeaders : null,
      ),
    );

    final data = response.data;
    if (data == null || data.isEmpty) {
      throw Exception('Empty config response');
    }

    try {
      return parse(data);
    } catch (_) {
      unawaited(SbConfigCache.rememberInvalid(url, data));
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> _loadWithCache(
    String url,
    Future<Map<String, dynamic>> Function() load,
  ) async {
    try {
      final config = await load();
      unawaited(SbConfigCache.remember(url, config));
      return config;
    } catch (e) {
      final cached = await SbConfigCache.recall(url);
      if (cached != null) {
        unawaited(SbConfigCache.markFallback(url));
        // ignore: avoid_print
        print('SbConfigLoader: fetch fail ($e) → dùng cache cũ cho $url');
        return cached;
      }
      rethrow;
    }
  }

  static Map<String, dynamic> _parseJsonResponse(dynamic data) {
    if (data == null) {
      throw Exception('Empty config response');
    }
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is String) return decodeConfigBody(data);
    throw Exception('Unsupported config response type: ${data.runtimeType}');
  }

  static Future<bool> waitForReady({
    required bool Function() isReady,
    Duration maxWaitTime = const Duration(seconds: 10),
    Duration checkInterval = const Duration(milliseconds: 100),
  }) async {
    if (isReady()) {
      return true;
    }

    final startTime = DateTime.now();

    while (!isReady()) {
      final elapsed = DateTime.now().difference(startTime);
      if (elapsed > maxWaitTime) {
        return false;
      }
      await Future<void>.delayed(checkInterval);
    }

    return true;
  }
}
