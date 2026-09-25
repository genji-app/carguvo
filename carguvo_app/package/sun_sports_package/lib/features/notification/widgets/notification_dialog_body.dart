import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/features/notification/widgets/notification_panel_content.dart';
import 'package:sun_sports/features/notification/widgets/notification_panel_root.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class NotificationDialogBody extends ConsumerStatefulWidget {
  const NotificationDialogBody({required this.anchored, super.key});

  final bool anchored;

  @override
  ConsumerState<NotificationDialogBody> createState() =>
      _NotificationDialogBodyState();
}

class _NotificationDialogBodyState
    extends ConsumerState<NotificationDialogBody> {
  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: AppColorStyles.backgroundSecondary,
      border: Border.all(color: AppColors.gray700),
    );
    if (widget.anchored) {
      return DecoratedBox(
        decoration: decoration,
        child: const NotificationPanelRoot(child: NotificationPanelContent()),
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: SoundTap.wrap(() => Navigator.of(context).pop()),
          ),
        ),
        Positioned(
          top: 30,
          right: 30,
          child: Container(
            width: 420,
            height: 673,
            decoration: decoration.copyWith(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const NotificationPanelRoot(
              child: NotificationPanelContent(),
            ),
          ),
        ),
      ],
    );
  }
}
