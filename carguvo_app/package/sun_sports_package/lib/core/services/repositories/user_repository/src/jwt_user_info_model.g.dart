
part of 'jwt_user_info_model.dart';

_JwtUserInfoModel _$JwtUserInfoModelFromJson(Map<String, dynamic> json) =>
    _JwtUserInfoModel(
      userId: json['userId'] as String,
      username: json['username'] as String,
      displayName: json['displayName'] as String,
      avatar: json['avatar'] as String,
      brand: json['brand'] as String,
      customerId: (json['customerId'] as num).toInt(),
      platformId: (json['platformId'] as num).toInt(),
      amount: json['amount'] == null ? 0 : _toNum(json['amount']),
      gender: (json['gender'] as num?)?.toInt() ?? 0,
      banned: json['banned'] == null ? false : _intToBool(json['banned']),
      bot: json['bot'] == null ? false : _intToBool(json['bot']),
      lockChat: json['lockChat'] == null ? false : _intToBool(json['lockChat']),
      mute: json['mute'] == null ? false : _intToBool(json['mute']),
      phoneVerified: json['phoneVerified'] == null
          ? false
          : _intToBool(json['phoneVerified']),
      deposit: json['deposit'] == null ? false : _intToBool(json['deposit']),
      verifiedBankAccount: json['verifiedBankAccount'] == null
          ? false
          : _intToBool(json['verifiedBankAccount']),
      canViewStat: json['canViewStat'] == null
          ? false
          : _intToBool(json['canViewStat']),
      isMerchant: json['isMerchant'] == null
          ? false
          : _intToBool(json['isMerchant']),
      playEventLobby: json['playEventLobby'] == null
          ? false
          : _intToBool(json['playEventLobby']),
      lockGames: json['lockGames'] as List<dynamic>? ?? const [],
      phone: _phoneToString(json['phone']),
      affId: json['affId'] as String?,
      ipAddress: json['ipAddress'] as String?,
      timestamp: (json['timestamp'] as num?)?.toInt(),
      regTime: (json['regTime'] as num?)?.toInt(),
    );

Map<String, dynamic> _$JwtUserInfoModelToJson(_JwtUserInfoModel instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'username': instance.username,
      'displayName': instance.displayName,
      'avatar': instance.avatar,
      'brand': instance.brand,
      'customerId': instance.customerId,
      'platformId': instance.platformId,
      'amount': instance.amount,
      'gender': instance.gender,
      'banned': instance.banned,
      'bot': instance.bot,
      'lockChat': instance.lockChat,
      'mute': instance.mute,
      'phoneVerified': instance.phoneVerified,
      'deposit': instance.deposit,
      'verifiedBankAccount': instance.verifiedBankAccount,
      'canViewStat': instance.canViewStat,
      'isMerchant': instance.isMerchant,
      'playEventLobby': instance.playEventLobby,
      'lockGames': instance.lockGames,
      'phone': instance.phone,
      'affId': instance.affId,
      'ipAddress': instance.ipAddress,
      'timestamp': instance.timestamp,
      'regTime': instance.regTime,
    };
