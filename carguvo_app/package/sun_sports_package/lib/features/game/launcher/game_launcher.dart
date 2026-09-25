import 'dart:async' show unawaited;

import 'package:provider_game_manager/provider_game_manager.dart';
// ignore: depend_on_referenced_packages
import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/utils/extensions/log_helper.dart';
import 'package:sun_sports/features/game/cocos/cocos_game_controller.dart';
import 'package:sun_sports/features/game/cocos/cocos_game_providers.dart';
import 'package:sun_sports/features/game/cocos/cocos_log.dart';
import 'package:sun_sports/features/game/player/providers/asset_wipe_provider.dart';
import 'package:sun_sports/features/game/player/view/game_player_screen.dart';
import 'package:sun_sports/features/mini_game/presentation/mini_game_casino_link.dart';
import 'package:sun_sports/features/mini_game/presentation/mini_game_visibility_provider.dart';
import 'package:sun_sports/mini/game_volta/volta/volta_page.dart';
import 'package:sun_sports/providers/auth_provider.dart';
import 'package:sun_sports/shared/widgets/dialogs/dialog_login_required.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';

import 'package:game_foundation/game_foundation.dart'
    show GameLauncherState, GameLauncherStatus;
export 'package:game_foundation/game_foundation.dart'
    show GameLauncherState, GameLauncherStatus;

final gameLauncherProvider =
    StateNotifierProvider<GameLauncher, GameLauncherState>(
      (ref) => GameLauncher(ref),
    );

class GameLauncher extends StateNotifier<GameLauncherState> with LoggerMixin {
  GameLauncher(this.ref) : super(const GameLauncherState());

  final Ref ref;

  @override
  String get logTag => 'GameLauncher';

  static const _cooldown = Duration(seconds: 2);
  final Map<String, DateTime> _lastSessionEndedAt = {};
  final Map<String, bool> _isSessionActive = {};

  bool canLaunchGame(String providerId) {
    if (_isSessionActive[providerId] == true) {
      return false;
    }

    final lastEndedAt = _lastSessionEndedAt[providerId];
    if (lastEndedAt != null) {
      final elapsed = clock.now().difference(lastEndedAt);
      if (elapsed < _cooldown) {
        return false;
      }
    }

    return true;
  }

  Duration remainingCooldown(String providerId) {
    final lastEndedAt = _lastSessionEndedAt[providerId];
    if (lastEndedAt == null) return Duration.zero;
    final elapsed = clock.now().difference(lastEndedAt);
    if (elapsed >= _cooldown) return Duration.zero;
    return _cooldown - elapsed;
  }

  void onSessionStarted(String providerId) {
    _isSessionActive[providerId] = true;
    _lastSessionEndedAt.remove(providerId);
  }

