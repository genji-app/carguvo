import 'package:adaptive_overlay/adaptive_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/providers/auth_provider.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/providers/parlay_state_provider.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/screens/parlay_mobile_screen.dart';
import 'package:sun_sports/shared/widgets/cards/inner_shadow_card.dart';
import 'package:sun_sports/shared/widgets/livestream/livestream_overlay_blocker.dart';
import 'package:sun_sports/shared/widgets/flying_bet_animation.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class CollapsedBettingTicket extends ConsumerWidget {
  final VoidCallback? onTap;

  const CollapsedBettingTicket({super.key, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final singleBetsCount = ref.watch(singleBetsCountProvider);
    final comboBetsCount = ref.watch(comboBetsCountProvider);
    final minMatches = ref.watch(minMatchesProvider);
    final hasValidCombo = comboBetsCount >= minMatches;
    final totalBetCount = singleBetsCount + (hasValidCombo ? 1 : 0);

    return GestureDetector(
      key: FlyingBetController.instance.collapsedTicketKey,
      onTap: SoundTap.wrap(onTap ?? () => _showParlayBottomSheet(context, ref)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.green300,
            width: 1,
          ),
          color: AppColorStyles.backgroundPrimary,
        ),
        child: Stack(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Phiếu cược',
                  style: AppTextStyles.labelXSmall(
                    color: AppColorStyles.contentPrimary,
                  ),
                ),
                if (totalBetCount > 0)
                const SizedBox(width: 12),
                if (totalBetCount > 0)
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.green300,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      totalBetCount > 99 ? '99+' : totalBetCount.toString(),
                      style: AppTextStyles.labelXSmall(
                        color: AppColors.gray950,
                      ).copyWith(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showParlayBottomSheet(BuildContext context, WidgetRef ref) {
    if (!ref.watch(isAuthenticatedProvider)) {
      AppToast.showError(
        context,
        message: 'Vui lòng đăng nhập để thực hiện hành động này',
      );
      return;
    }
    pushLivestreamOverlayBlock();
    showFadeBottomSheet<void>(
      context: context,
      useSafeArea: false,
      liftForKeyboard: true,
      builder: (ctx) => const FractionallySizedBox(
        heightFactor: 0.9,
        widthFactor: 1,
        child: ParlayMobileScreen(),
      ),
    ).whenComplete(popLivestreamOverlayBlock);
  }
}
