import 'dart:async';

import 'package:sun_sports/core/services/websocket/base_websocket.dart';
import 'package:sun_sports/core/services/websocket/websocket_messages.dart';
import 'package:sun_sports/core/services/websocket/isolate/ws_isolate.dart';
import 'package:sun_sports/core/utils/app_logger.dart';

class SbWebSocket extends BaseWebSocket {
  final AppLogger _logger = AppLogger();

  final WsIsolateProcessor _isolateProcessor = WsIsolateProcessor();

  final List<String> _rawMessageBuffer = [];

  Timer? _isolateTimer;

  bool _useIsolate = true;

  bool _isolateInitialized = false;

  String? _custLogin;

  final Set<int> _subscribedSports = {};

  final Set<int> _subscribedEvents = {};

  final StreamController<WsMessage> _typedMessageController =
      StreamController<WsMessage>.broadcast();

  final StreamController<OddsUpdateData> _oddsController =
      StreamController<OddsUpdateData>.broadcast();

  final StreamController<OddsRemoveData> _oddsRemoveController =
      StreamController<OddsRemoveData>.broadcast();

  final StreamController<BalanceUpdateData> _balanceController =
      StreamController<BalanceUpdateData>.broadcast();

  final StreamController<ScoreUpdateData> _scoreController =
      StreamController<ScoreUpdateData>.broadcast();

  final StreamController<OddsFullListData> _oddsFullListController =
      StreamController<OddsFullListData>.broadcast();

  final StreamController<EventInsertData> _eventInsertController =
      StreamController<EventInsertData>.broadcast();

  final StreamController<EventRemoveData> _eventRemoveController =
      StreamController<EventRemoveData>.broadcast();

  final StreamController<LeagueInsertData> _leagueInsertController =
      StreamController<LeagueInsertData>.broadcast();

  final StreamController<MarketStatusData> _marketStatusController =
      StreamController<MarketStatusData>.broadcast();

  @override
  String get name => 'SbWebSocket';

  Stream<WsMessage> get typedMessageStream => _typedMessageController.stream;

  Stream<OddsUpdateData> get oddsStream => _oddsController.stream;

  Stream<OddsRemoveData> get oddsRemoveStream => _oddsRemoveController.stream;

  Stream<BalanceUpdateData> get balanceStream => _balanceController.stream;

  Stream<ScoreUpdateData> get scoreStream => _scoreController.stream;

  Stream<OddsFullListData> get oddsFullListStream =>
      _oddsFullListController.stream;

  Stream<EventInsertData> get eventInsertStream =>
      _eventInsertController.stream;

  Stream<EventRemoveData> get eventRemoveStream =>
      _eventRemoveController.stream;

  Stream<LeagueInsertData> get leagueInsertStream =>
      _leagueInsertController.stream;

  Stream<MarketStatusData> get marketStatusStream =>
      _marketStatusController.stream;

  bool get useIsolate => _useIsolate;
  set useIsolate(bool value) {
    _useIsolate = value;
    if (!value) {
      _rawMessageBuffer.clear();
    }
  }

  bool get isIsolateInitialized => _isolateInitialized;

  Future<void> _initializeIsolate() async {
    if (_isolateInitialized) return;

    _logger.i('$name: [ISOLATE] Starting isolate initialization...');

    try {
      await _isolateProcessor.initialize();
      _isolateInitialized = true;

      _isolateTimer = Timer.periodic(
        const Duration(milliseconds: 16),
        (_) => _processIsolateBuffer(),
      );

      _logger.i(
        '$name: [ISOLATE] ✅ Isolate processor initialized successfully',
      );
      _logger.i(
        '$name: [ISOLATE] Messages will now be processed in background isolate/worker',
      );

    } catch (e) {
      _logger.w(
        '$name: [ISOLATE] ❌ Initialization failed, falling back to main thread: $e',
      );
      _useIsolate = false;
    }
  }

  final Map<String, int> _messageTypeCounts = {};

  bool _isProcessingIsolateBuffer = false;

  Future<void> _processIsolateBuffer() async {
    if (_rawMessageBuffer.isEmpty) return;

    if (_isProcessingIsolateBuffer) return;
    _isProcessingIsolateBuffer = true;

    final messages = List<String>.from(_rawMessageBuffer);
    _rawMessageBuffer.clear();

    const sportId = 0;

    try {
      final input = WsIsolateInput(
        rawMessages: messages,
        currentSportId: sportId,
      );

      final output = await _isolateProcessor
          .process(input)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              _logger.w(
                '$name: [ISOLATE] Process timeout after 5s for ${messages.length} messages',
              );
              throw TimeoutException('Isolate process timeout');
            },
          );

