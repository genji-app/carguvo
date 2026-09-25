import 'package:flutter/material.dart';

import 'package:sun_sports/mini/up_down/widgets/up_down_play_area.dart';

class UpDownLandscapePlayArea extends StatelessWidget {
  final int selectedBetIndex;
  final ValueChanged<int> onSelectBet;

  final bool betEnabled;

  static const double _kSlotHeight = 54;

  static const double _kChipHeight = 32.4;

  static const double _kCardScale = 0.9;

  static const double _kGap = 16;

  const UpDownLandscapePlayArea({
    required this.selectedBetIndex,
    required this.onSelectBet,
    this.betEnabled = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const UpDownASlots(slotHeight: _kSlotHeight),
            const SizedBox(width: _kGap),
            const UpDownCenterCard(scale: _kCardScale, topGap: 0),
            const SizedBox(width: _kGap),
            UpDownUnitColumn(
              selected: selectedBetIndex,
              onSelect: onSelectBet,
              enabled: betEnabled,
              chipHeight: _kChipHeight,
            ),
          ],
        ),
      ),
    );
  }
}
