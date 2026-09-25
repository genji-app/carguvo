import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/texts/gradient_text.dart';

const LinearGradient kMiniBetGoldGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFFFFE5B8), Color(0xFFFFB732)],
);

class MiniBetUnitItem extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double width;
  final double height;

  const MiniBetUnitItem({
    required this.label,
    required this.selected,
    required this.onTap,
    this.width = 56,
    this.height = 40,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: SoundTap.wrap(onTap),
        child: Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF000000), width: 2),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: selected
                  ? const [Color(0x00000000), Color(0xFF7D5100)]
                  : const [Color(0xFF3D3C3B), Color(0xFF252423)],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x3D000000),
                blurRadius: 4,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: GradientText(
            label,
            gradient: kMiniBetGoldGradient,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 20 / 14,
            ),
          ),
        ),
      ),
    );
  }
}
