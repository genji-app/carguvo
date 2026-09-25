import 'package:freezed_annotation/freezed_annotation.dart';

part 'tai_xiu_message.freezed.dart';

@freezed
sealed class TaiXiuMessage with _$TaiXiuMessage {
  const factory TaiXiuMessage.subscribeInfo({
    required int sessionId,
    required int gameState,
    required double remainingTimeSec,
    required double timeForBettingSec,
    required double timeForPayingSec,
    required List<dynamic> history,
    required Map<String, dynamic> gameInfo,
    required List<dynamic> chatHistory,
    @Default(0) int availableGold,
    @Default(0) int availableChip,
    @Default(0) int freeBetTimes,
    @Default(0) int freeBetAmount,
    @Default(false) bool enableEvent,
    String? eventMessage,
    String? eventUrl,
  }) = TaiXiuSubscribeInfo;

  const factory TaiXiuMessage.bet({
    required int accountId,
    required int entryId,
    required int thisBet,
    required int totalEntryBet,
    required int totalUsers,
    @Default(0) int availableBalance,
  }) = TaiXiuBet;

  const factory TaiXiuMessage.startGame({required int sessionId}) =
      TaiXiuStartGame;

  const factory TaiXiuMessage.showResult({
    required int d1,
    required int d2,
    required int d3,
  }) = TaiXiuShowResult;

  const factory TaiXiuMessage.calculateResultMoney({
    @Default(0) int gold,
    @Default(0) int chip,
    @Default(0) int goldExchange,
    @Default(0) int chipExchange,
    @Default(0) int availableGold,
    @Default(0) int availableChip,
    @Default(0) int goldRefund,
    @Default(0) int chipRefund,
    @Default(0) int goldBet,
    @Default(0) int chipBet,
    @Default(0) int goldBalanceBet,
    @Default(0) int chipBalanceBet,
  }) = TaiXiuCalculateResultMoney;

  const factory TaiXiuMessage.sessionAnalytic({
    required List<dynamic> betStats,
    required int sessionId,
    int? d1,
    int? d2,
    int? d3,
    int? startTime,
    @Default(false) bool ended,
  }) = TaiXiuSessionAnalytic;

  const factory TaiXiuMessage.updateBetInfo({required List<dynamic> betArr}) =
      TaiXiuUpdateBetInfo;

  const factory TaiXiuMessage.getBetHistory({
    required List<dynamic> items,
    required int accountId,
  }) = TaiXiuGetBetHistory;

  const factory TaiXiuMessage.betFree() = TaiXiuBetFree;

  const factory TaiXiuMessage.chat({required Map<String, dynamic> entry}) =
      TaiXiuChat;
}

TaiXiuMessage parseTaiXiuMessage(Map<String, dynamic> dict) {
  final cmd = _intFrom(dict['cmd']);
  switch (cmd) {
    case 1005:
      final enableEvt = _boolFrom(dict['enableEvent']);
      return TaiXiuMessage.subscribeInfo(
        sessionId: _intFrom(dict['sid']),
        gameState: _intFrom(dict['gS']),
        remainingTimeSec: _millisecondsToSeconds(dict['rmT']),
        timeForBettingSec: _millisecondsToSeconds(dict['tFB']),
        timeForPayingSec: _millisecondsToSeconds(dict['tFP']),
        history: _listFrom(dict['htr']),
        gameInfo: _mapFrom(dict['gi']),
        availableGold: _intFrom(dict['ag']),
        availableChip: _intFrom(dict['ac']),
        freeBetTimes: _intFrom(dict['fbn']),
        freeBetAmount: _intFrom(dict['fba']),
        enableEvent: enableEvt,
        eventMessage: enableEvt ? dict['eventMgs'] as String? : null,
        eventUrl: enableEvt ? dict['eventUrl'] as String? : null,
        chatHistory: _listFrom(dict['cH']),
      );
    case 1000:
      return TaiXiuMessage.bet(
        accountId: _intFrom(dict['aid']),
        entryId: _intFrom(dict['eid']),
        thisBet: _intFrom(dict['tB']),
        totalEntryBet: _intFrom(dict['tEB']),
        totalUsers: _intFrom(dict['tU']),
        availableBalance: _intFrom(dict['ab']),
      );
    case 1002:
      return TaiXiuMessage.startGame(sessionId: _intFrom(dict['sid']));
    case 1003:
      return TaiXiuMessage.showResult(
        d1: _intFrom(dict['d1']),
        d2: _intFrom(dict['d2']),
        d3: _intFrom(dict['d3']),
      );
    case 1004:
      final hasG = dict['G'] != null;
      return TaiXiuMessage.calculateResultMoney(
        gold: hasG ? _intFrom(dict['G']) : 0,
        chip: hasG ? _intFrom(dict['C']) : 0,
        goldExchange: hasG ? _intFrom(dict['GX']) : 0,
        chipExchange: hasG ? _intFrom(dict['CX']) : 0,
        availableGold: hasG ? _intFrom(dict['ag']) : 0,
        availableChip: hasG ? _intFrom(dict['ac']) : 0,
        goldRefund: hasG ? _intFrom(dict['gR']) : 0,
        chipRefund: hasG ? _intFrom(dict['cR']) : 0,
        goldBet: hasG ? _intFrom(dict['gB']) : 0,
        chipBet: hasG ? _intFrom(dict['cB']) : 0,
        goldBalanceBet: _intFrom(dict['gBB']),
        chipBalanceBet: _intFrom(dict['cBB']),
      );
    case 1007:
      return TaiXiuMessage.sessionAnalytic(
        betStats: _listFrom(dict['bs']),
        sessionId: _intFrom(dict['sid']),
        d1: dict['d1'] == null ? null : _intFrom(dict['d1']),
        d2: dict['d2'] == null ? null : _intFrom(dict['d2']),
        d3: dict['d3'] == null ? null : _intFrom(dict['d3']),
        startTime: dict['st'] == null ? null : _intFrom(dict['st']),
        ended: _boolFrom(dict['ended']),
      );
    case 1008:
      return TaiXiuMessage.updateBetInfo(
        betArr: (dict['gi'] as List?) ?? const [],
      );
    case 1009:
      return TaiXiuMessage.getBetHistory(
        items: _listFrom(dict['items']),
        accountId: _intFrom(dict['aid']),
      );
    case 1010:
      return const TaiXiuMessage.betFree();
    case 1011:
      return TaiXiuMessage.chat(entry: Map<String, dynamic>.from(dict));
    default:
      throw UnimplementedError('Unknown TaiXiu cmd: $cmd');
  }
}

int _intFrom(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

bool _boolFrom(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) return value == 'true' || value == '1';
  return false;
}

double _millisecondsToSeconds(dynamic value) {
  if (value is num) return value.toDouble() / 1000;
  if (value is String) return (double.tryParse(value) ?? 0) / 1000;
  return 0;
}

List<dynamic> _listFrom(dynamic value) {
  if (value is List) return value;
  return const [];
}

Map<String, dynamic> _mapFrom(dynamic value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  if (value is List && value.isNotEmpty && value.first is Map) {
    return Map<String, dynamic>.from(value.first as Map);
  }
  return const {};
}

extension TaiXiuShowResultX on TaiXiuShowResult {
  int get total => d1 + d2 + d3;

  bool get isTai => total > 10;
}
