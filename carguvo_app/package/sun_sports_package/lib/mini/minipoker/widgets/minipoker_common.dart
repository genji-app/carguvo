import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/texts/gradient_text.dart';

const LinearGradient kMinipokerGoldGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFFFFE5B8), Color(0xFFFFB732)],
);

class MinipokerGoldText extends StatelessWidget {
  final String text;

  static const double _maxFontSize = 16;

  const MinipokerGoldText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: GradientText(
        text,
        maxLines: 1,
        gradient: kMinipokerGoldGradient,
        style: GoogleFonts.plusJakartaSans(
          fontSize: _maxFontSize,
          fontWeight: FontWeight.w700,
          height: 20 / 16,
        ),
      ),
    );
  }
}

class MinipokerGoldNumber extends StatelessWidget {
  final String text;

  const MinipokerGoldNumber(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return GradientText(
      text,
      gradient: kMinipokerGoldGradient,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 20 / 14,
      ),
    );
  }
}

class MinipokerPaginationBar extends StatelessWidget {
  final int page;
  final int total;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const MinipokerPaginationBar({
    required this.page,
    required this.total,
    this.onPrev,
    this.onNext,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            _NavButton(icon: Icons.chevron_left_rounded, onTap: onPrev),
            Expanded(
              child: Text(
                '$page/$total',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ),
            _NavButton(icon: Icons.chevron_right_rounded, onTap: onNext),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _NavButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Opacity(
      opacity: enabled ? 1 : 0.35,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: SoundTap.wrap(onTap),
          child: Container(
            width: 40,
            height: 28,
            alignment: Alignment.center,
            child: Icon(icon, size: 22, color: Colors.white.withValues(alpha: 0.85)),
          ),
        ),
      ),
    );
  }
}

class MinipokerRiveSlot extends StatelessWidget {
  final double? width;
  final double? height;
  final String label;
  final BorderRadius borderRadius;

  const MinipokerRiveSlot({
    this.width,
    this.height,
    this.label = 'RIVE',
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: Colors.white.withValues(alpha: 0.02),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          height: 1.2,
          letterSpacing: 0.5,
          color: Colors.white.withValues(alpha: 0.35),
        ),
      ),
    );
  }
}
