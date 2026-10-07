import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../api/model_converter.dart';
import '../api/rest_v2_json.dart';
import '../client/socket_config.dart';
import '../client/sport_socket_client.dart';
import '../client/v2_subscription_helper.dart';
import '../data/models/event_data.dart';
import '../data/models/odds_update_data.dart';
import '../events/connection_state.dart';
import '../subscription/subscription_registry.dart';
import '../utils/constants.dart';
import '../utils/logger.dart';
import 'protocol.dart';

typedef PostMessage = void Function(Map<String, Object?> message,
    [List<Object> transfer]);

typedef FetchText = Future<String?> Function(Uri url);

class SportWorkerHost {
  SportWorkerHost({
    required PostMessage post,
    required FetchText fetchText,
    required WebSocketChannel Function(Uri url) channelFactory,
    Logger logger = const NoOpLogger(),
  })  : _post = post,
        _fetchText = fetchText,
        _channelFactory = channelFactory,
        _logger = logger;

  final PostMessage _post;
  final FetchText _fetchText;
  final WebSocketChannel Function(Uri url) _channelFactory;
  final Logger _logger;

  static const String _source = 'worker';
  static const Duration _batchWindow = Duration(milliseconds: 50);

  SportSocketClient? _client;
  SubscriptionRegistry? _registry;
  StreamSubscription<ConnectionStateEvent>? _connSub;
  StreamSubscription<OddsUpdateData>? _oddsSub;

  String _baseUrl = '';
  int _populateGen = 0;
  final Set<int> _heldEventIds = <int>{};

  final Map<String, OddsUpdateData> _pending = <String, OddsUpdateData>{};
  Timer? _flushTimer;
  int _seq = 0;

  int _ticks = 0;
  int _oddsSeen = 0;
  int _batchesSent = 0;

  Timer? _tickTimer;

  void start() {
    _tickTimer ??= Timer.periodic(const Duration(seconds: 1), (_) => _ticks++);
    _post({SportRunnerProtocol.type: SportRunnerProtocol.ready});
  }

  void handle(Map<Object?, Object?> raw) {
    final msg = raw.map((k, v) => MapEntry(k.toString(), v));
    final type = msg[SportRunnerProtocol.type];
    try {
      switch (type) {
        case SportRunnerProtocol.connect:
          unawaited(
            _connect(
              url: msg['url'] as String,
              lang: (msg['lang'] as String?) ??
                  V2SubscriptionHelper.defaultLanguage,
              baseUrl: (msg['baseUrl'] as String?) ?? '',
            ),
          );
        case SportRunnerProtocol.setConfig:
          if (msg['baseUrl'] is String) _baseUrl = msg['baseUrl'] as String;
        case SportRunnerProtocol.subscribeList:
          _registry?.subscribe(
            MatchListKey(msg['sportId'] as int, msg['tr'] as int),
            source: _source,
          );
        case SportRunnerProtocol.unsubscribeList:
          _registry?.unsubscribe(
            MatchListKey(msg['sportId'] as int, msg['tr'] as int),
            source: _source,
          );
        case SportRunnerProtocol.populate:
          unawaited(
            _populate(
              sportId: msg['sportId'] as int,
              tr: msg['tr'] as int,
              gen: msg['gen'] as int,
            ),
          );
        case SportRunnerProtocol.querySlice:
          _querySlice(
            reqId: msg['reqId'] as int,
            sportId: msg['sportId'] as int,
            gen: (msg['gen'] as int?) ?? 0,
          );
        case SportRunnerProtocol.setHeldEvents:
          _heldEventIds
            ..clear()
            ..addAll((msg['ids'] as List).cast<int>());
        case SportRunnerProtocol.ping:
          _post({
            SportRunnerProtocol.type: SportRunnerProtocol.pong,
            'n': msg['n'],
            'ticks': _ticks,
            'decoded': _oddsSeen,
            'batches': _batchesSent,
          });
        case SportRunnerProtocol.dispose:
          unawaited(dispose());
        default:
          _error('unknown command: $type');
      }
    } catch (e, st) {
      _error('$type failed: $e\n$st');
    }
  }

  Future<void> _connect({
    required String url,
    required String lang,
    required String baseUrl,
  }) async {
    if (_client != null) return;
    _baseUrl = baseUrl;

    final client = SportSocketClient(
      config: SocketConfig.liveMode(
        url: url,
        logger: _logger,
        useV2Protocol: true,
        v2Language: lang,
        channelFactory: _channelFactory,
      ),
    );
    _client = client;
    client.dataStore.pruneProtection = _heldEventIds.contains;

    final registry = SubscriptionRegistry(
      send: client.sendRaw,
      language: lang,
      logger: _logger,
    );
    _registry = registry;

    _connSub = client.onConnectionChanged.listen((event) {
      switch (event.currentState) {
        case ConnectionState.connected:
          registry.onConnected();
        case ConnectionState.disconnected:
          registry.onDisconnected();
        default:
          break;
      }
      _post({
        SportRunnerProtocol.type: SportRunnerProtocol.status,
        'state': event.currentState.name,
        'attempt': event.reconnectAttempt,
      });
    });

    _oddsSub = client.onOddsUpdate.listen(_onOdds);

    await client.connect();
  }

