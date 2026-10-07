import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app_package/features/mini_game/presentation/mini_game_floating_overlay.dart'
    show miniGameSocketEverAuthedProvider;
import 'package:app_package/features/mini_game/socket/mini_game_socket_providers.dart';
import 'package:app_package/features/mini_game/socket/mini_game_socket_state.dart';
import 'package:app_package/providers/auth_provider.dart';

enum MiniGameNavConn {
  guest,

  connecting,

  failed,

  ready,
}

enum MiniGameNavTip { hidden, connecting, connected, failed }

final miniGameNavFailedProvider = StateProvider<bool>((ref) => false);

final miniGameNavTipProvider = StateProvider<MiniGameNavTip>(
  (ref) => MiniGameNavTip.hidden,
);

final miniGameNavConnProvider = Provider<MiniGameNavConn>((ref) {
  if (!ref.watch(isAuthenticatedProvider)) return MiniGameNavConn.guest;
  final authedNow =
      ref.watch(miniGameSocketStateProvider).valueOrNull is SocketAuthenticated;
  if (ref.watch(miniGameSocketEverAuthedProvider) || authedNow) {
    return MiniGameNavConn.ready;
  }
  if (ref.watch(miniGameNavFailedProvider)) return MiniGameNavConn.failed;
  return MiniGameNavConn.connecting;
});
