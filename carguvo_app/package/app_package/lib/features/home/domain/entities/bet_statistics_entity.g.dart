
part of 'bet_statistics_entity.dart';

_BetStatisticsSimple _$BetStatisticsSimpleFromJson(Map<String, dynamic> json) =>
    _BetStatisticsSimple(
      eventId: (json['0'] as num?)?.toInt(),
      marketStatistics: (json['1'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
          k,
          (e as List<dynamic>)
              .map(
                (e) =>
                    BetStatisticsSelection.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
        ),
      ),
    );

Map<String, dynamic> _$BetStatisticsSimpleToJson(
  _BetStatisticsSimple instance,
) => <String, dynamic>{
  '0': instance.eventId,
  '1': instance.marketStatistics?.map(
    (k, e) => MapEntry(k, e.map((e) => e.toJson()).toList()),
  ),
};

_BetStatisticsSelection _$BetStatisticsSelectionFromJson(
  Map<String, dynamic> json,
) => _BetStatisticsSelection(
  marketId: (json['1'] as num?)?.toInt(),
  points: _parsePoints(json['2']),
  selectionName: json['3'] as String?,
  percentage: (json['4'] as num?)?.toDouble(),
);

Map<String, dynamic> _$BetStatisticsSelectionToJson(
  _BetStatisticsSelection instance,
) => <String, dynamic>{
  '1': instance.marketId,
  '2': instance.points,
  '3': instance.selectionName,
  '4': instance.percentage,
};

_BetStatisticsUserDetails _$BetStatisticsUserDetailsFromJson(
  Map<String, dynamic> json,
) => _BetStatisticsUserDetails(
  userBets:
      (json['0'] as List<dynamic>?)
          ?.map(
            (e) =>
                BetStatisticsUserBetDetail.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  totalCount: (json['1'] as num?)?.toInt(),
  marketTypes:
      (json['2'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$BetStatisticsUserDetailsToJson(
  _BetStatisticsUserDetails instance,
) => <String, dynamic>{
  '0': instance.userBets.map((e) => e.toJson()).toList(),
  '1': instance.totalCount,
  '2': instance.marketTypes,
};

_BetStatisticsUserBetDetail _$BetStatisticsUserBetDetailFromJson(
  Map<String, dynamic> json,
) => _BetStatisticsUserBetDetail(
  userName: json['1'] as String?,
  selectionName: json['2'] as String?,
  opponentName: json['3'] as String?,
  eventId: (json['4'] as num?)?.toInt(),
  leagueName: json['5'] as String?,
  leagueId: (json['6'] as num?)?.toInt(),
  flag: json['7'] as bool?,
  marketName: json['8'] as String?,
  idOrTimestamp: json['9'] as String?,
  oddsStyle: json['10'] as String?,
  oddsValueString: json['11'] as String?,
  score: json['12'] as String?,
  selectionId: json['13'] as String?,
  selectionName2: json['14'] as String?,
  betTimestamp: json['15'] as String?,
  oddsValue: (json['16'] as num?)?.toDouble(),
  points: json['17'] as String?,
  number: (json['18'] as num?)?.toInt(),
  marketId: (json['19'] as num?)?.toInt(),
  oddsValues: (json['20'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  id: json['21'] as String?,
  matchTime: json['22'] as String?,
);

Map<String, dynamic> _$BetStatisticsUserBetDetailToJson(
  _BetStatisticsUserBetDetail instance,
) => <String, dynamic>{
  '1': instance.userName,
  '2': instance.selectionName,
  '3': instance.opponentName,
  '4': instance.eventId,
  '5': instance.leagueName,
  '6': instance.leagueId,
  '7': instance.flag,
  '8': instance.marketName,
  '9': instance.idOrTimestamp,
  '10': instance.oddsStyle,
  '11': instance.oddsValueString,
  '12': instance.score,
  '13': instance.selectionId,
  '14': instance.selectionName2,
  '15': instance.betTimestamp,
  '16': instance.oddsValue,
  '17': instance.points,
  '18': instance.number,
  '19': instance.marketId,
  '20': instance.oddsValues,
  '21': instance.id,
  '22': instance.matchTime,
};
