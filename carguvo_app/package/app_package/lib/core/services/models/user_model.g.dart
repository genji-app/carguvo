
part of 'user_model.dart';

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  uid: json['uid'] as String,
  displayName: json['displayName'] as String,
  custLogin: json['cust_login'] as String,
  custId: json['cust_id'] as String,
  balance: _parseBalance(json['balance']),
  currency: json['currency'] as String? ?? 'VND',
  status: json['status'] as String? ?? 'Active',
  email: json['email'] as String?,
  phone: json['phone'] as String?,
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'displayName': instance.displayName,
      'cust_login': instance.custLogin,
      'cust_id': instance.custId,
      'balance': instance.balance,
      'currency': instance.currency,
      'status': instance.status,
      'email': instance.email,
      'phone': instance.phone,
    };
