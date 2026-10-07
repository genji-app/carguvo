import 'package:flutter/material.dart';

class GradientText extends StatelessWidget {
  const GradientText(
    this.text, {
    super.key,
    this.style,
    this.gradient = gold,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  static const LinearGradient gold = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFE5B8), Color(0xFFFFB732)],
  );

  final String text;

  final TextStyle? style;

  final LinearGradient gradient;

  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) => ShaderMask(
    blendMode: BlendMode.srcIn,
    shaderCallback: gradient.createShader,
    child: Text(
      text,
      style: (style ?? const TextStyle()).copyWith(color: Colors.white),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    ),
  );
}
