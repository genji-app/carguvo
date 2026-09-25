import 'dart:io';

import 'package:dio/dio.dart';

enum SunApiExceptionType {
  businessError,

  authenticationError,

  networkError,

  timeout,

  serverError,

  clientError,

  parsingError,

  unknown,
}

class SunApiException implements Exception {
  final SunApiExceptionType type;

  final String message;

  final String? messageKey;

  final int? status;

  final Object? data;

  final Object? originalError;

  final StackTrace? stackTrace;

  SunApiException({
    required this.message,
    SunApiExceptionType? type,
    this.messageKey,
    this.status,
    this.data,
    this.originalError,
    this.stackTrace,
  }) : type = type ?? _detectType(status, message, originalError);

  static SunApiExceptionType _detectType(
    int? status,
    String message,
    Object? originalError,
  ) {
    if (status != null && status != 0) {
      if (status == 401 || status == 403) {
        return SunApiExceptionType.authenticationError;
      }
      if (status >= 500) {
        return SunApiExceptionType.serverError;
      }
      if (status >= 400 && status < 500) {
        return SunApiExceptionType.clientError;
      }
      return SunApiExceptionType.businessError;
    }

    if (originalError is DioException) {
      switch (originalError.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return SunApiExceptionType.timeout;
        case DioExceptionType.connectionError:
          return SunApiExceptionType.networkError;
        case DioExceptionType.badResponse:
          final statusCode = originalError.response?.statusCode;
          if (statusCode != null) {
            if (statusCode == 401 || statusCode == 403) {
              return SunApiExceptionType.authenticationError;
            }
            if (statusCode >= 500) {
              return SunApiExceptionType.serverError;
            }
            if (statusCode >= 400) {
              return SunApiExceptionType.clientError;
            }
          }
          return SunApiExceptionType.unknown;
        default:
          return SunApiExceptionType.unknown;
      }
    }

    if (originalError is SocketException) {
      return SunApiExceptionType.networkError;
    }

    if (originalError is FormatException || originalError is TypeError) {
      return SunApiExceptionType.parsingError;
    }

    return SunApiExceptionType.unknown;
  }

  int? get httpStatusCode {
    final error = originalError;
    if (error is DioException) {
      return error.response?.statusCode;
    }
    return null;
  }

  bool get isNetworkError => type == SunApiExceptionType.networkError;
  bool get isTimeout => type == SunApiExceptionType.timeout;
  bool get isAuthError => type == SunApiExceptionType.authenticationError;
  bool get isBusinessError => type == SunApiExceptionType.businessError;
  bool get isServerError => type == SunApiExceptionType.serverError;
  bool get isClientError => type == SunApiExceptionType.clientError;
  bool get isParsingError => type == SunApiExceptionType.parsingError;

  bool get isRetryable =>
      type == SunApiExceptionType.networkError ||
      type == SunApiExceptionType.timeout ||
      type == SunApiExceptionType.serverError;

  @override
  String toString() {
    final buffer = StringBuffer('SunApiException[${type.name}]: $message');
    if (status != null) buffer.write(' (status: $status)');
    if (messageKey != null) buffer.write(' (messageKey: $messageKey)');
    if (httpStatusCode != null) buffer.write(' [HTTP $httpStatusCode]');
    return buffer.toString();
  }

  String get userFriendlyMessage {
    if (_isVietnamese(message)) {
      return message;
    }

    switch (type) {
      case SunApiExceptionType.networkError:
        return 'Vui lòng kiểm tra kết nối mạng của bạn.';
      case SunApiExceptionType.timeout:
        return 'Kết nối đã hết hạn, vui lòng thử lại.';
      case SunApiExceptionType.authenticationError:
        return 'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại.';
      case SunApiExceptionType.serverError:
        return 'Hệ thống đang bảo trì hoặc gặp sự cố, vui lòng thử lại sau.';
      case SunApiExceptionType.businessError:
        return message;
      default:
        return 'Đã xảy ra lỗi hệ thống, vui lòng thử lại.';
    }
  }
}

bool _isVietnamese(String? message) {
  final s = message?.trim();
  if (s == null || s.isEmpty) return false;
  final vietnameseChars = RegExp(
    '[ăâđêôơưàáảãạằắẳẵặầấẩẫậèéẻẽẹềếểễệìíỉĩịòóỏõọồốổỗộờớởỡợùúủũụừứửữựỳýỷỹỵ]',
  );
  return vietnameseChars.hasMatch(s.toLowerCase());
}
