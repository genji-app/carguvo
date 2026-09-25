import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sun_sports/mini/up_down/state/up_down_state.dart';
import 'package:sun_sports/mini/up_down/widgets/up_down_common.dart';
import 'package:sun_sports/mini/widgets/mini_jackpot_overlay.dart';
import 'package:sun_sports/shared/widgets/texts/gradient_text.dart';

class UpDownNoHuView extends StatelessWidget {
  final int amount;

  final VoidCallback onClose;

  const UpDownNoHuView({
    required this.amount,
    required this.onClose,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MiniJackpotOverlay(
      amount: amount,
      onClose: onClose,
      borderRadius: BorderRadius.zero,
      amountBuilder: (_, value) => GradientText(
        upDownMoney(value),
        gradient: kUpDownGoldGradient,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 34,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}
