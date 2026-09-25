import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/mini_game/presentation/mini_game_floating_overlay.dart'
    show miniGameSocketEverAuthedProvider;
import 'package:sun_sports/features/mini_game/presentation/state/mini_game_countdown_provider.dart';
import 'package:sun_sports/providers/auth_provider.dart';

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

    final Widget inner;
    if (sec != null) {
      inner = _label('$sec', 10);
    } else if (isTai != null) {
      inner = _label(isTai ? 'Tài' : 'Xỉu', 9);
    } else {
      inner = const SizedBox(
        width: 12,
        height: 12,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
          backgroundColor: Color(0x4DFFFFFF),
        ),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: ImageHelper.load(
              path: AppIcons.iconNavMiniGameCounter,
              fit: BoxFit.contain,
            ),
          ),
          inner,
        ],
      ),
    );
  }

  Widget _label(String text, double fontSize) => Text(
    text,
    textAlign: TextAlign.center,
    style: AppTextStyles.labelXXSmall(color: Colors.white).copyWith(
      fontSize: fontSize,
      height: 1,
      shadows: const [
        Shadow(offset: Offset(0, 1), blurRadius: 2, color: Colors.black),
      ],
    ),
  );
}
