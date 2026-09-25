import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:sun_sports/features/profile/deposit/presentation/utils/deposit_navigator.dart';
import 'package:sun_sports/features/profile/deposit/mobile_waiting_payment_confirm_bottom_sheet.dart';
import 'package:sun_sports/features/profile/deposit/presentation/web_tablet/deposit_waiting_payment_confirm_overlay.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/shared/domain/enums/button_enums.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';
import 'package:sun_sports/shared/widgets/buttons/shine_button.dart';
import 'package:sun_sports/shared/widgets/scoin_icon.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class EWalletConfirmMoneyTransferContainer extends ConsumerStatefulWidget {
  final CodepayCreateQrResponse qrResponse;
  final PaymentMethod paymentMethod;
  final bool hideButtons;

  const EWalletConfirmMoneyTransferContainer({
    super.key,
    required this.qrResponse,
    required this.paymentMethod,
    this.hideButtons = false,
  });

  @override
  ConsumerState<EWalletConfirmMoneyTransferContainer> createState() =>
      _EWalletConfirmMoneyTransferContainerState();
}

class _EWalletConfirmMoneyTransferContainerState
    extends ConsumerState<EWalletConfirmMoneyTransferContainer> {
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      _buildHeader(),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoBanner(),
              const SizedBox(height: 24),
              _QRCodeSection(
                qrCode: widget.qrResponse.qrcode,
                codepay: widget.qrResponse.codepay,
                remainingTime: widget.qrResponse.remainingTime,
              ),
              const SizedBox(height: 24),
              _buildAccountDetailsSection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      _buildBottomButtons(),
    ],
  );

  Widget _buildHeader() => Container(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
    child: Row(
      children: [
        Expanded(
          child: Text(
            'Nạp tiền ví điện tử',
            style: AppTextStyles.headingXSmall(
              color: AppColors.gray25,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const Gap(12),
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
                style: AppTextStyles.paragraphXSmall(
                  color: AppColors.gray25,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Chuyển sai nội dung, số tiền hoặc sau khi hết hạn đều không nhận được tiền vào tài khoản.',
                style: AppTextStyles.paragraphXSmall(
                  color: AppColors.gray25,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildAccountDetailsSection() => Container(
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
        _buildDetailRow(
          label: 'Ngân hàng',
          value: widget.qrResponse.bankName.toUpperCase(),
          showCopy: false,
        ),
        _buildDetailRow(
          label: 'Tên TK',
          value: widget.qrResponse.accountName,
          showCopy: true,
          onCopy: () => _copyToClipboard(widget.qrResponse.accountName),
        ),
        _buildDetailRow(
          label: 'Số tiền',
          value:
              '${widget.qrResponse.amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
          showCopy: true,
          onCopy: () => _copyToClipboard(widget.qrResponse.amount.toString()),
        ),
        _buildDetailRow(
          label: 'Nội dung',
          value: widget.qrResponse.codepay,
          showCopy: true,
          onCopy: () => _copyToClipboard(widget.qrResponse.codepay),
        ),
      ],
    ),
  );

  Widget _buildDetailRow({
    required String label,
    required String value,
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
            style: AppTextStyles.labelSmall(
              color: AppColors.gray300,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.labelSmall(
              color: AppColors.green400,
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

  Future<void> _copyToClipboard(String text) async {
    if (!mounted) return;
    await ClipboardUtils.copyToClipboard(context, text);
  }

  Widget _buildBottomButtons() {
    if (widget.hideButtons) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 24),
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
          ShineButton(
            text: 'Xác nhận chuyển khoản',
            height: 48,
            size: ShineButtonSize.large,
            width: double.infinity,
            style: ShineButtonStyle.primaryYellow,
            onPressed: () {
              _handleConfirm();
            },
          ),
          const SizedBox(height: 12),
          ShineButton(
            text: 'Tạo phiếu mới',
            height: 48,
            size: ShineButtonSize.large,
            width: double.infinity,
            onPressed: () => DepositNavigator().pop<void>(context),
          ),
        ],
      ),
    );
  }

  void _handleConfirm() async {
    if (!mounted) {
      return;
    }

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

    final navigator = Navigator.of(context, rootNavigator: true);
    Navigator.of(context).pop();

    await Future<void>.delayed(const Duration(milliseconds: 400));

    if (!navigator.context.mounted) {
      return;
    }

    try {
      if (deviceType == DeviceType.mobile) {
        DepositMobileWaitingPaymentConfirmBottomSheet.show(
          navigator.context,
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
          context: navigator.context,
          barrierColor: Colors.black.withValues(alpha: 0.5),
          barrierDismissible: true,
          barrierLabel: MaterialLocalizations.of(
            navigator.context,
          ).modalBarrierDismissLabel,
          transitionDuration: const Duration(milliseconds: 200),
          pageBuilder: (dialogContext, animation, secondaryAnimation) =>
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
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Error in _handleConfirm: $e\n$stackTrace');
      }
    }
  }
}

class _QRCodeSection extends ConsumerStatefulWidget {
  final String qrCode;
  final String codepay;
  final int remainingTime;

  const _QRCodeSection({
    required this.qrCode,
    required this.codepay,
    required this.remainingTime,
  });

  @override
  ConsumerState<_QRCodeSection> createState() => _QRCodeSectionState();
}

class _QRCodeSectionState extends ConsumerState<_QRCodeSection> {
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
        debugPrint('Failed to decode QR code: $e');
        _cachedQrImageBytes = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        children: [
          if (_cachedQrImageBytes != null)
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.gray700, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Image.memory(
                  _cachedQrImageBytes!,
                  width: 176,
                  height: 176,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Text(
                      'Lỗi hiển thị QR',
                      style: AppTextStyles.labelSmall(color: AppColors.gray400),
                    ),
                  ),
                ),
              ),
            )
          else
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.gray900,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.gray700, width: 1),
              ),
              child: Center(
                child: Text(
                  'Không thể hiển thị QR',
                  style: AppTextStyles.labelSmall(color: AppColors.gray400),
                ),
              ),
            ),
          const SizedBox(height: 12),
          Text(
            'Quét mã QR',
            style: AppTextStyles.paragraphMedium(color: AppColors.gray25),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          _TimerTextWidget(
            codepay: widget.codepay,
            remainingTime: widget.remainingTime,
          ),
        ],
      ),
    );
  }
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
          style: AppTextStyles.paragraphMedium(color: AppColors.gray400),
        ),
        Text(
          timerState.formattedTime,
          style: AppTextStyles.paragraphMedium(color: const Color(0xFFEF6820)),
        ),
      ],
    );
  }
}
