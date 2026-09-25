import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/sport/presentation/widgets/sport_live_chat.dart';
import 'package:sun_sports/router/auth_navigation.dart';
import 'package:sun_sports/shared/layouts/shell_scroll_header_bar.dart';

class ChatGuestLockStrip extends StatelessWidget {
  const ChatGuestLockStrip({required this.headerColor, super.key});

  final Color headerColor;

  static const _bottomRadius = BorderRadius.only(
    bottomLeft: Radius.circular(16),
    bottomRight: Radius.circular(16),
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => openAuth(context, showLogin: true),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColorStyles.backgroundTertiary,
                borderRadius: _bottomRadius,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: _bottomRadius,
                  border: const Border(
                    bottom: BorderSide(
                      color: Color.fromRGBO(255, 255, 255, 0.12),
                      width: 1.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(
                top: ShellScrollHeaderBar.barHeight,
                left: 16,
                right: 16,
              ),
              child: Center(
                child: Text.rich(
                  TextSpan(
                    text: 'Vui lòng ',
                    children: [
                      TextSpan(
                        text: 'đăng nhập',
                        style: AppTextStyles.textStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.yellow400,
                          height: 20 / 14,
                        ),
                      ),
                      const TextSpan(text: ' để sử dụng tính năng này'),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.textStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColorStyles.contentSecondary,
                    height: 20 / 14,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: ChatLineMetrics.topFadeUnderHeader,
            child: IgnorePointer(child: ChatTopFade(color: headerColor)),
          ),
        ],
      ),
    );
  }
}
