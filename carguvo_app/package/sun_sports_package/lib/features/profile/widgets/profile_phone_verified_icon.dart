import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';

class ProfilePhoneVerifiedIcon extends StatelessWidget {
  const ProfilePhoneVerifiedIcon({super.key, this.size});

  final Size? size;

  @override
  Widget build(BuildContext context) {
    return ImageHelper.load(
      width: size?.width,
      height: size?.height,
      path: AppIcons.iconVerified,
    );
  }
}
