import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/shared/widgets/texts/gradient_text.dart';
import 'package:sun_sports/mini/up_down/state/up_down_state.dart';
import 'package:sun_sports/mini/up_down/state/up_down_state_provider.dart';
import 'package:sun_sports/mini/up_down/widgets/up_down_common.dart';

class UpDownJackpotBar extends ConsumerWidget {
  const UpDownJackpotBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jackpot = ref.watch(upDownStateProvider.select((s) => s.jackpot));
    return SizedBox(
      height: 26,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              I18n.upDownJackpot,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                height: 1,
                letterSpacing: 1,
                color: const Color(0xFFD8A93E),
              ),
            ),
            const SizedBox(width: 6),
            GradientText(
              upDownMoney(jackpot),
              gradient: kUpDownGoldGradient,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
