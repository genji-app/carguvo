import 'package:freezed_annotation/freezed_annotation.dart';

part 'jwt_user_info_model.freezed.dart';
part 'jwt_user_info_model.g.dart';

@freezed
sealed class JwtUserInfoModel with _$JwtUserInfoModel {
  const JwtUserInfoModel._();

  const factory JwtUserInfoModel({
    required String userId,
    required String username,
    required String displayName,
    required String avatar,
    required String brand,
    required int customerId,
    required int platformId,
    @JsonKey(fromJson: _toNum) @Default(0) num amount,
    @Default(0) int gender,

    @JsonKey(fromJson: _intToBool) @Default(false) bool banned,
    @JsonKey(fromJson: _intToBool) @Default(false) bool bot,
    @JsonKey(fromJson: _intToBool) @Default(false) bool lockChat,
    @JsonKey(fromJson: _intToBool) @Default(false) bool mute,
    @JsonKey(fromJson: _intToBool) @Default(false) bool phoneVerified,
    @JsonKey(fromJson: _intToBool) @Default(false) bool deposit,
    @JsonKey(fromJson: _intToBool) @Default(false) bool verifiedBankAccount,
    @JsonKey(fromJson: _intToBool) @Default(false) bool canViewStat,
    @JsonKey(fromJson: _intToBool) @Default(false) bool isMerchant,
    @JsonKey(fromJson: _intToBool) @Default(false) bool playEventLobby,
    @Default([]) List<dynamic> lockGames,

    @JsonKey(fromJson: _phoneToString) String? phone,
    String? affId,
    String? ipAddress,
    int? timestamp,
    int? regTime,
  }) = _JwtUserInfoModel;

  factory JwtUserInfoModel.fromJson(Map<String, dynamic> json) =>
      _$JwtUserInfoModelFromJson(json);
}

bool _intToBool(dynamic value) {
  if (value is bool) return value;
  if (value is int) return value != 0;
  return false;
}

num _toNum(dynamic value) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value) ?? 0;
  return 0;
}

String? _phoneToString(dynamic value) {
  if (value == null) return null;
  if (value is String) return value.isEmpty ? null : value;
  return value.toString();
}
