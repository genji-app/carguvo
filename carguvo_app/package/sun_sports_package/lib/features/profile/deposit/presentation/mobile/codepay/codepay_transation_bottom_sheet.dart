import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/payment_method.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/codepay_create_qr_response.dart';
import 'package:sun_sports/features/profile/deposit/presentation/utils/deposit_navigator.dart';
import 'package:sun_sports/features/profile/deposit/presentation/widgets/codepay_transfer_section.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/features/profile/deposit/mobile_waiting_payment_confirm_bottom_sheet.dart';
import 'package:sun_sports/shared/widgets/bottom_sheet/app_bottom_sheet.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class CodepayTransationBottomSheet extends ConsumerStatefulWidget {
  final CodepayCreateQrResponse qrResponse;
  final PaymentMethod paymentMethod;
  final bool hideButtons;

  const CodepayTransationBottomSheet({
    super.key,
    required this.qrResponse,
    required this.paymentMethod,
    this.hideButtons = false,
  });

  static Future<void> show(
    BuildContext context, {
    required CodepayCreateQrResponse qrResponse,
    required PaymentMethod paymentMethod,
    bool hideButtons = false,
  }) => AppBottomSheet.show(
    context,
    builder: (_) => CodepayTransationBottomSheet(
      qrResponse: qrResponse,
      paymentMethod: paymentMethod,
      hideButtons: hideButtons,
    ),
  );

  @override
  ConsumerState<CodepayTransationBottomSheet> createState() =>
      _DepositMobileTransationBottomSheetState();
}

class _DepositMobileTransationBottomSheetState
    extends ConsumerState<CodepayTransationBottomSheet> {
  @override
  Widget build(BuildContext context) {
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CodepayTransferSection(
                        qrResponse: widget.qrResponse,
                        paymentMethod: widget.paymentMethod,
                        layout: CodepayTransferLayout.mobile,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              _buildBottomButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() => Container(
    padding: const EdgeInsets.fromLTRB(17, 12, 16, 12),
    child: Row(
      children: [
        InkWell(
          onTap: SoundTap.wrap(() => DepositNavigator().pop<void>(context)),
          child: Container(
            width: 20,
            height: 20,
            color: Colors.transparent,
            child: ImageHelper.load(
              path: AppIcons.icBack,
              width: 20,
              height: 20,
            ),
          ),
        ),
        const Gap(12),
        Expanded(
          child: Text(
            'Nạp tiền',
            style: AppTextStyles.headingXSmall(
              color: AppColors.gray25,
            ),
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

  Widget _buildBottomButtons() {
    if (widget.hideButtons) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 40),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.gray700,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        children: [
          _buildActionButton(
            text: 'Xác nhận chuyển khoản',
            backgroundColor: AppColors.yellow700,
            textColor: Colors.white,
            onTap: () async {
              Navigator.of(context).pop();
              final amount = widget.qrResponse.amount.toString();
              final paymentMethod = widget.paymentMethod;
              final transactionCode = widget.qrResponse.codepay;
              final bankName = widget.qrResponse.bankName;
              final accountName = widget.qrResponse.accountName;
              final accountNumber = widget.qrResponse.bankAccount;
              final note = widget.qrResponse.codepay;
              final bankBranch = widget.qrResponse.bankBranch.isNotEmpty
                  ? widget.qrResponse.bankBranch
                  : null;

              Future.delayed(
                const Duration(milliseconds: 300),
                () {
                  if (mounted) {
                    DepositMobileWaitingPaymentConfirmBottomSheet.show(
                      context,
                      amount: amount,
                      paymentMethod: paymentMethod,
                      transactionCode: transactionCode,
                      bankName: bankName,
                      accountName: accountName,
                      accountNumber: accountNumber,
                      note: note,
                      bankBranch: bankBranch,
                    );
                  }
                },
              );
            },
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            text: 'Tạo phiếu mới',
            backgroundColor: AppColors.gray950,
            textColor: Colors.white,
            onTap: () {
              DepositNavigator().pop<void>(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onTap,
  }) => SizedBox(
    width: double.infinity,
    height: 48,
    child: InkWell(
      onTap: SoundTap.wrap(onTap),
      borderRadius: BorderRadius.circular(100),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.55232],
                    colors: [
                      Colors.white.withValues(
                        alpha: 0.24,
                      ),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: Text(
              text,
              style: AppTextStyles.textStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textColor,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
