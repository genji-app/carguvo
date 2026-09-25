import 'package:flutter/material.dart';

import 'package:sun_sports/mini/diamond/state/diamond_state.dart';
import 'package:sun_sports/mini/diamond/widgets/diamond_common.dart';
import 'package:sun_sports/mini/widgets/mini_jackpot_overlay.dart';

class DiamondNoHu extends StatelessWidget {
  final int amount;
  final VoidCallback onClose;
  final bool auto;
  final BorderRadius borderRadius;

  const DiamondNoHu({
    required this.amount,
    required this.onClose,
    this.auto = false,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MiniJackpotOverlay(
      amount: amount,
      onClose: onClose,
      auto: auto,
      borderRadius: borderRadius,
      amountBuilder: (_, value) =>
          DiamondGoldText(diamondMoney(value), fontSize: 40),
    );
  }
}
