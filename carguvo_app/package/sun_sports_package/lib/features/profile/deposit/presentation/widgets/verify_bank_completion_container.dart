import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/profile/deposit/presentation/utils/deposit_navigator.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/shared/widgets/buttons/deposit_action_button.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class VerifyBankCompletionContainer extends StatelessWidget {
  const VerifyBankCompletionContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray950,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          _buildHeader(context),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSuccessIcon(),
                  const SizedBox(height: 20),
                  Text(
                    'Yêu cầu đã được ghi nhận',
                    style: AppTextStyles.headingSmall(color: AppColors.gray25),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Ban quản trị sẽ kiểm tra xác minh trong giây lát.',
                    style: AppTextStyles.paragraphMedium(
                      color: AppColors.gray300,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
            child: DepositActionButton(
              text: 'Quay lại',
              isEnabled: true,
              onTap: () => DepositNavigator().pop<void>(context),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
    child: Row(
      children: [
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Xác minh ngân hàng',
            style: AppTextStyles.headingXSmall(color: AppColors.gray25),
            textAlign: TextAlign.center,
          ),
        ),
        InkWell(
          onTap: SoundTap.wrap(() => DepositNavigator().closeAll<void>(context)),
          borderRadius: BorderRadius.circular(100),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Center(
              child: Icon(Icons.close, size: 20, color: AppColors.gray25),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildSuccessIcon() => Container(
    width: 96,
    height: 96,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: const LinearGradient(
        colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF22C55E).withValues(alpha: 0.35),
          blurRadius: 24,
          spreadRadius: 4,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: const Center(
      child: Icon(Icons.check_rounded, size: 48, color: Colors.white),
    ),
  );
}
