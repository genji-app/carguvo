import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/payment_method.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/codepay_create_qr_response.dart';
import 'package:sun_sports/features/profile/deposit/presentation/notifiers/codepay_qr_timer_notifier.dart';
import 'package:sun_sports/features/profile/deposit/presentation/providers/deposit_providers.dart';
import 'package:sun_sports/features/profile/deposit/presentation/utils/clipboard_utils.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/shared/widgets/scoin_icon.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

enum CodepayTransferLayout { mobile, web }

class CodepayTransferSection extends ConsumerWidget {
  final CodepayCreateQrResponse qrResponse;
  final PaymentMethod paymentMethod;
  final CodepayTransferLayout layout;

  const CodepayTransferSection({
    super.key,
    required this.qrResponse,
    required this.paymentMethod,
    this.layout = CodepayTransferLayout.mobile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoBanner(),
        const SizedBox(height: 24),
        _QRCodeSection(
          qrCode: qrResponse.qrcode,
          layout: layout,
          codepay: qrResponse.codepay,
          remainingTime: qrResponse.remainingTime,
        ),
        const SizedBox(height: 24),
        _buildTransactionDetailsSection(context),
      ],
    );
  }

  Widget _buildInfoBanner() => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.yellow400.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ImageHelper.load(path: AppIcons.icWarning, width: 20, height: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mã code chỉ dùng được 1 lần.',
                style: AppTextStyles.paragraphXSmall(color: AppColors.gray25),
              ),
              const SizedBox(height: 4),
              Text(
                'Chuyển sai nội dung, số tiền hoặc sau khi hết hạn đều không nhận được tiền vào tài khoản.',
                style: AppTextStyles.paragraphXSmall(color: AppColors.gray25),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildTransactionDetailsSection(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray700, width: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          _buildTransactionDetailRow(
            context: context,
            label: 'Ngân hàng',
            value: qrResponse.bankName,
            showCopy: false,
          ),
          _buildTransactionDetailRow(
            context: context,
            label: 'Tên TK',
            value: qrResponse.accountName,
            showCopy: true,
            onCopy: () => _copyToClipboard(context, qrResponse.accountName),
          ),
          _buildTransactionDetailRow(
            context: context,
            label: 'Số tiền',
            value:
                '${qrResponse.amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
            valueColor: AppColors.green400,
            showCopy: true,
            onCopy: () =>
                _copyToClipboard(context, qrResponse.amount.toString()),
          ),
          if (qrResponse.bankBranch.isNotEmpty)
            _buildTransactionDetailRow(
              context: context,
              label: 'Chi nhánh',
              value: qrResponse.bankBranch,
              showCopy: false,
            ),
          _buildTransactionDetailRow(
            context: context,
            label: 'Nội dung',
            value: qrResponse.codepay,
            valueColor: AppColors.green400,
            showCopy: true,
            onCopy: () => _copyToClipboard(context, qrResponse.codepay),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionDetailRow({
    required BuildContext context,
    required String label,
    required String value,
    Color? valueColor,
    required bool showCopy,
    VoidCallback? onCopy,
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    child: Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: AppTextStyles.labelSmall(color: AppColors.gray300),
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

  Future<void> _copyToClipboard(BuildContext context, String text) =>
      ClipboardUtils.copyToClipboard(context, text);
}

class _QRCodeSection extends StatefulWidget {
  final String qrCode;
  final CodepayTransferLayout layout;
  final String codepay;
  final int remainingTime;

  const _QRCodeSection({
    required this.qrCode,
    required this.layout,
    required this.codepay,
    required this.remainingTime,
  });

  @override
  State<_QRCodeSection> createState() => _QRCodeSectionState();
}

class _QRCodeSectionState extends State<_QRCodeSection> {
  Uint8List? _cachedQrImageBytes;

  @override
  void initState() {
    super.initState();
    _decodeAndCacheQRCode();
  }

  void _decodeAndCacheQRCode() {
    if (widget.qrCode.isNotEmpty) {
      try {
        _cachedQrImageBytes = base64Decode(widget.qrCode);
      } catch (e) {
        _cachedQrImageBytes = null;
      }
    }
  }

  @override
  void didUpdateWidget(_QRCodeSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.qrCode != widget.qrCode) {
      _decodeAndCacheQRCode();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWebLayout = widget.layout == CodepayTransferLayout.web;
    final qrSize = isWebLayout ? 200.0 : 160.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Quét mã QR',
            style: AppTextStyles.textStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.gray300,
              height: 1.25,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            width: qrSize,
            height: qrSize,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gray700, width: 1),
            ),
            child: _cachedQrImageBytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Image.memory(
                        _cachedQrImageBytes!,
                        width: qrSize,
                        height: qrSize,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildQRCodePlaceholder(qrSize),
                      ),
                    ),
                  )
                : _buildQRCodePlaceholder(qrSize),
          ),
          const SizedBox(height: 16),
          _TimerTextWidget(
            codepay: widget.codepay,
            remainingTime: widget.remainingTime,
          ),
        ],
      ),
    );
  }

  Widget _buildQRCodePlaceholder(double size) => Center(
    child: Icon(
      Icons.qr_code_scanner,
      size: size * 0.6,
      color: AppColors.gray400,
    ),
  );
}

class _TimerTextWidget extends ConsumerWidget {
  final String codepay;
  final int remainingTime;

  const _TimerTextWidget({
    required this.codepay,
    required this.remainingTime,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(
      codepayQrTimerProvider(
        CodepayQrTimerArgs(id: codepay, remainingTime: remainingTime),
      ),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Hết hạn sau: ',
          style: AppTextStyles.labelSmall(color: AppColors.gray300),
        ),
        Text(
          timerState.formattedTime,
          style: AppTextStyles.labelSmall(color: const Color(0xFFEF6820)),
        ),
      ],
    );
  }
}
