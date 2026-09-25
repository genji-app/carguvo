import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/providers/parlay_state_provider.dart';
import 'package:sun_sports/shared/widgets/bet_details/bet_details_bottom_sheet.dart';
import 'package:sun_sports/shared/widgets/snackbars/providers/bet_success_snackbar_provider.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class BetSuccessSnackBar extends ConsumerWidget {
  const BetSuccessSnackBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(betSuccessSnackBarProvider);
    final parlayState = ref.watch(parlayStateProvider);

    debugPrint(
      '[BetSuccessSnackBar] build() - isVisible=${state.isVisible}, latestBet=${state.latestBet?.displayName}',
    );

    final hasValidBets = parlayState.singleBets.any((bet) => !bet.isDisabled);

    if (!state.isVisible || state.latestBet == null) {
      debugPrint('[BetSuccessSnackBar] returning SizedBox.shrink()');
      return const SizedBox.shrink();
    }

    if (parlayState.singleBets.isEmpty || !hasValidBets) {
      debugPrint(
        '[BetSuccessSnackBar] hiding - no valid bets remain (empty=${parlayState.singleBets.isEmpty}, hasValidBets=$hasValidBets)',
      );
      return const SizedBox.shrink();
    }

    debugPrint('[BetSuccessSnackBar] showing snackbar widget');

    return Container(
      width: double.infinity,
      height: 64,
      margin: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ImageHelper.load(
                path: AppImages.backgroundBetting,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                ImageHelper.load(
                  path: AppIcons.iconBetSuccess,
                  width: 32,
                  height: 32,
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Đã thêm kèo vào phiếu cược',
                        style: AppTextStyles.labelSmall(
                          color: AppColorStyles.contentPrimary,
                        ),
                      ),
                      const Gap(2),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: SoundTap.wrap(() {
                          debugPrint(
                            '[BetSuccessSnackBar] Xem vé cược đơn tapped',
                          );
                          final parlayState = ref.read(parlayStateProvider);
                          debugPrint(
                            '[BetSuccessSnackBar] singleBets.length = ${parlayState.singleBets.length}',
                          );
                          if (parlayState.singleBets.isNotEmpty) {
                            final latestBet = parlayState.singleBets.last;
                            debugPrint(
                              '[BetSuccessSnackBar] Opening popup for: ${latestBet.displayName}',
                            );
                            BetDetailsBottomSheet.show(
                              context,
                              data: latestBet.toBettingPopupData(),
                            );
                          }
                        }),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Xem vé cược đơn',
                                style: AppTextStyles.labelXSmall(
                                  color: AppColorStyles.contentSecondary,
                                ),
                              ),
                              const Gap(4),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: AppColorStyles.contentSecondary,
                                size: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: SoundTap.wrap(() {
                    ref.read(betSuccessSnackBarProvider.notifier).hide();
                  }),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.transparent,
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
