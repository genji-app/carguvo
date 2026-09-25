import 'dart:async';

import 'package:dio/dio.dart';

class GameApiRetryInterceptor extends Interceptor {
  GameApiRetryInterceptor({required this.dio, this.maxRetries = 3});

  final Dio dio;

  final int maxRetries;

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      var attempt = err.requestOptions.extra['retryAttempt'] as int? ?? 0;

      if (attempt < maxRetries) {
        attempt++;

        final delay = Duration(seconds: 1 << (attempt - 1));
        await Future.delayed(delay);

        final options = err.requestOptions;
        options.extra['retryAttempt'] = attempt;

        try {
          final response = await dio.request<dynamic>(
            options.path,
            data: options.data,
            queryParameters: options.queryParameters,
            cancelToken: options.cancelToken,
            options: Options(
              method: options.method,
              sendTimeout: options.sendTimeout,
              receiveTimeout: options.receiveTimeout,
              extra: options.extra,
              headers: options.headers,
              responseType: options.responseType,
              contentType: options.contentType,
              validateStatus: options.validateStatus,
              receiveDataWhenStatusError: options.receiveDataWhenStatusError,
              followRedirects: options.followRedirects,
              maxRedirects: options.maxRedirects,
              requestEncoder: options.requestEncoder,
              responseDecoder: options.responseDecoder,
              listFormat: options.listFormat,
            ),
            onSendProgress: options.onSendProgress,
            onReceiveProgress: options.onReceiveProgress,
          );

          return handler.resolve(response);
        } on DioException catch (e) {
          return handler.next(e);
        }
      }
    }

    return handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.unknown;
  }
}
