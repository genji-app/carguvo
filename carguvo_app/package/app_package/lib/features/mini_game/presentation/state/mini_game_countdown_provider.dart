import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_game_countdown_core/mini_game_countdown_core.dart'
    as countdown;

import '../../messages/mini_game_message_streams.dart';
import '../../messages/tai_xiu_message.dart';
import 'tai_xiu_state_provider.dart';

typedef MiniGameCountdownState = countdown.TaiXiuCountdownState;

final miniGameCountdownProvider =
    StreamProvider<MiniGameCountdownState>((ref) {
  final controller = StreamController<MiniGameCountdownState>.broadcast();

  final c = countdown.TaiXiuCountdownController(
    onStateChanged: (s) => controller.add(s),
  );

  ref.onDispose(() {
    c.dispose();
    controller.close();
  });

  ref.listen(taiXiuMessageStreamProvider, (prev, next) {
    next.when(
      data: (msg) {
        if (msg is TaiXiuSubscribeInfo) {
          c.onSubscribeInfo(msg);
        } else if (msg is TaiXiuStartGame) {
          c.onStartGame(msg);
        } else if (msg is TaiXiuShowResult) {
          c.onShowResult(msg);
        }
      },
      loading: () {},
      error: (_, __) {},
    );
  });

  ref.listen(taiXiuNanBowlOpenedProvider, (prev, next) {
    if (next == true) {
      c.onBowlOpened();
    }
  });

  final timer = Timer.periodic(const Duration(seconds: 1), (_) => c.onTick());
  ref.onDispose(() => timer.cancel());

  return controller.stream;
});
