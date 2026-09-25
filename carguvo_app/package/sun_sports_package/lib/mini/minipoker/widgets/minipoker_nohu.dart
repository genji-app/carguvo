import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sun_sports/core/utils/money_formatter.dart';
import 'package:sun_sports/mini/widgets/mini_jackpot_overlay.dart';

class MinipokerNoHu extends StatelessWidget {
  final int amount;

  final VoidCallback onClose;

  final bool auto;

  const MinipokerNoHu({
    required this.amount,
    required this.onClose,
    this.auto = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MiniJackpotOverlay(
      amount: amount,
      onClose: onClose,
      auto: auto,
      borderRadius: BorderRadius.zero,
      amountBuilder: (_, value) => Text(
        MoneyFormatter.formatWithCommas(value),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 34,
          fontWeight: FontWeight.w800,
          height: 1,
          color: const Color(0xFFFFD24A),
          letterSpacing: 1,
          shadows: const [
            Shadow(color: Color(0xFF7A3B00), blurRadius: 2),
            Shadow(color: Color(0xCC000000), blurRadius: 8),
          ],
        ),
      ),
    );
  }
}
