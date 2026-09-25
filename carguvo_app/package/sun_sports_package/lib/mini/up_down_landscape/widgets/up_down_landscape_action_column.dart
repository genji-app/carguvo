import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/mini/up_down/state/up_down_state.dart';
import 'package:sun_sports/mini/up_down/state/up_down_state_provider.dart';
import 'package:sun_sports/mini/up_down/widgets/up_down_bet_area.dart';
import 'package:sun_sports/mini/up_down/widgets/up_down_common.dart';
import 'package:sun_sports/mini/up_down/widgets/up_down_start_area.dart';

const double kUpDownLandscapeActionWidth = 208;

const double _kButtonWidth = 160;

const double _kButtonHeight = 48;

class UpDownLandscapeStartColumn extends StatelessWidget {
  final VoidCallback onStart;

  final bool Function() canStart;

  const UpDownLandscapeStartColumn({
    required this.onStart,
    required this.canStart,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      height: 20 / 14,
      color: Colors.white,
    );
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          UpDownStartButton(onTap: onStart, canStart: canStart),
          SizedBox(
            height: 34,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(I18n.upDownTap, style: textStyle),
                  const SizedBox(width: 8),
                  const UpDownSwapIcon(size: 17),
                  const SizedBox(width: 8),
                  Text(I18n.upDownToStart, style: textStyle),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UpDownLandscapeBetColumn extends ConsumerWidget {
  final VoidCallback onNewRound;

  final VoidCallback onPickUp;
  final VoidCallback onPickDown;

  final GlobalKey? cashoutKey;

  const UpDownLandscapeBetColumn({
    required this.onNewRound,
    required this.onPickUp,
    required this.onPickDown,
    this.cashoutKey,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final credit = ref.watch(upDownStateProvider.select((s) => s.credit));
    final up = ref.watch(upDownStateProvider.select((s) => s.upPayout));
    final down = ref.watch(upDownStateProvider.select((s) => s.downPayout));
    final canUp = ref.watch(upDownStateProvider.select((s) => s.canBetUp));
    final canDown = ref.watch(upDownStateProvider.select((s) => s.canBetDown));
    final canCashout =
        ref.watch(upDownStateProvider.select((s) => s.canCashout));
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: _kButtonWidth,
            child: UpDownBetBar(
              side: UpDownBetSide.up,
              amount: upDownMoney(up),
              available: canUp,
              onTap: onPickUp,
              height: _kButtonHeight,
              mirrored: true,
            ),
          ),
          const SizedBox(height: 16),
          UpDownCashoutButton(
            key: cashoutKey,
            amount: upDownMoney(credit),
            enabled: canCashout,
            onTap: onNewRound,
            width: _kButtonWidth,
            height: _kButtonHeight,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: _kButtonWidth,
            child: UpDownBetBar(
              side: UpDownBetSide.down,
              amount: upDownMoney(down),
              available: canDown,
              onTap: onPickDown,
              height: _kButtonHeight,
            ),
          ),
        ],
      ),
    );
  }
}
