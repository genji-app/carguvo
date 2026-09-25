import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sun_sports/core/network/sb_token_freshness.dart';
import 'package:sun_sports/core/services/network/fix_json_content_type_transformer.dart';
import 'package:sun_sports/core/services/network/dio_logger_interceptor.dart';
import 'package:sun_sports/core/services/auth/token_error_handler.dart';
import 'package:sun_sports/core/services/maintenance/maintenance_service.dart';
import 'package:sun_sports/core/utils/app_logger.dart';

class SbApiClient {
  static final SbApiClient _instance = SbApiClient._internal();
  static SbApiClient get instance => _instance;
  factory SbApiClient() => _instance;

  SbApiClient._internal() {
    _initDio();
  }

  late final Dio _dio;

  String _userToken = '';
  String _userTokenSb = '';
  String _chatToken = '';

  String Function() sbTokenProbeUrlBuilder = () => '';

  String get userToken => _userToken;
  String get userTokenSb => _userTokenSb;
  String get chatToken => _chatToken;

  set userToken(String value) => _userToken = value;
  set userTokenSb(String value) => _userTokenSb = value;
  set chatToken(String value) => _chatToken = value;

  void _initDio() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: kIsWeb ? null : const Duration(seconds: 60),
        validateStatus: (status) =>
        (status != null && status >= 200 && status < 400) ||
            status == 502 ||
            status == 504,
      ),
    )..transformer = FixJsonContentTypeTransformer();

    _dio.interceptors.addAll([
      _RequestTimingInterceptor(),
      DioLoggerInterceptor(
        enableRequestLogging: true,
        enableResponseLogging: true,
        enableErrorLogging: true,
        logRequestHeaders: true,
        logResponseHeaders: false,
        maxResponseBodyLength: 10000,
      ),
      _TokenRefreshInterceptor(
        dio: _dio,
        getToken: () => _userTokenSb,
        getUserToken: () => _userToken,
      ),
      _SbEmptyResponseValidator(
        dio: _dio,
        getToken: () => _userTokenSb,
        getUserToken: () => _userToken,
        getProbeUrl: () => sbTokenProbeUrlBuilder(),
      ),
    ]);
  }

  Future<Response<T>> get<T>(
      String url, {
        Map<String, dynamic>? queryParameters,
        Map<String, String>? headers,
        CancelToken? cancelToken,
      }) async {
    return _dio.get<T>(
      url,
      queryParameters: queryParameters,
      options: Options(headers: headers),
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> post<T>(
      String url, {
        dynamic data,
        Map<String, String>? headers,
        CancelToken? cancelToken,
      }) async {
    return _dio.post<T>(
      url,
      data: data,
      options: Options(headers: headers),
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> put<T>(
      String url, {
        dynamic data,
        Map<String, String>? headers,
        CancelToken? cancelToken,
      }) async {
    return _dio.put<T>(
      url,
      data: data,
      options: Options(headers: headers),
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> delete<T>(
      String url, {
        dynamic data,
        Map<String, String>? headers,
        CancelToken? cancelToken,
      }) async {
    return _dio.delete<T>(
      url,
      data: data,
      options: Options(headers: headers),
      cancelToken: cancelToken,
    );
  }

  Future<dynamic> send(
      String url, {
        bool post = false,
        bool delete = false,
        String? body,
        bool contentJson = false,
        bool headerToken = false,
        bool base64 = false,
        bool json = false,
        bool authorization = false,
        String? token,
        String? lng,
        CancelToken? cancelToken,
      }) async {
    try {
      final headers = <String, String>{};
      if (lng != null) headers['lng'] = lng;
      if (headerToken) headers['token'] = _userTokenSb;
      if (authorization) headers['Authorization'] = token ?? _userTokenSb;
      if (contentJson) headers['Content-Type'] = 'application/json';

      final Response<String> response;
      if (delete) {
        response = await _dio.delete<String>(
          url,
          data: body,
          options: Options(headers: headers, responseType: ResponseType.plain),
          cancelToken: cancelToken,
        );
      } else if (post) {
        response = await _dio.post<String>(
          url,
          data: body,
          options: Options(headers: headers, responseType: ResponseType.plain),
          cancelToken: cancelToken,
        );
      } else {
        response = await _dio.get<String>(
          url,
          options: Options(headers: headers, responseType: ResponseType.plain),
          cancelToken: cancelToken,
        );
      }

      if (response.statusCode == 502 || response.statusCode == 504) {
        return json ? <String, dynamic>{} : '';
      }

      String responseText = response.data ?? '';

      if (base64 && responseText.isNotEmpty) {
        final bytes = base64Decode(responseText);
        responseText = utf8.decode(bytes);
      }

      if (json && responseText.isNotEmpty) {
        return jsonDecode(responseText);
      }

      return responseText;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) rethrow;
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw HttpException(0, 'Request timeout');
      }
      final statusCode = e.response?.statusCode ?? 0;
      if (statusCode == MaintenanceService.maintenanceCode) {
        MaintenanceService.instance.trigger();
      }
      throw HttpException(
        statusCode,
        'Network error: ${e.message}',
        body: e.response?.data,
      );
    }
  }

  void clearTokens() {
    _userToken = '';
    _userTokenSb = '';
    _chatToken = '';
  }
}

class _SbEmptyResponseValidator extends Interceptor {
  _SbEmptyResponseValidator({
    required this.dio,
    required this.getToken,
    required this.getUserToken,
    required this.getProbeUrl,
  });

  final Dio dio;
  final String Function() getToken;
  final String Function() getUserToken;
  final String Function() getProbeUrl;

  static final _logger = AppLogger(tag: '_SbEmptyResponseValidator');

  static const String _probeFlag = '_sbTokenProbe';

  static const String _validatedFlag = '_sbEmptyValidated';

  @override
  void onResponse(
      Response<dynamic> response,
      ResponseInterceptorHandler handler,
      ) async {
    final options = response.requestOptions;
    final sbToken = getToken();

    if (options.extra[_probeFlag] == true) return handler.next(response);
    if (options.extra[_validatedFlag] == true) return handler.next(response);
    if (sbToken.isEmpty) return handler.next(response);
    if (isRefreshChainUrl(options.uri.toString())) {
      return handler.next(response);
    }
    if (!carriesSbToken(options, sbToken)) return handler.next(response);
    if (!isSuspiciousEmptyBody(response.data)) return handler.next(response);

    final alive = await _isTokenAlive(sbToken);
    if (alive != false) return handler.next(response);

    _logger.w(
      'Response rỗng + sb token đã chết (${options.uri.path}) → refresh rồi '
          'gọi lại 1 lần',
    );

    final oldAccess = getUserToken();
    final refreshed = await TokenErrorHandler.instance.handleTokenError(
      closeGameOnFail: false,
    );
    if (!refreshed) return handler.next(response);

    options.extra[_validatedFlag] = true;
    reapplySbTokens(
      options,
      oldSb: sbToken,
      oldAccess: oldAccess,
      newSb: getToken(),
      newAccess: getUserToken(),
    );

    if (isNonIdempotentWrite(options.uri.path)) {
      _logger.w(
        'Đã refresh token nhưng KHÔNG gửi lại ${options.uri.path} '
            '(API ghi — tránh đặt cược trùng)',
      );
      return handler.next(response);
    }

    try {
      return handler.resolve(await dio.fetch<dynamic>(options));
    } catch (e, stackTrace) {
      _logger.e(
        'Gọi lại sau refresh thất bại — trả response rỗng ban đầu',
        error: e,
        stackTrace: stackTrace,
      );
      return handler.next(response);
    }
  }

  static const Duration _aliveCacheTtl = Duration(seconds: 10);
  DateTime? _aliveAt;
  Future<bool?>? _inFlightProbe;

  Future<bool?> _isTokenAlive(String sbToken) {
    final aliveAt = _aliveAt;
    if (aliveAt != null && DateTime.now().difference(aliveAt) < _aliveCacheTtl) {
      return Future.value(true);
    }
    final pending = _inFlightProbe;
    if (pending != null) return pending;

    final probe = _probeTokenAlive(sbToken);
    _inFlightProbe = probe;
    return probe.whenComplete(() {
      if (identical(_inFlightProbe, probe)) _inFlightProbe = null;
    });
  }

  Future<bool?> _probeTokenAlive(String sbToken) async {
    final url = getProbeUrl();
    if (url.isEmpty) return null;
    try {
      final probe = await dio.get<String>(
        url,
        options: Options(
          headers: {'token': sbToken},
          responseType: ResponseType.plain,
          extra: const {_probeFlag: true},
        ),
      );
      final alive = !isSuspiciousEmptyBody(probe.data);
      _aliveAt = alive ? DateTime.now() : null;
      return alive;
    } catch (e) {
      _logger.w('Probe users/info lỗi: $e');
      return null;
    }
  }
}

class _RequestTimingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['_startTime'] = DateTime.now().millisecondsSinceEpoch;
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final startTime = response.requestOptions.extra['_startTime'] as int?;
    if (startTime != null) {
      final duration = DateTime.now().millisecondsSinceEpoch - startTime;
      AppLogger(tag: 'HTTP').d(
        '${response.requestOptions.method} ${response.requestOptions.uri} - ${duration}ms',
      );
    }
    handler.next(response);
  }
}

class _TokenRefreshInterceptor extends QueuedInterceptor {
  _TokenRefreshInterceptor({
    required this.dio,
    required this.getToken,
    required this.getUserToken,
  });

  final Dio dio;
  final String Function() getToken;
  final String Function() getUserToken;

  static final _logger = AppLogger(tag: '_TokenRefreshInterceptor');

  bool _isBettingPath(String path) {
    final p = path.toLowerCase();
    return p.contains('/bet/') || p.contains('place-bet') ||
        p.contains('cash-out');
  }

  bool _hasBusinessErrorCode(dynamic data) {
    if (data is Map) return data['errorCode'] != null;
    if (data is String) return data.contains('"errorCode"');
    return false;
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final opts = err.requestOptions;
    final requestUrl = opts.uri.toString();

    if (isRefreshChainUrl(requestUrl)) {
      return handler.next(err);
    }

    final status = err.response?.statusCode;

    final isAuth = status == 401;

    final carriesSbToken =
        opts.headers.containsKey('Authorization') ||
            opts.headers.containsKey('token');
    final maybeExpiredOn500 = status == 500 && carriesSbToken;

    final maybeExpiredOn400 =
        status == 400 &&
            carriesSbToken &&
            _isBettingPath(opts.uri.path) &&
            !_hasBusinessErrorCode(err.response?.data);

    if (!isAuth && !maybeExpiredOn500 && !maybeExpiredOn400) {
      return handler.next(err);
    }

    if (opts.extra['_tokenRetried'] == true) {
      return handler.next(err);
    }

    _logger.w(
      'Received $status, attempting token refresh... '
          '(sbTokenReq=$carriesSbToken)',
    );

    final oldSb = getToken();
    final oldAccess = getUserToken();

    try {
      final refreshed = await TokenErrorHandler.instance.handleTokenError(
        closeGameOnFail: isAuth,
      );

      if (!refreshed) {
        return handler.reject(err);
      }

      if (isNonIdempotentWrite(opts.uri.path)) {
        _logger.w(
          'Đã refresh token nhưng KHÔNG auto-retry ${opts.uri.path} '
              '(API ghi — tránh thao tác trùng)',
        );
        return handler.reject(err);
      }

      _logger.i('Token refreshed, retrying request once...');
      opts.extra['_tokenRetried'] = true;
      reapplySbTokens(
        opts,
        oldSb: oldSb,
        oldAccess: oldAccess,
        newSb: getToken(),
        newAccess: getUserToken(),
      );

      final response = await dio.fetch<dynamic>(opts);
      return handler.resolve(response);
    } catch (e) {
      _logger.e('Error during token refresh retry: $e');
      return handler.reject(err);
    }
  }
}

class HttpException implements Exception {
  final int statusCode;
  final String message;

  final Object? body;

  HttpException(this.statusCode, this.message, {this.body});

  @override
  String toString() => 'HttpException($statusCode): $message';
}
