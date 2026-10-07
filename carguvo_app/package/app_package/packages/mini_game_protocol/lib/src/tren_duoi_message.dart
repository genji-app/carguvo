import 'package:freezed_annotation/freezed_annotation.dart';

import 'jackpot_data.dart';

part 'tren_duoi_message.freezed.dart';

class UpDownMsg {
  UpDownMsg._();

  static const String plugin = 'updownPlugin';

  static const int infoGame = 1500;
  static const int startGame = 1501;
  static const int startRound = 1502;
  static const int stopGame = 1503;
  static const int updateJar = 1504;

  static const String cmd = 'cmd';
  static const String accountId = 'aid';
  static const String bet = 'b';
  static const String sessionId = 'sid';
  static const String upDown = 'udr';

  static const String jars = 'Js';
  static const String session = 'ss';
  static const String remainingTimeMs = 'rmT';
  static const String cardCode = 'iid';
  static const String credit = 'crd';
  static const String upPayout = 'up';
  static const String downPayout = 'down';
  static const String isGameOver = 'iF';
  static const String isJackpot = 'iJ';
  static const String jackpot = 'J';
  static const String forcedNewGame = 'ng';
  static const String errorMessage = 'mgs';
  static const String errorCode = 'c';

  static const String sessionItems = 'items';
  static const String sessionSid = 'sid';
  static const String sessionCredit = 'crd';
  static const String sessionBet = 'b';
}

class UpDownDir {
  UpDownDir._();
  static const int up = 1;
  static const int down = -1;
}

@freezed
sealed class TrenDuoiMessage with _$TrenDuoiMessage {
  const factory TrenDuoiMessage.infoGame({
    required List<JackpotData> jackpots,
    int? sessionId,
    @Default(-1) int remainingTimeMs,
    @Default(0) int up,
    @Default(0) int down,
    @Default(0) int credit,
    @Default(0) int bet,
    @Default(<int>[]) List<int> history,
    @Default(false) bool hasSession,
  }) = TrenDuoiInfoGame;

  const factory TrenDuoiMessage.startGame({
    String? errorMessage,
    int? cardCode,
    int? credit,
    int? bet,
    int? accountId,
    int? sessionId,
    int? up,
    int? down,
  }) = TrenDuoiStartGame;

  const factory TrenDuoiMessage.startRound({
    required int cardCode,
    required int credit,
    required int bet,
    required int accountId,
    required int sessionId,
    required int up,
    required int down,
    required bool isFree,
    required bool isJackpot,
    required bool nextGame,
    @Default(0) int jackpot,
  }) = TrenDuoiStartRound;

  const factory TrenDuoiMessage.stopGame({required int credit}) =
      TrenDuoiStopGame;

  const factory TrenDuoiMessage.updateJar({required List<JackpotData> jackpots}) =
      TrenDuoiUpdateJar;
}
TrenDuoiMessage parseTrenDuoiMessage(Map<String, dynamic> dict) {
  final cmd = (dict[UpDownMsg.cmd] as num).toInt();
  switch (cmd) {
    case UpDownMsg.infoGame:
      final ss = dict[UpDownMsg.session];
      final session = ss is Map ? ss.cast<String, dynamic>() : null;
      final hasSession = session != null;
      return TrenDuoiMessage.infoGame(
        jackpots: parseJackpotList(dict[UpDownMsg.jars]),
        sessionId: (session?[UpDownMsg.sessionSid] as num?)?.toInt(),
        credit: (session?[UpDownMsg.sessionCredit] as num?)?.toInt() ?? 0,
        bet: (session?[UpDownMsg.sessionBet] as num?)?.toInt() ?? 0,
        history: _parseCardCodes(session?[UpDownMsg.sessionItems]),
        hasSession: hasSession,
        remainingTimeMs:
            (dict[UpDownMsg.remainingTimeMs] as num?)?.toInt() ?? -1,
        up: hasSession ? ((dict[UpDownMsg.upPayout] as num?)?.toInt() ?? 0) : 0,
        down: hasSession
            ? ((dict[UpDownMsg.downPayout] as num?)?.toInt() ?? 0)
            : 0,
      );
    case UpDownMsg.startGame:
      return TrenDuoiMessage.startGame(
        errorMessage: dict[UpDownMsg.errorMessage] as String?,
        cardCode: (dict[UpDownMsg.cardCode] as num?)?.toInt(),
        credit: (dict[UpDownMsg.credit] as num?)?.toInt(),
        bet: (dict[UpDownMsg.bet] as num?)?.toInt(),
        accountId: (dict[UpDownMsg.accountId] as num?)?.toInt(),
        sessionId: (dict[UpDownMsg.sessionId] as num?)?.toInt(),
        up: (dict[UpDownMsg.upPayout] as num?)?.toInt(),
        down: (dict[UpDownMsg.downPayout] as num?)?.toInt(),
      );
    case UpDownMsg.startRound:
      final isJackpot = _asBool(dict[UpDownMsg.isJackpot]) ?? false;
      return TrenDuoiMessage.startRound(
        cardCode: (dict[UpDownMsg.cardCode] as num?)?.toInt() ?? 0,
        credit: (dict[UpDownMsg.credit] as num?)?.toInt() ?? 0,
        bet: (dict[UpDownMsg.bet] as num?)?.toInt() ?? 0,
        accountId: (dict[UpDownMsg.accountId] as num?)?.toInt() ?? 0,
        sessionId: (dict[UpDownMsg.sessionId] as num?)?.toInt() ?? 0,
        up: (dict[UpDownMsg.upPayout] as num?)?.toInt() ?? 0,
        down: (dict[UpDownMsg.downPayout] as num?)?.toInt() ?? 0,
        isFree: _asBool(dict[UpDownMsg.isGameOver]) ?? false,
        isJackpot: isJackpot,
        jackpot:
            isJackpot ? ((dict[UpDownMsg.jackpot] as num?)?.toInt() ?? 0) : 0,
        nextGame: _asBool(dict[UpDownMsg.forcedNewGame]) ?? false,
      );
    case UpDownMsg.stopGame:
      return TrenDuoiMessage.stopGame(
        credit: (dict[UpDownMsg.credit] as num?)?.toInt() ?? 0,
      );
    case UpDownMsg.updateJar:
      return TrenDuoiMessage.updateJar(
        jackpots: parseJackpotList(dict[UpDownMsg.jars]),
      );
    default:
      throw UnimplementedError('Unknown TrenDuoi cmd: $cmd');
  }
}

bool? _asBool(dynamic v) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  return null;
}

List<int> _parseCardCodes(dynamic raw) {
  if (raw is! List) return const [];
  return raw.whereType<num>().map((e) => e.toInt()).toList(growable: false);
}
