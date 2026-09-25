import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/payment_method.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class DepositPaymentMethodCard extends StatelessWidget {
  final PaymentMethod method;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const DepositPaymentMethodCard({
    super.key,
    required this.method,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const double cardRadius = 12;
    final borderRadius = BorderRadius.circular(cardRadius);

    return ClipRRect(
      borderRadius: borderRadius,
      child: InkWell(
        onTap: SoundTap.wrap(onTap),
        borderRadius: borderRadius,
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
                  borderRadius: borderRadius,
                )
              : BoxDecoration(
                  color: AppColorStyles.backgroundTertiary,
                  borderRadius: borderRadius,
                ),
          child: Stack(
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
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
  }

  String _getPaymentMethodIconPath() {
    debugPrint('_getPaymentMethodIconPath $method');
    switch (method) {
      case PaymentMethod.codepay:
        return AppIcons.icPaymentCodepay;
      case PaymentMethod.bank:
        return AppIcons.icPaymentBank;
      case PaymentMethod.eWallet:
        return AppIcons.icPaymentMomo;
      case PaymentMethod.crypto:
        return AppIcons.icPaymentCrypto;
      case PaymentMethod.scratchCard:
        return AppIcons.icPaymentScratchCard;
      case PaymentMethod.giftcode:
        return AppIcons.icPaymentGiftcode;
    }
  }

  Widget _getPaymentMethodIcon() {
    const iconSize = 36.0;

    return ImageHelper.load(
      path: _getPaymentMethodIconPath(),
      width: iconSize,
      height: iconSize,
      fit: BoxFit.contain,
    );
  }
}
