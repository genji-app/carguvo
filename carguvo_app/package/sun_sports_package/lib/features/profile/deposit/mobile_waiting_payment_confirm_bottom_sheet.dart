import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/payment_method.dart';
import 'package:sun_sports/features/profile/deposit/presentation/utils/deposit_navigator.dart';
import 'package:sun_sports/features/profile/deposit/presentation/widgets/waiting_payment_confirm_section.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/shared/widgets/bottom_sheet/app_bottom_sheet.dart';
import 'package:sun_sports/shared/widgets/buttons/shine_button.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class DepositMobileWaitingPaymentConfirmBottomSheet
    extends ConsumerStatefulWidget {
  final String amount;
  final PaymentMethod paymentMethod;
  final String transactionCode;
  final String bankName;
  final String accountName;
  final String accountNumber;
  final String note;

  final String? bankBranch;

  const DepositMobileWaitingPaymentConfirmBottomSheet({
    super.key,
    required this.amount,
    required this.paymentMethod,
    required this.transactionCode,
    required this.bankName,
    required this.accountName,
    required this.accountNumber,
    required this.note,
    this.bankBranch,
  });

  static Future<void> show(
    BuildContext context, {
    required String amount,
    required PaymentMethod paymentMethod,
    required String transactionCode,
    required String bankName,
    required String accountName,
    required String accountNumber,
    required String note,
    String? bankBranch,
  }) => AppBottomSheet.show(
    context,
    barrierColor: AppColorStyles.backgroundQuaternary,
    builder: (_) => DepositMobileWaitingPaymentConfirmBottomSheet(
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

  @override
  ConsumerState<DepositMobileWaitingPaymentConfirmBottomSheet> createState() =>
      _DepositMobileWaitingPaymentConfirmBottomSheetState();
}

class _DepositMobileWaitingPaymentConfirmBottomSheetState
    extends ConsumerState<DepositMobileWaitingPaymentConfirmBottomSheet> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
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
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [_buildWaitingPaymentSection()],
                        ),
                      ),
              ),
              _buildBottomButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWaitingPaymentSection() {
    return WaitingPaymentConfirmSection(
      amount: widget.amount,
      paymentMethod: widget.paymentMethod,
      transactionCode: widget.transactionCode,
      bankName: widget.bankName,
      accountName: widget.accountName,
      accountNumber: widget.accountNumber,
      note: widget.note,
      bankBranch: widget.bankBranch,
      layout: WaitingPaymentLayout.mobile,
    );
  }

  Widget _buildHeader() => Container(
    padding: const EdgeInsets.fromLTRB(17, 12, 16, 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
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

  Widget _buildBottomButton() => Container(
    padding: const EdgeInsets.fromLTRB(28, 16, 28, 40),
    child: ShineButton(
      text: 'Quay lại',
      height: 48,
      size: ShineButtonSize.large,
      width: double.infinity,
      style: ShineButtonStyle.primaryGray,
      onPressed: () => DepositNavigator().closeAll<void>(context),
    ),
  );
}
