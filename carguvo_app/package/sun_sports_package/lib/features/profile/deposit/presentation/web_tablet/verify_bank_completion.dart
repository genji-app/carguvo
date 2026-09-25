import 'package:flutter/material.dart';
import 'package:sun_sports/features/profile/deposit/presentation/utils/deposit_navigator.dart';
import 'package:sun_sports/features/profile/deposit/presentation/widgets/verify_bank_completion_container.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/shared/widgets/cards/inner_shadow_card.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class VerifyBankCompletionOverlay extends StatelessWidget {
  const VerifyBankCompletionOverlay({super.key});

  static Future<void> show(BuildContext context) => showGeneralDialog(
    context: context,
    barrierColor: Colors.transparent,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    transitionDuration: const Duration(milliseconds: 100),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    pageBuilder: (context, animation, secondaryAnimation) =>
        const VerifyBankCompletionOverlay(),
  );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: SoundTap.wrap(() async {
              await DepositNavigator().pop<void>(context);
            }),
            child: Container(color: Colors.transparent),
          ),
        ),
        Center(
          child: Material(
            color: Colors.transparent,
            elevation: 24,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: InnerShadowCard(
                borderRadius: 24,
                child: Container(
                  width: 640,
                  height: 823,
                  constraints: BoxConstraints(maxHeight: size.height * 0.9),
                  decoration: BoxDecoration(
                    color: AppColors.gray950,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.75),
                        offset: const Offset(-20, 4),
                        blurRadius: 200,
                      ),
                      BoxShadow(
                        offset: const Offset(0, 0.5),
                        blurRadius: 0.5,
                        spreadRadius: 0,
                        blurStyle: BlurStyle.inner,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ],
                    border: Border.all(color: AppColors.gray700, width: 1),
                  ),
                  child: const VerifyBankCompletionContainer(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
