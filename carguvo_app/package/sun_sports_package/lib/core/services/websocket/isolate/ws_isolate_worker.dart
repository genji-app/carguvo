import 'dart:convert';

import 'package:isolate_manager/isolate_manager.dart';

import 'ws_isolate_types.dart';

@pragma('vm:entry-point')
@isolateManagerWorker
Map<String, dynamic> wsIsolateWorker(Map<String, dynamic> inputMap) {
  final rawMessages = List<String>.from(inputMap['rawMessages'] as List);
  final currentSportId = inputMap['currentSportId'] as int;

  final output = _processMessagesSync(rawMessages, currentSportId);
  return output.toMap();
}

WsIsolateOutput _processMessagesSync(
  List<String> rawMessages,
  int currentSportId,
) {
  final oddsUpdates = <IsolateOddsUpdate>[];
  final oddsFullListUpdates = <IsolateOddsFullList>[];
  final eventInserts = <IsolateEventInsert>[];
  final eventRemoves = <IsolateEventRemove>[];
  final leagueInserts = <IsolateLeagueInsert>[];
  final marketStatusUpdates = <IsolateMarketStatus>[];
  final balanceUpdates = <IsolateBalanceUpdate>[];
  final scoreUpdates = <IsolateScoreUpdate>[];
  final typedMessages = <IsolateTypedMessage>[];

  final validPointsPerMarket = <String, Set<String>>{};
  final marketInfo = <String, (int, int)>{};

  for (final rawJson in rawMessages) {
    try {
      final data = jsonDecode(rawJson) as Map<String, dynamic>;
      final type = data['t'] as String? ?? '';

      typedMessages.add(IsolateTypedMessage(type: type, data: data));

      switch (type) {
        case 'odds_up':
        case 'odds_ins':
          _processOddsUpdate(
            data,
            oddsUpdates,
            validPointsPerMarket,
            marketInfo,
          );
          break;

        case 'event_ins':
          final eventData = _parseEventInsert(data);
          if (eventData != null) {
            eventInserts.add(eventData);
          }
          break;

        case 'event_rm':
          final eventId = _extractEventId(data);
          if (eventId != null && eventId > 0) {
            eventRemoves.add(IsolateEventRemove(eventId: eventId));
          }
          break;

        case 'league_ins':
          final leagueData = _parseLeagueInsert(data);
          if (leagueData != null) {
            leagueInserts.add(leagueData);
          }
          break;

        case 'market_up':
          final marketData = _parseMarketStatus(data);
          if (marketData != null) {
            marketStatusUpdates.add(marketData);
          }
          break;

        case 'balance_up':
          final balanceData = _parseBalanceUpdate(data);
          if (balanceData != null) {
            balanceUpdates.add(balanceData);
          }
          break;

        case 'score_up':
          final scoreData = _parseScoreUpdate(data);
          if (scoreData != null) {
            scoreUpdates.add(scoreData);
          }
          break;

        case 'event_up':
          final eventScoreData = _parseEventUpdate(data);
          if (eventScoreData != null) {
            scoreUpdates.add(eventScoreData);
          }
          break;
      }
    } catch (e) {
      continue;
    }
  }

  for (final entry in validPointsPerMarket.entries) {
    final info = marketInfo[entry.key];
    if (info != null) {
      oddsFullListUpdates.add(
        IsolateOddsFullList(
          eventId: info.$1,
          marketId: info.$2,
          validPoints: entry.value.toList(),
        ),
      );
    }
  }

  return WsIsolateOutput(
    oddsUpdates: oddsUpdates,
    oddsFullListUpdates: oddsFullListUpdates,
    eventInserts: eventInserts,
    eventRemoves: eventRemoves,
    leagueInserts: leagueInserts,
    marketStatusUpdates: marketStatusUpdates,
    balanceUpdates: balanceUpdates,
    scoreUpdates: scoreUpdates,
    typedMessages: typedMessages,
  );
}

void _processOddsUpdate(
  Map<String, dynamic> data,
  List<IsolateOddsUpdate> oddsUpdates,
  Map<String, Set<String>> validPointsPerMarket,
  Map<String, (int, int)> marketInfo,
) {
  final d = data['d'] as Map<String, dynamic>?;
  if (d == null) return;

  final kafkaOddsList = d['kafkaOddsList'] as List<dynamic>?;
  if (kafkaOddsList == null) return;

  for (final item in kafkaOddsList) {
    if (item is! Map<String, dynamic>) continue;

    final eventId = item['eventId'] as int? ?? 0;
    final marketIdInt =
        item['domainMarketId'] as int? ?? item['marketId'] as int? ?? 0;
    final marketId = marketIdInt.toString();
    final odds = item['odds'] as Map<String, dynamic>?;

    if (odds == null || eventId == 0) continue;

    final points = odds['points'] as String? ?? '';
    final selectionHomeId = odds['selectionHomeId'] as String? ?? '';
    final selectionAwayId = odds['selectionAwayId'] as String? ?? '';
    final selectionDrawId = odds['selectionDrawId'] as String?;

    final oddsHome = odds['oddsHome'] as Map<String, dynamic>?;
    final oddsAway = odds['oddsAway'] as Map<String, dynamic>?;
    final oddsDraw = odds['oddsDraw'] as Map<String, dynamic>?;

    final marketKey = '${eventId}_$marketIdInt';
    validPointsPerMarket[marketKey] ??= <String>{};
    marketInfo[marketKey] = (eventId, marketIdInt);

    if (points.isNotEmpty) {
      validPointsPerMarket[marketKey]!.add(points);
    }

    if (selectionHomeId.isNotEmpty && oddsHome != null) {
      oddsUpdates.add(
        IsolateOddsUpdate(
          eventId: eventId,
          marketId: marketId,
          selectionId: selectionHomeId,
          odds: oddsHome['decimal']?.toString() ?? '0',
          trueOdds: double.tryParse(oddsHome['trueOdds']?.toString() ?? ''),
          oddsValues: oddsHome,
        ),
      );
    }

    if (selectionAwayId.isNotEmpty && oddsAway != null) {
      oddsUpdates.add(
        IsolateOddsUpdate(
          eventId: eventId,
          marketId: marketId,
          selectionId: selectionAwayId,
          odds: oddsAway['decimal']?.toString() ?? '0',
          trueOdds: double.tryParse(oddsAway['trueOdds']?.toString() ?? ''),
          oddsValues: oddsAway,
        ),
      );
    }

    if (selectionDrawId != null &&
        selectionDrawId.isNotEmpty &&
        oddsDraw != null) {
      oddsUpdates.add(
        IsolateOddsUpdate(
          eventId: eventId,
          marketId: marketId,
          selectionId: selectionDrawId,
          odds: oddsDraw['decimal']?.toString() ?? '0',
          trueOdds: double.tryParse(oddsDraw['trueOdds']?.toString() ?? ''),
          oddsValues: oddsDraw,
        ),
      );
    }
  }
}

