import 'package:flutter/material.dart';

import 'package:sun_sports/core/env/app_env.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';

class UpDownLoading extends StatelessWidget {
  final double size;

  final Color background;

  const UpDownLoading({
    this.size = 72,
    this.background = Colors.transparent,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: background,
      alignment: Alignment.center,
      child: ImageHelper.load(
        path: AppEnv.loadingGifUrl,
        width: size,
        height: size,
        fit: BoxFit.contain,
        placeholder: _fallback(),
        errorWidget: _fallback(),
      ),
    );
  }

  Widget _fallback() => SizedBox(
        width: size,
        height: size,
        child: const Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation(Color(0xFFFFB732)),
            ),
          ),
        ),
      );
}
