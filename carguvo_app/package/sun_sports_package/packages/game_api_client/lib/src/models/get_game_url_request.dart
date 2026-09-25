part of 'models.dart';

@freezed
sealed class GetGameUrlRequest with _$GetGameUrlRequest {
  const factory GetGameUrlRequest({
    required String providerId,
    required String productId,
    required String gameCode,
    String? lang,
    bool? isMobileLogin,
  }) = _GetGameUrlRequest;

  const GetGameUrlRequest._();

  factory GetGameUrlRequest.fromJson(Map<String, dynamic> json) =>
      _$GetGameUrlRequestFromJson(json);

  Map<String, dynamic> toApiJson() {
    return {
      'providerId': providerId,
      'productId': productId,
      'gameCode': gameCode,
      'extra': {'isMobileLogin': isMobileLogin ?? false, 'lang': lang ?? 'vi'},
    };
  }
}
