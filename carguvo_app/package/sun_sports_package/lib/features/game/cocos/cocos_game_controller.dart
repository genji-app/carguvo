import 'package:provider_game_manager/provider_game_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_downloader/game_downloader.dart';
import 'package:game_launcher/game_launcher.dart';

import 'package:sun_sports/core/services/auth/token_manager.dart';
import 'package:sun_sports/core/services/network/sb_http_manager.dart';
import 'package:sun_sports/providers/auth_provider.dart';

import 'cocos_game_download_state.dart';
import 'cocos_game_providers.dart';
import 'cocos_log.dart';

final cocosGameControllerProvider =
    StateNotifierProvider<CocosGameController, CocosGameDownloadState>((ref) {
      return CocosGameController(ref);
    });

class CocosGameController extends StateNotifier<CocosGameDownloadState> {
  CocosGameController(this.ref) : super(const CocosGameDownloadState());

  final Ref ref;

  String _xxteaKey = '';

  Future<bool> downloadGame(LobbyGame game, {String xxteaKey = ''}) async {
    if (state.isBusy) {
      cocosLog(
        'download',
        'bỏ qua — đang bận (status=${state.status.name}, '
            'game=${state.gameName})',
      );
      return false;
    }

    final bundle = game.gameBundle;
    if (bundle == null || bundle.isEmpty) {
      cocosLog('download', 'bỏ qua — game "${game.gameName}" không có bundle');
      return false;
    }

    final downloader = ref.read(gameDownloaderProvider);
    _xxteaKey = xxteaKey;

    state = CocosGameDownloadState(
      status: CocosGameStatus.preparing,
      gameName: bundle,
      game: game,
    );

    cocosLog('download', '▶ prepareGame: $bundle (game=${game.gameName})');
    try {
      String? gamePath;
      DownloadPhase? lastPhase;
      var lastLoggedPct = -1;
      await for (final p in downloader.prepareGame(bundle)) {
        if (!mounted) {
          cocosLog('download', 'controller disposed giữa chừng → dừng');
          return false;
        }
        state = state.copyWith(
          status: CocosGameStatus.preparing,
          phase: p.phase,
          progress: p.progress,
        );

        final pct = (p.progress * 100).clamp(0, 100).toInt();
        if (p.phase != lastPhase) {
          lastPhase = p.phase;
          lastLoggedPct = pct;
          cocosLog('progress', '$bundle · phase=${p.phase.name} $pct%');
        } else if (pct >= lastLoggedPct + 25) {
          lastLoggedPct = pct;
          cocosLog('progress', '$bundle · ${p.phase.name} $pct%');
        }

        if (p.phase == DownloadPhase.done) gamePath = p.gamePath;
      }

      if (gamePath == null || gamePath.isEmpty) {
        throw const UnexpectedException('Không nhận được gamePath sau khi tải');
      }

      if (!mounted) return false;
      cocosLog(
        'ready',
        '✓ tải + giải nén xong: $bundle → chờ user xác nhận '
            '(gamePath=$gamePath)',
      );

      state = state.copyWith(
        status: CocosGameStatus.readyToPlay,
        gamePath: gamePath,
        progress: 1,
      );
      return true;
    } on GameDownloaderException catch (e) {
      cocosLog('error', '✗ download $bundle: ${e.message}');
      if (mounted) {
        state = state.copyWith(
          status: CocosGameStatus.error,
          errorMessage: e.message,
        );
      }
      return false;
    } catch (e) {
      cocosLog('error', '✗ download $bundle (unexpected): $e');
      if (mounted) {
        state = state.copyWith(
          status: CocosGameStatus.error,
          errorMessage: e.toString(),
        );
      }
      return false;
    }
  }

  Future<GameLaunchResult?> launchPrepared() async {
    final game = state.game;
    final gamePath = state.gamePath;
    if (state.status != CocosGameStatus.readyToPlay ||
        game == null ||
        gamePath == null ||
        gamePath.isEmpty) {
      cocosLog(
        'launch',
        'bỏ qua — state không hợp lệ (status=${state.status.name}, '
            'game=${game?.gameName}, gamePath=$gamePath)',
      );
      return null;
    }

    state = state.copyWith(status: CocosGameStatus.launching);
    cocosLog(
      'launch',
      '→ launchGame: ${state.gameName} (gameId=${game.gameId}, '
          'isLandscape=${game.isLandscape})',
    );

    try {
      final creds = await _resolveCredentials();
      cocosLog(
        'launch',
        'credentials resolved (token=${creds.userToken.isNotEmpty}, '
            'user=${creds.userName.isNotEmpty})',
      );

      final result = await ref
          .read(nativeGameLauncherProvider)
          .launch(
            GameLaunchConfig(
              gamePath: gamePath,
              gameId: game.gameId?.toString() ?? state.gameName ?? '',
              xxteaKey: _xxteaKey,
              isLandscape: game.isLandscape,
              credentials: creds,
            ),
          );

      if (!mounted) return result;
      if (result is GameLaunchFailure) {
        cocosLog('error', '✗ launch FAIL [${result.code}]: ${result.message}');
        state = state.copyWith(
          status: CocosGameStatus.error,
          errorMessage: result.message,
        );
      } else {
        cocosLog('active', '✅ launch OK: ${state.gameName}');
        state = state.copyWith(status: CocosGameStatus.active);
      }
      return result;
    } catch (e) {
      cocosLog('error', '✗ launch ${state.gameName} (unexpected): $e');
      if (mounted) {
        state = state.copyWith(
          status: CocosGameStatus.error,
          errorMessage: e.toString(),
        );
      }
      return null;
    }
  }

  void dismiss() {
    if (state.status == CocosGameStatus.readyToPlay) {
      cocosLog('later', '${state.gameName} → idle (bundle giữ trên máy)');
      state = const CocosGameDownloadState();
    }
  }

  Future<VersionCheckResult> checkVersion(String gameName) {
    return ref.read(gameDownloaderProvider).checkVersion(gameName);
  }

  Future<bool> isGameReady(String gameName) {
    return ref.read(gameDownloaderProvider).isGameReady(gameName);
  }

  Future<void> deleteGame(String gameName) {
    return ref.read(gameDownloaderProvider).deleteGame(gameName);
  }

  void reset() {
    cocosLog('reset', 'state → idle (từ ${state.status.name})');
    state = const CocosGameDownloadState();
  }

  Future<GameCredentials> _resolveCredentials() async {
    final http = SbHttpManager.instance;

    var accessToken = await TokenManager.getAccessToken() ?? '';
    if (accessToken.isEmpty) accessToken = http.userToken;

    final refreshToken = await TokenManager.getRefreshToken() ?? '';

    var userName = ref.read(authProvider).user?.custLogin ?? '';
    if (userName.isEmpty) {
      userName = http.user['cust_login'] as String? ?? '';
    }
    if (userName.isEmpty) {
      final (savedUser, _) = await UserManager.getSavedCredentials();
      userName = savedUser ?? '';
    }

    return GameCredentials(
      userToken: accessToken,
      refreshToken: refreshToken,
      userName: userName,
      userPassword: '',
    );
  }
}
