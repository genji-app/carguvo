import 'package:dio/dio.dart';

import 'game_api_exception.dart';

typedef TokenRefreshCallback = Future<String?> Function();

class GameApiTokenRefreshInterceptor extends Interceptor {
  final TokenRefreshCallback onRefreshToken;

  final Dio _dio;

  bool _isRefreshing = false;

  final List<_RequestRetry> _requestQueue = [];

  static const String _retryKey = '_token_refresh_retry';

  GameApiTokenRefreshInterceptor({required this.onRefreshToken, required Dio dio}) : _dio = dio;

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (response.data is! Map<String, dynamic>) {
      return handler.next(response);
    }

    final json = response.data as Map<String, dynamic>;
    final code = (json['code'] ?? 0) as int;
    final status = (json['status'] ?? 0) as int;
    final message = json['message']?.toString() ?? '';

    final isTokenExpired = _isTokenExpirationError(code, status, message);

    if (isTokenExpired) {
      if (response.requestOptions.extra[_retryKey] == true) {
        return handler.next(response);
      }

      _handleTokenRefresh(response, handler);
      return;
    }

    handler.next(response);
  }

  bool _isTokenExpirationError(int code, int status, String message) {
    final messageLower = message.toLowerCase();

    if ((code == 500 || status == 500) &&
        messageLower.contains('access token is invalid or expired')) {
      return true;
    }

    if ((code == 1 || status == 1) &&
        messageLower.contains('access_token đã hết hạn hoặc không hợp lệ')) {
      return true;
    }

    return false;
  }

  Future<void> _handleTokenRefresh(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    if (_isRefreshing) {
      _requestQueue.add(_RequestRetry(response, handler));
      return;
    }

    _isRefreshing = true;

    try {
      final newToken = await onRefreshToken();

      if (newToken == null) {
        final rawServerMsg = (response.data is Map<String, dynamic>)
            ? (response.data as Map<String, dynamic>)['message']?.toString()
            : null;

        final gameException = GameApiException.unauthorized(
          serverMessage: rawServerMsg,
          description: 'Failed to refresh access token',
          httpStatusCode: response.statusCode ?? 401,
          data: response.data,
          originalError: response,
        );

        final dioError = DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: gameException,
          message: gameException.message,
        );

        _rejectAllPendingRequests(dioError);
        handler.reject(dioError);
        return;
      }

      final retryResponse = await _retryRequest(response.requestOptions, newToken);
      handler.resolve(retryResponse);

      await _retryAllPendingRequests(newToken);
    } catch (e) {
      final gameException = GameApiException.tokenRefresh(
        description: 'Token refresh failed: $e',
        originalError: e,
      );

      final error = DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.unknown,
        error: gameException,
        message: gameException.message,
      );

      _rejectAllPendingRequests(error);
      handler.reject(error);
    } finally {
      _isRefreshing = false;
      _requestQueue.clear();
    }
  }

  Future<Response<dynamic>> _retryRequest(RequestOptions requestOptions, String newToken) async {
    final newOptions = requestOptions.copyWith(
      headers: {...requestOptions.headers, 'Authorization': newToken},
      extra: {
        ...requestOptions.extra,
        _retryKey: true,
      },
    );

    return _dio.fetch<dynamic>(newOptions);
  }

  Future<void> _retryAllPendingRequests(String newToken) async {
    for (final retry in _requestQueue) {
      try {
        final retryResponse = await _retryRequest(retry.requestOptions, newToken);
        retry.handler.resolve(retryResponse);
      } catch (e) {
        final gameException = GameApiException.tokenRefresh(
          description: 'Retry failed: $e',
          originalError: e,
        );

        retry.handler.reject(
          DioException(
            requestOptions: retry.requestOptions,
            type: DioExceptionType.unknown,
            error: gameException,
            message: gameException.message,
          ),
        );
      }
    }
  }

  void _rejectAllPendingRequests(DioException error) {
    for (final retry in _requestQueue) {
      retry.handler.reject(error);
    }
  }
}

class _RequestRetry {
  final Response<dynamic> response;
  final ResponseInterceptorHandler handler;

  _RequestRetry(this.response, this.handler);

  RequestOptions get requestOptions => response.requestOptions;
}