  void _onOdds(OddsUpdateData update) {
    _oddsSeen++;
    _pending['${update.eventId}_${update.marketId}_${update.offerId}'] = update;
    _flushTimer ??= Timer(_batchWindow, _flushBatch);
  }

  void _flushBatch() {
    _flushTimer = null;
    if (_pending.isEmpty) return;
    final updates = _pending.values.toList(growable: false);
    _pending.clear();

    final n = updates.length;
    final eventIds = Int32List(n);
    final marketIds = Int32List(n);
    final offerIds = List<String>.filled(n, '');
    final home = Float64List(n);
    final away = Float64List(n);
    final draw = Float64List(n);
    final suspended = Int8List(n);
    for (var i = 0; i < n; i++) {
      final u = updates[i];
      eventIds[i] = u.eventId;
      marketIds[i] = u.marketId;
      offerIds[i] = u.offerId;
      home[i] = u.odds.oddsHome ?? double.nan;
      away[i] = u.odds.oddsAway ?? double.nan;
      draw[i] = u.odds.oddsDraw ?? double.nan;
      suspended[i] = u.odds.isSuspended ? 1 : 0;
    }
    _batchesSent++;
    _post(
      {
        SportRunnerProtocol.type: SportRunnerProtocol.batch,
        'seq': ++_seq,
        'count': n,
        'eventIds': eventIds,
        'marketIds': marketIds,
        'offerIds': offerIds,
        'home': home,
        'away': away,
        'draw': draw,
        'suspended': suspended,
      },
      [
        eventIds.buffer,
        marketIds.buffer,
        home.buffer,
        away.buffer,
        draw.buffer,
        suspended.buffer
      ],
    );
  }

  Future<void> _populate(
      {required int sportId, required int tr, required int gen}) async {
    final client = _client;
    if (client == null) {
      _error('populate before connect');
      return;
    }
    if (gen < _populateGen) {
      return;
    }
    _populateGen = gen;
    final fetchStartMs = DateTime.now().millisecondsSinceEpoch;

    final url = Uri.parse(
      '$_baseUrl/events?sportId=$sportId&timeRange=$tr&tzOffset=-420&isMobile=true',
    );
    final text = await _fetchText(url);
    if (text == null) {
      _error('populate: fetch failed for sport $sportId tr $tr');
      return;
    }
    if (gen != _populateGen) return;

    final decoded = jsonDecode(text);
    if (decoded is! List) {
      _error('populate: unexpected payload');
      return;
    }
    final jsonLeagues = [
      for (final league in decoded)
        if (league is Map)
          RestV2Json.leagueJsonV2(Map<String, dynamic>.from(league), sportId),
    ];
    final store = client.dataStore;
    ModelConverter.upsertPopulateDataStore(
      jsonLeagues,
      store,
      sportId: sportId,
      timeRange: switch (tr) {
        1 || 3 => TimeRange.today,
        2 => TimeRange.early,
        _ => TimeRange.live,
      },
      prune: true,
      protectSocketTouchAfterMs: fetchStartMs,
    );
    store.emitBatchChanges();

    var events = 0;
    for (final l in jsonLeagues) {
      events += (l['events'] as List).length;
    }
    _post({
      SportRunnerProtocol.type: SportRunnerProtocol.populated,
      'gen': gen,
      'sportId': sportId,
      'tr': tr,
      'leagues': jsonLeagues.length,
      'events': events,
    });
  }

  void _querySlice(
      {required int reqId, required int sportId, required int gen}) {
    final store = _client?.dataStore;
    final leagues = <Map<String, Object?>>[];
    if (store != null) {
      for (final league in store.getSortedLeaguesBySport(sportId)) {
        final rows = <Map<String, Object?>>[
          for (final EventData e in store.getEventsByLeague(league.leagueId))
            {
              'id': e.eventId,
              'home': e.homeName,
              'away': e.awayName,
              'live': e.isLive,
              'hs': e.homeScore,
              'as': e.awayScore,
              'start': e.startDate?.millisecondsSinceEpoch,
            },
        ];
        leagues
            .add({'id': league.leagueId, 'name': league.name, 'events': rows});
      }
    }
    _post({
      SportRunnerProtocol.type: SportRunnerProtocol.slice,
      'reqId': reqId,
      'sportId': sportId,
      'gen': gen,
      'leagues': leagues,
    });
  }

  void _error(String msg) {
    _logger.error(msg);
    _post({SportRunnerProtocol.type: SportRunnerProtocol.error, 'msg': msg});
  }

  Future<void> dispose() async {
    _tickTimer?.cancel();
    _tickTimer = null;
    _flushTimer?.cancel();
    _flushTimer = null;
    await _connSub?.cancel();
    await _oddsSub?.cancel();
    _registry?.onDisconnected();
    _registry = null;
    await _client?.dispose();
    _client = null;
  }
}
