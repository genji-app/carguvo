import 'package:flutter/material.dart';

import 'package:sun_sports/core/utils/extensions/image_helper.dart';

import '../volta_colors.dart';

class VoltaTeamLogo extends StatelessWidget {
  const VoltaTeamLogo({required this.url, required this.size, super.key});

  final String? url;

  final double size;

  @override
  Widget build(BuildContext context) {
    final String? value = url;
    if (value == null || value.isEmpty) return _fallback;

    return ImageHelper.getNetworkImage(
      imageUrl: value,
      width: size,
      height: size,
      fit: BoxFit.contain,
      cacheWidth: (size * 2).round(),
      cacheHeight: (size * 2).round(),
      placeholder: _fallback,
      errorWidget: _fallback,
    );
  }

  Widget get _fallback => SizedBox(
    width: size,
    height: size,
    child: Center(
      child: Icon(
        Icons.shield_outlined,
        size: size * 0.68,
        color: VoltaColors.contentPrimary.withAlpha(90),
      ),
    ),
  );
}
