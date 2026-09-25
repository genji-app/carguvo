library;

import 'package:flutter/widgets.dart';
import 'package:mini_game_protocol/mini_game_protocol.dart' as mp;

class MiniGamePingManager extends mp.MiniGamePingManager
    with WidgetsBindingObserver {
  static const Duration defaultPingInterval =
      mp.MiniGamePingManager.defaultPingInterval;
  static const Duration defaultResponseTimeout =
      mp.MiniGamePingManager.defaultResponseTimeout;

  MiniGamePingManager({
    required super.send,
    required super.reconnect,
    super.pingInterval,
    super.responseTimeout,
  }) {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      pause();
      return;
    }

    if (state == AppLifecycleState.resumed ||
        state == AppLifecycleState.inactive) {
      resume();
    }
  }

  @override
  void dispose() {
    if (isDisposed) return;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
