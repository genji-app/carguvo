import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:sun_sports/core/error/exceptions.dart';
import 'package:sun_sports/core/network/api_endpoints.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient({Dio? dio, String? baseUrl, Map<String, dynamic>? headers}) {
    _dio = dio ?? Dio();
    _dio.options = BaseOptions(
      baseUrl: baseUrl ?? ApiEndpoints.baseUrl,
      connectTimeout: ApiEndpoints.connectTimeout,
      receiveTimeout: ApiEndpoints.receiveTimeout,
      sendTimeout: kIsWeb ? null : ApiEndpoints.sendTimeout,
      headers: headers ?? _defaultHeaders,
      validateStatus: (status) => status != null && status < 500,
    );

    _setupInterceptors();
  }

  Map<String, dynamic> get _defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  void _setupInterceptors() {
    if (kDebugMode) {
      try {
        _dio.interceptors.add(
          PrettyDioLogger(
            requestHeader: true,
            requestBody: true,
            responseBody: true,
            responseHeader: false,
            error: true,
            compact: true,
            maxWidth: 90,
          ),
        );
      } catch (e) {
      }
    }

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.next(options);
        },
        onError: (error, handler) {
          handler.next(error);
        },
      ),
    );
  }

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void removeAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put<dynamic>(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> patch(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch<dynamic>(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> delete(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete<dynamic>(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Map<String, dynamic> _handleResponse(Response<dynamic> response) {
    final statusCode = response.statusCode ?? 0;

    if (statusCode >= 200 && statusCode < 300) {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      }
      return {'data': data};
    }

    switch (statusCode) {
      case 401:
        throw const AuthenticationException();
      case 403:
        throw const AuthorizationException();
      case 404:
        throw const NotFoundException();
      case 422:
        final responseData = response.data;
        final errors = responseData is Map<String, dynamic>
            ? responseData['errors'] as Map<String, dynamic>?
            : null;
        final message = responseData is Map<String, dynamic>
            ? (responseData['message'] as String?) ?? 'Validation failed'
            : 'Validation failed';
        throw ValidationException(message: message, errors: errors);
      default:
        final responseData = response.data;
        final message = responseData is Map<String, dynamic>
            ? (responseData['message'] as String?) ?? 'Server error occurred'
            : 'Server error occurred';
        throw ServerException(message: message, statusCode: statusCode);
    }
  }

  AppException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();

      case DioExceptionType.badResponse:
        return _handleBadResponse(error);

      case DioExceptionType.cancel:
        return const ServerException(message: 'Request cancelled');

      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return const NetworkException();

      default:
        return ServerException(
          message: error.message ?? 'Unknown error occurred',
        );
    }
  }

  AppException _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    switch (statusCode) {
      case 401:
        return const AuthenticationException();
      case 403:
        return const AuthorizationException();
      case 404:
        return const NotFoundException();
      case 422:
        final errors = data is Map<String, dynamic>
            ? data['errors'] as Map<String, dynamic>?
            : null;
        final message = data is Map<String, dynamic>
            ? (data['message'] as String?) ?? 'Validation failed'
            : 'Validation failed';
        return ValidationException(message: message, errors: errors);
      default:
        final message = data is Map<String, dynamic>
            ? (data['message'] as String?) ?? 'Server error occurred'
            : 'Server error occurred';
        return ServerException(message: message, statusCode: statusCode);
    }
  }

  void dispose() {
    _dio.close();
  }
}
