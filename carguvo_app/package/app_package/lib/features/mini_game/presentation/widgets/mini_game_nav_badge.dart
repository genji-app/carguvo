import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app_package/core/utils/styles/app_text_styles.dart';
import 'package:app_package/features/mini_game/presentation/mini_game_floating_overlay.dart'
    show miniGameSocketEverAuthedProvider;
import 'package:app_package/features/mini_game/presentation/state/mini_game_countdown_provider.dart';
import 'package:app_package/features/mini_game/presentation/state/mini_game_nav_status.dart';
import 'package:app_package/features/mini_game/presentation/widgets/mini_game_badge_tx_rive.dart';
import 'package:app_package/features/mini_game/presentation/widgets/mini_game_status_rive.dart';
import 'package:app_package/providers/auth_provider.dart';

class MiniGameNavIndicator extends ConsumerWidget {
  const MiniGameNavIndicator({super.key});

  static const double dotSize = 12;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conn = ref.watch(miniGameNavConnProvider);
    switch (conn) {
      case MiniGameNavConn.ready:
        return const MiniGameNavBadge();
      case MiniGameNavConn.guest:
        return const SizedBox.shrink();
      case MiniGameNavConn.connecting:
      case MiniGameNavConn.failed:
        return SizedBox.square(
          dimension: MiniGameNavBadge.size,
          child: Center(
            child: MiniGameStatusRive(
              size: dotSize,
              disconnected: conn == MiniGameNavConn.failed,
            ),
          ),
        );
    }
  }
}

class MiniGameNavBadge extends ConsumerWidget {
  const MiniGameNavBadge({super.key});

  static const double size = 24;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final available =
        ref.watch(isAuthenticatedProvider) &&
        ref.watch(miniGameSocketEverAuthedProvider);
    if (!available) return const SizedBox.shrink();

    final state = ref.watch(miniGameCountdownProvider).valueOrNull;
    final sec = state?.taiXiuSec;
    final isTai = state?.taiXiuIsTai;

    return SizedBox.square(
      dimension: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          MiniGameBadgeTxRive(
            size: size,
            result: sec != null ? null : isTai,
            isLoading: sec == null && isTai == null,
            showFallback: false,
          ),
          if (sec != null) _countText('$sec'),
        ],
      ),
    );
  }

  Widget _countText(String text) => Text(
    text,
    textAlign: TextAlign.center,
    style: AppTextStyles.labelXXSmall(color: Colors.white).copyWith(
      fontSize: 10,
      height: 1,
      decoration: TextDecoration.none,
      shadows: const [
        Shadow(offset: Offset(0, 1), blurRadius: 2, color: Colors.black),
      ],
    ),
  );
}
