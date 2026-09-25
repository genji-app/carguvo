import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';

class DesktopLivestreamIframe extends StatelessWidget {
  final String url;

  final bool roundedTop;

  const DesktopLivestreamIframe({
    super.key,
    required this.url,
    this.roundedTop = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 200),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: roundedTop
            ? const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              )
            : BorderRadius.zero,
      ),
      child: Center(
        child: Text(
          'Livestream chỉ hỗ trợ trên web',
          style: AppTextStyles.paragraphXSmall(color: const Color(0xFF888888)),
        ),
      ),
    );
  }
}
