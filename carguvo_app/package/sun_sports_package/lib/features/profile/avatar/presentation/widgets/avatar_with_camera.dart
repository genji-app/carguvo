import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/shared/widgets/avatar/avatar.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class AvatarWithCamera extends StatelessWidget {
  const AvatarWithCamera({
    super.key,
    required this.avatarUrl,
    this.avatarSize = 80,
    this.cameraSize = 28,
    this.onPressed,
  });

  final String? avatarUrl;
  final double avatarSize;
  final double cameraSize;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final overflow = cameraSize / 2;
    final stackSize = avatarSize + overflow;

    return SizedBox(
      width: stackSize,
      height: stackSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ProfileAvatar.url(
            avatarUrl,
            size: Size.square(avatarSize),
            onPressed: onPressed,
          ),
          PositionedDirectional(
            end: 10,
            bottom: 10,
            child: GestureDetector(
              onTap: SoundTap.wrap(onPressed),
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: cameraSize,
                height: cameraSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.4),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(6),
                child: ImageHelper.load(
                  path: AppIcons.iconCamera,
                  width: 15,
                  height: 15,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
