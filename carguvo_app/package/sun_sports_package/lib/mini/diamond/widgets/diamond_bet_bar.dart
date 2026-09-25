import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/mini/diamond/state/diamond_state.dart';
import 'package:sun_sports/mini/diamond/state/diamond_state_provider.dart';
import 'package:sun_sports/mini/diamond/widgets/diamond_common.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/texts/gradient_text.dart';

class DiamondBetBar extends ConsumerWidget {
  final VoidCallback? onOpenLines;

  const DiamondBetBar({this.onOpenLines, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (locked, lineCount, selectedBet) = ref.watch(
      diamondStateProvider.select(
        (s) => (s.busy, s.lineCount, s.selectedBet),
      ),
    );
    final notifier = ref.read(diamondStateProvider.notifier);

    return Row(
      children: [
        DiamondLineCountButton(
          count: lineCount,
          onTap: locked ? null : onOpenLines,
        ),
        const SizedBox(width: 12),
        const _VerticalDivider(),
        const SizedBox(width: 12),
        for (var i = 0; i < kDiamondChips.length; i++) ...[
          Expanded(
            child: DiamondChipButton(
              value: kDiamondChips[i],
              selected: selectedBet == kDiamondChips[i],
              onTap: locked ? null : () => notifier.setBet(kDiamondChips[i]),
            ),
          ),
          if (i < kDiamondChips.length - 1) const SizedBox(width: 12),
        ],
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 33,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x00FFFFFF), Color(0x24FFFFFF), Color(0x00FFFFFF)],
          ),
        ),
      );
}

class DiamondLineCountButton extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;

  final double height;

  const DiamondLineCountButton({
    required this.count,
    this.onTap,
    this.height = 40,
    super.key,
  });

  @override
  Widget build(BuildContext context) => _BetButton(
        label: I18n.diamondLinesCount(count),
        fontSize: 14,
        height: height,
        onTap: onTap,
        bgGradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF544645), Color(0xFF3A2026)],
        ),
        textGradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE0ECFF), Color(0xFFFF2D5B)],
        ),
        insetColor: const Color(0x66ECE5FF),
      );
}

class DiamondChipButton extends StatelessWidget {
  final int value;
  final bool selected;
  final VoidCallback? onTap;

  final double height;

  const DiamondChipButton({
    required this.value,
    required this.selected,
    this.onTap,
    this.height = 40,
    super.key,
  });

  String get _label => value >= 1000 ? '${value ~/ 1000}K' : '$value';

  @override
  Widget build(BuildContext context) => _BetButton(
        label: _label,
        fontSize: 16,
        height: height,
        onTap: onTap,
        bgGradient: selected
            ? const LinearGradient(
                begin: Alignment(0, -1.99),
                end: Alignment(0, 1),
                colors: [Colors.transparent, Color(0xFF7D5100)],
              )
            : const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF3D3C3B), Color(0xFF252423)],
              ),
        textGradient: kDiamondGoldGradient,
        insetColor: const Color(0x66FFFFFF),
      );
}

class _BetButton extends StatelessWidget {
  final String label;
  final double fontSize;
  final LinearGradient bgGradient;
  final LinearGradient textGradient;
  final Color insetColor;
  final VoidCallback? onTap;
  final double height;

  const _BetButton({
    required this.label,
    required this.fontSize,
    required this.bgGradient,
    required this.textGradient,
    required this.insetColor,
    this.onTap,
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) {
    return SoundTap(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1,
        child: Container(
          height: height,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            gradient: bgGradient,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14FFFFFF),
                offset: Offset(0, -1),
                blurRadius: 0.5,
              ),
              BoxShadow(
                color: Color(0x3D000000),
                offset: Offset(0, 3),
                blurRadius: 4,
              ),
              BoxShadow(
                color: Color(0x33000000),
                offset: Offset(0, 2),
                blurRadius: 8,
              ),
            ],
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: GradientText(
              label,
              gradient: textGradient,
              maxLines: 1,
              overflow: TextOverflow.visible,
              style: GoogleFonts.plusJakartaSans(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                height: (fontSize == 14 ? 20 : 24) / fontSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
