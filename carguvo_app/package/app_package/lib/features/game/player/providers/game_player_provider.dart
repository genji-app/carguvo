import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_package/features/game/game.dart';
import 'package:app_package/features/game/player/providers/asset_wipe_provider.dart';
import 'package:app_package/features/mini_game/presentation/mini_game_casino_link.dart';
import 'package:app_package/features/mini_game/presentation/mini_game_visibility_provider.dart';
import 'package:app_package/providers/user_provider/user_provider.dart';

final gamePlayerProvider = StateNotifierProvider.autoDispose
    .family<GamePlayerNotifier, GamePlayerState, LobbyGame>((ref, game) {
      final manager = ref.read(providerGameManagerProvider);
      final userNotifier = ref.read(userProvider.notifier);
      final gameLauncher = ref.read(gameLauncherProvider.notifier);

      ref.onDispose(() {
        ref.read(gameLauncherProvider.notifier).finish();
        ref.read(casinoBackButtonVisibleProvider.notifier).state = false;
        ref.read(casinoGameOpenProvider.notifier).state = false;
        ref.read(casinoGameBodyLevelProvider.notifier).state = false;
        ref.read(miniGameVisibilityProvider.notifier).show();

        ref.read(assetWipeControllerProvider).onGamePlayerDisposed();
      });

      // ignore: unawaited_futures
      Future<void>.microtask(() => userNotifier.refreshBalanceThrottled());

      return GamePlayerNotifier(
        game: game,
        manager: manager,
        gameLauncher: gameLauncher,
        assetReloader: ref.read(assetWipeControllerProvider),
        onRefreshBalance: userNotifier.refreshBalance,
        strictOrientationApply: game.isSunGame,
        bypassCooldownWait: true,
        finishLoadDelay:
            game.loadStopDebounce ?? const Duration(milliseconds: 555),
      );
    });
