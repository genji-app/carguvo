import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/services/models/bet_model.dart';
import 'package:sun_sports/core/utils/styles/app_audios.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/error/betting_api_error_messages.dart';
import 'package:sun_sports/providers/user_provider/user_provider.dart';
import 'package:sun_sports/features/parlay/domain/models/single_bet_data.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/providers/parlay_state_provider.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/providers/parlay_live_odds_provider.dart';
import 'package:sun_sports/features/betting/betting.dart';
import 'package:sun_sports/features/parlay/presentation/providers/parlay_overlay_provider.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/widgets/dialog_confirm_clear_all.dart';
import 'package:sun_sports/features/my_bet_hub/my_bet_hub_providers.dart';
import 'package:sun_sports/features/my_bet_hub/my_bet_hub_sheet_scope.dart';
import 'package:sun_sports/features/profile/deposit/presentation/show_deposit_flow.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/shared/widgets/buttons/shine_button.dart';
import 'package:sun_sports/shared/widgets/scoin_icon.dart';
import 'package:sun_sports/core/utils/money_formatter.dart';
import 'package:sun_sports/core/utils/platform_utils.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';

String _placeBetLabel(double totalBet) => totalBet > 0
    ? 'Đặt cược: ${MoneyFormatter.formatCompact(totalBet.round())}'
    : 'Đặt cược';

final _insufficientBalanceProvider = Provider.autoDispose<bool>((ref) {
  final tab = ref.watch(parlayStateProvider.select((s) => s.tab));
  if (tab != ParlayTab.single) return false;
  final hasUser = ref.watch(userInfoProvider.select((user) => user != null));
  if (!hasUser) return false;
  final totalBet = ref.watch(parlayStateProvider.select((s) => s.validTotalBet));
  final balance = ref.watch(balanceInVNDProvider);
  return totalBet > balance;
});

void _openDepositPopup(BuildContext context, WidgetRef ref) {
  final rootContext = Navigator.of(context, rootNavigator: true).context;

  ref.read(myBetHubControllerProvider).close();
  ref.read(parlayOverlayVisibleProvider.notifier).state = false;
  showDepositFlow(rootContext, ref);
}

class ParlaySummarySection extends StatelessWidget {
  final bool isPlacingBetOverride;

  final VoidCallback? onPlaceBetPressed;

  const ParlaySummarySection({
    super.key,
    this.isPlacingBetOverride = false,
    this.onPlaceBetPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12).copyWith(
        bottom: MyBetHubSheetScope.navPassThroughOf(context)
            ? 12.0
            : 28 +
                  (PlatformUtils.isAndroid
                      ? MediaQuery.of(context).viewPadding.bottom
                      : 0.0),
      ),
      decoration: BoxDecoration(
        color: AppColorStyles.backgroundQuaternary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Consumer(
            builder: (context, ref, _) {
              final totalBet = ref.watch(parlayLiveValidTotalBetProvider);
              final ticketCount = ref.watch(parlayValidTicketCountProvider);
              return _SummaryRow(
                label: totalBetLabel(ticketCount),
                value: totalBet,
              );
            },
          ),
          const Gap(4),
          Consumer(
            builder: (context, ref, _) {
              final potentialWin = ref.watch(
                parlayLiveValidPotentialWinProvider,
              );
              return _SummaryRow(
                label: 'Thanh toán dự kiến',
                value: potentialWin,
                isGold: true,
              );
            },
          ),
          const Gap(12),
          const _InsufficientBalanceNotification(),
          _ActionButtonsSection(
            isPlacingBetOverride: isPlacingBetOverride,
            onPlaceBetPressed: onPlaceBetPressed,
          ),
          const Gap(4),
          _PlaceBetResultListener(),
          _ErrorListener(),
        ],
      ),
    );
  }
}

