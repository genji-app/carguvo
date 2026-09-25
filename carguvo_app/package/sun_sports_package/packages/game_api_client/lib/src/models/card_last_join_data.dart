part of 'models.dart';

@freezed
abstract class CardLastJoinData with _$CardLastJoinData {
  const factory CardLastJoinData({
    @JsonKey(name: 'username') @Default('') String username,
    @JsonKey(name: 'serverId', fromJson: _parseInt) @Default(0) int serverId,
    @JsonKey(name: 'gameId', fromJson: _parseInt) @Default(0) int gameId,
    @JsonKey(name: 'roomId', fromJson: _parseInt) @Default(-1) int roomId,
    @JsonKey(name: 'userCount', fromJson: _parseInt) @Default(0) int userCount,
    @JsonKey(name: 'maxUser', fromJson: _parseInt) @Default(0) int maxUser,
    @JsonKey(name: 'maxSlot', fromJson: _parseInt) @Default(0) int maxSlot,
    @JsonKey(name: 'betting', fromJson: _parseNum) @Default(0) num betting,
    @JsonKey(name: 'maxBet', fromJson: _parseNum) @Default(0) num maxBet,
    @JsonKey(name: 'minMoney', fromJson: _parseNum) @Default(0) num minMoney,
    @JsonKey(name: 'minMoneyBuyIn', fromJson: _parseNum) @Default(0) num minMoneyBuyIn,
    @JsonKey(name: 'maxMoneyBuyIn', fromJson: _parseNum) @Default(0) num maxMoneyBuyIn,
    @JsonKey(name: 'assetId', fromJson: _parseInt) @Default(0) int assetId,
    @JsonKey(name: 'status', fromJson: _parseInt) @Default(0) int status,
    @JsonKey(name: 'roomType', fromJson: _parseInt) @Default(0) int roomType,
    @JsonKey(name: 'subGroupId', fromJson: _parseInt) @Default(0) int subGroupId,
    @JsonKey(name: 'full', fromJson: _parseBool) @Default(false) bool full,
    @JsonKey(name: 'playing', fromJson: _parseBool) @Default(false) bool playing,
    @JsonKey(name: 'incognito', fromJson: _parseBool) @Default(false) bool incognito,
    @JsonKey(name: 'huge', fromJson: _parseBool) @Default(false) bool huge,
    @JsonKey(name: 'hasPassword', fromJson: _parseBool) @Default(false) bool hasPassword,
    @JsonKey(name: 'password') @Default('') String password,
    @JsonKey(name: 'startTimeOfGame', fromJson: _parseInt) @Default(0) int startTimeOfGame,
    @JsonKey(name: 'partial', fromJson: _parseBool) @Default(false) bool partial,
  }) = _CardLastJoinData;

  factory CardLastJoinData.fromJson(Map<String, dynamic> json) {
    final normalized = <String, dynamic>{
      ...json,
      if (!json.containsKey('serverId') && json.containsKey('sid')) 'serverId': json['sid'],
      if (!json.containsKey('serverId') && json.containsKey('serverID'))
        'serverId': json['serverID'],
      if (!json.containsKey('password') && json.containsKey('pwd')) 'password': json['pwd'],
      if (!json.containsKey('password') && json.containsKey('roomPassword'))
        'password': json['roomPassword'],
    };
    return _$CardLastJoinDataFromJson(normalized);
  }
}

extension CardLastJoinDataX on CardLastJoinData {
  bool get hasActiveRoom => roomId > 0;
}
