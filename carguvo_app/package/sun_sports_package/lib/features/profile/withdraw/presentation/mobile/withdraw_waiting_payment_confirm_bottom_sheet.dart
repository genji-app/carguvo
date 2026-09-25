import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/profile/withdraw/presentation/providers/withdraw_overlay_provider.dart';
import 'package:sun_sports/features/profile/withdraw/presentation/withdraw_waiting_payment_confirm_container.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/shared/widgets/buttons/shine_button.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/shared/widgets/bottom_sheet/app_bottom_sheet.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class WithdrawMobileWaitingPaymentConfirmBottomSheet
    extends ConsumerStatefulWidget {
  const WithdrawMobileWaitingPaymentConfirmBottomSheet({super.key});

  static Future<void> show(BuildContext context) => AppBottomSheet.show(
    context,
    barrierColor: Colors.transparent,
    builder: (_) => const WithdrawMobileWaitingPaymentConfirmBottomSheet(),
  );

  @override
  ConsumerState<WithdrawMobileWaitingPaymentConfirmBottomSheet> createState() =>
      _WithdrawMobileWaitingPaymentConfirmBottomSheetState();
}

class _WithdrawMobileWaitingPaymentConfirmBottomSheetState
    extends ConsumerState<WithdrawMobileWaitingPaymentConfirmBottomSheet> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      debugPrint(
        '🟣 [withdraw_mobile_waiting_payment_confirm_bottom_sheet] initState',
      );
    }
    Future<void>.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final confirmationData = ref.watch(withdrawConfirmationDataProvider);

    if (confirmationData == null) {
      return const SizedBox.shrink();
    }

    final screenSize = MediaQuery.of(context).size;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final maxHeight = screenSize.height;

    return Dialog(
      backgroundColor: AppColorStyles.backgroundSecondary,
      alignment: Alignment.bottomCenter,
      insetPadding: EdgeInsets.only(top: statusBarHeight),
      child: Container(
        width: screenSize.width,
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: BoxDecoration(
          color: AppColorStyles.backgroundSecondary,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              _buildHeader(),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.yellow400,
                        ),
                      )
                    : WithdrawWaitingPaymentConfirmContainer(
                        data: confirmationData,
                      ),
              ),
              _buildBottomButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() => Container(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
    child: Row(
      children: [
        Expanded(
          child: Text(
            'Đang chờ xác nhận rút',
            style: AppTextStyles.headingSmall(color: AppColors.gray25),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: SoundTap.wrap(() {
            ref.read(withdrawConfirmationDataProvider.notifier).state = null;
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          }),
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

  Widget _buildBottomButton() => Container(
    padding: const EdgeInsets.fromLTRB(28, 16, 28, 40),
    child: ShineButton(
      text: 'Quay lại',
      height: 48,
      size: ShineButtonSize.large,
      width: double.infinity,
      style: ShineButtonStyle.primaryGray,
      onPressed: () {
        ref.read(withdrawConfirmationDataProvider.notifier).state = null;
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      },
    ),
  );
}