      _handleIsolateOutput(output);
    } catch (e) {
      _logger.e('$name: [ISOLATE] Processing error: $e');
      for (final message in messages) {
        final wsMessage = WsMessage.parse(message);
        _typedMessageController.add(wsMessage);
        _dispatchMessage(wsMessage);
      }
    } finally {
      _isProcessingIsolateBuffer = false;
    }
  }

  void _handleIsolateOutput(WsIsolateOutput output) {
    if (output.scoreUpdates.isNotEmpty || output.eventInserts.isNotEmpty) {
    }

    for (final msg in output.typedMessages) {
      _messageTypeCounts[msg.type] = (_messageTypeCounts[msg.type] ?? 0) + 1;
    }

    for (final odds in output.oddsUpdates) {
      final oddsValuesMap = odds.oddsValues;
      _oddsController.add(
        OddsUpdateData(
          eventId: odds.eventId,
          marketId: odds.marketId,
          selectionId: odds.selectionId,
          odds: odds.odds,
          trueOdds: odds.trueOdds,
          oddsValues: oddsValuesMap != null
              ? OddsStyleValues.fromJson(oddsValuesMap)
              : const OddsStyleValues(),
        ),
      );
    }

    for (final fullList in output.oddsFullListUpdates) {
      final data = OddsFullListData(
        eventId: fullList.eventId,
        marketId: fullList.marketId,
        validPoints: fullList.validPoints.toSet(),
      );
      _oddsFullListController.add(data);
    }

    for (final event in output.eventInserts) {
      final data = EventInsertData(
        sportId: event.sportId,
        leagueId: event.leagueId,
        eventId: event.eventId,
        homeName: event.homeName,
        awayName: event.awayName,
        homeScore: event.homeScore,
        awayScore: event.awayScore,
        isLive: event.isLive,
        startTime: int.tryParse(event.startTime ?? '') ?? 0,
        eventStatus: event.eventStatus?.toString(),
        gameTime: int.tryParse(event.gameTime ?? '') ?? 0,
        gamePart: int.tryParse(event.gamePart ?? '') ?? 0,
        homeLogo: event.homeLogo,
        awayLogo: event.awayLogo,
      );
      _eventInsertController.add(data);
    }

    for (final event in output.eventRemoves) {
      final data = EventRemoveData(eventId: event.eventId, leagueId: 0);
      _eventRemoveController.add(data);
    }

    for (final league in output.leagueInserts) {
      final data = LeagueInsertData(
        sportId: league.sportId,
        leagueId: league.leagueId,
        leagueName: league.leagueName,
        logoUrl: league.logoUrl,
      );
      _leagueInsertController.add(data);
    }

    for (final market in output.marketStatusUpdates) {
      final status = market.isSuspended
          ? MarketStatus.suspended
          : MarketStatus.active;

      final data = MarketStatusData(
        eventId: market.eventId,
        leagueId: 0,
        marketId: market.marketId,
        status: status,
      );
      _marketStatusController.add(data);
    }

    for (final balance in output.balanceUpdates) {
      _balanceController.add(
        BalanceUpdateData(
          balance: balance.balance,
          raw: balance.balance.toString(),
        ),
      );
    }

    for (final score in output.scoreUpdates) {
      _scoreController.add(
        ScoreUpdateData(
          eventId: score.eventId,
          home: score.homeScore,
          away: score.awayScore,
          gameTime: int.tryParse(score.gameTime ?? ''),
          gamePart: int.tryParse(score.gamePart ?? ''),
        ),
      );
    }

    for (final typed in output.typedMessages) {
      _typedMessageController.add(
        WsMessage(
          type: WsMessageType.values.firstWhere(
            (t) => t.name == typed.type,
            orElse: () => WsMessageType.unknown,
          ),
          data: typed.data,
        ),
      );
    }
  }

  Future<bool> connectWithAuth(String url, String custLogin) async {
    _custLogin = custLogin;
    return connect(url);
  }

  void subscribeSport(int sportId) {
    if (_subscribedSports.contains(sportId)) return;

    _subscribedSports.add(sportId);
    if (isConnected) {
      _sendSportSubscription(sportId);
    }
  }

  void unsubscribeSport(int sportId) {
    _subscribedSports.remove(sportId);
    if (isConnected) {
      send('UNSUB:s:$sportId');
    }
  }

  void subscribeEvent(int eventId) {
    if (_subscribedEvents.contains(eventId)) return;

    _subscribedEvents.add(eventId);
    if (isConnected) {
      _sendEventSubscription(eventId);
    }
  }

  void unsubscribeEvent(int eventId) {
    _subscribedEvents.remove(eventId);
    if (isConnected) {
      send('UNSUB:e:$eventId');
    }
  }

  void subscribeBalance() {
    if (_custLogin != null && isConnected) {
      send('userbal:$_custLogin');
    }
  }

  void clearSubscriptions() {
    _subscribedSports.clear();
    _subscribedEvents.clear();
  }

  @override
  void dispose() {
    _isolateTimer?.cancel();
    _isolateTimer = null;
    _isolateProcessor.dispose();
    _rawMessageBuffer.clear();

    _typedMessageController.close();
    _oddsController.close();
    _oddsRemoveController.close();
    _oddsFullListController.close();
    _balanceController.close();
    _scoreController.close();
    _eventInsertController.close();
    _eventRemoveController.close();
    _leagueInsertController.close();
    _marketStatusController.close();
    super.dispose();
  }

  @override
  void onConnected() {
    _logger.i('$name: Connected, restoring subscriptions...');

    if (_useIsolate && !_isolateInitialized) {
      _initializeIsolate();
    }

    for (final sportId in _subscribedSports) {
      _sendSportSubscription(sportId);
    }

    for (final eventId in _subscribedEvents) {
      _sendEventSubscription(eventId);
    }

    subscribeBalance();
  }

  @override
  void onMessage(String message) {
    if (_useIsolate && _isolateInitialized) {
      _rawMessageBuffer.add(message);
      return;
    }

    final wsMessage = WsMessage.parse(message);

    _typedMessageController.add(wsMessage);
    _dispatchMessage(wsMessage);
  }

  void _handleOddsRemove(WsMessage wsMessage) {
    final data = wsMessage.data;
    final d = data['d'] as Map<String, dynamic>?;

    if (d != null) {
      final kafkaOddsList = d['kafkaOddsList'] as List<dynamic>?;
      if (kafkaOddsList != null) {
        for (final item in kafkaOddsList) {
          if (item is Map<String, dynamic>) {
            final removeData = OddsRemoveData.fromKafkaItem(item);
            _logger.d('$name: Odds removed - $removeData');
            _oddsRemoveController.add(removeData);
          }
        }
      }
    }
  }

  void _handleOddsUpdate(WsMessage wsMessage) {
    final data = wsMessage.data;

    final d = data['d'] as Map<String, dynamic>?;
    if (d != null) {
      final kafkaOddsList = d['kafkaOddsList'] as List<dynamic>?;
      if (kafkaOddsList != null) {
        final validPointsPerMarket = <String, Set<String>>{};
        final marketInfo = <String, (int, int)>{};

        for (final item in kafkaOddsList) {
          if (item is Map<String, dynamic>) {
            _emitOddsFromKafkaItem(item, validPointsPerMarket, marketInfo);
          }
        }

        for (final entry in validPointsPerMarket.entries) {
          final info = marketInfo[entry.key];
          if (info != null) {
            _oddsFullListController.add(
              OddsFullListData(
                eventId: info.$1,
                marketId: info.$2,
                validPoints: entry.value,
              ),
            );
          }
        }
        return;
      }
    }

    final oddsData = OddsUpdateData.fromMessage(wsMessage);
    if (oddsData.selectionId.isNotEmpty) {
      _logger.d(
        '$name: Odds update - selectionId: ${oddsData.selectionId}, odds: ${oddsData.odds}',
      );
      _oddsController.add(oddsData);
    }
  }

  void _emitOddsFromKafkaItem(
    Map<String, dynamic> item,
    Map<String, Set<String>> validPointsPerMarket,
    Map<String, (int, int)> marketInfo,
  ) {
    final eventId = item['eventId'] as int? ?? 0;
    final marketIdInt =
        item['domainMarketId'] as int? ?? item['marketId'] as int? ?? 0;
    final marketId = marketIdInt.toString();
    final odds = item['odds'] as Map<String, dynamic>?;

    if (odds == null) return;

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
      final oddsValues = OddsStyleValues.fromJson(oddsHome);
      final decimalOdds = oddsHome['decimal']?.toString() ?? '0';
      final trueOdds = double.tryParse(oddsHome['trueOdds']?.toString() ?? '');

      _oddsController.add(
        OddsUpdateData(
          eventId: eventId,
          marketId: marketId,
          selectionId: selectionHomeId,
          odds: decimalOdds,
          trueOdds: trueOdds,
          oddsValues: oddsValues,
        ),
      );
    }

    if (selectionAwayId.isNotEmpty && oddsAway != null) {
      final oddsValues = OddsStyleValues.fromJson(oddsAway);
      final decimalOdds = oddsAway['decimal']?.toString() ?? '0';
      final trueOdds = double.tryParse(oddsAway['trueOdds']?.toString() ?? '');
      _oddsController.add(
        OddsUpdateData(
          eventId: eventId,
          marketId: marketId,
          selectionId: selectionAwayId,
          odds: decimalOdds,
          trueOdds: trueOdds,
          oddsValues: oddsValues,
        ),
      );
    }

    if (selectionDrawId != null &&
        selectionDrawId.isNotEmpty &&
        oddsDraw != null) {
      final oddsValues = OddsStyleValues.fromJson(oddsDraw);
      final decimalOdds = oddsDraw['decimal']?.toString() ?? '0';
      final trueOdds = double.tryParse(oddsDraw['trueOdds']?.toString() ?? '');
      _oddsController.add(
        OddsUpdateData(
          eventId: eventId,
          marketId: marketId,
          selectionId: selectionDrawId,
          odds: decimalOdds,
          trueOdds: trueOdds,
          oddsValues: oddsValues,
        ),
      );
    }
  }

  @override
  void onDisconnected() {
    _logger.w('$name: Disconnected');
  }

  @override
  void onError(dynamic error) {
    _logger.e('$name: Error: $error');
  }

  void _dispatchMessage(WsMessage wsMessage) {
    switch (wsMessage.type) {
      case WsMessageType.oddsUpdate:
      case WsMessageType.oddsInsert:
        _handleOddsUpdate(wsMessage);
        break;
      case WsMessageType.oddsRemove:
        _handleOddsRemove(wsMessage);
        break;

      case WsMessageType.balanceUpdate:
        _balanceController.add(BalanceUpdateData.fromMessage(wsMessage));
        break;

      case WsMessageType.scoreUpdate:
        final scoreData = ScoreUpdateData.fromMessage(wsMessage);
        _scoreController.add(scoreData);
        break;

      case WsMessageType.eventStatus:
        break;

      case WsMessageType.eventInsert:
        _handleEventInsert(wsMessage);
        break;

      case WsMessageType.eventRemove:
        _handleEventRemove(wsMessage);
        break;

      case WsMessageType.marketStatus:
        _handleMarketStatus(wsMessage);
        break;

      case WsMessageType.leagueInsert:
        _handleLeagueInsert(wsMessage);
        break;

      default:
        break;
    }
  }

  void _sendSportSubscription(int sportId) {
    send('SUB:s:$sportId');
    _logger.d('$name: Subscribed to sport $sportId');
  }

  void _sendEventSubscription(int eventId) {
    send('SUB:e:$eventId');
    _logger.d('$name: Subscribed to event $eventId');
  }

  void _handleEventInsert(WsMessage wsMessage) {
    final data = EventInsertData.fromMessage(wsMessage);
    if (data.eventId == 0) return;

    _logger.d('$name: Event inserted - $data');
    _eventInsertController.add(data);
  }

  void _handleEventRemove(WsMessage wsMessage) {
    final data = EventRemoveData.fromMessage(wsMessage);
    if (data.eventId == 0) return;

    _logger.d('$name: Event removed - $data');
    _eventRemoveController.add(data);
  }

  void _handleLeagueInsert(WsMessage wsMessage) {
    final data = LeagueInsertData.fromMessage(wsMessage);
    if (data.leagueId == 0) return;

    _logger.d('$name: League inserted - $data');
    _leagueInsertController.add(data);
  }

  void _handleMarketStatus(WsMessage wsMessage) {
    final data = MarketStatusData.fromMessage(wsMessage);
    if (data.eventId == 0 || data.marketId == 0) return;

    _logger.d('$name: Market status - $data');
    _marketStatusController.add(data);
  }
}
