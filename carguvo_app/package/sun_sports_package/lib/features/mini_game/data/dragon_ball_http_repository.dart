import 'package:sun_sports/core/services/network/sb_http_manager.dart';
import 'package:sun_sports/core/utils/app_logger.dart';
import 'package:sun_sports/features/mini_game/messages/slot_message.dart';

class DragonBallHttpRepository {
  const DragonBallHttpRepository();

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

  Future<DragonBallPage<DragonBallHistoryItem>> fetchHistory({
    required int page,
  }) async {
    final skip = (page - 1) * pageSize;
    final gid = SlotGameId.dragonBall.code;
    final url =
        '$_saBase?command=fetchSlotMachineHistory&assetId=1&limit=$pageSize&skip=$skip&gameId=$gid';
    AppLoggers.api.i('[DragonBall] fetchHistory page=$page url=$url');
    final doc = await _get(url);
    final data = _asMap(doc['data']);
    final items = _asList(data['items'])
        .whereType<Map>()
        .map((e) =>
            DragonBallHistoryItem.fromJson(Map<String, dynamic>.from(e)))
        .toList(growable: false);
    return DragonBallPage(items: items, count: _asInt(data['count']));
  }

  Future<DragonBallPage<DragonBallRankItem>> fetchRank({
    required int page,
  }) async {
    final skip = (page - 1) * pageSize;
    final gid = SlotGameId.dragonBall.code;
    final url =
        '$_saBase?command=fetchTopSlotMachine&gameId=$gid&limit=$pageSize&skip=$skip';
    AppLoggers.api.i('[DragonBall] fetchRank page=$page url=$url');
    final doc = await _get(url);
    final data = _asMap(doc['data']);
    final items = _asList(data['items'])
        .whereType<Map>()
        .map((e) => DragonBallRankItem.fromJson(Map<String, dynamic>.from(e)))
        .toList(growable: false);
    return DragonBallPage(items: items, count: _asInt(data['count']));
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

class DragonBallPage<T> {
  final List<T> items;
  final int count;

  const DragonBallPage({required this.items, required this.count});

  int get maxPages =>
      count <= 0 ? 1 : (count / DragonBallHttpRepository.pageSize).ceil();
}

class DragonBallHistoryItem {
  final int sessionId;

  final int betting;

  final int money;

  final int totalBet;

  final int numLines;

  final int createdTime;

  final List<int> symbols;

  final List<int> payoutLineIds;

  const DragonBallHistoryItem({
    required this.sessionId,
    required this.betting,
    required this.money,
    required this.totalBet,
    required this.numLines,
    required this.createdTime,
    required this.symbols,
    required this.payoutLineIds,
  });

  int get wonLines => payoutLineIds.length;

  factory DragonBallHistoryItem.fromJson(Map<String, dynamic> j) {
    return DragonBallHistoryItem(
      sessionId: DragonBallHttpRepository._asInt(j['sessionId']),
      betting: DragonBallHttpRepository._asInt(j['betting']),
      money: DragonBallHttpRepository._asInt(j['money']),
      totalBet: DragonBallHttpRepository._asInt(j['totalBet']),
      numLines: DragonBallHttpRepository._asInt(j['numLines']),
      createdTime: DragonBallHttpRepository._asInt(j['createdTime']),
      symbols: DragonBallHttpRepository._asList(j['symbols'])
          .whereType<num>()
          .map((e) => e.toInt())
          .toList(growable: false),
      payoutLineIds: DragonBallHttpRepository._asList(j['payoutLines'])
          .whereType<Map>()
          .map((e) => DragonBallHttpRepository._asInt(e['id']))
          .toList(growable: false),
    );
  }
}

class DragonBallRankItem {
  final int betting;
  final String displayName;
  final int money;
  final String description;
  final int createdTime;

  const DragonBallRankItem({
    required this.betting,
    required this.displayName,
    required this.money,
    required this.description,
    required this.createdTime,
  });

  factory DragonBallRankItem.fromJson(Map<String, dynamic> j) {
    return DragonBallRankItem(
      betting: DragonBallHttpRepository._asInt(j['betting']),
      displayName: '${j['displayName'] ?? ''}',
      money: DragonBallHttpRepository._asInt(j['money']),
      description: '${j['description'] ?? ''}',
      createdTime: DragonBallHttpRepository._asInt(j['createdTime']),
    );
  }
}
