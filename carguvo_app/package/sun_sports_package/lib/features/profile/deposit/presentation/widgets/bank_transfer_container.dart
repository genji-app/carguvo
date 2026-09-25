import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/payment_method.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/models/bank_account_item.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/models/item_account.dart';
import 'package:sun_sports/features/profile/deposit/presentation/utils/clipboard_utils.dart';
import 'package:sun_sports/features/profile/deposit/presentation/utils/deposit_navigator.dart';
import 'package:sun_sports/features/profile/deposit/presentation/mobile/bank/bank_confirm_money_transfer_bottomsheet.dart';
import 'package:sun_sports/features/profile/deposit/presentation/mobile/bank/bank_transfer_money_bottom_sheet.dart';
import 'package:sun_sports/features/profile/deposit/presentation/web_tablet/bank_confirm_money_transfer_overlay.dart';
import 'package:sun_sports/features/profile/deposit/presentation/web_tablet/bank_transfer_overlay.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/shared/domain/enums/responsive_enums.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class BankTransferContainer extends ConsumerStatefulWidget {
  final BankAccountItem bankAccountItem;
  final PaymentMethod paymentMethod;
  final BuildContext parentContext;

  const BankTransferContainer({
    super.key,
    required this.bankAccountItem,
    required this.paymentMethod,
    required this.parentContext,
  });

  @override
  ConsumerState<BankTransferContainer> createState() =>
      _BankTransferContainerState();
}

class _BankTransferContainerState extends ConsumerState<BankTransferContainer> {
  @override
  Widget build(BuildContext context) {
    final bankAccountItem = widget.bankAccountItem;

    if (bankAccountItem.accounts.isEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          Expanded(
            child: Center(
              child: Text(
                'Ngân hàng này không có tài khoản',
                style: AppTextStyles.labelMedium(color: AppColors.gray300),
              ),
            ),
          ),
        ],
      );
    }

    final account = bankAccountItem.accounts.first;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQRCodeSection(account: account),
                const SizedBox(height: 24),
                _buildBankAccountDetailsSection(
                  bankName: bankAccountItem.name,
                  accountNumber: account.accountNumber,
                  accountName: account.accountName,
                  branch: account.bankBranch,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        _buildBottomButton(),
      ],
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
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Nạp tiền ngân hàng',
            style: AppTextStyles.headingXSmall(
              color: AppColors.gray25,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: 32),
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

  Widget _buildQRCodeSection({required ItemAccount account}) {
    if (account.qrCodeImage.isEmpty) return const SizedBox.shrink();

    final Uint8List strQrcode = base64Decode(account.qrCodeImage);

    const qrSize = 180.0;
    const containerPadding = 16.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(containerPadding),
      child: Column(
        children: [
          Container(
            width: qrSize,
            height: qrSize,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gray25, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Image.memory(
                strQrcode,
                width: 180,
                height: 180,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Mã QR tài khoản',
            style: AppTextStyles.textStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.gray25,
              height: 1.25,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBankAccountDetailsSection({
    required String bankName,
    required String accountNumber,
    required String accountName,
    required String branch,
  }) => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      border: Border.all(
        color: AppColors.gray700,
        width: 0.5,
      ),
      borderRadius: BorderRadius.circular(16),
    ),
    padding: const EdgeInsets.only(top: 8, bottom: 8),
    child: Column(
      children: [
        _buildBankDetailRow(
          label: 'Ngân hàng',
          value: bankName,
          valueColor: AppColors.green400,
          showCopy: false,
        ),
        _buildBankDetailRow(
          label: 'Tên TK',
          value: accountName,
          showCopy: false,
        ),
        _buildBankDetailRow(
          label: 'Số TK',
          value: accountNumber,
          valueColor: AppColors.green400,
          showCopy: true,
          onCopy: () => _copyToClipboard(accountNumber.replaceAll(' ', '')),
        ),
        _buildBankDetailRow(label: 'Chi nhánh', value: branch, showCopy: false),
      ],
    ),
  );

  Widget _buildBankDetailRow({
    required String label,
    required String value,
    Color? valueColor,
    required bool showCopy,
    VoidCallback? onCopy,
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Row(
      children: [
        SizedBox(
          width: 105,
          child: Text(
            label,
            style: AppTextStyles.labelSmall(
              color: AppColors.gray300,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.labelSmall(
              color: valueColor ?? AppColors.gray25,
            ),
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(
          width: 56,
          child: showCopy
              ? Center(child: _buildCopyButton(onCopy ?? () {}))
              : const SizedBox.shrink(),
        ),
      ],
    ),
  );

  Widget _buildCopyButton(VoidCallback onCopy) => SizedBox(
    width: 28,
    height: 28,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Material(
        color: AppColors.gray700,
        child: InkWell(
          onTap: SoundTap.wrap(onCopy),
          child: Center(
            child: ImageHelper.load(
              path: AppIcons.icCopy,
              width: 16,
              height: 16,
            ),
          ),
        ),
      ),
    ),
  );

  Future<void> _copyToClipboard(String text) async {
    if (!mounted) return;
    await ClipboardUtils.copyToClipboard(context, text);
  }

  Widget _buildBottomButton() => Container(
    padding: const EdgeInsets.fromLTRB(28, 16, 28, 40),
    decoration: BoxDecoration(
      border: Border(
        top: BorderSide(
          color: AppColors.gray700,
          width: 0.5,
        ),
      ),
    ),
    child: _buildActionButton(
      text: 'Xác nhận chuyển khoản',
      backgroundColor: AppColors.yellow700,
      textColor: Colors.white,
      onTap: () async {
        final rootContext = Navigator.of(context, rootNavigator: true).context;
        final navigator = DepositNavigator();

        navigator.push(
          context: rootContext,
          mobileShowMethod: (ctx) => BankConfirmMoneyTransferBottomSheet.show(
            ctx,
            bankAccountItem: widget.bankAccountItem,
            paymentMethod: widget.paymentMethod,
          ),
          webShowMethod: (ctx) => DepositNavigator.showWebDialog<void>(
            context: ctx,
            builder: (dialogContext, animation, secondaryAnimation) {
              return BankConfirmMoneyTransferOverlay(
                bankAccountItem: widget.bankAccountItem,
                paymentMethod: widget.paymentMethod,
              );
            },
          ),
          showPreviousDialog: (rootContext, deviceType) async {
            if (deviceType == DeviceType.mobile) {
              await BankTransferMoneyBottomSheet.show(
                rootContext,
                bankAccountItem: widget.bankAccountItem,
                amount: '',
                paymentMethod: widget.paymentMethod,
              );
            } else {
              await DepositNavigator.showWebDialog<void>(
                context: rootContext,
                builder: (dialogContext, animation, secondaryAnimation) =>
                    BankTransferOverlay(
                      bankAccountItem: widget.bankAccountItem,
                      paymentMethod: widget.paymentMethod,
                    ),
              );
            }
          },
        );
      },
    ),
  );

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
                fontWeight: FontWeight.w600,
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
