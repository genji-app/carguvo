import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/error/app_error_messages.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/services/repositories/transaction_repository/transaction_repository.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/payment_method.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/crypto_address_response.dart';
import 'package:sun_sports/features/profile/deposit/presentation/utils/deposit_navigator.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/crypto_deposit_request.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/crypto_option.dart';
import 'package:sun_sports/features/profile/deposit/presentation/providers/deposit_providers.dart';
import 'package:sun_sports/features/profile/deposit/presentation/utils/clipboard_utils.dart';
import 'package:sun_sports/features/profile/deposit/presentation/utils/payment_util.dart';
import 'package:sun_sports/features/profile/deposit/domain/state/deposit_state.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/shared/widgets/buttons/deposit_action_button.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/features/profile/shared/money_flow_success.dart';

class CryptoConfirmMoneyTransferContainer extends ConsumerStatefulWidget {
  final CryptoAddressResponse cryptoAddressResponse;
  final CryptoOption cryptoOption;
  final PaymentMethod paymentMethod;

  const CryptoConfirmMoneyTransferContainer({
    super.key,
    required this.cryptoAddressResponse,
    required this.cryptoOption,
    required this.paymentMethod,
  });

  @override
  ConsumerState<CryptoConfirmMoneyTransferContainer> createState() =>
      _CryptoConfirmMoneyTransferContainerState();
}

class _CryptoConfirmMoneyTransferContainerState
    extends ConsumerState<CryptoConfirmMoneyTransferContainer> {
  Uint8List? _cachedQrImageBytes;

  @override
  void initState() {
    super.initState();
    _decodeAndCacheQRCode();
  }

  void _decodeAndCacheQRCode() {
    if (widget.cryptoAddressResponse.qrCode.isNotEmpty) {
      try {
        _cachedQrImageBytes = base64Decode(widget.cryptoAddressResponse.qrCode);
      } catch (e) {
        _cachedQrImageBytes = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final submitState = ref.watch(cryptoSubmitNotifierProvider);

    return Column(
      mainAxisSize: MainAxisSize.max,
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
                _buildQRCodeSection(),
                const SizedBox(height: 24),
                _buildCryptoDetailsSection(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        _buildBottomButton(submitState),
      ],
    );
  }

  Widget _buildHeader() => Container(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
    child: Row(
      children: [
        InkWell(
          onTap: SoundTap.wrap(() => Navigator.of(context).pop()),
          child: SizedBox(
            width: 20,
            height: 20,
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
            'Nạp tiền điện tử',
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
          child: Text(
            '• Vui lòng chuyển tới địa chỉ ví dưới đây.\n• Địa chỉ ví được tạo riêng biệt cho mỗi tài khoản, luôn thay đổi, vui lòng không lưu lại',
            style: AppTextStyles.paragraphXSmall(
              color: AppColors.gray25,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildQRCodeSection() => Container(
    width: double.infinity,
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ImageHelper.load(
                  path: PaymentUtil.getCryptoIconPath(
                    widget.cryptoOption.name,
                  ),
                  width: 24,
                  height: 24,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              widget.cryptoOption.name,
              style: AppTextStyles.paragraphMedium(color: AppColors.gray25),
            ),
            const SizedBox(width: 4),
            Text(
              widget.cryptoOption.network,
              style: AppTextStyles.paragraphXSmall(
                color: AppColors.gray300,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
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
      ],
    ),
  );

  Widget _buildCryptoDetailsSection() => Container(
    width: double.infinity,
    child: Column(
      children: [
        _buildDetailRow(
          label: 'Mạng lưới',
          value: widget.cryptoAddressResponse.network,
          showCopy: false,
        ),
        _buildDetailRow(
          label: 'Địa chỉ nạp',
          value: widget.cryptoAddressResponse.address,
          showCopy: true,
          onCopy: () => _copyToClipboard(widget.cryptoAddressResponse.address),
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
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall(
            color: AppColors.gray300,
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                value,
                style: AppTextStyles.labelSmall(
                  color: AppColors.gray25,
                ),
              ),
            ),
            if (showCopy) ...[
              const SizedBox(width: 24),
              _buildCopyButton(onCopy ?? () {}),
            ],
          ],
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

  Widget _buildBottomButton(CryptoSubmitState submitState) => Container(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
    decoration: BoxDecoration(
      border: Border(
        top: BorderSide(
          color: AppColors.gray700,
          width: 0.5,
        ),
      ),
    ),
    child: DepositActionButton(
      text: submitState.maybeWhen(
        submitting: () => 'Đang xử lý...',
        orElse: () => 'Xác nhận chuyển tiền',
      ),
      isEnabled: submitState.maybeWhen(
        submitting: () => false,
        orElse: () => true,
      ),
      onTap: () => _handleConfirm(submitState),
      padding: EdgeInsets.zero,
    ),
  );

  Future<void> _handleConfirm(CryptoSubmitState submitState) async {
    final isSubmitting = submitState.maybeWhen(
      submitting: () => true,
      orElse: () => false,
    );
    if (isSubmitting) {
      return;
    }

    final request = CryptoDepositRequest(
      cryptoType: widget.cryptoOption.id,
      amount: '0',
      depositAddress: widget.cryptoAddressResponse.address,
    );

    await ref.read(cryptoSubmitNotifierProvider.notifier).submit(request);
    final rootContext = Navigator.of(context, rootNavigator: true).context;
    final newState = ref.read(cryptoSubmitNotifierProvider);
    newState.when(
      idle: () {},
      submitting: () {},
      success: () async {
        Navigator.of(context).pop();

        notifyMoneyFlowSuccess(ref, source: TransactionSource.paymentSlip);

        await Future<void>.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          await AppToast.showSuccess(
            rootContext,
            message: 'Chúng tôi đang xác nhận. Vui lòng đợi vài phút !',
          );
        }
      },
      error: (message) {
        if (mounted) {
          AppToast.showError(
            rootContext,
            message: localizedMoneyError('Xác nhận chuyển crypto', message),
          );
        }
      },
    );
  }
}
