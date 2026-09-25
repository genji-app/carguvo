import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/utils/styles/mini_game_icons.dart';
import 'package:sun_sports/mini/diamond/state/diamond_state.dart';
import 'package:sun_sports/mini/diamond/state/diamond_state_provider.dart';
import 'package:sun_sports/mini/diamond/widgets/diamond_bet_bar.dart';
import 'package:sun_sports/mini/diamond/widgets/diamond_controls.dart';

const double kDiamondLandscapeControlWidth = 268;

const double _kBetBlockHeight = 136;
const double _kSpinBlockHeight = 116;

const double _kBetButtonHeight = 36;
const double _kSpinSize = 80;
const double _kSideIconSize = 44;

class DiamondLandscapeControlColumn extends ConsumerWidget {
  final VoidCallback? onOpenLines;

  const DiamondLandscapeControlColumn({this.onOpenLines, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (locked, lineCount, selectedBet, fastSpin, spinning, canSpin, autoSpin) =
        ref.watch(
      diamondStateProvider.select(
        (s) => (
          s.busy,
          s.lineCount,
          s.selectedBet,
          s.fastSpin,
          s.spinning,
          s.canSpin,
          s.autoSpin,
        ),
      ),
    );
    final notifier = ref.read(diamondStateProvider.notifier);

    return Column(
      children: [
        SizedBox(
          height: _kBetBlockHeight,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 36, 24, 16),
            child: Column(
              children: [
                DiamondLineCountButton(
                  count: lineCount,
                  height: _kBetButtonHeight,
                  onTap: locked ? null : onOpenLines,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    for (var i = 0; i < kDiamondChips.length; i++) ...[
                      Expanded(
                        child: DiamondChipButton(
                          value: kDiamondChips[i],
                          selected: selectedBet == kDiamondChips[i],
                          height: _kBetButtonHeight,
                          onTap: locked
                              ? null
                              : () => notifier.setBet(kDiamondChips[i]),
                        ),
                      ),
                      if (i < kDiamondChips.length - 1)
                        const SizedBox(width: 12),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: _kSpinBlockHeight,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                DiamondSideButton(
                  iconPath: MiniGameIcons.diamondTurbo,
                  iconPathSelected: MiniGameIcons.diamondTurboSelected,
                  label: I18n.diamondTurbo,
                  active: fastSpin,
                  iconSize: _kSideIconSize,
                  onTap: notifier.toggleFast,
                ),
                DiamondSpinButton(
                  spinning: spinning,
                  enabled: canSpin,
                  size: _kSpinSize,
                  onTap: () => diamondTrySpin(context, ref),
                ),
                DiamondSideButton(
                  iconPath: MiniGameIcons.diamondAuto,
                  iconPathSelected: MiniGameIcons.diamondAutoSelected,
                  label: I18n.diamondAuto,
                  active: autoSpin,
                  iconSize: _kSideIconSize,
                  onTap: notifier.toggleAuto,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
