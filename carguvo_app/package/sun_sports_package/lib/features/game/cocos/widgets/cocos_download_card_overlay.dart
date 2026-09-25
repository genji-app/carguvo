import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/game/cocos/cocos_game_controller.dart';
import 'package:sun_sports/shared/widgets/sun_progress_bar.dart';

class CocosDownloadCardOverlay extends ConsumerWidget {
  const CocosDownloadCardOverlay({
    required this.gameBundle,
    required this.borderRadius,
    super.key,
  });

  final String gameBundle;

  final double borderRadius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(
      cocosGameControllerProvider.select(
        (s) => s.isDownloading && s.gameName == gameBundle ? s.progress : null,
      ),
    );

    if (progress == null) return const SizedBox.shrink();

    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SunProgressBar(progress: progress),
              const Gap(8),
              Center(
                child: Text(
                  'Đang tải...',
                  style: AppTextStyles.labelXSmall(
                    color: AppColorStyles.contentPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
