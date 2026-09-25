
part of 'league_model.dart';

_LeagueData _$LeagueDataFromJson(Map<String, dynamic> json) => _LeagueData(
  leagueId: (json['li'] as num?)?.toInt() ?? 0,
  leagueName: json['ln'] as String? ?? '',
  leagueLogo: json['lg'] as String? ?? '',
  priorityOrder: (json['lpo'] as num?)?.toInt(),
  events:
      (json['e'] as List<dynamic>?)
          ?.map((e) => LeagueEventData.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  outrightEvents: (json['eo'] as List<dynamic>?)
      ?.map((e) => OutrightData.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$LeagueDataToJson(_LeagueData instance) =>
    <String, dynamic>{
      'li': instance.leagueId,
      'ln': instance.leagueName,
      'lg': instance.leagueLogo,
      'lpo': instance.priorityOrder,
      'e': instance.events.map((e) => e.toJson()).toList(),
      'eo': instance.outrightEvents?.map((e) => e.toJson()).toList(),
    };

_LeagueEventData _$LeagueEventDataFromJson(Map<String, dynamic> json) =>
    _LeagueEventData(
      eventId: (json['ei'] as num?)?.toInt() ?? 0,
      eventName: json['en'] as String?,
      homeId: (json['hi'] as num?)?.toInt() ?? 0,
      homeName: json['hn'] as String? ?? '',
      awayId: (json['ai'] as num?)?.toInt() ?? 0,
      awayName: json['an'] as String? ?? '',
      homeLogoFirst: json['hf'] as String?,
      homeLogoLast: json['hl'] as String?,
      awayLogoFirst: json['af'] as String?,
      awayLogoLast: json['al'] as String?,
      startTime: _readStartTime(json, 'st') == null
          ? 0
          : _parseStartTime(_readStartTime(json, 'st')),
      homeScore: (json['hs'] as num?)?.toInt() ?? 0,
      awayScore: (json['as'] as num?)?.toInt() ?? 0,
      isLive: json['l'] as bool? ?? false,
      isGoingLive: json['gl'] as bool? ?? false,
      isLivestream: json['ls'] as bool? ?? false,
      isSuspended: json['s'] as bool? ?? false,
      eventStatus: json['es'] as String?,
      eventStatsId: (json['esi'] as num?)?.toInt() ?? 0,
      gameTime: (json['gt'] as num?)?.toInt() ?? 0,
      gamePart: (json['gp'] as num?)?.toInt() ?? 0,
      stoppageTime: (json['stm'] as num?)?.toInt() ?? 0,
      cornersHome: (json['hc'] as num?)?.toInt() ?? 0,
      cornersAway: (json['ac'] as num?)?.toInt() ?? 0,
      homeScoreOT: (json['hso'] as num?)?.toInt() ?? 0,
      awayScoreOT: (json['aso'] as num?)?.toInt() ?? 0,
      redCardsHome: (json['rch'] as num?)?.toInt() ?? 0,
      redCardsAway: (json['rca'] as num?)?.toInt() ?? 0,
      yellowCardsHome: (json['ych'] as num?)?.toInt() ?? 0,
      yellowCardsAway: (json['yca'] as num?)?.toInt() ?? 0,
      totalMarketsCount: (json['mc'] as num?)?.toInt() ?? 0,
      isParlay: json['ip'] as bool? ?? false,
      minute: (json['min'] as num?)?.toInt(),
      markets:
          (json['m'] as List<dynamic>?)
              ?.map((e) => LeagueMarketData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$LeagueEventDataToJson(_LeagueEventData instance) =>
    <String, dynamic>{
      'ei': instance.eventId,
      'en': instance.eventName,
      'hi': instance.homeId,
      'hn': instance.homeName,
      'ai': instance.awayId,
      'an': instance.awayName,
      'hf': instance.homeLogoFirst,
      'hl': instance.homeLogoLast,
      'af': instance.awayLogoFirst,
      'al': instance.awayLogoLast,
      'st': instance.startTime,
      'hs': instance.homeScore,
      'as': instance.awayScore,
      'l': instance.isLive,
      'gl': instance.isGoingLive,
      'ls': instance.isLivestream,
      's': instance.isSuspended,
      'es': instance.eventStatus,
      'esi': instance.eventStatsId,
      'gt': instance.gameTime,
      'gp': instance.gamePart,
      'stm': instance.stoppageTime,
      'hc': instance.cornersHome,
      'ac': instance.cornersAway,
      'hso': instance.homeScoreOT,
      'aso': instance.awayScoreOT,
      'rch': instance.redCardsHome,
      'rca': instance.redCardsAway,
      'ych': instance.yellowCardsHome,
      'yca': instance.yellowCardsAway,
      'mc': instance.totalMarketsCount,
      'ip': instance.isParlay,
      'min': instance.minute,
      'm': instance.markets.map((e) => e.toJson()).toList(),
    };

_LeagueMarketData _$LeagueMarketDataFromJson(Map<String, dynamic> json) =>
    _LeagueMarketData(
      marketId: (json['mi'] as num?)?.toInt() ?? 0,
      marketName: json['mn'] as String? ?? '',
      marketType: json['mt'] as String?,
      isParlay: json['ip'] as bool? ?? false,
      odds:
          (json['o'] as List<dynamic>?)
              ?.map((e) => LeagueOddsData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$LeagueMarketDataToJson(_LeagueMarketData instance) =>
    <String, dynamic>{
      'mi': instance.marketId,
      'mn': instance.marketName,
      'mt': instance.marketType,
      'ip': instance.isParlay,
      'o': instance.odds.map((e) => e.toJson()).toList(),
    };

_LeagueOddsData _$LeagueOddsDataFromJson(Map<String, dynamic> json) =>
    _LeagueOddsData(
      points: json['p'] as String? ?? '',
      isMainLine: json['ml'] as bool? ?? false,
      selectionHomeId: json['shi'] as String?,
      selectionAwayId: json['sai'] as String?,
      selectionDrawId: json['sdi'] as String?,
      offerId: json['soi'] as String?,
      isSuspended: json['isSuspended'] as bool? ?? false,
      oddsHome: json['oh'] == null
          ? const OddsValue()
          : OddsValue.fromJson(json['oh'] as Map<String, dynamic>?),
      oddsAway: json['oa'] == null
          ? const OddsValue()
          : OddsValue.fromJson(json['oa'] as Map<String, dynamic>?),
      oddsDraw: json['od'] == null
          ? const OddsValue()
          : OddsValue.fromJson(json['od'] as Map<String, dynamic>?),
      homeOddsLegacy: (json['ho'] as num?)?.toDouble(),
      awayOddsLegacy: (json['ao'] as num?)?.toDouble(),
      drawOddsLegacy: (json['do'] as num?)?.toDouble(),
      offerIdLegacy: json['oi'] as String?,
      selectionIdLegacy: json['si'] as String?,
      playerName: json['playerName'] as String? ?? '',
      playerId: json['playerId'] as String? ?? '',
      period: (json['period'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$LeagueOddsDataToJson(_LeagueOddsData instance) =>
    <String, dynamic>{
      'p': instance.points,
      'ml': instance.isMainLine,
      'shi': instance.selectionHomeId,
      'sai': instance.selectionAwayId,
      'sdi': instance.selectionDrawId,
      'soi': instance.offerId,
      'isSuspended': instance.isSuspended,
      'oh': OddsValue.toJsonStatic(instance.oddsHome),
      'oa': OddsValue.toJsonStatic(instance.oddsAway),
      'od': OddsValue.toJsonStatic(instance.oddsDraw),
      'ho': instance.homeOddsLegacy,
      'ao': instance.awayOddsLegacy,
      'do': instance.drawOddsLegacy,
      'oi': instance.offerIdLegacy,
      'si': instance.selectionIdLegacy,
      'playerName': instance.playerName,
      'playerId': instance.playerId,
      'period': instance.period,
    };

_OutrightData _$OutrightDataFromJson(Map<String, dynamic> json) =>
    _OutrightData(
      outrightId: (json['oi'] as num?)?.toInt() ?? 0,
      outrightName: json['on'] as String? ?? '',
      selections:
          (json['os'] as List<dynamic>?)
              ?.map(
                (e) => OutrightSelection.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$OutrightDataToJson(_OutrightData instance) =>
    <String, dynamic>{
      'oi': instance.outrightId,
      'on': instance.outrightName,
      'os': instance.selections.map((e) => e.toJson()).toList(),
    };

_OutrightSelection _$OutrightSelectionFromJson(Map<String, dynamic> json) =>
    _OutrightSelection(
      selectionId: json['si'] as String? ?? '',
      selectionName: json['sn'] as String? ?? '',
      odds: (json['od'] as num?)?.toDouble() ?? 0.0,
      offerId: json['oi'] as String?,
    );

Map<String, dynamic> _$OutrightSelectionToJson(_OutrightSelection instance) =>
    <String, dynamic>{
      'si': instance.selectionId,
      'sn': instance.selectionName,
      'od': instance.odds,
      'oi': instance.offerId,
    };
