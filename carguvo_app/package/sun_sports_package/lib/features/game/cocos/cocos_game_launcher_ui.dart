import 'package:provider_game_manager/provider_game_manager.dart';
import 'package:sun_sports/features/game/lobby_game_extensions.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/game/assets/assets.dart';
import 'package:sun_sports/shared/widgets/buttons/secondary_button.dart';
import 'package:sun_sports/shared/widgets/buttons/shine_button.dart';
import 'package:sun_sports/shared/widgets/cards/inner_shadow_card.dart';

class CocosDownloadCompleteDialog extends StatelessWidget {
  const CocosDownloadCompleteDialog({required this.game, super.key});

  final LobbyGame game;

  static Future<bool?> show(BuildContext context, LobbyGame game) {
    return showGeneralDialog<bool>(
      context: context,
      useRootNavigator: true,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) =>
          CocosDownloadCompleteDialog(game: game),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);

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
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(context),
                    const Gap(20),
                    _buildGameCover(),
                    const Gap(20),
                    _buildMessage(context),
                    const Gap(24),
                    _buildActions(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 28,
      child: Stack(
        children: [
          Center(
            child: Text(
              'Hoàn tất tải game',
              style: AppTextStyles.headingXSmall(
                color: AppColorStyles.contentPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCover() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 128,
        height: 170,
        child: GameAssetImage(imagePath: game.imagePath),
      ),
    );
  }

  Widget _buildMessage(BuildContext context) {
    final baseStyle = AppTextStyles.paragraphMedium(
      color: AppColorStyles.contentPrimary,
    );

    return Align(
      alignment: Alignment.centerLeft,
      child: Text.rich(
        TextSpan(
          children: [
            const TextSpan(text: 'Game '),
            TextSpan(
              text: game.gameName,
              style: baseStyle.copyWith(
                color: AppColors.yellow400,
                fontWeight: FontWeight.w700,
              ),
            ),
            const TextSpan(
              text: ' đã tải xong. Bạn có muốn vào game ngay không?',
            ),
          ],
        ),
        style: baseStyle,
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SecondaryButton.yellow(
            size: SecondaryButtonSize.xl,
            onPressed: () =>
                Navigator.of(context, rootNavigator: true).pop(false),
            label: const Text('Để sau'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ShineButton(
            text: 'Chơi ngay',
            height: 48,
            width: double.infinity,
            style: ShineButtonStyle.primaryYellow,
            onPressed: () =>
                Navigator.of(context, rootNavigator: true).pop(true),
          ),
        ),
      ],
    );
  }
}
