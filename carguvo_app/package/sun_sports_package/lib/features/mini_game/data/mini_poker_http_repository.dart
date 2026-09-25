import 'package:sun_sports/core/services/network/sb_http_manager.dart';
import 'package:sun_sports/core/utils/app_logger.dart';
import 'package:sun_sports/features/mini_game/messages/slot_message.dart';

class MiniPokerHttpRepository {
  const MiniPokerHttpRepository();

  static const int pageSize = 6;

  String get _saBase {
    final base = SbHttpManager.instance.apiDomain;
    if (base.isEmpty) return base;
    return base.endsWith('/') ? '${base}sa' : '$base/sa';
  }

  Future<Map<String, dynamic>> _get(String url) async {
    final res = await SbHttpManager.instance.send(
      url,
      json: true,
      authorization: true,
      token: SbHttpManager.instance.userToken,
    );
    if (res is Map<String, dynamic>) return res;
    if (res is Map) return Map<String, dynamic>.from(res);
    throw StateError('Unexpected response: $res');
  }

  Future<MiniPokerPage<MiniPokerHistoryItem>> fetchHistoryChunk({
    required int skip,
    required int limit,
  }) async {
    final gid = SlotGameId.miniPoker.code;
    final url =
        '$_saBase?command=fetchSlotMachineHistory&assetId=1&limit=$limit&skip=$skip&gameId=$gid';
    AppLoggers.api.i('[MiniPoker] fetchHistoryChunk skip=$skip limit=$limit url=$url');
    final doc = await _get(url);
    final data = _asMap(doc['data']);
    final items = _asList(data['items'])
        .whereType<Map>()
        .map((e) => MiniPokerHistoryItem.fromJson(Map<String, dynamic>.from(e)))
        .toList(growable: false);
    AppLoggers.api.i(
      '[GSB-624] fetchHistoryChunk skip=$skip limit=$limit '
      'count=${_asInt(data['count'])} '
      'rows=${items.map((e) => '#${e.sessionId}/b${e.betting}').join(',')}',
    );
    return MiniPokerPage(items: items, count: _asInt(data['count']));
  }

  Future<MiniPokerPage<MiniPokerRankItem>> fetchRank({
    required int page,
  }) async {
    final skip = (page - 1) * pageSize;
    final gid = SlotGameId.miniPoker.code;
    final url =
        '$_saBase?command=fetchTopSlotMachine&gameId=$gid&limit=$pageSize&skip=$skip';
    AppLoggers.api.i('[MiniPoker] fetchRank page=$page url=$url');
    final doc = await _get(url);
    final data = _asMap(doc['data']);
    final items = _asList(data['items'])
        .whereType<Map>()
        .map((e) => MiniPokerRankItem.fromJson(Map<String, dynamic>.from(e)))
        .toList(growable: false);
    return MiniPokerPage(items: items, count: _asInt(data['count']));
  }

  static Map<String, dynamic> _asMap(dynamic v) =>
      v is Map ? Map<String, dynamic>.from(v) : const {};
  static List<dynamic> _asList(dynamic v) => v is List ? v : const [];
  static int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}

class MiniPokerPage<T> {
  final List<T> items;
  final int count;

  const MiniPokerPage({required this.items, required this.count});

  int get maxPages =>
      count <= 0 ? 1 : (count / MiniPokerHttpRepository.pageSize).ceil();
}

class MiniPokerHistoryItem {
  final int sessionId;
  final int betting;
  final int money;
  final int createdTime;
  final List<int> symbols;

  const MiniPokerHistoryItem({
    required this.sessionId,
    required this.betting,
    required this.money,
    required this.createdTime,
    required this.symbols,
  });

  factory MiniPokerHistoryItem.fromJson(Map<String, dynamic> j) {
    return MiniPokerHistoryItem(
      sessionId: MiniPokerHttpRepository._asInt(j['sessionId']),
      betting: MiniPokerHttpRepository._asInt(j['betting']),
      money: MiniPokerHttpRepository._asInt(j['money']),
      createdTime: MiniPokerHttpRepository._asInt(j['createdTime']),
      symbols: MiniPokerHttpRepository._asList(j['symbols'])
          .whereType<num>()
          .map((e) => e.toInt())
          .toList(growable: false),
    );
  }
}

class MiniPokerRankItem {
  final int betting;
  final String displayName;
  final int money;
  final String description;
  final int createdTime;

  const MiniPokerRankItem({
    required this.betting,
    required this.displayName,
    required this.money,
    required this.description,
    required this.createdTime,
  });

  factory MiniPokerRankItem.fromJson(Map<String, dynamic> j) {
    return MiniPokerRankItem(
      betting: MiniPokerHttpRepository._asInt(j['betting']),
      displayName: '${j['displayName'] ?? ''}',
      money: MiniPokerHttpRepository._asInt(j['money']),
      description: '${j['description'] ?? ''}',
      createdTime: MiniPokerHttpRepository._asInt(j['createdTime']),
    );
  }
}
