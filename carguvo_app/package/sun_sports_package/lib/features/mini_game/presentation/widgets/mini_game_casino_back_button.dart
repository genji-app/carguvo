import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class MiniGameCasinoBackButton extends StatelessWidget {
  static const double size = 40;

  final VoidCallback onTap;

  const MiniGameCasinoBackButton({required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: SoundTap.wrap(onTap),
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppColors.orange300,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.reply_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
