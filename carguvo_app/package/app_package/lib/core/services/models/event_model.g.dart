
part of 'event_model.dart';

_EventModel _$EventModelFromJson(Map<String, dynamic> json) => _EventModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  leagueId: (json['leagueId'] as num).toInt(),
  leagueName: json['leagueName'] as String?,
  startDate: json['startDate'] as String,
  isLive: json['isLive'] as bool? ?? false,
  homeTeam: json['homeTeam'] == null
      ? null
      : TeamModel.fromJson(json['homeTeam'] as Map<String, dynamic>),
  awayTeam: json['awayTeam'] == null
      ? null
      : TeamModel.fromJson(json['awayTeam'] as Map<String, dynamic>),
  score: json['score'] == null
      ? null
      : ScoreModel.fromJson(json['score'] as Map<String, dynamic>),
  minute: (json['minute'] as num?)?.toInt(),
  markets:
      (json['markets'] as List<dynamic>?)
          ?.map((e) => MarketModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  featured: json['featured'] as bool? ?? false,
  popularityScore: (json['popularityScore'] as num?)?.toDouble(),
);

Map<String, dynamic> _$EventModelToJson(_EventModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'leagueId': instance.leagueId,
      'leagueName': instance.leagueName,
      'startDate': instance.startDate,
      'isLive': instance.isLive,
      'homeTeam': instance.homeTeam?.toJson(),
      'awayTeam': instance.awayTeam?.toJson(),
      'score': instance.score?.toJson(),
      'minute': instance.minute,
      'markets': instance.markets.map((e) => e.toJson()).toList(),
      'featured': instance.featured,
      'popularityScore': instance.popularityScore,
    };

_TeamModel _$TeamModelFromJson(Map<String, dynamic> json) => _TeamModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  logo: json['logo'] as String?,
  shortName: json['shortName'] as String?,
);

Map<String, dynamic> _$TeamModelToJson(_TeamModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'logo': instance.logo,
      'shortName': instance.shortName,
    };

_ScoreModel _$ScoreModelFromJson(Map<String, dynamic> json) => _ScoreModel(
  home: (json['home'] as num?)?.toInt() ?? 0,
  away: (json['away'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ScoreModelToJson(_ScoreModel instance) =>
    <String, dynamic>{'home': instance.home, 'away': instance.away};

_EventsResponse _$EventsResponseFromJson(Map<String, dynamic> json) =>
    _EventsResponse(
      events:
          (json['events'] as List<dynamic>?)
              ?.map((e) => EventModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      total: (json['total'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$EventsResponseToJson(_EventsResponse instance) =>
    <String, dynamic>{
      'events': instance.events.map((e) => e.toJson()).toList(),
      'total': instance.total,
    };
