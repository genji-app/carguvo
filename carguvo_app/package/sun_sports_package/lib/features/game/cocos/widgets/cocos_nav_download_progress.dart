import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/features/game/cocos/cocos_game_controller.dart';

class CocosNavDownloadProgress extends ConsumerWidget {
  const CocosNavDownloadProgress({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(
      cocosGameControllerProvider.select(
        (s) => s.isDownloading ? s.progress : null,
      ),
    );

    if (progress == null) return const SizedBox.shrink();

    return SizedBox(
      width: 32,
      height: 3,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(1000),
        child: ColoredBox(
          color: Colors.white.withValues(alpha: 0.16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: progress.clamp(0.0, 1.0) <= 0
                  ? 0.0001
                  : progress.clamp(0.0, 1.0),
              heightFactor: 1,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF644202), AppColors.yellow600],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
