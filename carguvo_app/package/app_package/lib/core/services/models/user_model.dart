import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
sealed class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    @JsonKey(name: 'uid') required String uid,
    @JsonKey(name: 'displayName') required String displayName,
    @JsonKey(name: 'cust_login') required String custLogin,
    @JsonKey(name: 'cust_id') required String custId,
    @JsonKey(name: 'balance', fromJson: _parseBalance) required double balance,
    @JsonKey(name: 'currency') @Default('VND') String currency,
    @JsonKey(name: 'status') @Default('Active') String status,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'phone') String? phone,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  factory UserModel.fromHttpMap(Map<String, dynamic> httpMap) =>
      UserModel.fromJson(httpMap);

  factory UserModel.empty() => const UserModel(
    uid: '',
    displayName: '',
    custLogin: '',
    custId: '',
    balance: 0.0,
    currency: 'VND',
    status: 'Inactive',
  );
}

double _parseBalance(dynamic value) {
  if (value == null) return 0.0;

  if (value is num) {
    return value.toDouble();
  }

  if (value is String) {
    final cleaned = value.replaceAll('.', '');
    return (int.tryParse(cleaned) ?? 0).toDouble();
  }

  return 0.0;
}

extension UserModelX on UserModel {
  bool get isActive => status == 'Active';

  bool get isLoggedIn => uid.isNotEmpty && custId.isNotEmpty;

  String get formattedBalance => '${balance.toStringAsFixed(0)}K $currency';

  double get balanceInVND => balance * 1000;
}
