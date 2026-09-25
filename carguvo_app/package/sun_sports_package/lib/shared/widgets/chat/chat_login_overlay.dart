import 'package:flutter/material.dart';
import 'package:sun_sports/router/auth_navigation.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/buttons/shine_button.dart';

class ChatLoginOverlay extends StatelessWidget {
  final bool isMobile;

  const ChatLoginOverlay({super.key, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColorStyles.backgroundTertiary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColorStyles.borderSecondary, width: 1),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.4),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      size: 32,
                      color: AppColorStyles.contentSecondary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Vui lòng đăng nhập để sử dụng tính năng này',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.paragraphSmall(
                        color: AppColorStyles.contentSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ShineButton(
                      text: I18n.txtLogin,
                      height: 44,
                      style: ShineButtonStyle.primaryYellow,
                      onPressed: () => openAuth(context, showLogin: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
