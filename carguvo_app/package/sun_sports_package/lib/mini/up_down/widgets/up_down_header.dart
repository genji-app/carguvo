import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/mini_game_icons.dart';
import 'package:sun_sports/mini/up_down/state/up_down_state.dart';
import 'package:sun_sports/mini/up_down/state/up_down_state_provider.dart';
import 'package:sun_sports/mini/up_down/widgets/up_down_common.dart';
import 'package:sun_sports/mini/widgets/jackpot_count_animation.dart';

class UpDownHeader extends StatelessWidget {
  final VoidCallback? onClose;
  final VoidCallback? onHelp;
  final VoidCallback? onRank;
  final VoidCallback? onHistory;

  const UpDownHeader({
    this.onClose,
    this.onHelp,
    this.onRank,
    this.onHistory,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            UpDownIconButton(
              iconPath: MiniGameIcons.upDownTrophy,
              onTap: onRank,
            ),
            const SizedBox(width: 8),
            UpDownIconButton(
              iconPath: MiniGameIcons.upDownClock,
              onTap: onHistory,
            ),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SizedBox(
                    width: 200,
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
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 8,
                          ),
                          child: UpDownJackpotAmount(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            UpDownIconButton(
              iconPath: MiniGameIcons.upDownHelp,
              onTap: onHelp,
            ),
            const SizedBox(width: 8),
            UpDownIconButton(
              iconPath: MiniGameIcons.upDownClose,
              onTap: onClose,
            ),
          ],
        ),
      ),
    );
  }
}

class UpDownJackpotAmount extends ConsumerStatefulWidget {
  const UpDownJackpotAmount({super.key});

  @override
  ConsumerState<UpDownJackpotAmount> createState() =>
      _UpDownJackpotAmountState();
}

class _UpDownJackpotAmountState extends ConsumerState<UpDownJackpotAmount> {
  @override
  Widget build(BuildContext context) {
    final jackpot = ref.watch(upDownStateProvider.select((s) => s.jackpot));
    final amount = JackpotCountAnimation(
      jackpot: jackpot,
      money: upDownMoney,
      gold: (String t) => UpDownGoldText(t),
    );
    if (!kDebugMode) return amount;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () =>
          ref.read(upDownStateProvider.notifier).debugShowJackpot(),
      child: amount,
    );
  }
}