  bool get _isNativeMobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);

  void launch(
    BuildContext context,
    LobbyGame game, {
    bool showToastIfCooldown = false,
    int? serverId,
    int? roomId,
    String? roomPassword,
    Map<String, String>? extraQueryParams,
  }) {
    logInfo(
      'launch: game=${game.gameCode}, serverId=$serverId, roomId=$roomId, roomPassword=${roomPassword?.isNotEmpty == true ? "***" : "none"}',
    );

    if (!ref.read(isAuthenticatedProvider)) {
      DialogLoginRequired.show(context);
      return;
    }

    if (isVoltaGameCode(game.gameCode)) {
      unawaited(VoltaPage.open(context));
      return;
    }

    final miniSelection = miniGameSelectionForGameCode(game.gameCode);
    if (miniSelection != null) {
      ref.read(requestOpenMiniGameProvider.notifier).state = miniSelection;
      return;
    }

    if (!_checkCocosDownloadBusy(context, game)) return;

    if (!_checkGameStatus(context, game)) return;

    if (!_checkSessionCooldown(context, game, showToastIfCooldown)) return;

    final bundle = game.gameBundle;
    if (_isNativeMobile && bundle != null && bundle.isNotEmpty) {
      _launchNativeCocos(
        context,
        game,
        bundle,
        serverId: serverId,
        roomId: roomId,
        roomPassword: roomPassword,
        extraQueryParams: extraQueryParams,
      );
      return;
    }

    _openWebViewPlayer(
      context,
      game,
      serverId: serverId,
      roomId: roomId,
      roomPassword: roomPassword,
      extraQueryParams: extraQueryParams,
    );
  }

  void _openWebViewPlayer(
    BuildContext context,
    LobbyGame game, {
    int? serverId,
    int? roomId,
    String? roomPassword,
    Map<String, String>? extraQueryParams,
  }) {
    logInfo(
      '_openWebViewPlayer: game=${game.gameCode}, serverId=$serverId, roomId=$roomId',
    );

    ref.read(miniGameVisibilityProvider.notifier).hide();

    final assetWipe = ref.read(assetWipeControllerProvider);
    if (assetWipe.shouldWipeFor(game)) {
      unawaited(assetWipe.suspendForGame());
    }

    state = GameLauncherState(
      activeGame: game,
      status: GameLauncherStatus.active,
    );
    onSessionStarted(game.providerId);
    Navigator.of(context).push(
      GamePlayerScreen.route(
        game: game,
        serverId: serverId,
        roomId: roomId,
        roomPassword: roomPassword,
        extraQueryParams: extraQueryParams,
      ),
    );
  }

  Future<void> _launchNativeCocos(
    BuildContext context,
    LobbyGame game,
    String bundle, {
    int? serverId,
    int? roomId,
    String? roomPassword,
    Map<String, String>? extraQueryParams,
  }) async {
    cocosLog(
      'click',
      'user click "${game.gameName}" (bundle=$bundle, id=${game.gameId}) '
          '→ luồng native cocos',
    );
    final nativeLauncher = ref.read(nativeGameLauncherProvider);

    if (!await nativeLauncher.isLauncherAvailable()) {
      cocosLog(
        'fallback',
        'host native chưa có channel launcher → mở WebView (game=$bundle)',
      );
      if (context.mounted) {
        _openWebViewPlayer(
          context,
          game,
          serverId: serverId,
          roomId: roomId,
          roomPassword: roomPassword,
          extraQueryParams: extraQueryParams,
        );
      }
      return;
    }

    cocosLog('download', 'bắt đầu tải background: $bundle');
    unawaited(
      ref
          .read(cocosGameControllerProvider.notifier)
          .downloadGame(game, xxteaKey: '6noSqb84JAwJnih1'),
    );
  }

  bool _checkCocosDownloadBusy(BuildContext context, LobbyGame game) {
    if (!_isNativeMobile) return true;

    final cocosState = ref.read(cocosGameControllerProvider);
    if (!cocosState.isBusy) return true;

    final bundle = game.gameBundle;
    if (bundle != null && bundle == cocosState.gameName) {
      cocosLog('guard', 'click lại game đang tải "$bundle" → bỏ qua');
      return false;
    }

    final downloadingName = cocosState.game?.gameName ?? cocosState.gameName;
    cocosLog(
      'guard',
      'đang tải "$downloadingName" → chặn click "${game.gameName}", '
          'show toast',
    );
    AppToast.show(
      context,
      type: AppToastType.error,
      message: 'Bạn đang tải game $downloadingName. Xin hãy chờ tải xong !',
    );
    return false;
  }

  bool _checkGameStatus(BuildContext context, LobbyGame game) {
    final gameStatus = game.status;
    if (gameStatus.isPlayable) return true;

    final message = switch (gameStatus) {
      SunGameStatus.maintenance =>
        'Game đang bảo trì, vui lòng thử lại sau nhé',
      SunGameStatus.comingSoon => 'Game sắp ra mắt, hãy đón chờ nhé',
      _ => 'Game hiện chưa khả dụng.',
    };
    AppToast.showGeneric(context, message: message);
    return false;
  }

  bool _checkSessionCooldown(
    BuildContext context,
    LobbyGame game,
    bool showToastIfCooldown,
  ) {
    if (!showToastIfCooldown || !game.requiresSessionGuard) return true;

    if (!canLaunchGame(game.providerId)) {
      final remaining = remainingCooldown(game.providerId).inSeconds;
      AppToast.showError(
        context,
        message: 'Vui lòng chờ $remaining giây trước khi mở game mới',
      );
      return false;
    }
    return true;
  }

  void finish() {
    final game = state.activeGame;

    if (game != null && game.requiresSessionGuard) {
      _isSessionActive[game.providerId] = false;
      _lastSessionEndedAt[game.providerId] = clock.now();
    }

    state = const GameLauncherState(status: GameLauncherStatus.idle);
  }
}
