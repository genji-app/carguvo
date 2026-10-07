import 'package:flutter/material.dart';
import 'package:app_package/core/constants/i18n.dart';
import 'package:app_package/core/utils/styles/app_color.dart';
import 'package:app_package/core/utils/styles/app_text_styles.dart';
import 'package:app_package/shared/widgets/buttons/buttons.dart';

class GameLobbyFailureView extends StatelessWidget {
  const GameLobbyFailureView({required this.onRetry, this.message, super.key});

  final String? message;

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Text(
              message ?? 'Chưa tải được danh sách trò chơi',
              style: AppTextStyles.labelMedium(color: AppColors.red400),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SecondaryButton.yellow(
              onPressed: onRetry,
              label: const Text(I18n.txtRetry),
            ),
          ],
        ),
      ),
    );
  }
}
