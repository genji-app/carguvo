import 'package:freezed_annotation/freezed_annotation.dart';

part 'sun_api_response.freezed.dart';

@Freezed(genericArgumentFactories: true)
sealed class SunApiResponse<T> with _$SunApiResponse<T> {
  const factory SunApiResponse.success({
    @JsonKey(name: 'messageKey') required String messageKey,
    @JsonKey(name: 'status') required int status,
    @JsonKey(name: 'Locale') String? locale,
    @JsonKey(name: 'data') T? data,
  }) = SunApiSuccessResponse<T>;

  const factory SunApiResponse.failure({
    @JsonKey(name: 'messageKey') required String messageKey,
    @JsonKey(name: 'status') required int code,
    @JsonKey(name: 'Locale') String? locale,
    String? error,
    Object? data,
  }) = SunApiFailureResponse<T>;

  factory SunApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    int status;
    if (json['status'] is int) {
      status = json['status'] as int;
    } else if (json['errorCode'] is int) {
      status = json['errorCode'] as int;
    } else {
      status = -1;
    }

    final messageKey = json['messageKey'] as String? ?? '';
    final locale = json['Locale'] as String?;
    final rawData = json['data'];

    if (status == 0 && rawData is Map<String, dynamic>) {
      final innerStatus = rawData['status'];
      if (innerStatus is int && innerStatus != 0) {
        String? errorMessage;
        final innerData = rawData['data'];
        if (innerData is Map<String, dynamic>) {
          errorMessage = innerData['message'] as String?;
        }
        errorMessage ??= rawData['message'] as String?;

        return SunApiFailureResponse<T>(
          code: innerStatus,
          messageKey: messageKey,
          locale: rawData['Locale'] as String? ?? locale,
          error: errorMessage ?? 'Unknown error (code: $innerStatus)',
          data: innerData ?? rawData,
        );
      }
    }

    if (status == 0) {
      return SunApiSuccessResponse<T>(
        status: status,
        messageKey: messageKey,
        locale: locale,
        data: rawData == null ? null : fromJsonT(rawData),
      );
    } else {
      String? errorMessage;
      if (rawData is Map<String, dynamic>) {
        errorMessage = rawData['message'] as String?;
      }
      if (errorMessage == null && json['message'] is String) {
        errorMessage = json['message'] as String;
      }

      return SunApiFailureResponse<T>(
        code: status,
        messageKey: messageKey,
        locale: locale,
        error: errorMessage ?? messageKey,
        data: rawData,
      );
    }
  }

  factory SunApiResponse.fromJsonNullable(
    Map<String, dynamic> json,
    T Function(Object json) fromJsonT,
  ) => SunApiResponse.fromJson(
    json,
    (dataJson) => dataJson == null ? null as T : fromJsonT(dataJson),
  );

  factory SunApiResponse.fromJsonMap(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json) fromJsonT,
  ) => SunApiResponse.fromJson(
    json,
    (dataJson) => fromJsonT(dataJson as Map<String, dynamic>),
  );

  factory SunApiResponse.fromJsonMapNullable(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json) fromJsonT,
  ) => SunApiResponse.fromJsonNullable(
    json,
    (dataJson) => fromJsonT(dataJson as Map<String, dynamic>),
  );
}

extension SunApiResponsePropsX<T> on SunApiResponse<T> {
  bool get isSuccess => status == 0;
  bool get isError => !isSuccess;

  int get status =>
      map(success: (val) => val.status, failure: (val) => val.code);

  String get messageKey =>
      map(success: (val) => val.messageKey, failure: (val) => val.messageKey);

  String get message => map(
    success: (val) => val.messageKey,
    failure: (val) => val.error ?? val.messageKey,
  );

  T? get dataOrNull => map(success: (val) => val.data, failure: (_) => null);
}
