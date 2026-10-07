import '../socket/enums.dart';
import '../socket/mini_game_socket_client.dart';
import 'slot_message.dart';
import 'up_down_message_keys.dart';

abstract class _BaseSender {
  final MiniGameSocketClient _socket;
  _BaseSender(this._socket);

  void _send(String plugin, Map<String, Object?> dict) {
    _socket.send([
      MessageRequest.zonePluginType.code,
      'MiniGame',
      plugin,
      dict,
    ]);
  }
}

class MiniGameLobbySender extends _BaseSender {
  MiniGameLobbySender(super.socket);

  void subscribeJackpot() => _send('lobbyPlugin', {'cmd': 10001});
}

class TrenDuoiSender extends _BaseSender {
  TrenDuoiSender(super.socket);

  void subscribe() =>
      _send(UpDownMsg.plugin, {UpDownMsg.cmd: UpDownMsg.infoGame});

  void startGame({required int bet, int accountId = 1}) =>
      _send(UpDownMsg.plugin, {
        UpDownMsg.cmd: UpDownMsg.startGame,
        UpDownMsg.accountId: accountId,
        UpDownMsg.bet: bet,
      });

  void startRound({
    required int bet,
    required int sessionId,
    required int upDown,
    int accountId = 1,
  }) => _send(UpDownMsg.plugin, {
    UpDownMsg.cmd: UpDownMsg.startRound,
    UpDownMsg.accountId: accountId,
    UpDownMsg.bet: bet,
    UpDownMsg.sessionId: sessionId,
    UpDownMsg.upDown: upDown,
  });

  void stopGame({required int sessionId}) => _send(UpDownMsg.plugin, {
    UpDownMsg.cmd: UpDownMsg.stopGame,
    UpDownMsg.sessionId: sessionId,
  });
}

class TaiXiuSender extends _BaseSender {
  TaiXiuSender(super.socket);

  void subscribe() => _send('taixiuPlugin', {'cmd': 1005});

  void bet({
    required int entry,
    required int amount,
    required int sessionId,
    int accountId = 1,
  }) => _send('taixiuPlugin', {
    'cmd': 1000,
    'aid': accountId,
    'eid': entry,
    'b': amount,
    'sid': sessionId,
  });

  void requestSessionAnalytic({required int sessionId, int accountId = 1}) =>
      _send('taixiuPlugin', {'cmd': 1007, 'sid': sessionId, 'aid': accountId});

  void requestBetHistory({int accountId = 1, int limit = 500, int skip = 0}) =>
      _send('taixiuPlugin', {
        'cmd': 1009,
        'L': limit,
        'S': skip,
        'aid': accountId,
      });

  void sendChat({required String message}) =>
      _send('taixiuPlugin', {'cmd': 1011, 'mgs': message});
}

class SlotSender extends _BaseSender {
  final SlotGameId game;
  SlotSender(super.socket, {required this.game});

  Map<String, Object?> _withGid(Map<String, Object?> base) => {
    ...base,
    'gid': game.code,
  };

  void subscribe() => _send('slotMachinePlugin', _withGid({'cmd': 1300}));

  void unsubscribe() => _send('slotMachinePlugin', _withGid({'cmd': 1301}));

  void spin({required int bet, int accountId = 1, List<dynamic>? lines}) =>
      _send(
        'slotMachinePlugin',
        _withGid({
          'cmd': 1302,
          'aid': accountId,
          'b': bet,
          if (lines != null) 'ls': lines,
        }),
      );

  void autoSpin({required int bet, int accountId = 1, List<dynamic>? lines}) =>
      _send(
        'slotMachinePlugin',
        _withGid({
          'cmd': 1303,
          'aid': accountId,
          'asb': bet,
          if (lines != null) 'asls': lines,
        }),
      );

  void cancelAutoSpin() => _send('slotMachinePlugin', _withGid({'cmd': 1305}));

  void spinFree({int accountId = 1}) =>
      _send('slotMachinePlugin', _withGid({'cmd': 1308, 'aid': accountId}));
}

class MiniPokerSender extends SlotSender {
  MiniPokerSender(super.socket) : super(game: SlotGameId.miniPoker);
}

class KimCuongSender extends SlotSender {
  KimCuongSender(super.socket) : super(game: SlotGameId.kimCuong);
}

class DragonBallSender extends SlotSender {
  DragonBallSender(super.socket) : super(game: SlotGameId.dragonBall);
}
