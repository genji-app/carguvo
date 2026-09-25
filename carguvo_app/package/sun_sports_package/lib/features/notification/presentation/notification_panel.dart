import 'package:flutter/material.dart';
import 'package:sun_sports/features/notification/widgets/notification_dialog_body.dart';
import 'package:sun_sports/features/notification/widgets/notification_sheet.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';

class NotificationPanel {
  static Future<void> show(
    BuildContext context, {
    BuildContext? anchorContext,
  }) {
    final isMobile = ResponsiveBuilder.isMobile(context);
    if (isMobile) {
      return showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        isDismissible: true,
        enableDrag: true,
        builder: (ctx) => const NotificationSheet(),
      );
    }
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (ctx) => const NotificationDialogBody(anchored: false),
    );
  }
}