class _PlaceBetResultListener extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<PlaceBetResponse?>(
      parlayStateProvider.select((s) => s.lastPlaceBetResult),
      (previous, next) {
        if (previous != next && next != null) {
          if (next.isSuccess) {
            _showSuccessSnackbar(
              context,
              next.message ?? 'Đặt cược thành công!',
            );
          } else {
            _showErrorSnackbar(
              context,
              bettingApiErrorDisplayMessage(
                next.errorCode,
                serverMessage: next.message,
                fallback: bettingApiPlaceBetFailureFallback,
              ),
            );
          }
        }
      },
    );
    return const SizedBox.shrink();
  }

  void _showSuccessSnackbar(BuildContext context, String message) {
    if (!context.mounted) return;
    AppToast.showSuccess(context, message: message);
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    if (!context.mounted) return;
    AppToast.showError(context, message: message);
  }
}

class _ErrorListener extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<String?>(parlayErrorProvider, (previous, next) {
      if (next != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            AppToast.showError(context, message: next);
          }
          ref.read(parlayStateProvider.notifier).clearError();
        });
      }
    });
    return const SizedBox.shrink();
  }
}

class _ActionButtonsSection extends ConsumerWidget {
  final bool isPlacingBetOverride;
  final VoidCallback? onPlaceBetPressed;

