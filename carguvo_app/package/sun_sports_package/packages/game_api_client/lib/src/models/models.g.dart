
part of 'models.dart';

_CardLastJoinData _$CardLastJoinDataFromJson(
  Map<String, dynamic> json,
) => _CardLastJoinData(
  username: json['username'] as String? ?? '',
  serverId: json['serverId'] == null ? 0 : _parseInt(json['serverId']),
  gameId: json['gameId'] == null ? 0 : _parseInt(json['gameId']),
  roomId: json['roomId'] == null ? -1 : _parseInt(json['roomId']),
  userCount: json['userCount'] == null ? 0 : _parseInt(json['userCount']),
  maxUser: json['maxUser'] == null ? 0 : _parseInt(json['maxUser']),
  maxSlot: json['maxSlot'] == null ? 0 : _parseInt(json['maxSlot']),
  betting: json['betting'] == null ? 0 : _parseNum(json['betting']),
  maxBet: json['maxBet'] == null ? 0 : _parseNum(json['maxBet']),
  minMoney: json['minMoney'] == null ? 0 : _parseNum(json['minMoney']),
  minMoneyBuyIn: json['minMoneyBuyIn'] == null
      ? 0
      : _parseNum(json['minMoneyBuyIn']),
  maxMoneyBuyIn: json['maxMoneyBuyIn'] == null
      ? 0
      : _parseNum(json['maxMoneyBuyIn']),
  assetId: json['assetId'] == null ? 0 : _parseInt(json['assetId']),
  status: json['status'] == null ? 0 : _parseInt(json['status']),
  roomType: json['roomType'] == null ? 0 : _parseInt(json['roomType']),
  subGroupId: json['subGroupId'] == null ? 0 : _parseInt(json['subGroupId']),
  full: json['full'] == null ? false : _parseBool(json['full']),
  playing: json['playing'] == null ? false : _parseBool(json['playing']),
  incognito: json['incognito'] == null ? false : _parseBool(json['incognito']),
  huge: json['huge'] == null ? false : _parseBool(json['huge']),
  hasPassword: json['hasPassword'] == null
      ? false
      : _parseBool(json['hasPassword']),
  password: json['password'] as String? ?? '',
  startTimeOfGame: json['startTimeOfGame'] == null
      ? 0
      : _parseInt(json['startTimeOfGame']),
  partial: json['partial'] == null ? false : _parseBool(json['partial']),
);

Map<String, dynamic> _$CardLastJoinDataToJson(_CardLastJoinData instance) =>
    <String, dynamic>{
      'username': instance.username,
      'serverId': instance.serverId,
      'gameId': instance.gameId,
      'roomId': instance.roomId,
      'userCount': instance.userCount,
      'maxUser': instance.maxUser,
      'maxSlot': instance.maxSlot,
      'betting': instance.betting,
      'maxBet': instance.maxBet,
      'minMoney': instance.minMoney,
      'minMoneyBuyIn': instance.minMoneyBuyIn,
      'maxMoneyBuyIn': instance.maxMoneyBuyIn,
      'assetId': instance.assetId,
      'status': instance.status,
      'roomType': instance.roomType,
      'subGroupId': instance.subGroupId,
      'full': instance.full,
      'playing': instance.playing,
      'incognito': instance.incognito,
      'huge': instance.huge,
      'hasPassword': instance.hasPassword,
      'password': instance.password,
      'startTimeOfGame': instance.startTimeOfGame,
      'partial': instance.partial,
    };

_GameUrlData _$GameUrlDataFromJson(Map<String, dynamic> json) =>
    _GameUrlData(url: json['url'] as String);

Map<String, dynamic> _$GameUrlDataToJson(_GameUrlData instance) =>
    <String, dynamic>{'url': instance.url};

_GetGameUrlRequest _$GetGameUrlRequestFromJson(Map<String, dynamic> json) =>
    _GetGameUrlRequest(
      providerId: json['providerId'] as String,
      productId: json['productId'] as String,
      gameCode: json['gameCode'] as String,
      lang: json['lang'] as String?,
      isMobileLogin: json['isMobileLogin'] as bool?,
    );

Map<String, dynamic> _$GetGameUrlRequestToJson(_GetGameUrlRequest instance) =>
    <String, dynamic>{
      'providerId': instance.providerId,
      'productId': instance.productId,
      'gameCode': instance.gameCode,
      'lang': instance.lang,
      'isMobileLogin': instance.isMobileLogin,
    };

_JackpotEntry _$JackpotEntryFromJson(Map<String, dynamic> json) =>
    _JackpotEntry(
      gameId: json['gameId'] == null ? 0 : _parseInt(json['gameId']),
      gameName: json['gameName'] as String? ?? '',
      balance: json['balance'] == null ? 0 : _parseNum(json['balance']),
      betting: json['betting'] == null ? 0 : _parseNum(json['betting']),
    );

Map<String, dynamic> _$JackpotEntryToJson(_JackpotEntry instance) =>
    <String, dynamic>{
      'gameId': instance.gameId,
      'gameName': instance.gameName,
      'balance': instance.balance,
      'betting': instance.betting,
    };

_ProviderGames _$ProviderGamesFromJson(Map<String, dynamic> json) =>
    _ProviderGames(
      providerId: json['providerId'] as String,
      providerName: json['providerName'] as String,
      gameList:
          (json['gameList'] as List<dynamic>?)
              ?.map((e) => Game.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ProviderGamesToJson(_ProviderGames instance) =>
    <String, dynamic>{
      'providerId': instance.providerId,
      'providerName': instance.providerName,
      'gameList': instance.gameList,
    };

_Game _$GameFromJson(Map<String, dynamic> json) => _Game(
  productId: json['productId'] as String,
  gameCode: json['gameCode'] as String,
  gameName: json['gameName'] as String,
  lang: json['lang'] as String,
  lobbyUrl: json['lobbyUrl'] as String,
  cashierUrl: json['cashierUrl'] as String,
  gameType: GameType.fromJson((json['gameType'] as num).toInt()),
  mobileLogin: json['mobileLogin'] as bool? ?? false,
);

Map<String, dynamic> _$GameToJson(_Game instance) => <String, dynamic>{
  'productId': instance.productId,
  'gameCode': instance.gameCode,
  'gameName': instance.gameName,
  'lang': instance.lang,
  'lobbyUrl': instance.lobbyUrl,
  'cashierUrl': instance.cashierUrl,
  'gameType': GameType.toJson(instance.gameType),
  'mobileLogin': instance.mobileLogin,
};
