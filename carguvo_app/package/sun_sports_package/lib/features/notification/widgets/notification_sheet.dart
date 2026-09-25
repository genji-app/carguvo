import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/features/notification/widgets/notification_panel_content.dart';
import 'package:sun_sports/features/notification/widgets/notification_panel_root.dart';

class NotificationSheet extends StatelessWidget {
  const NotificationSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.95,
      decoration: const BoxDecoration(
        color: AppColorStyles.backgroundSecondary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: const NotificationPanelRoot(child: NotificationPanelContent()),
    );
  }
}
