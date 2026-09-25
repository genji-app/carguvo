import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/profile/withdraw/models/withdraw_payment_method.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class WithdrawPaymentMethodCard extends StatelessWidget {
  final WithdrawPaymentMethod method;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const WithdrawPaymentMethodCard({
    super.key,
    required this.method,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      onTap: SoundTap.wrap(onTap),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: isSelected
            ? BoxDecoration(
                color: AppColorStyles.backgroundTertiary,
                border: const GradientBoxBorder(
                  width: 0.7,
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Color(0xFFFFD791),
                      Color(0x00FFD791),
                    ],
                  ),
                ),
                borderRadius: BorderRadius.circular(12),
              )
            : BoxDecoration(
                color: AppColorStyles.backgroundTertiary,
                borderRadius: BorderRadius.circular(12),
              ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            if (isSelected)
              Positioned.fill(
                child: ImageHelper.load(
                  path: AppImages.activatedglow,
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: _getPaymentMethodIcon(),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: AppTextStyles.paragraphXSmall(
                      color: isSelected
                          ? const Color(0xFFF9DBAF)
                          : AppColors.gray25,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );

  String _getPaymentMethodIconPath() {
    switch (method) {
      case WithdrawPaymentMethod.bank:
        return AppIcons.icPaymentBank;
      case WithdrawPaymentMethod.scratchCard:
        return AppIcons.icPaymentScratchCard;
      case WithdrawPaymentMethod.crypto:
        return AppIcons.icPaymentCrypto;
    }
  }

  Widget _getPaymentMethodIcon() {
    const iconSize = 36.0;
    return ImageHelper.load(
      path: _getPaymentMethodIconPath(),
      width: iconSize,
      height: iconSize,
    );
  }
}
