import 'package:flutter/material.dart';
import 'package:app_package/core/utils/extensions/image_helper.dart';
import 'package:app_package/core/utils/styles/app_icons.dart';

class SCoinIcon extends StatelessWidget {
  final double size;

  const SCoinIcon({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return ImageHelper.load(
      path: AppIcons.iconCurrencyUnit,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
