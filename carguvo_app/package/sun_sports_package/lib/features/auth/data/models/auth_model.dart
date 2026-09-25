import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sun_sports/features/auth/domain/entities/auth_entity.dart';

part 'auth_model.freezed.dart';
part 'auth_model.g.dart';

@freezed
sealed class AuthResponseModel with _$AuthResponseModel {
  const AuthResponseModel._();

  const factory AuthResponseModel({required int status, AuthDataModel? data}) =
      _AuthResponseModel;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);

  bool get isSuccess => status == 0;

  bool get isOtpRequired => status == 110;

  bool get isExistsOnOtherBrand => status == 309;

  bool get isAccountLocked => status == 404;

  String get errorMessage => data?.message ?? 'Đã xảy ra lỗi';

  bool get shouldShowPopup => status == 404 || data?.type == 1;

  AuthEntity? toEntity() {
    if (!isSuccess || data == null) return null;

    return AuthEntity(
      accessToken: data!.accessToken ?? '',
      refreshToken: data!.refreshToken ?? '',
      wsToken: data!.wsToken ?? '',
      signature: data!.signature,
      userInfo: data!.info?.toEntity(),
      showPopupChangeUsername: data!.showPopupChangeUsername ?? false,
      showPopupChangeBrand: data!.showPopupChangeBrand ?? false,
    );
  }
}

@freezed
sealed class AuthDataModel with _$AuthDataModel {
  const AuthDataModel._();

  const factory AuthDataModel({
    String? accessToken,
    String? refreshToken,
    String? wsToken,
    String? signature,
    UserInfoModel? info,
    bool? showPopupChangeUsername,
    bool? showPopupChangeBrand,
    String? sessionId,
    String? message,
    int? type,
  }) = _AuthDataModel;

  factory AuthDataModel.fromJson(Map<String, dynamic> json) =>
      _$AuthDataModelFromJson(json);
}

@freezed
sealed class UserInfoModel with _$UserInfoModel {
  const UserInfoModel._();

  const factory UserInfoModel({
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
  }) = _UserInfoModel;

  factory UserInfoModel.fromJson(Map<String, dynamic> json) =>
      _$UserInfoModelFromJson(json);

  UserInfo toEntity() {
    return UserInfo(
      visibleUserName: visibleUserName,
      displayName: displayName,
      gold: gold,
      chip: chip,
      safe: safe,
      visibleUserId: visibleUserId,
      phone: phone,
      email: email,
      vipPoint: vipPoint,
      vip: vip,
      avatar: avatar,
      gender: gender,
      birthDay: birthDay,
      brand: brand,
    );
  }
}

@freezed
sealed class LoginRequestModel with _$LoginRequestModel {
  const LoginRequestModel._();

  const factory LoginRequestModel({
    required String username,
    required String password,
  }) = _LoginRequestModel;

  factory LoginRequestModel.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestModelFromJson(json);

  factory LoginRequestModel.fromEntity(LoginRequest entity) {
    return LoginRequestModel(
      username: entity.username,
      password: entity.password,
    );
  }
}

@freezed
sealed class RegisterRequestModel with _$RegisterRequestModel {
  const RegisterRequestModel._();

  const factory RegisterRequestModel({
    required String username,
    required String password,
    required String displayName,
    String? affId,
    String? utmSource,
    String? utmMedium,
    String? utmCampaign,
    String? utmContent,
    String? utmTerm,
  }) = _RegisterRequestModel;

  factory RegisterRequestModel.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestModelFromJson(json);

  factory RegisterRequestModel.fromEntity(RegisterRequest entity) {
    return RegisterRequestModel(
      username: entity.username,
      password: entity.password,
      displayName: entity.displayName,
      affId: entity.affId,
      utmSource: entity.utmSource,
      utmMedium: entity.utmMedium,
      utmCampaign: entity.utmCampaign,
      utmContent: entity.utmContent,
      utmTerm: entity.utmTerm,
    );
  }
}

@freezed
sealed class OtpRequestModel with _$OtpRequestModel {
  const OtpRequestModel._();

  const factory OtpRequestModel({
    required String sessionId,
    required String otp,
    required String username,
    required String password,
  }) = _OtpRequestModel;

  factory OtpRequestModel.fromJson(Map<String, dynamic> json) =>
      _$OtpRequestModelFromJson(json);

  factory OtpRequestModel.fromEntity(OtpRequest entity) {
    return OtpRequestModel(
      sessionId: entity.sessionId,
      otp: entity.otp,
      username: entity.username,
      password: entity.password,
    );
  }
}
