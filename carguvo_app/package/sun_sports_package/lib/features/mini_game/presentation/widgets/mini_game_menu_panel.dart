import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/core/utils/styles/mini_game_icons.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

import '../state/mini_game_countdown_provider.dart';
import 'mini_game_badge_tx_rive.dart';
import 'mini_game_preload_ring.dart';
import 'mini_game_selection.dart';

class MiniGameMenuPanel extends ConsumerWidget {
  final void Function(MiniGameSelection game) onGameSelected;

  final MiniGameSelection? loadingGame;

  const MiniGameMenuPanel({
    required this.onGameSelected,
    this.loadingGame,
    super.key,
  });

  static const double designWidth = 378;
  static const double designHeight = 276;

  static const double _iconSize = 90;
  static const double _gap = 32;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countdownAsync = ref.watch(miniGameCountdownProvider);
    final (taiXiuSec, taiXiuIsTai, taiXiuAwaiting) = countdownAsync.maybeWhen(
      data: (s) => (s.taiXiuSec, s.taiXiuIsTai, s.taiXiuAwaitingResult),
      orElse: () => (null, null, false),
    );

    Widget wrap(MiniGameSelection game, Widget item) {
      final loading = loadingGame;
      final isThis = loading == game;
      return IgnorePointer(
        ignoring: loading != null,
        child: Opacity(
          opacity: loading == null || isThis ? 1.0 : 0.35,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              item,
              if (isThis)
                Positioned.fill(
                  child: MiniGameBundleProgressRing(
                    bundleKey: game.bundleKey,
                    size: _iconSize,
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: designWidth,
      height: designHeight,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF252423),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x1FFFFFFF), width: 0.5),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 40,
            child: Center(
              child: SizedBox(
                width: 170,
                height: 40,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: ImageHelper.load(
                        path: MiniGameIcons.upDownBackgroundTotalMoney,
                        fit: BoxFit.fill,
                      ),
                    ),
                    const Text(
                      'Mini Games',
                      style: TextStyle(
                        color: Color(0xFFFFFEF5),
                        fontSize: 16,
                        height: 20 / 16,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                        shadows: [
                          Shadow(
                            color: Color(0x99000000),
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              wrap(
                MiniGameSelection.taiXiu,
                _GameItem(
                  imageUrl: AppImages.taiXiu,
                  countdownSec: taiXiuSec,
                  resultIsTai: taiXiuIsTai,
                  awaitingResult: taiXiuAwaiting,
                  onTap: () => onGameSelected(MiniGameSelection.taiXiu),
                ),
              ),
              const SizedBox(width: _gap),
              wrap(
                MiniGameSelection.miniPoker,
                _GameItem(
                  imageUrl: AppImages.miniPoker,
                  onTap: () => onGameSelected(MiniGameSelection.miniPoker),
                ),
              ),
              const SizedBox(width: _gap),
              wrap(
                MiniGameSelection.trenDuoi,
                _GameItem(
                  imageUrl: AppImages.trenDuoi,
                  onTap: () => onGameSelected(MiniGameSelection.trenDuoi),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              wrap(
                MiniGameSelection.kimCuong,
                _GameItem(
                  imageUrl: AppImages.kimCuong,
                  onTap: () => onGameSelected(MiniGameSelection.kimCuong),
                ),
              ),
              const SizedBox(width: _gap),
              wrap(
                MiniGameSelection.dragonBall,
                _GameItem(
                  imageUrl: AppImages.dragonBall,
                  onTap: () => onGameSelected(MiniGameSelection.dragonBall),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GameItem extends StatelessWidget {
  final String imageUrl;
  final int? countdownSec;
  final bool? resultIsTai;
  final bool awaitingResult;
  final VoidCallback onTap;

  const _GameItem({
    required this.imageUrl,
    required this.onTap,
    this.countdownSec,
    this.resultIsTai,
    this.awaitingResult = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasRound =
        countdownSec != null || awaitingResult || resultIsTai != null;
    return GestureDetector(
      onTap: SoundTap.wrap(onTap),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: MiniGameMenuPanel._iconSize,
        height: MiniGameMenuPanel._iconSize,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: ImageHelper.load(
                path: imageUrl,
                fit: BoxFit.contain,
              ),
            ),
            if (hasRound)
              Positioned(
                right: 0,
                top: 0,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    MiniGameBadgeTxRive(
                      result: countdownSec != null ? null : resultIsTai,
                      isLoading: awaitingResult,
                      size: 28,
                    ),
                    if (countdownSec != null)
                      _CountTimeText(seconds: countdownSec!),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CountTimeText extends StatelessWidget {
  final int seconds;

  const _CountTimeText({required this.seconds});

  @override
  Widget build(BuildContext context) {
    return Text(
      '$seconds',
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Color(0xFFFFFEF5),
        fontSize: 16,
        height: 1.0,
        leadingDistribution: TextLeadingDistribution.even,
        fontWeight: FontWeight.bold,
        decoration: TextDecoration.none,
        shadows: [
          Shadow(color: Colors.black, blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
    );
  }
}
