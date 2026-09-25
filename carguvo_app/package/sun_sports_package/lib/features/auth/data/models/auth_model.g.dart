
part of 'auth_model.dart';

_AuthResponseModel _$AuthResponseModelFromJson(Map<String, dynamic> json) =>
    _AuthResponseModel(
      status: (json['status'] as num).toInt(),
      data: json['data'] == null
          ? null
          : AuthDataModel.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuthResponseModelToJson(_AuthResponseModel instance) =>
    <String, dynamic>{
      'status': instance.status,
      'data': instance.data?.toJson(),
    };

_AuthDataModel _$AuthDataModelFromJson(Map<String, dynamic> json) =>
    _AuthDataModel(
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      wsToken: json['wsToken'] as String?,
      signature: json['signature'] as String?,
      info: json['info'] == null
          ? null
          : UserInfoModel.fromJson(json['info'] as Map<String, dynamic>),
      showPopupChangeUsername: json['showPopupChangeUsername'] as bool?,
      showPopupChangeBrand: json['showPopupChangeBrand'] as bool?,
      sessionId: json['sessionId'] as String?,
      message: json['message'] as String?,
      type: (json['type'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AuthDataModelToJson(_AuthDataModel instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'wsToken': instance.wsToken,
      'signature': instance.signature,
      'info': instance.info?.toJson(),
      'showPopupChangeUsername': instance.showPopupChangeUsername,
      'showPopupChangeBrand': instance.showPopupChangeBrand,
      'sessionId': instance.sessionId,
      'message': instance.message,
      'type': instance.type,
    };

_UserInfoModel _$UserInfoModelFromJson(Map<String, dynamic> json) =>
    _UserInfoModel(
      visibleUserName: json['visibleUserName'] as String?,
      displayName: json['displayName'] as String?,
      gold: (json['gold'] as num?)?.toInt(),
      chip: (json['chip'] as num?)?.toInt(),
      safe: (json['safe'] as num?)?.toInt(),
      visibleUserId: json['visibleUserId'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      vipPoint: (json['vipPoint'] as num?)?.toInt(),
      vip: (json['vip'] as num?)?.toInt(),
      avatar: json['avatar'] as String?,
      gender: (json['gender'] as num?)?.toInt(),
      birthDay: json['birthDay'] as String?,
      brand: json['brand'] as String?,
    );

Map<String, dynamic> _$UserInfoModelToJson(_UserInfoModel instance) =>
    <String, dynamic>{
      'visibleUserName': instance.visibleUserName,
      'displayName': instance.displayName,
      'gold': instance.gold,
      'chip': instance.chip,
      'safe': instance.safe,
      'visibleUserId': instance.visibleUserId,
      'phone': instance.phone,
      'email': instance.email,
      'vipPoint': instance.vipPoint,
      'vip': instance.vip,
      'avatar': instance.avatar,
      'gender': instance.gender,
      'birthDay': instance.birthDay,
      'brand': instance.brand,
    };

_LoginRequestModel _$LoginRequestModelFromJson(Map<String, dynamic> json) =>
    _LoginRequestModel(
      username: json['username'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$LoginRequestModelToJson(_LoginRequestModel instance) =>
    <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
    };

_RegisterRequestModel _$RegisterRequestModelFromJson(
  Map<String, dynamic> json,
) => _RegisterRequestModel(
  username: json['username'] as String,
  password: json['password'] as String,
  displayName: json['displayName'] as String,
  affId: json['affId'] as String?,
  utmSource: json['utmSource'] as String?,
  utmMedium: json['utmMedium'] as String?,
  utmCampaign: json['utmCampaign'] as String?,
  utmContent: json['utmContent'] as String?,
  utmTerm: json['utmTerm'] as String?,
);

Map<String, dynamic> _$RegisterRequestModelToJson(
  _RegisterRequestModel instance,
) => <String, dynamic>{
  'username': instance.username,
  'password': instance.password,
  'displayName': instance.displayName,
  'affId': instance.affId,
  'utmSource': instance.utmSource,
  'utmMedium': instance.utmMedium,
  'utmCampaign': instance.utmCampaign,
  'utmContent': instance.utmContent,
  'utmTerm': instance.utmTerm,
};

_OtpRequestModel _$OtpRequestModelFromJson(Map<String, dynamic> json) =>
    _OtpRequestModel(
      sessionId: json['sessionId'] as String,
      otp: json['otp'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$OtpRequestModelToJson(_OtpRequestModel instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'otp': instance.otp,
      'username': instance.username,
      'password': instance.password,
    };
