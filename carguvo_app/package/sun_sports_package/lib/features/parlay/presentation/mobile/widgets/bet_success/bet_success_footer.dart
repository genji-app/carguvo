import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class BetSuccessFooter extends StatelessWidget {
  final VoidCallback onViewMyBets;

  const BetSuccessFooter({super.key, required this.onViewMyBets});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
    decoration: BoxDecoration(
      color: AppColorStyles.backgroundQuaternary,
      boxShadow: const [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.4),
          blurRadius: 20,
          offset: Offset(0, -8),
        ),
      ],
    ),
    child: _ViewMyBetsButton(onPressed: onViewMyBets),
  );
}

class _ViewMyBetsButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _ViewMyBetsButton({required this.onPressed});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: SoundTap.wrap(onPressed),
    child: Container(
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.yellow700,
        borderRadius: BorderRadius.circular(100),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromRGBO(255, 255, 255, 0.24),
            Color.fromRGBO(255, 255, 255, 0.0),
          ],
          stops: [0.0, 0.5523],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.25),
            blurRadius: 0,
            offset: Offset(0, -1.5),
            blurStyle: BlurStyle.inner,
          ),
        ],
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.yellow700,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromRGBO(255, 255, 255, 0.24),
                  Color.fromRGBO(255, 255, 255, 0.0),
                ],
                stops: [0.0, 0.5523],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: const Color.fromRGBO(255, 255, 255, 0.12),
                width: 1,
              ),
            ),
          ),
          Center(
            child: Text(
              'Xem cược của tôi',
              style: AppTextStyles.labelMedium(
                color: Colors.white,
              ).copyWith(height: 1.5),
            ),
          ),
        ],
      ),
    ),
  );
}