IsolateEventInsert? _parseEventInsert(Map<String, dynamic> data) {
  final d = data['d'] as Map<String, dynamic>?;
  if (d == null) return null;

  final eventId = d['eventId'] as int? ?? 0;
  if (eventId == 0) return null;

  final sportId = data['s'] as int? ?? d['sportId'] as int? ?? 0;

  return IsolateEventInsert(
    eventId: eventId,
    leagueId: d['leagueId'] as int? ?? 0,
    sportId: sportId,
    homeName: d['homeName'] as String? ?? '',
    awayName: d['awayName'] as String? ?? '',
    homeScore: d['homeScore'] as int? ?? 0,
    awayScore: d['awayScore'] as int? ?? 0,
    isLive: d['isLive'] as bool? ?? false,
    startTime: d['startTime'] as String?,
    eventStatus: d['eventStatus'] as int?,
    gameTime: d['gameTime'] as String?,
    gamePart: d['gamePart'] as String?,
    homeLogo: d['homeLogo'] as String?,
    awayLogo: d['awayLogo'] as String?,
  );
}

IsolateLeagueInsert? _parseLeagueInsert(Map<String, dynamic> data) {
  final d = data['d'] as Map<String, dynamic>?;
  if (d == null) return null;

  final leagueId = d['leagueId'] as int? ?? 0;
  if (leagueId == 0) return null;

  final sportId = data['s'] as int? ?? d['sportId'] as int? ?? 0;

  return IsolateLeagueInsert(
    leagueId: leagueId,
    sportId: sportId,
    leagueName: d['leagueName'] as String? ?? '',
    logoUrl: d['logoUrl'] as String?,
  );
}

IsolateMarketStatus? _parseMarketStatus(Map<String, dynamic> data) {
  final d = data['d'] as Map<String, dynamic>?;
  if (d == null) return null;

  final eventId = d['eventId'] as int? ?? 0;
  final marketId = d['marketId'] as int? ?? 0;
  if (eventId == 0 || marketId == 0) return null;

  return IsolateMarketStatus(
    eventId: eventId,
    marketId: marketId,
    isSuspended: d['isSuspended'] as bool? ?? false,
  );
}

IsolateBalanceUpdate? _parseBalanceUpdate(Map<String, dynamic> data) {
  final d = data['d'] as Map<String, dynamic>?;
  if (d == null) return null;

  final balance = d['balance'];
  if (balance == null) return null;

  return IsolateBalanceUpdate(
    balance: (balance as num).toDouble(),
    currency: d['currency'] as String?,
  );
}

IsolateScoreUpdate? _parseScoreUpdate(Map<String, dynamic> data) {
  final d = data['d'] as Map<String, dynamic>?;
  if (d == null) return null;

  final eventId = _parseIntField(d['eventId']);
  if (eventId == 0) return null;

  return IsolateScoreUpdate(
    eventId: eventId,
    homeScore: _parseIntField(d['homeScore']),
    awayScore: _parseIntField(d['awayScore']),
    gameTime: _parseStringField(d['gameTime']),
    gamePart: _parseStringField(d['gamePart']),
  );
}

int? _extractEventId(Map<String, dynamic> data) {
  final d = data['d'] as Map<String, dynamic>?;
  return d?['eventId'] as int?;
}

IsolateScoreUpdate? _parseEventUpdate(Map<String, dynamic> data) {
  final d = data['d'] as Map<String, dynamic>?;
  if (d == null) return null;

  final eventId = _parseIntField(d['eventId']);
  if (eventId == 0) return null;

  return IsolateScoreUpdate(
    eventId: eventId,
    homeScore: _parseIntField(d['homeScore']),
    awayScore: _parseIntField(d['awayScore']),
    gameTime: _parseStringField(d['gameTime']),
    gamePart: _parseStringField(d['gamePart']),
  );
}

int _parseIntField(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  if (value is double) return value.toInt();
  return 0;
}

String? _parseStringField(dynamic value) {
  if (value == null) return null;
  return value.toString();
}
