import 'package:flutter/material.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';

class VerificationDescription extends StatelessWidget {
  const VerificationDescription({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      I18n.msgAccountVerificationDescription,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyles.paragraphSmall(
        color: AppColorStyles.contentSecondary,
      ),
    );
  }
}
