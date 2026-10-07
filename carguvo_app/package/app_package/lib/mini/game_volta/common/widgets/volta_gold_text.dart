import 'package:flutter/material.dart';

import '../volta_gradients.dart';

class VoltaGoldText extends StatelessWidget {
  const VoltaGoldText(
    this.text, {
    required this.style,
    this.textAlign,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.shadows,
    this.gradient,
    super.key,
  });

  final String text;
  final TextStyle style;
  final TextAlign? textAlign;
  final int maxLines;
  final TextOverflow overflow;
  final List<Shadow>? shadows;

  final LinearGradient? gradient;

  @override
  Widget build(BuildContext context) {
    final Widget gradientText = ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (gradient ?? VoltaGradients.goldText).createShader,
      child: Text(
        text,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        style: style.copyWith(color: Colors.white),
      ),
    );

    if (shadows == null || shadows!.isEmpty) return gradientText;

    return Stack(
      children: <Widget>[
        Text(
          text,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          style: style.copyWith(
            color: const Color(0x00000000),
            shadows: shadows,
          ),
        ),
        gradientText,
      ],
    );
  }
}
