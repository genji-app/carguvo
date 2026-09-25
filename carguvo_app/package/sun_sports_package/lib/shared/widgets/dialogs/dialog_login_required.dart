import 'package:flutter/material.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/router/auth_navigation.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/buttons/shine_button.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/cards/inner_shadow_card.dart';
import 'package:sun_sports/shared/widgets/livestream/livestream_overlay_blocker.dart';

class DialogLoginRequired extends StatelessWidget {
  const DialogLoginRequired({super.key});

  static Future<void> show(BuildContext context) async {
    pushLivestreamOverlayBlock();
    try {
      await showGeneralDialog<void>(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.5),
        barrierDismissible: true,
        barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const DialogLoginRequired(),
      );
    } finally {
      popLivestreamOverlayBlock();
    }
  }

  void _goToAuth(BuildContext context, {required bool showLogin}) {
    Navigator.of(context).pop();
    openAuth(context, showLogin: showLogin);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: InnerShadowCard(
          child: Container(
            width: screenSize.width > 400 ? 400 : screenSize.width * 0.9,
            decoration: BoxDecoration(
              color: AppColorStyles.backgroundTertiary,
              border: Border.all(
                color: AppColorStyles.borderSecondary,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.75),
                  offset: const Offset(0, -20),
                  blurRadius: 200,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(context),
                  _buildBody(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SizedBox(
        height: 40,
        child: Row(
          children: [
            const Icon(
              Icons.lock_outline,
              size: 20,
              color: AppColorStyles.contentPrimary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Đăng nhập để tiếp tục',
                style: AppTextStyles.headingXXSmall(
                  color: AppColorStyles.contentPrimary,
                ),
              ),
            ),
            GestureDetector(
              onTap: SoundTap.wrap(() => Navigator.of(context).pop()),
              child: const Icon(
                Icons.close,
                size: 24,
                color: AppColorStyles.contentPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vui lòng đăng nhập/đăng ký để sử dụng tính năng này',
            style: AppTextStyles.paragraphSmall(
              color: AppColorStyles.contentSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ShineButton(
                  text: I18n.txtLogin,
                  height: 48,
                  width: double.infinity,
                  style: ShineButtonStyle.primaryGray,
                  onPressed: () => _goToAuth(context, showLogin: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ShineButton(
                  text: I18n.txtRegister,
                  width: double.infinity,
                  height: 48,
                  style: ShineButtonStyle.primaryYellow,
                  onPressed: () => _goToAuth(context, showLogin: false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
