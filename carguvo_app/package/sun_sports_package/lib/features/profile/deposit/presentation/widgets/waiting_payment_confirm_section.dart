import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/payment_method.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/models/bank_account_item.dart';
import 'package:sun_sports/features/profile/deposit/presentation/utils/clipboard_utils.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/shared/widgets/scoin_icon.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

enum WaitingPaymentLayout { mobile, web }

class WaitingPaymentConfirmSection extends StatelessWidget {
  final WaitingPaymentLayout layout;

  final String amount;
  final PaymentMethod paymentMethod;
  final String transactionCode;
  final String bankName;
  final String accountName;
  final String accountNumber;
  final String note;

  final String? bankBranch;
  final String? walletAddress;
  final String? network;

  const WaitingPaymentConfirmSection({
    super.key,
    required this.amount,
    required this.paymentMethod,
    required this.transactionCode,
    required this.bankName,
    required this.accountName,
    required this.accountNumber,
    required this.note,
    this.bankBranch,
    this.walletAddress,
    this.network,
    this.layout = WaitingPaymentLayout.mobile,
  });

  factory WaitingPaymentConfirmSection.fromBankAccountItem({
    required BankAccountItem bankAccountItem,
    required String amount,
    required PaymentMethod paymentMethod,
    required String transactionCode,
    String? note,
    WaitingPaymentLayout layout = WaitingPaymentLayout.mobile,
  }) {
    final accounts = bankAccountItem.accounts;
    final firstAccount = accounts.isNotEmpty ? accounts.first : null;

    final extractedAmount = amount;
    final extractedPaymentMethod = paymentMethod;
    final extractedTransactionCode = transactionCode;
    final extractedBankName = bankAccountItem.name;
    final extractedAccountName = firstAccount?.accountName ?? '';
    final extractedAccountNumber = firstAccount?.accountNumber ?? '';
    final extractedNote = note ?? transactionCode;
    final extractedBankBranch = firstAccount?.bankBranch;

    return WaitingPaymentConfirmSection(
      amount: extractedAmount,
      paymentMethod: extractedPaymentMethod,
      transactionCode: extractedTransactionCode,
      bankName: extractedBankName,
      accountName: extractedAccountName,
      accountNumber: extractedAccountNumber,
      note: extractedNote,
      bankBranch: extractedBankBranch,
      layout: layout,
    );
  }

  String _getPaymentMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.codepay:
        return 'Codepay';
      case PaymentMethod.bank:
        return 'Ngân hàng';
      case PaymentMethod.eWallet:
        return 'Ví điện tử';
      case PaymentMethod.crypto:
        return 'Tiền điện tử';
      case PaymentMethod.scratchCard:
        return 'Thẻ cào';
      case PaymentMethod.giftcode:
        return 'Giftcode';
    }
  }

  String _getBankOrWalletLabel() {
    switch (paymentMethod) {
      case PaymentMethod.eWallet:
      case PaymentMethod.codepay:
        return 'Ngân hàng';
      case PaymentMethod.crypto:
        return 'Loại tiền';
      default:
        return 'Ngân hàng';
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (layout == WaitingPaymentLayout.mobile) ...[
        _buildTitle(),
        const SizedBox(height: 32),
      ] else
        const SizedBox(height: 8),
      _buildPaymentInfoCard(context),
      const SizedBox(height: 16),
      _buildTransactionDetailsSection(context),
    ],
  );

  Widget _buildTitle() => Text(
    'Đang chờ xác nhận thanh toán',
    style: AppTextStyles.headingSmall(color: AppColors.gray25),
  );

  Widget _buildPaymentInfoCard(BuildContext context) => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.gray700, width: 0.5),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.gray800,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Row(
            children: [
              Text(
                'Nạp tiền',
                style: AppTextStyles.labelSmall(color: AppColors.green400),
              ),
              const Gap(8),
              Text(
                _getPaymentMethodName(paymentMethod),
                style: AppTextStyles.labelSmall(color: AppColors.gray25),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            children: [
              _buildPaymentInfoRow(
                label: 'Số tiền',
                value: '$amount',
                showCopy: false,
              ),
              _buildPaymentInfoRow(
                label: 'ID',
                value: transactionCode,
                showCopy: true,
                onCopy: () => _copyToClipboard(context, transactionCode),
                color: AppColors.green400,
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildPaymentInfoRow({
    required String label,
    required String value,
    required bool showCopy,
    VoidCallback? onCopy,
    Color? color,
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Row(
      children: [
        SizedBox(
          width: 79,
          child: Text(
            label,
            style: AppTextStyles.labelSmall(color: AppColors.gray300),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.labelSmall(color: color ?? AppColors.gray25),
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Visibility(
          visible: label == 'Số tiền',
          child: const Row(children: [Gap(4), SCoinIcon()]),
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

  Widget _buildTransactionDetailsSection(BuildContext context) => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.gray700, width: 0.5),
      borderRadius: BorderRadius.circular(16),
    ),
    padding: const EdgeInsets.only(top: 8, bottom: 8),
    child: Column(
      children: [
        _buildTransactionDetailRow(
          label: _getBankOrWalletLabel(),
          value: bankName,
          showCopy: false,
        ),
        if (paymentMethod == PaymentMethod.crypto && network != null)
          _buildTransactionDetailRow(
            label: 'Network',
            value: network!,
            showCopy: false,
          ),
        if (paymentMethod == PaymentMethod.crypto && walletAddress != null)
          _buildTransactionDetailRow(
            label: 'Địa chỉ ví',
            value: walletAddress!,
            showCopy: true,
            onCopy: () => _copyToClipboard(context, walletAddress!),
          ),
        if (accountName.isNotEmpty)
          _buildTransactionDetailRow(
            label: 'Tên TK',
            value: accountName,
            showCopy: true,
            onCopy: () => _copyToClipboard(context, accountName),
          ),
        if (accountNumber.isNotEmpty)
          _buildTransactionDetailRow(
            label: 'Số TK',
            value: accountNumber,
            showCopy: true,
            onCopy: () =>
                _copyToClipboard(context, accountNumber.replaceAll(' ', '')),
          ),
        if (note.isNotEmpty)
          _buildTransactionDetailRow(
            label: 'Ghi chú',
            value: note,
            showCopy: true,
            onCopy: () => _copyToClipboard(context, note),
          ),
        if (bankBranch != null)
          _buildTransactionDetailRow(
            label: 'Chi nhánh',
            value: bankBranch!,
            showCopy: false,
          ),
      ],
    ),
  );

  Widget _buildTransactionDetailRow({
    required String label,
    required String value,
    required bool showCopy,
    VoidCallback? onCopy,
    Color? color,
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    child: Row(
      children: [
        SizedBox(
          width: 105,
          child: Text(
            label,
            style: AppTextStyles.labelSmall(color: AppColors.gray300),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.labelSmall(color: color ?? AppColors.gray25),
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

  Future<void> _copyToClipboard(BuildContext context, String text) async {
    await ClipboardUtils.copyToClipboard(context, text);
  }
}
