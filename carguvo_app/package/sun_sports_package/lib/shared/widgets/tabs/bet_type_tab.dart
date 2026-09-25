import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class BetTypeTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const BetTypeTab({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: SoundTap.wrap(onTap),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.textStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFAAA49B),
            ),
          ),
        ),
      ),
    );
  }
}