  const _ActionButtonsSection({
    required this.isPlacingBetOverride,
    this.onPlaceBetPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlacingBet =
        isPlacingBetOverride || ref.watch(isPlacingBetProvider);
    final tab = ref.watch(parlayStateProvider.select((s) => s.tab));

    if (tab == ParlayTab.single) {
      return _SingleTabButtons(
        isPlacingBet: isPlacingBet,
        onPlaceBetPressed: onPlaceBetPressed,
      );
    }

    if (tab == ParlayTab.combo) {
      return _ComboTabButtons(
        isPlacingBet: isPlacingBet,
        onPlaceBetPressed: onPlaceBetPressed,
      );
    }

    return Consumer(
      builder: (context, ref, _) {
        final canPlaceBet = ref.watch(
          parlayStateProvider.select((s) => s.canPlaceBet),
        );
        return Row(
          children: [
            Expanded(
              child: ShineButton(
                height: 40,
                width: double.infinity,
                text: 'Thêm vào xiên',
                style: ShineButtonStyle.primaryGray,
                onPressed: () {},
              ),
            ),
            const Gap(8),
            Expanded(
              child: ShineButton(
                height: 40,
                width: double.infinity,
                text: 'Đặt cược',
                style: ShineButtonStyle.primaryYellow,
                onPressed: canPlaceBet ? () {} : null,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SingleTabButtons extends ConsumerWidget {
  final bool isPlacingBet;
  final VoidCallback? onPlaceBetPressed;

  const _SingleTabButtons({required this.isPlacingBet, this.onPlaceBetPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final singleBetsData = ref.watch(
      parlayStateProvider.select(
        (s) => (singleBets: s.singleBets, totalBet: s.validTotalBet),
      ),
    );

    final validBetsCount = singleBetsData.singleBets
        .where((bet) => bet.canPlaceBet)
        .length;
    final canPlaceSingleBet = validBetsCount > 0;

    final isInsufficientBalance = ref.watch(_insufficientBalanceProvider);

    return _SingleBetButtons(
      canPlaceBet: canPlaceSingleBet,
      isPlacingBet: isPlacingBet,
      isInsufficientBalance: isInsufficientBalance,
      betsCount: validBetsCount,
      singleBetsCount: singleBetsData.singleBets.length,
      totalBet: singleBetsData.totalBet,
      onDeposit: () => _openDepositPopup(context, ref),
      onClearAll: () async {
        final confirmed = await DialogConfirmClearAll.show(context);
        if (confirmed == true) {
          ref.read(parlayStateProvider.notifier).clearAllSingleBets();
        }
      },
      onPlaceBet: () async {
        final singleBets = singleBetsData.singleBets;
        if (_exceedsBalance(ref, singleBets)) {
          if (context.mounted) {
            AppToast.showError(
              context,
              message:
                  'Số dư tài khoản của bạn không đủ, Vui lòng nạp thêm để thao tác tiếp!',
            );
          }
          return;
        }
        if (onPlaceBetPressed != null) {
          onPlaceBetPressed!();
          return;
        }
        final successCount = await ref
            .read(parlayStateProvider.notifier)
            .placeAllSingleBets();
        if (successCount > 0 && context.mounted) {
          if (ref.read(parlayStateProvider).singleBets.isEmpty) {
            Navigator.of(context).pop();
          }
        }
      },
      onAcceptChanges: () {
        ref.read(parlayStateProvider.notifier).acceptOddsChanges();
      },
    );
  }

  bool _exceedsBalance(WidgetRef ref, List<SingleBetData> singleBets) {
    final balance = ref.read(balanceInVNDProvider).floor();
    if (balance <= 0) return false;
    var total = 0.0;
    for (final bet in singleBets) {
      if (bet.canPlaceBet) {
        total += bet.totalCost;
      }
    }
    return total > balance;
  }
}

class _ComboTabButtons extends ConsumerWidget {
  final bool isPlacingBet;
  final VoidCallback? onPlaceBetPressed;

  const _ComboTabButtons({required this.isPlacingBet, this.onPlaceBetPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comboData = ref.watch(
      parlayStateProvider.select(
        (s) => (
          canPlaceBet: s.canPlaceBet,
          hasEnoughMatches: s.hasEnoughMatches,
          comboBetsCount: s.comboBets.length,
          totalBet: s.totalBet,
        ),
      ),
    );

    return _ComboBetButtons(
      canPlaceBet: comboData.canPlaceBet,
      isPlacingBet: isPlacingBet,
      hasEnoughMatches: comboData.hasEnoughMatches,
      comboBetsCount: comboData.comboBetsCount,
      totalBet: comboData.totalBet,
      onClearAll: () async {
        final confirmed = await DialogConfirmClearAll.show(context);
        if (confirmed == true) {
          ref.read(parlayStateProvider.notifier).clearAllComboBets();
        }
      },
      onPlaceBet: () async {
        final balance = ref.read(balanceInVNDProvider).floor();
        final totalBet = ref.read(parlayStateProvider).totalBet.round();
        if (balance > 0 && totalBet > balance) {
          if (context.mounted) {
            AppToast.showError(
              context,
              message:
                  'Số dư tài khoản của bạn không đủ, Vui lòng nạp thêm để thao tác tiếp!',
            );
          }
          return;
        }
        if (onPlaceBetPressed != null) {
          onPlaceBetPressed!();
          return;
        }
        final success = await ref
            .read(parlayStateProvider.notifier)
            .placeComboParlay();
        if (success && context.mounted) {
          if (ref.read(parlayStateProvider).comboBets.isEmpty) {
            Navigator.of(context).pop();
          }
        }
      },
      onAcceptChanges: () {
        ref.read(parlayStateProvider.notifier).acceptOddsChanges();
      },
    );
  }
}

class _ComboBetButtons extends StatelessWidget {
  final bool canPlaceBet;
  final bool isPlacingBet;
  final bool hasEnoughMatches;
  final int comboBetsCount;
  final double totalBet;
  final VoidCallback onClearAll;
  final VoidCallback onPlaceBet;
  final VoidCallback onAcceptChanges;

  const _ComboBetButtons({
    required this.canPlaceBet,
    required this.isPlacingBet,
    required this.hasEnoughMatches,
    required this.comboBetsCount,
    required this.totalBet,
    required this.onClearAll,
    required this.onPlaceBet,
    required this.onAcceptChanges,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: ShineButton(
          height: 40,
          width: double.infinity,
          text: 'Xóa toàn bộ',
          style: ShineButtonStyle.primaryGray,
          tapSound: AppSound.removeFromBetslip,
          onPressed: comboBetsCount > 0 && !isPlacingBet ? onClearAll : null,
        ),
      ),
      const Gap(8),
      Expanded(
        child: isPlacingBet
            ? _LoadingButton()
            : canPlaceBet
            ? ShineButton(
                height: 40,
                text: _placeBetLabel(totalBet),
                width: double.infinity,
                style: ShineButtonStyle.primaryYellow,
                onPressed: onPlaceBet,
              )
            : const _DisabledPlaceBetButton(),
      ),
    ],
  );
}

class _SingleBetButtons extends StatelessWidget {
  final bool canPlaceBet;
  final bool isPlacingBet;

  final bool isInsufficientBalance;
  final int betsCount;
  final int singleBetsCount;
  final double totalBet;
  final VoidCallback onClearAll;
  final VoidCallback onPlaceBet;
  final VoidCallback onDeposit;
  final VoidCallback onAcceptChanges;

  const _SingleBetButtons({
    required this.canPlaceBet,
    required this.isPlacingBet,
    required this.isInsufficientBalance,
    required this.betsCount,
    required this.singleBetsCount,
    required this.totalBet,
    required this.onClearAll,
    required this.onPlaceBet,
    required this.onDeposit,
    required this.onAcceptChanges,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: ShineButton(
          height: 40,
          width: double.infinity,
          text: 'Xóa toàn bộ',
          style: ShineButtonStyle.primaryGray,
          tapSound: AppSound.removeFromBetslip,
          onPressed: singleBetsCount > 0 && !isPlacingBet ? onClearAll : null,
        ),
      ),
      const Gap(8),
      Expanded(
        child: isPlacingBet
            ? _LoadingButton()
            : isInsufficientBalance
            ? ShineButton(
                height: 40,
                text: 'Nạp & Cược',
                width: double.infinity,
                style: ShineButtonStyle.primaryYellow,
                onPressed: onDeposit,
              )
            : canPlaceBet
            ? ShineButton(
                height: 40,
                text: _placeBetLabel(totalBet),
                width: double.infinity,
                style: ShineButtonStyle.primaryYellow,
                onPressed: onPlaceBet,
              )
            : const _DisabledPlaceBetButton(),
      ),
    ],
  );
}

class _DisabledPlaceBetButton extends StatelessWidget {
  const _DisabledPlaceBetButton();

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    height: 40,
    decoration: ShapeDecoration(
      color: const Color(0xFF393836),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Đặt cược',
          style: AppTextStyles.buttonMedium(
            color: AppColorStyles.contentTertiary,
          ),
        ),
      ],
    ),
  );
}

class _LoadingButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    height: 40,
    decoration: BoxDecoration(
      color: AppColorStyles.borderPrimary,
      borderRadius: BorderRadius.circular(100),
    ),
    child: const Center(
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            AppColorStyles.contentSecondary,
          ),
        ),
      ),
    ),
  );
}

String totalBetLabel(int ticketCount) =>
    ticketCount > 0 ? 'Tổng cược ($ticketCount Phiếu)' : 'Tổng cược';

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;

