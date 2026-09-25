import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart' as rive;

import 'package:sun_sports/features/mini_game/presentation/state/dragon_ball_state_provider.dart';
import 'package:sun_sports/mini/dragon_ball/widgets/dragon_ball_reels_rive.dart';
import 'package:sun_sports/mini/dragon_ball/widgets/dragon_ball_symbols.dart';
import 'package:sun_sports/mini/dragon_ball/widgets/dragon_ball_win_banner.dart';

const double kDragonBallPlayAreaHeight = 240;

class DragonBallPlayArea extends StatelessWidget {
  final double? height;

  final EdgeInsets padding;

  const DragonBallPlayArea({
    this.height = kDragonBallPlayAreaHeight,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 6),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding, child: const _ReelView());
    if (height == null) return content;
    return SizedBox(height: height, child: content);
  }
}

class _ReelView extends ConsumerWidget {
  const _ReelView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spinStartToken = ref.watch(
      dragonBallStateProvider.select((s) => s.spinStartToken),
    );
    final resultToken = ref.watch(
      dragonBallStateProvider.select((s) => s.resultToken),
    );
    final winAnimToken = ref.watch(
      dragonBallStateProvider.select((s) => s.winAnimToken),
    );
    final winBannerToken = ref.watch(
      dragonBallStateProvider.select((s) => s.winBannerToken),
    );
    final jackpotToken = ref.watch(
      dragonBallStateProvider.select((s) => s.jackpotToken),
    );
    final turbo = ref.watch(dragonBallStateProvider.select((s) => s.turbo));
    final isSpinning = ref.watch(
      dragonBallStateProvider.select((s) => s.isSpinning),
    );
    final st = ref.read(dragonBallStateProvider);
    final notifier = ref.read(dragonBallStateProvider.notifier);

    final lineRows = st.winLineRows;

    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        DragonBallWinLineOverlay(lineRows: lineRows),
        DragonBallReelsRive(
          entrySymbols: st.boardSymbols,
          resultSymbols: st.boardSymbols,
          winCells: st.winCells,
          dimAll: st.winDimAll,
          winToken: winAnimToken,
          jackpotToken: jackpotToken,
          turbo: turbo,
          spinStartToken: spinStartToken,
          resultToken: resultToken,
          roundInProgress: isSpinning,
          onRoundDone: notifier.onRoundDone,
          fit: rive.Fit.contain,
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: -16,
          child: Center(
            child: DragonBallWinBanner(
              winToken: winBannerToken,
              amount: st.lastWin,
              label: st.wonJackpot
                  ? 'NỔ HŨ!'
                  : st.bigWin
                  ? 'BIG WIN!'
                  : null,
              turbo: turbo,
            ),
          ),
        ),
      ],
    );
  }
}
