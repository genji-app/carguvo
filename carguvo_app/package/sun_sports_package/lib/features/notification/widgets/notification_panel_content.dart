import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/notification/widgets/notification_async_body.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class NotificationPanelContent extends StatelessWidget {
  const NotificationPanelContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Thông báo',
                  style: AppTextStyles.headingXSmall(
                    context: context,
                    color: AppColorStyles.contentPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.gray400),
                onPressed: SoundTap.wrap(() => Navigator.of(context).pop()),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.gray700),
        const Expanded(child: NotificationAsyncBody()),
      ],
    );
  }
}
