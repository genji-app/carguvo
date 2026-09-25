part of 'models.dart';

@Freezed(genericArgumentFactories: true)
sealed class GameApiResponse<T> with _$GameApiResponse<T> {
  const factory GameApiResponse.success({
    required String message,
    required int code,
    required int status,
    required T data,
  }) = GameApiSuccessResponse<T>;

  const factory GameApiResponse.failure({
    required String message,
    required int code,
    required int status,
    Object? data,
  }) = GameApiFailureResponse<T>;

  factory GameApiResponse.fromJson(Map<String, dynamic> json, T Function(Object? json) fromJsonT) {
    final code = json['code'] as int? ?? 0;
    final status = json['status'] as int? ?? 0;
    final message = json['message']?.toString() ?? '';
    final rawData = json['data'];

    if (code == 0 && status == 0) {
      return GameApiSuccessResponse<T>(
        message: message,
        code: code,
        status: status,
        data: fromJsonT(rawData),
      );
    }

    return GameApiFailureResponse<T>(message: message, code: code, status: status, data: rawData);
  }
}

extension GameApiResponseX<T> on GameApiResponse<T> {
  bool get isSuccess => map(success: (_) => true, failure: (_) => false);

  bool get isFailure => !isSuccess;

  int get statusCode => map(success: (s) => s.status, failure: (f) => f.status);

  int get errorCode => map(success: (s) => s.code, failure: (f) => f.code);

  String get message => map(success: (s) => s.message, failure: (f) => f.message);

  T? get dataOrNull => map(success: (s) => s.data, failure: (_) => null);
}
