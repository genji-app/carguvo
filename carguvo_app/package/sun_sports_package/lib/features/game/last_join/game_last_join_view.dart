import 'package:sun_sports/features/game/last_join/card_last_join_session.dart';
import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/buttons/shine_button.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/cards/inner_shadow_card.dart';

class GameLastJoinView extends StatelessWidget {
  const GameLastJoinView({required this.session, super.key});

  final CardLastJoinSession session;

  static Future<bool?> show(
    BuildContext context, {
    required CardLastJoinSession session,
  }) => showGeneralDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    barrierDismissible: true,
    useRootNavigator: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, animation, secondaryAnimation) =>
        GameLastJoinView(session: session),
  );

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
                  const _Header(),
                  _Body(session: session),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SizedBox(
        height: 40,
        child: Row(
          children: [
            ImageHelper.load(
              path: AppIcons.catCard,
              width: 20,
              height: 20,
              color: AppColorStyles.contentPrimary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Tiếp tục ván chơi?',
                style: AppTextStyles.headingXXSmall(
                  color: AppColorStyles.contentPrimary,
                ),
              ),
            ),
            GestureDetector(
              onTap: SoundTap.wrap(() => Navigator.of(context).pop(false)),
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
}

class _Body extends StatelessWidget {
  const _Body({required this.session});

  final CardLastJoinSession session;

  @override
  Widget build(BuildContext context) {
    final gameName = session.game?.gameName ?? 'Game Bài';
    final roomId = session.roomId;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Bạn đang có bàn chơi $gameName (Bàn #$roomId) chưa kết thúc. Bạn có muốn quay lại bàn chơi ngay không?',
            style: AppTextStyles.paragraphSmall(
              color: AppColorStyles.contentSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ShineButton(
                text: 'Vào lại bàn',
                height: 48,
                style: ShineButtonStyle.primaryYellow,
                onPressed: () => Navigator.of(context).pop(true),
              ),
              const SizedBox(width: 12),
              ShineButton(
                text: 'Để sau',
                height: 48,
                style: ShineButtonStyle.primaryGray,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