  final bool isGold;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isGold = false,
  });

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: AppTextStyles.labelSmall(color: AppColorStyles.contentSecondary),
      ),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isGold)
            _GoldText(text: _formatCurrency(value))
          else
            Text(
              _formatCurrency(value),
              style: AppTextStyles.labelSmall(
                color: AppColorStyles.contentPrimary,
              ),
            ),
          const Gap(4),
          const SCoinIcon(),
        ],
      ),
    ],
  );

  String _formatCurrency(double value) =>
      '${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]},')}';
}

class _InsufficientBalanceNotification extends ConsumerWidget {
  const _InsufficientBalanceNotification();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insufficient = ref.watch(_insufficientBalanceProvider);
    if (!insufficient) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0x1FEF6820),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline,
              color: AppColors.orange500,
              size: 24,
            ),
            const Gap(12),
            Text(
              'Không đủ số dư, nạp ngay',
              style: AppTextStyles.labelMedium(color: AppColors.orange200),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoldText extends StatelessWidget {
  final String text;

  const _GoldText({required this.text});

  @override
  Widget build(BuildContext context) => ShaderMask(
    shaderCallback: (Rect bounds) => const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFFFE5B8), Color(0xFFFFB732)],
    ).createShader(bounds),
    blendMode: BlendMode.srcIn,
    child: Text(text, style: AppTextStyles.labelSmall()),
  );
}
