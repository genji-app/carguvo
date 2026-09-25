import 'package:dio/dio.dart';

sealed class GameApiException implements Exception {
  const GameApiException(
    this.code, {
    this.serverMessage,
    this.description,
    this.apiCode,
    this.apiStatus,
    this.data,
    this.httpStatusCode,
    this.originalError,
    this.stackTrace,
  });

  final String code;

  final String? serverMessage;

  final String? description;

  final int? apiCode;

  final int? apiStatus;

  final Object? data;

  final int? httpStatusCode;

  final Object? originalError;

  final StackTrace? stackTrace;

  String? get message => serverMessage ?? description;

  String get errorCode => code;

  bool get isRetryable => switch (this) {
    GameApiNetworkException() || GameApiTimeoutException() || GameApiServerException() => true,
    _ => false,
  };

  const factory GameApiException.business({
    String code,
    String? serverMessage,
    String? description,
    int? apiCode,
    int? apiStatus,
    Object? data,
    int? httpStatusCode,
    Object? originalError,
    StackTrace? stackTrace,
  }) = GameApiBusinessException;

  const factory GameApiException.unauthorized({
    String code,
    String? serverMessage,
    String? description,
    int? apiCode,
    int? apiStatus,
    Object? data,
    int? httpStatusCode,
    Object? originalError,
    StackTrace? stackTrace,
  }) = GameApiUnauthorizedException;

  const factory GameApiException.network({
    String code,
    String? serverMessage,
    String? description,
    int? httpStatusCode,
    Object? originalError,
    StackTrace? stackTrace,
  }) = GameApiNetworkException;

  const factory GameApiException.timeout({
    String code,
    String? serverMessage,
    String? description,
    int? httpStatusCode,
    Object? originalError,
    StackTrace? stackTrace,
  }) = GameApiTimeoutException;

  const factory GameApiException.server({
    String code,
    String? serverMessage,
    String? description,
    int? apiCode,
    int? apiStatus,
    Object? data,
    int? httpStatusCode,
    Object? originalError,
    StackTrace? stackTrace,
  }) = GameApiServerException;

  const factory GameApiException.client({
    String code,
    String? serverMessage,
    String? description,
    int? apiCode,
    int? apiStatus,
    Object? data,
    int? httpStatusCode,
    Object? originalError,
    StackTrace? stackTrace,
  }) = GameApiClientException;

  const factory GameApiException.parsing({
    String code,
    String? serverMessage,
    String? description,
    Object? originalError,
    StackTrace? stackTrace,
  }) = GameApiParsingException;

  const factory GameApiException.tokenRefresh({
    String code,
    String? serverMessage,
    String? description,
    Object? originalError,
    StackTrace? stackTrace,
  }) = GameApiTokenRefreshException;

  const factory GameApiException.unknown({
    String code,
    String? serverMessage,
    String? description,
    int? apiCode,
    int? apiStatus,
    Object? data,
    int? httpStatusCode,
    Object? originalError,
    StackTrace? stackTrace,
  }) = GameApiUnknownException;

