import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:intl/intl.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/profile/deposit/presentation/utils/clipboard_utils.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';
import 'package:sun_sports/shared/widgets/scoin_icon.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

enum WithdrawPaymentMethodType { bank, crypto, card }

class WithdrawConfirmationData {
  final String amount;
  final String id;
  final WithdrawPaymentMethodType methodType;

  final String? bankName;
  final String? accountName;
  final String? accountNumber;

  final String? currencyType;
  final String? network;
  final String? walletAddress;

  final String? cardType;
  final int? quantity;

  const WithdrawConfirmationData({
    required this.amount,
    required this.id,
    required this.methodType,
    this.bankName,
    this.accountName,
    this.accountNumber,
    this.currencyType,
    this.network,
    this.walletAddress,
    this.cardType,
    this.quantity,
  });
}

class WithdrawWaitingPaymentConfirmContainer extends StatelessWidget {
  final WithdrawConfirmationData data;

  const WithdrawWaitingPaymentConfirmContainer({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        final isMobile = deviceType == DeviceType.mobile;
        return isMobile
            ? _buildMobileLayout(context)
            : _buildWebTabletLayout(context);
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(20),
            _buildCounterSection(context),
            const Gap(24),
            _buildDetailsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWebTabletLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(8),
            _buildCounterSection(context),
            const Gap(44),
            _buildDetailsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterSection(BuildContext context) {
    final methodName = _getMethodName(data.methodType);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.gray900,
            border: Border.all(color: AppColors.gray700, width: 1),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Rút tiền',
                  style: AppTextStyles.labelSmall(color: AppColors.green400),
                ),
                const Gap(8),
                Text(
                  methodName,
                  style: AppTextStyles.labelSmall(color: AppColors.gray400),
                ),
              ],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.gray900,
            border: Border.all(color: AppColors.gray700, width: 1),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
          child: Column(
            children: [
              _buildTableRow(
                label: 'Số tiền',
                value: _formatAmount(data.amount),
                showCopy: false,
              ),
              _buildTableRow(
                label: 'ID',
                value: data.id,
                showCopy: true,
                onCopy: () => _copyToClipboard(context, data.id),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    switch (data.methodType) {
      case WithdrawPaymentMethodType.bank:
        return _buildBankDetails(context);
      case WithdrawPaymentMethodType.crypto:
        return _buildCryptoDetails(context);
      case WithdrawPaymentMethodType.card:
        return _buildCardDetails();
    }
  }

  Widget _buildBankDetails(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray900,
        border: Border.all(color: AppColors.gray700, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildDetailTableRow(
            label: 'Ngân hàng',
            value: data.bankName ?? '',
            showCopy: false,
          ),
          const Gap(3),
          _buildDetailTableRow(
            label: 'Tên TK',
            value: data.accountName ?? '',
            showCopy: false,
          ),
          const Gap(3),
          _buildDetailTableRow(
            label: 'Số TK',
            value: _formatAccountNumber(data.accountNumber ?? ''),
            showCopy: true,
            onCopy: () => _copyToClipboard(context, data.accountNumber ?? ''),
          ),
        ],
      ),
    );
  }

  Widget _buildCryptoDetails(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray900,
        border: Border.all(color: AppColors.gray700, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildCryptoDetailRow(
            label: 'Loại tiền',
            value: data.currencyType ?? '',
            showCopy: false,
          ),
          const Gap(8),
          _buildCryptoDetailRow(
            label: 'Mạng lưới',
            value: data.network ?? '',
            showCopy: false,
          ),
          const Gap(8),
          _buildCryptoDetailRow(
            label: 'Địa chỉ rút',
            value: data.walletAddress ?? '',
            showCopy: true,
            onCopy: () => _copyToClipboard(context, data.walletAddress ?? ''),
          ),
        ],
      ),
    );
  }

  Widget _buildCryptoDetailRow({
    required String label,
    required String value,
    required bool showCopy,
    VoidCallback? onCopy,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSmall(color: AppColors.gray400),
                ),
                const Gap(4),
                Text(
                  value,
                  style: AppTextStyles.paragraphMedium(color: AppColors.gray25),
                ),
              ],
            ),
          ),
          if (showCopy) ...[
            const Gap(8),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: _buildCopyButton(onCopy ?? () {}),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCardDetails() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray900,
        border: Border.all(color: AppColors.gray700, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildDetailTableRow(
            label: 'Loại thẻ',
            value: data.cardType ?? '',
            showCopy: false,
            labelWidth: 92,
          ),
          Container(
            height: 1,
            color: AppColors.gray700,
            margin: const EdgeInsets.symmetric(horizontal: 0),
          ),
          _buildDetailTableRow(
            label: 'Số lượng',
            value: data.quantity?.toString() ?? '',
            showCopy: false,
            labelWidth: 92,
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow({
    required String label,
    required String value,
    required bool showCopy,
    VoidCallback? onCopy,
  }) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 79,
            child: Text(
              label,
              style: AppTextStyles.labelMedium(color: AppColors.gray25),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.paragraphMedium(color: AppColors.gray25),
              textAlign: TextAlign.right,
            ),
          ),
          Visibility(
            visible: label == 'Số tiền',
            child: const Row(children: [Gap(4), SCoinIcon()]),
          ),
          if (showCopy) ...[
            const Gap(8),
            _buildCopyButton(onCopy ?? () {}),
          ] else ...[
            const SizedBox(width: 36),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailTableRow({
    required String label,
    required String value,
    required bool showCopy,
    VoidCallback? onCopy,
    double? labelWidth,
  }) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: labelWidth ?? 105,
            child: Text(
              label,
              style: AppTextStyles.labelMedium(color: AppColors.gray25),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.paragraphMedium(color: AppColors.gray25),
              textAlign: TextAlign.right,
            ),
          ),
          if (showCopy) ...[
            const Gap(8),
            _buildCopyButton(onCopy ?? () {}),
          ] else ...[
            const SizedBox(width: 36),
          ],
        ],
      ),
    );
  }

  Widget _buildCopyButton(VoidCallback onCopy) {
    return SizedBox(
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
  }

  String _getMethodName(WithdrawPaymentMethodType type) {
    switch (type) {
      case WithdrawPaymentMethodType.bank:
        return 'Ngân hàng';
      case WithdrawPaymentMethodType.crypto:
        return 'Tiền điện tử';
      case WithdrawPaymentMethodType.card:
        return 'Thẻ cào';
    }
  }

  String _formatAmount(String amount) {
    try {
      final num = double.parse(amount.replaceAll(',', ''));
      final formatter = NumberFormat('#,###');
      return '${formatter.format(num)}';
    } catch (e) {
      return '$amount';
    }
  }

  String _formatAccountNumber(String accountNumber) {
    final cleaned = accountNumber.replaceAll(' ', '');
    if (cleaned.length <= 4) return cleaned;

    final buffer = StringBuffer();
    for (int i = 0; i < cleaned.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(cleaned[i]);
    }
    return buffer.toString();
  }

  Future<void> _copyToClipboard(BuildContext context, String text) async {
    await ClipboardUtils.copyToClipboard(context, text);
  }
}
