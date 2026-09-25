import 'package:flutter/material.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'info_message.dart';

class BetSlipBlank extends StatelessWidget {
  const BetSlipBlank({super.key});

  @override
  Widget build(BuildContext context) {
    return InfoMessage(
      primaryMessage: const Text(I18n.msgEmptyBettingSlip),
      secondaryMessage: const Text(I18n.msgStartBettingNow),
      image: SizedBox.square(
        dimension: 160,
        child: ImageHelper.load(
          path: AppImages.imgBetTicket,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