  factory GameApiException.fromDioException(DioException err) {
    if (err.error is GameApiException) {
      return err.error! as GameApiException;
    }

    final statusCode = err.response?.statusCode;
    String? serverMessage;
    int? apiCode;
    int? apiStatus;
    Object? data;

    if (err.response?.data is Map<String, dynamic>) {
      final json = err.response!.data as Map<String, dynamic>;
      serverMessage = json['message']?.toString();
      apiCode = json['code'] is int
          ? json['code'] as int
          : (json['code'] is String ? int.tryParse(json['code'] as String) : null);
      apiStatus = json['status'] is int
          ? json['status'] as int
          : (json['status'] is String ? int.tryParse(json['status'] as String) : null);
      data = json['data'];
    }

    final description = err.message;

    return switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.transformTimeout => GameApiException.timeout(
        serverMessage: serverMessage,
        description: description,
        httpStatusCode: statusCode,
        originalError: err,
        stackTrace: err.stackTrace,
      ),
      DioExceptionType.connectionError => GameApiException.network(
        serverMessage: serverMessage,
        description: description,
        httpStatusCode: statusCode,
        originalError: err,
        stackTrace: err.stackTrace,
      ),
      DioExceptionType.badResponse => _handleHttpStatus(
        statusCode,
        serverMessage: serverMessage,
        description: description,
        apiCode: apiCode,
        apiStatus: apiStatus,
        data: data,
        err: err,
      ),
      _ => GameApiException.unknown(
        serverMessage: serverMessage,
        description: description,
        apiCode: apiCode,
        apiStatus: apiStatus,
        data: data,
        httpStatusCode: statusCode,
        originalError: err,
        stackTrace: err.stackTrace,
      ),
    };
  }

  static GameApiException _handleHttpStatus(
    int? statusCode, {
    String? serverMessage,
    String? description,
    int? apiCode,
    int? apiStatus,
    Object? data,
    required DioException err,
  }) {
    if (statusCode == 401 || statusCode == 403) {
      return GameApiUnauthorizedException(
        serverMessage: serverMessage,
        description: description,
        apiCode: apiCode,
        apiStatus: apiStatus,
        data: data,
        httpStatusCode: statusCode,
        originalError: err,
        stackTrace: err.stackTrace,
      );
    }
    if (statusCode != null && statusCode >= 500) {
      return GameApiServerException(
        serverMessage: serverMessage,
        description: description,
        apiCode: apiCode,
        apiStatus: apiStatus,
        data: data,
        httpStatusCode: statusCode,
        originalError: err,
        stackTrace: err.stackTrace,
      );
    }
    if (statusCode != null && statusCode >= 400) {
      return GameApiClientException(
        serverMessage: serverMessage,
        description: description,
        apiCode: apiCode,
        apiStatus: apiStatus,
        data: data,
        httpStatusCode: statusCode,
        originalError: err,
        stackTrace: err.stackTrace,
      );
    }
    return GameApiBusinessException(
      serverMessage: serverMessage,
      description: description,
      apiCode: apiCode,
      apiStatus: apiStatus,
      data: data,
      httpStatusCode: statusCode,
      originalError: err,
      stackTrace: err.stackTrace,
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer('GameApiException[$code]: ');
    if (serverMessage != null) {
      buffer.write(serverMessage);
    } else if (description != null) {
      buffer.write(description);
    }

    if (apiCode != null && apiStatus != null) {
      buffer.write(' (code: $apiCode, status: $apiStatus)');
    } else if (apiCode != null) {
      buffer.write(' (code: $apiCode)');
    } else if (apiStatus != null) {
      buffer.write(' (status: $apiStatus)');
    }

    if (httpStatusCode != null) {
      buffer.write(' [HTTP $httpStatusCode]');
    }

    return buffer.toString();
  }
}

final class GameApiBusinessException extends GameApiException {
  const GameApiBusinessException({
    String code = 'business_error',
    super.serverMessage,
    super.description,
    super.apiCode,
    super.apiStatus,
    super.data,
    super.httpStatusCode,
    super.originalError,
    super.stackTrace,
  }) : super(code);
}

final class GameApiUnauthorizedException extends GameApiException {
  const GameApiUnauthorizedException({
    String code = 'unauthorized',
    super.serverMessage,
    super.description,
    super.apiCode,
    super.apiStatus,
    super.data,
    super.httpStatusCode = 401,
    super.originalError,
    super.stackTrace,
  }) : super(code);
}

final class GameApiNetworkException extends GameApiException {
  const GameApiNetworkException({
    String code = 'network_error',
    super.serverMessage,
    super.description,
    super.httpStatusCode,
    super.originalError,
    super.stackTrace,
  }) : super(code);
}

final class GameApiTimeoutException extends GameApiException {
  const GameApiTimeoutException({
    String code = 'timeout_error',
    super.serverMessage,
    super.description,
    super.httpStatusCode,
    super.originalError,
    super.stackTrace,
  }) : super(code);
}

final class GameApiServerException extends GameApiException {
  const GameApiServerException({
    String code = 'server_error',
    super.serverMessage,
    super.description,
    super.apiCode,
    super.apiStatus,
    super.data,
    super.httpStatusCode,
    super.originalError,
    super.stackTrace,
  }) : super(code);
}

final class GameApiClientException extends GameApiException {
  const GameApiClientException({
    String code = 'client_error',
    super.serverMessage,
    super.description,
    super.apiCode,
    super.apiStatus,
    super.data,
    super.httpStatusCode,
    super.originalError,
    super.stackTrace,
  }) : super(code);
}

final class GameApiParsingException extends GameApiException {
  const GameApiParsingException({
    String code = 'parsing_error',
    super.serverMessage,
    super.description,
    super.originalError,
    super.stackTrace,
  }) : super(code);
}

final class GameApiTokenRefreshException extends GameApiException {
  const GameApiTokenRefreshException({
    String code = 'token_refresh_error',
    super.serverMessage,
    super.description,
    super.originalError,
    super.stackTrace,
  }) : super(code);
}

final class GameApiUnknownException extends GameApiException {
  const GameApiUnknownException({
    String code = 'unknown_error',
    super.serverMessage,
    super.description,
    super.apiCode,
    super.apiStatus,
    super.data,
    super.httpStatusCode,
    super.originalError,
    super.stackTrace,
  }) : super(code);
}
