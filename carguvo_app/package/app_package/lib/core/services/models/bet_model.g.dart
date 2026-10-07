
part of 'bet_model.dart';

_BetSelectionModel _$BetSelectionModelFromJson(Map<String, dynamic> json) =>
    _BetSelectionModel(
      eventId: (json['eventId'] as num).toInt(),
      eventName: json['eventName'] as String,
      selectionId: json['selectionId'] as String,
      selectionName: json['selectionName'] as String,
      offerId: json['offerId'] as String,
      displayOdds: json['displayOdds'] as String,
      oddsStyle: json['oddsStyle'] as String? ?? 'decimal',
      cls: json['cls'] as String,
      leagueId: json['leagueId'] as String?,
      matchTime: json['matchTime'] as String?,
      isLive: json['isLive'] as bool? ?? false,
      sportId: (json['sportId'] as num?)?.toInt() ?? 1,
      homeScore: (json['homeScore'] as num?)?.toInt(),
      awayScore: (json['awayScore'] as num?)?.toInt(),
      stake: (json['stake'] as num?)?.toDouble(),
      winnings: (json['winnings'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$BetSelectionModelToJson(_BetSelectionModel instance) =>
    <String, dynamic>{
      'eventId': instance.eventId,
      'eventName': instance.eventName,
      'selectionId': instance.selectionId,
      'selectionName': instance.selectionName,
      'offerId': instance.offerId,
      'displayOdds': instance.displayOdds,
      'oddsStyle': instance.oddsStyle,
      'cls': instance.cls,
      'leagueId': instance.leagueId,
      'matchTime': instance.matchTime,
      'isLive': instance.isLive,
      'sportId': instance.sportId,
      'homeScore': instance.homeScore,
      'awayScore': instance.awayScore,
      'stake': instance.stake,
      'winnings': instance.winnings,
    };

_CalculateBetRequest _$CalculateBetRequestFromJson(Map<String, dynamic> json) =>
    _CalculateBetRequest(
      leagueId: json['leagueId'] as String,
      matchTime: json['matchTime'] as String,
      isLive: json['isLive'] as bool? ?? false,
      offerId: json['offerId'] as String,
      selectionId: json['selectionId'] as String,
      displayOdds: json['displayOdds'] as String,
      oddsStyle: json['oddsStyle'] as String? ?? 'decimal',
    );

Map<String, dynamic> _$CalculateBetRequestToJson(
  _CalculateBetRequest instance,
) => <String, dynamic>{
  'leagueId': instance.leagueId,
  'matchTime': instance.matchTime,
  'isLive': instance.isLive,
  'offerId': instance.offerId,
  'selectionId': instance.selectionId,
  'displayOdds': instance.displayOdds,
  'oddsStyle': instance.oddsStyle,
};

_CalculateBetResponse _$CalculateBetResponseFromJson(
  Map<String, dynamic> json,
) => _CalculateBetResponse(
  minStake: json['minStake'] == null ? 0 : _numToInt(json['minStake']),
  maxStake: json['maxStake'] == null ? 0 : _numToInt(json['maxStake']),
  maxPayout: (json['maxPayout'] as num?)?.toInt() ?? 0,
  displayOdds: json['displayOdds'] as String? ?? '',
  trueOdds: (json['trueOdds'] as num?)?.toDouble(),
  errorCode: (json['errorCode'] as num?)?.toInt() ?? 0,
  message: json['message'] as String?,
  minMatches: (json['minMatches'] as num?)?.toInt() ?? 2,
  maxMatches: (json['maxMatches'] as num?)?.toInt() ?? 10,
  selectionIdOdds: (json['selectionIdOdds'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
);

Map<String, dynamic> _$CalculateBetResponseToJson(
  _CalculateBetResponse instance,
) => <String, dynamic>{
  'minStake': instance.minStake,
  'maxStake': instance.maxStake,
  'maxPayout': instance.maxPayout,
  'displayOdds': instance.displayOdds,
  'trueOdds': instance.trueOdds,
  'errorCode': instance.errorCode,
  'message': instance.message,
  'minMatches': instance.minMatches,
  'maxMatches': instance.maxMatches,
  'selectionIdOdds': instance.selectionIdOdds,
};

_PlaceBetRequest _$PlaceBetRequestFromJson(Map<String, dynamic> json) =>
    _PlaceBetRequest(
      acceptBetterOdds: json['acceptBetterOdds'] as bool? ?? true,
      acceptMaxStake: json['acceptMaxStake'] as bool? ?? true,
      matchId: (json['matchId'] as num).toInt(),
      selections: (json['selections'] as List<dynamic>)
          .map((e) => BetSelectionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      singleBet: json['singleBet'] as bool? ?? true,
      parlay: json['parlay'] as bool? ?? false,
      acceptAllOdds: json['acceptAllOdds'] as bool? ?? true,
    );

Map<String, dynamic> _$PlaceBetRequestToJson(_PlaceBetRequest instance) =>
    <String, dynamic>{
      'acceptBetterOdds': instance.acceptBetterOdds,
      'acceptMaxStake': instance.acceptMaxStake,
      'matchId': instance.matchId,
      'selections': instance.selections.map((e) => e.toJson()).toList(),
      'singleBet': instance.singleBet,
      'parlay': instance.parlay,
      'acceptAllOdds': instance.acceptAllOdds,
    };

_PlaceBetResponse _$PlaceBetResponseFromJson(Map<String, dynamic> json) =>
    _PlaceBetResponse(
      ticketId: json['ticketId'] as String?,
      status: json['status'] as String,
      odds: _oddsToString(json['odds']),
      stake: _numToIntNullable(json['stake']),
      winnings: _numToIntNullable(json['winning']),
      errorCode: (json['errorCode'] as num?)?.toInt() ?? 0,
      message: json['message'] as String?,
      createdAt: json['createdAt'] as String?,
      values: _valuesToDoubles(json['values']),
    );

Map<String, dynamic> _$PlaceBetResponseToJson(_PlaceBetResponse instance) =>
    <String, dynamic>{
      'ticketId': instance.ticketId,
      'status': instance.status,
      'odds': instance.odds,
      'stake': instance.stake,
      'winning': instance.winnings,
      'errorCode': instance.errorCode,
      'message': instance.message,
      'createdAt': instance.createdAt,
      'values': instance.values,
    };
