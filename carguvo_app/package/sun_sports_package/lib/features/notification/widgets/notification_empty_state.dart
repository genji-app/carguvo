import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';

class NotificationEmptyState extends StatelessWidget {
  const NotificationEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ImageHelper.load(
              path: AppIcons.iconNotificationEmpty,
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 16),
            Text(
              'Không có thông báo nào',
              style: AppTextStyles.labelMedium(
                context: context,
                color: AppColorStyles.contentPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Thông tin cược, sự kiện, hệ thống sẽ hiển thị ở đây',
              style: AppTextStyles.labelSmall(
                context: context,
                color: AppColorStyles.contentSecondary,
              ).copyWith(fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
