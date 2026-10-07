import 'package:freezed_annotation/freezed_annotation.dart';

import 'jackpot_data.dart';

part 'slot_message.freezed.dart';

enum SlotGameId {
  miniPoker(199),
  kimCuong(202),
  dragonBall(219);

  final int code;
  const SlotGameId(this.code);

  static SlotGameId? fromCode(int code) {
    for (final v in SlotGameId.values) {
      if (v.code == code) return v;
    }
    return null;
  }
}

@freezed
sealed class SlotMessage with _$SlotMessage {
  const factory SlotMessage.subscribeJackpot({
    required SlotGameId game,
    required List<JackpotData> jackpots,
    @Default(false) bool autoSpin,
    @Default(0) int autoSpinBetting,
    @Default(1) int autoSpinAid,
    List<dynamic>? lines,
  }) = SlotSubscribeJackpot;

  const factory SlotMessage.spinResult({
    required SlotGameId game,
    String? errorMessage,
    int? accountId,
    @Default(0) int moneyExchange,
    @Default(<dynamic>[]) List<dynamic> symbols,
    @Default(<dynamic>[]) List<dynamic> rewards,
    @Default(false) bool wonJackpot,
    int? sessionId,
    int? freeSpins,
  }) = SlotSpinResult;

  const factory SlotMessage.updateJackpot({
    required SlotGameId game,
    required List<JackpotData> jackpots,
  }) = SlotUpdateJackpot;
}

SlotMessage parseSlotMessage(Map<String, dynamic> dict, SlotGameId game) {
  final cmd = (dict['cmd'] as num).toInt();
  switch (cmd) {
    case 1300:
      return SlotMessage.subscribeJackpot(
        game: game,
        jackpots: parseJackpotList(dict['Js']),
        autoSpin: _asBool(dict['as']) ?? false,
        autoSpinBetting: (dict['asb'] as num?)?.toInt() ?? 0,
        autoSpinAid: (dict['asaid'] as num?)?.toInt() ?? 1,
        lines: dict['ls'] as List?,
      );
    case 1302:
      {
        final rewards = (dict['wls'] as List?) ?? const [];
        final wonJackpot = _asBool(dict['iJ']) == true ||
            rewards.any((r) => r is Map && _asBool(r['iJ']) == true);
        return SlotMessage.spinResult(
          game: game,
          errorMessage: dict['mgs'] as String?,
          accountId: (dict['aid'] as num?)?.toInt(),
          moneyExchange: (dict['mX'] as num?)?.toInt() ?? 0,
          symbols: (dict['sbs'] as List?) ?? const [],
          rewards: rewards,
          wonJackpot: wonJackpot,
          sessionId: (dict['sid'] as num?)?.toInt(),
          freeSpins: (dict['fss'] as num?)?.toInt(),
        );
      }
    case 1304:
      return SlotMessage.updateJackpot(
        game: game,
        jackpots: parseJackpotList(dict['Js']),
      );
    default:
      throw UnimplementedError('Unknown Slot cmd: $cmd (game=$game)');
  }
}

bool? _asBool(dynamic v) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  return null;
}
