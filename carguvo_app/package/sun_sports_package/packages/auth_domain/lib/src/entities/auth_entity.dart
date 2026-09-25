import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_entity.freezed.dart';

@freezed
sealed class AuthEntity with _$AuthEntity {
  const factory AuthEntity({
    required String accessToken,
    required String refreshToken,
    required String wsToken,
    String? signature,
    UserInfo? userInfo,
    @Default(false) bool showPopupChangeUsername,
    @Default(false) bool showPopupChangeBrand,
  }) = _AuthEntity;
}

@freezed
sealed class UserInfo with _$UserInfo {
  const factory UserInfo({
    String? visibleUserName,
    String? displayName,
    int? gold,
    int? chip,
    int? safe,
    String? visibleUserId,
    String? phone,
    String? email,
    int? vipPoint,
    int? vip,
    String? avatar,
    int? gender,
    String? birthDay,
    String? brand,
  }) = _UserInfo;
}

@freezed
sealed class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    required String username,
    required String password,
  }) = _LoginRequest;
}

@freezed
sealed class RegisterRequest with _$RegisterRequest {
  const factory RegisterRequest({
    required String username,
    required String password,
    required String displayName,
    String? affId,
    String? utmSource,
    String? utmMedium,
    String? utmCampaign,
    String? utmContent,
    String? utmTerm,
  }) = _RegisterRequest;
}

@freezed
sealed class OtpRequest with _$OtpRequest {
  const factory OtpRequest({
    required String sessionId,
    required String otp,
    required String username,
    required String password,
  }) = _OtpRequest;
}
