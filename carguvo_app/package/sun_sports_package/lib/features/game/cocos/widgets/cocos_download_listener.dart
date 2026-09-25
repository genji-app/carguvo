import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sun_sports/features/game/cocos/cocos_game_controller.dart';
import 'package:sun_sports/features/game/cocos/cocos_game_download_state.dart';
import 'package:sun_sports/features/game/cocos/cocos_game_launcher_ui.dart';
import 'package:sun_sports/features/game/cocos/cocos_log.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';

class CocosDownloadListener extends ConsumerWidget {
  const CocosDownloadListener({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<CocosGameDownloadState>(cocosGameControllerProvider, (
      prev,
      next,
    ) {
      if (prev?.status == next.status) return;

      switch (next.status) {
        case CocosGameStatus.readyToPlay:
          unawaited(_onReadyToPlay(context, ref, next));
          break;
        case CocosGameStatus.error:
          _onError(context, ref, prev, next);
          break;
        case CocosGameStatus.idle:
        case CocosGameStatus.preparing:
        case CocosGameStatus.launching:
        case CocosGameStatus.active:
          break;
      }
    });

    return child;
  }

  Future<void> _onReadyToPlay(
    BuildContext context,
    WidgetRef ref,
    CocosGameDownloadState state,
  ) async {
    final game = state.game;
    if (game == null) {
      cocosLog('popup', 'readyToPlay nhưng thiếu LobbyGame → reset');
      ref.read(cocosGameControllerProvider.notifier).reset();
      return;
    }

    cocosLog('popup', 'show "Hoàn tất tải game" — ${game.gameName}');
    final play = await CocosDownloadCompleteDialog.show(context, game);

    if (!context.mounted) {
      cocosLog('popup', 'listener unmount sau khi đóng popup → bỏ qua');
      return;
    }

    final controller = ref.read(cocosGameControllerProvider.notifier);
    if (play == true) {
      cocosLog('play-now', 'user chọn "Chơi ngay" → launchPrepared');
      await controller.launchPrepared();
    } else {
      cocosLog('later', 'user chọn "Để sau"/đóng popup');
      controller.dismiss();
    }
  }

  void _onError(
    BuildContext context,
    WidgetRef ref,
    CocosGameDownloadState? prev,
    CocosGameDownloadState next,
  ) {
    final message = prev?.status == CocosGameStatus.launching
        ? 'Không thể mở game, vui lòng thử lại'
        : 'Tải game thất bại, vui lòng thử lại';

    cocosLog(
      'error',
      'show toast "$message" (từ ${prev?.status.name} → error, '
          'chi tiết: ${next.errorMessage})',
    );
    if (context.mounted) {
      AppToast.showError(context, message: message);
    }
    ref.read(cocosGameControllerProvider.notifier).reset();
  }
}
