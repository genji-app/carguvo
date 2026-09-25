import 'dart:io';

import 'package:game_api_client/game_api_client.dart';
import 'package:sun_sports/core/services/network/sun_api_exception.dart';

import 'models/models.dart';

sealed class TransactionFailure implements Exception {
  const TransactionFailure({Object? source, this.message}) : _source = source;

  final Object? _source;

  Object? get source => _source;

  final String? message;

  Object? get cause => _source;

  bool get isRetryable => false;

  factory TransactionFailure.from(
    Object error, [
    TransactionSource? transactionSource,
  ]) {
    if (error is TransactionFailure) return error;

    if (error is GameApiException) {
      return switch (error) {
        GameApiNetworkException() ||
        GameApiTimeoutException() => TransactionNetworkFailure(
          source: error,
          message: error.serverMessage,
        ),
        GameApiServerException() => TransactionServerFailure(
          source: error,
          statusCode: error.httpStatusCode ?? 500,
          serverMessage: error.serverMessage,
        ),
        GameApiParsingException() => TransactionParseFailure(
          source: error,
          transactionSource: transactionSource ?? TransactionSource.activityLog,
          message: error.serverMessage,
        ),
        GameApiUnauthorizedException() => TransactionAuthFailure(
          source: error,
          message: error.serverMessage,
        ),
        GameApiBusinessException() => TransactionBusinessFailure(
          message: error.serverMessage ?? error.description,
          source: error,
        ),
        _ => TransactionUnknownFailure(
          source: error,
          message: error.serverMessage,
        ),
      };
    }

    if (error is SunApiException) {
      return switch (error.type) {
        SunApiExceptionType.networkError ||
        SunApiExceptionType.timeout => TransactionNetworkFailure(
          source: error,
          message: error.userFriendlyMessage,
        ),
        SunApiExceptionType.serverError => TransactionServerFailure(
          source: error,
          statusCode: error.status ?? 500,
          serverMessage: error.message.isNotEmpty
              ? error.message
              : error.userFriendlyMessage,
        ),
        SunApiExceptionType.parsingError => TransactionParseFailure(
          source: error,
          transactionSource: transactionSource ?? TransactionSource.paymentSlip,
          message: error.userFriendlyMessage,
        ),
        SunApiExceptionType.authenticationError => TransactionAuthFailure(
          source: error,
          message: error.userFriendlyMessage,
        ),
        SunApiExceptionType.businessError || SunApiExceptionType.clientError =>
          TransactionBusinessFailure(message: error.message, source: error),
        _ => TransactionUnknownFailure(
          source: error,
          message: error.message.isNotEmpty
              ? error.message
              : error.userFriendlyMessage,
        ),
      };
    }

    if (error is SocketException) {
      return TransactionNetworkFailure(source: error);
    }

    if (error is HttpException) {
      if (error.message.toLowerCase().contains('timeout')) {
        return TransactionNetworkFailure(source: error);
      }
    }

    if (error is TypeError) {
      return TransactionParseFailure(
        source: error,
        transactionSource: transactionSource ?? TransactionSource.paymentSlip,
      );
    }

    return TransactionUnknownFailure(source: error);
  }

  factory TransactionFailure.fromAction(Object error) {
    if (error is TransactionFailure) return error;

    String? message;
    if (error is GameApiException) {
      message = error.serverMessage ?? error.description;
    } else if (error is SunApiException) {
      message = error.message.isNotEmpty
          ? error.message
          : error.userFriendlyMessage;
    }

    return TransactionActionFailure(source: error, message: message);
  }

  @override
  String toString() => '$runtimeType(message: $message, source: $source)';
}

final class TransactionNetworkFailure extends TransactionFailure {
  const TransactionNetworkFailure({super.source, super.message});

  @override
  bool get isRetryable => true;
}

final class TransactionServerFailure extends TransactionFailure {
  const TransactionServerFailure({
    required this.statusCode,
    super.source,
    String? serverMessage,
  }) : super(message: serverMessage);

  final int statusCode;

  String? get serverMessage => message;

  @override
  bool get isRetryable => statusCode >= 500;
}

final class TransactionParseFailure extends TransactionFailure {
  const TransactionParseFailure({
    required this.transactionSource,
    super.source,
    super.message,
  });

  final TransactionSource transactionSource;

  @override
  TransactionSource get source => transactionSource;
}

final class TransactionActionFailure extends TransactionFailure {
  const TransactionActionFailure({super.source, super.message});

  @override
  bool get isRetryable => true;
}

final class TransactionAuthFailure extends TransactionFailure {
  const TransactionAuthFailure({super.source, super.message});
}

final class TransactionBusinessFailure extends TransactionFailure {
  const TransactionBusinessFailure({super.message, super.source});
}

final class TransactionUnknownFailure extends TransactionFailure {
  const TransactionUnknownFailure({super.source, super.message});

  @override
  bool get isRetryable => true;
}

TransactionFailure mapToTransactionFailure(
  Object error, [
  TransactionSource? transactionSource,
]) => TransactionFailure.from(error, transactionSource);

TransactionFailure mapToTransactionActionFailure(Object error) =>
    TransactionFailure.fromAction(error);
