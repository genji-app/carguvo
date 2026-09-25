import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:rive/rive.dart' show Fit;

import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_rive.dart';
import 'package:sun_sports/mini/up_down/state/up_down_state.dart';
import 'package:sun_sports/mini/up_down/state/up_down_state_provider.dart';
import 'package:sun_sports/mini/up_down/widgets/up_down_common.dart';
import 'package:sun_sports/mini/up_down/widgets/up_down_rive.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/texts/gradient_text.dart';

class UpDownBetArea extends ConsumerWidget {
  final VoidCallback onNewRound;

  final VoidCallback onPickUp;
  final VoidCallback onPickDown;

  final GlobalKey? cashoutKey;

  const UpDownBetArea({
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
    return Container(
      height: 152,
      width: double.infinity,
      color: AppColorStyles.backgroundQuaternary,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          UpDownCashoutButton(
            key: cashoutKey,
            amount: upDownMoney(credit),
            enabled: canCashout,
            onTap: onNewRound,
          ),
          const SizedBox(height: 12),
          _BetBars(
            up: upDownMoney(up),
            down: upDownMoney(down),
            canUp: canUp,
            canDown: canDown,
            onPickUp: onPickUp,
            onPickDown: onPickDown,
          ),
        ],
      ),
    );
  }
}

class UpDownCashoutButton extends StatelessWidget {
  final String amount;
  final VoidCallback onTap;

  final bool enabled;

  final double width;
  final double height;

  const UpDownCashoutButton({
    required this.amount,
    required this.onTap,
    this.enabled = true,
    this.width = 151,
    this.height = 48,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: SoundTap.wrap(enabled ? onTap : null),
        child: Opacity(
          opacity: enabled ? 1 : 0.4,
          child: Container(
            width: width,
            height: height,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF000000), width: 2),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF3D3C3B), Color(0xFF252423)],
              ),
            ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GradientText(
                amount,
                gradient: kUpDownGoldGradient,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                I18n.upDownCashoutNewRound,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1,
                  color: const Color(0xFFC3C2BC),
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}

class _BetBars extends StatelessWidget {
  final String up;
  final String down;
  final bool canUp;
  final bool canDown;
  final VoidCallback onPickUp;
  final VoidCallback onPickDown;

  const _BetBars({
    required this.up,
    required this.down,
    required this.onPickUp,
    required this.onPickDown,
    this.canUp = true,
    this.canDown = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.5), width: 0.5),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2E2E2E), Color(0xFF151515)],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: UpDownBetBar(
              side: UpDownBetSide.up,
              amount: up,
              available: canUp,
              onTap: onPickUp,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: UpDownBetBar(
              side: UpDownBetSide.down,
              amount: down,
              available: canDown,
              onTap: onPickDown,
            ),
          ),
        ],
      ),
    );
  }
}

enum UpDownBetSide { up, down }

class UpDownBetBar extends StatefulWidget {
  final UpDownBetSide side;
  final String amount;
  final bool available;
  final VoidCallback onTap;

  final double height;

  final double arrowSlot;

  final bool mirrored;

  const UpDownBetBar({
    required this.side,
    required this.amount,
    required this.onTap,
    this.available = true,
    this.height = 56,
    this.arrowSlot = 48,
    this.mirrored = false,
    super.key,
  });

  @override
  State<UpDownBetBar> createState() => _UpDownBetBarState();
}

class _UpDownBetBarState extends State<UpDownBetBar> {
  static const String _kDisabledInput = 'isDisabled';

  UpDownRiveHandle? _rive;

  bool get _isUp => widget.side == UpDownBetSide.up;

  String get _riveName =>
      _isUp ? AppRive.upDownButtonUp : AppRive.upDowButtonDown;

  String get _pressTrigger => _isUp ? 'pressUp' : 'pressDown';

  void _onTap() {
    _rive?.fire(_pressTrigger);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final amountText = Expanded(
      child: Center(
        child: GradientText(
          widget.amount,
          gradient: kUpDownGoldGradient,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
      ),
    );
    Widget background = UpDownRive(
      name: _riveName,
      booleans: {_kDisabledInput: !widget.available},
      fit: Fit.fill,
      onReady: (h) => _rive = h,
    );
    if (widget.mirrored) {
      background = Transform.flip(flipX: true, child: background);
    }
    final arrowOnLeft = _isUp != widget.mirrored;
    return MouseRegion(
      cursor: widget.available
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: SoundTap.wrap(widget.available ? _onTap : null),
        child: SizedBox(
          height: widget.height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              background,
              Row(
                children: arrowOnLeft
                    ? [SizedBox(width: widget.arrowSlot), amountText]
                    : [amountText, SizedBox(width: widget.arrowSlot)],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
