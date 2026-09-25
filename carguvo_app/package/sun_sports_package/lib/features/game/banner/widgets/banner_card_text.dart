import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';

class BannerCardText extends StatelessWidget {
  const BannerCardText({
    required this.title,
    required this.subtitle,
    required this.titleColor,
    required this.isMobile,
    super.key,
  });

  final String title;
  final String subtitle;
  final Color titleColor;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    TextStyle style(double fontSize, double lineHeight) =>
        GoogleFonts.plusJakartaSans(
          fontSize: fontSize,
          height: lineHeight / fontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: isMobile ? 0 : -0.05 * fontSize,
        );

    final titleStyle = isMobile ? style(24, 28) : style(28, 32);
    final subtitleStyle = isMobile ? style(20, 24) : style(28, 32);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: titleStyle.copyWith(color: titleColor)),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: subtitleStyle.copyWith(color: AppColorStyles.contentPrimary),
        ),
      ],
    );
  }
}
