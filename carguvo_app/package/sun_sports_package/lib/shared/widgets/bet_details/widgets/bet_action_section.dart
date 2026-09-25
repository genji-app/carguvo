import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:sun_sports/core/error/betting_api_error_messages.dart';
import 'package:sun_sports/providers/user_provider/user_provider.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/platform_utils.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/sport/presentation/providers/events_v2_provider.dart';
import 'package:sun_sports/features/bet_detail/presentation/providers/bet_detail_mobile_v2_provider.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/providers/parlay_state_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/sport_providers.dart';
import 'package:sun_sports/shared/widgets/bet_details/providers/betting_popup_provider.dart';
import 'package:sun_sports/shared/widgets/buttons/shine_button.dart';
import 'package:sun_sports/shared/widgets/scoin_icon.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';

class BetActionSection extends ConsumerWidget {
  final bool isMobile;

  const BetActionSection({super.key, this.isMobile = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomPadding = isMobile
        ? MediaQuery.of(context).padding.bottom
        : 0.0;
    final bettingState = ref.watch(bettingPopupProvider);
    final bettingNotifier = ref.read(bettingPopupProvider.notifier);

    final winnings = bettingState.calculateWinnings();
    final isLoading = bettingState.isPlacingBet || bettingState.isCalculating;
    final canPlaceBet =
        !isLoading &&
        bettingState.betAmount.isNotEmpty &&
        bettingState.betAmount != '0' &&
        winnings > 0;
    final stakeValue =
        int.tryParse(bettingState.betAmount.replaceAll(',', '')) ?? 0;
    final placeBetLabel = stakeValue > 0
        ? 'Đặt cược ${_formatMoney(stakeValue)}'
        : 'Đặt cược';

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ).copyWith(bottom: PlatformUtils.isMobile ? 12 : 12 + bottomPadding),
          decoration: const BoxDecoration(
            color: AppColorStyles.backgroundTertiary,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Thanh toán dự kiến',
                        style: AppTextStyles.labelSmall(
                          color: AppColorStyles.contentSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            _formatMoney(winnings),
                            style: AppTextStyles.labelMedium(
                              color: AppColorStyles.contentPrimary,
                            ),
                          ),
                          const Gap(2),
                          const SCoinIcon(),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ShineButton(
                      isEnabled: canPlaceBet,
                      text: placeBetLabel,
                      style: ShineButtonStyle.primaryYellow,
                      height: 36,
                      width: double.infinity,
                      horizontalPadding: 12,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      onPressed: () => _onPlaceBet(
                        context,
                        ref,
                        canPlaceBet,
                        bettingNotifier,
                        bettingState,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          child: RepaintBoundary(
            child: SizedBox(
              width: double.infinity,
              child: ImageHelper.load(
                path: AppIcons.hr,
                width: double.infinity,
                height: 2,
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatMoney(int amount) {
    if (amount == 0) return '0';
    return NumberFormat('#,###').format(amount);
  }

  Future<void> _onPlaceBet(
    BuildContext context,
    WidgetRef ref,
    bool canPlaceBet,
    BettingPopupNotifier bettingNotifier,
    BettingPopupState bettingState,
  ) async {
    if (!canPlaceBet) return;

    final success = await bettingNotifier.placeBet();
    if (!context.mounted) return;

    if (success) {
      AppToast.showSuccess(context, message: 'Đặt cược thành công!');
      ref.read(userProvider.notifier).refreshBalance();
      final selectionId = bettingState.bettingData?.getSelectionId();
      debugPrint(
        '[BetActionSection] Trying to remove bet with selectionId: $selectionId',
      );
      if (selectionId != null) {
        final parlayState = ref.read(parlayStateProvider);
        final parlayNotifier = ref.read(parlayStateProvider.notifier);
        debugPrint(
          '[BetActionSection] Current singleBets count: ${parlayState.singleBets.length}',
        );
        debugPrint(
          '[BetActionSection] singleBets selectionIds: ${parlayState.singleBets.map((b) => b.selectionId).toList()}',
        );
        final index = parlayState.singleBets.indexWhere(
          (bet) => bet.selectionId == selectionId,
        );
        debugPrint('[BetActionSection] Found bet at index: $index');
        if (index >= 0) {
          parlayNotifier.removeSingleBetAt(index);
          debugPrint(
            '[BetActionSection] Removed bet. New count: ${ref.read(parlayStateProvider).singleBets.length}',
          );
        } else {
          debugPrint(
            '[BetActionSection] WARNING: Bet not found in singleBets!',
          );
        }
      }

    } else {
      final currentState = ref.read(bettingPopupProvider);
      final errorCode = currentState.errorCode;
      if (errorCode == BettingPopupNotifier.clientValidationErrorCode) {
        AppToast.showError(
          context,
          message: currentState.error ?? bettingApiPlaceBetFailureFallback,
        );
        bettingNotifier.clearError();
        return;
      }
      final errorMessage = bettingApiPlaceBetOfferStale(errorCode)
          ? bettingApiOddsChangedRetryMessage
          : bettingApiErrorDisplayMessage(
              errorCode,
              serverMessage: currentState.error,
              fallback: bettingApiPlaceBetFailureFallback,
            );
      AppToast.showError(context, message: errorMessage);

      if (bettingApiPlaceBetBasisChanged(errorCode)) {
        ref.read(betDetailMobileV2Provider.notifier).refreshFullMarkets();
        ref.read(eventsV2Provider.notifier).refreshOnStaleOffer(
              leagueId: bettingState.bettingData?.leagueData?.leagueId,
            );
        final outrightData = bettingState.bettingData;
        if (outrightData != null && outrightData.isSpecialOutright) {
          ref.invalidate(specialOutrightProvider(outrightData.sportId));
        }
      }

      if (!BettingPopupNotifier.isMoneyRelatedError(errorCode)) {
        final selectionId = bettingState.bettingData?.getSelectionId();
        if (selectionId != null) {
          final parlayState = ref.read(parlayStateProvider);
          final parlayNotifier = ref.read(parlayStateProvider.notifier);
          final index = parlayState.singleBets.indexWhere(
            (bet) => bet.selectionId == selectionId,
          );
          if (index >= 0) {
            parlayNotifier.removeSingleBetAt(index);
            debugPrint(
              '[BetActionSection] Removed bet due to non-money error: $errorCode',
            );
          }
        }
      }

      bettingNotifier.clearError();
      Navigator.of(context).pop();
    }
  }
}
