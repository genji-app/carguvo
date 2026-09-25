import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/payment_method.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/codepay_create_qr_response.dart';
import 'package:sun_sports/features/profile/deposit/presentation/utils/deposit_navigator.dart';
import 'package:sun_sports/features/profile/deposit/mobile_waiting_payment_confirm_bottom_sheet.dart';
import 'package:sun_sports/features/profile/deposit/presentation/web_tablet/deposit_waiting_payment_confirm_overlay.dart';
import 'package:sun_sports/features/profile/deposit/presentation/widgets/codepay_transfer_section.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';
import 'package:sun_sports/shared/widgets/buttons/shine_button.dart';
import 'package:sun_sports/shared/widgets/cards/inner_shadow_card.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class CodepayTransferOverlay extends ConsumerStatefulWidget {
  final CodepayCreateQrResponse qrResponse;
  final PaymentMethod paymentMethod;
  final bool hideButtons;

  const CodepayTransferOverlay({
    super.key,
    required this.qrResponse,
    required this.paymentMethod,
    this.hideButtons = false,
  });

  @override
  ConsumerState<CodepayTransferOverlay> createState() =>
      _CodepayTransferOverlayState();
}

class _CodepayTransferOverlayState
    extends ConsumerState<CodepayTransferOverlay> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: SoundTap.wrap(() => Navigator.of(context).pop()),
            child: Container(color: Colors.black.withValues(alpha: 0.5)),
          ),
        ),
        Center(
          child: Material(
            color: Colors.transparent,
            elevation: 24,
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
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                              layout: CodepayTransferLayout.web,
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
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() => Container(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
    child: Row(
      children: [
        const Gap(12),
        Expanded(
          child: Center(
            child: Text(
              'Nạp tiền Codepay',
              style: AppTextStyles.headingXSmall(color: AppColors.gray25),
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
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 24),
      child: Column(
        children: [
          ShineButton(
            height: 48,
            size: ShineButtonSize.large,
            width: double.infinity,
            style: ShineButtonStyle.primaryYellow,
            text: 'Xác nhận chuyển khoản',
            onPressed: () async {
              if (!mounted) {
                return;
              }

              final rootContext = Navigator.of(
                context,
                rootNavigator: true,
              ).context;
              final deviceType = ResponsiveBuilder.getDeviceType(context);
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

              Navigator.of(context).pop();

              Future<void>.delayed(const Duration(milliseconds: 300), () async {
                if (!rootContext.mounted) {
                  return;
                }

                if (deviceType == DeviceType.mobile) {
                  DepositMobileWaitingPaymentConfirmBottomSheet.show(
                    rootContext,
                    amount: amount,
                    paymentMethod: paymentMethod,
                    transactionCode: transactionCode,
                    bankName: bankName,
                    accountName: accountName,
                    accountNumber: accountNumber,
                    note: note,
                    bankBranch: bankBranch,
                  );
                } else {
                  await showGeneralDialog(
                    context: rootContext,
                    barrierColor: Colors.black.withValues(alpha: 0.5),
                    barrierDismissible: true,
                    barrierLabel: MaterialLocalizations.of(
                      rootContext,
                    ).modalBarrierDismissLabel,
                    transitionDuration: const Duration(milliseconds: 200),
                    pageBuilder:
                        (dialogContext, animation, secondaryAnimation) =>
                            DepositWaitingPaymentConfirmOverlayWeb(
                              amount: amount,
                              paymentMethod: paymentMethod,
                              transactionCode: transactionCode,
                              bankName: bankName,
                              accountName: accountName,
                              accountNumber: accountNumber,
                              note: note,
                              bankBranch: bankBranch,
                            ),
                  );
                }
              });
            },
          ),
          const SizedBox(height: 16),
          ShineButton(
            height: 48,
            size: ShineButtonSize.large,
            width: double.infinity,
            text: 'Tạo phiếu mới',
            onPressed: () async {
              DepositNavigator().pop<void>(context);
            },
            style: ShineButtonStyle.primaryGray,
          ),
        ],
      ),
    );
  }
}
