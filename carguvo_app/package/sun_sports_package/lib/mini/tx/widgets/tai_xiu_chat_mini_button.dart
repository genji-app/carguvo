import 'package:flutter/material.dart';

import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';

class TaiXiuChatMiniButton extends StatelessWidget {
  const TaiXiuChatMiniButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(
        color: const Color(0xFFFAC515),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 8,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
        decoration: BoxDecoration(
          color: AppColorStyles.backgroundQuaternary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Chat tài xỉu',
              style: AppTextStyles.displayStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColorStyles.contentPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColorStyles.backgroundTertiary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ImageHelper.load(
                path: AppIcons.iconChatMini,
                width: 20,
                height: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
