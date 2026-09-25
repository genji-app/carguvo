import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/payment_method.dart';
import 'package:sun_sports/features/profile/deposit/presentation/utils/clipboard_utils.dart';
import 'package:sun_sports/features/profile/deposit/presentation/utils/deposit_navigator.dart';
import 'package:sun_sports/features/profile/deposit/presentation/widgets/waiting_payment_confirm_section.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/shared/widgets/buttons/shine_button.dart';
import 'package:sun_sports/shared/widgets/cards/inner_shadow_card.dart';
import 'package:sun_sports/shared/widgets/scoin_icon.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class DepositWaitingPaymentConfirmOverlayWeb extends ConsumerStatefulWidget {
  final String amount;
  final PaymentMethod paymentMethod;
  final String transactionCode;
  final String bankName;
  final String accountName;
  final String accountNumber;
  final String note;

  final String? bankBranch;

  const DepositWaitingPaymentConfirmOverlayWeb({
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

  @override
  ConsumerState<DepositWaitingPaymentConfirmOverlayWeb> createState() =>
      _DepositWaitingPaymentConfirmOverlayWebState();
}

class _DepositWaitingPaymentConfirmOverlayWebState
    extends ConsumerState<DepositWaitingPaymentConfirmOverlayWeb> {
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
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: SoundTap.wrap(_handleGoBack),
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
                border: Border.all(color: AppColors.gray700, width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                              child: _buildWaitingPaymentSection(),
                            ),
                    ),
                    _buildBottomButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWaitingPaymentSection() {
    if (widget.paymentMethod == PaymentMethod.scratchCard) {
      return _buildScratchCardWaitingSection();
    }

    return WaitingPaymentConfirmSection(
      amount: widget.amount,
      paymentMethod: widget.paymentMethod,
      transactionCode: widget.transactionCode,
      bankName: widget.bankName,
      accountName: widget.accountName,
      accountNumber: widget.accountNumber,
      note: widget.note,
      bankBranch: widget.bankBranch,
      layout: WaitingPaymentLayout.web,
    );
  }

  Widget _buildScratchCardWaitingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),

        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.green400, width: 2),
                ),
              ),
              child: Text(
                'Nạp tiền',
                style: AppTextStyles.paragraphMedium(color: AppColors.green400),
              ),
            ),
            const SizedBox(width: 24),
            Text(
              'Ví điện tử',
              style: AppTextStyles.paragraphMedium(color: AppColors.gray400),
            ),
          ],
        ),
        const SizedBox(height: 24),

        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.gray700, width: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildScratchCardDetailRow(
                label: 'Số tiền',
                value:
                    '${widget.amount.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                valueColor: AppColors.green400,
                showCopy: false,
              ),
              const SizedBox(height: 12),
              _buildScratchCardDetailRow(
                label: 'ID',
                value: widget.transactionCode,
                valueColor: AppColors.gray25,
                showCopy: true,
                onCopy: () => _copyToClipboard(widget.transactionCode),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.gray700, width: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildScratchCardDetailRow(
                label: 'Loại thẻ',
                value: widget.bankName,
                valueColor: AppColors.gray25,
                showCopy: false,
              ),
              const SizedBox(height: 12),
              _buildScratchCardDetailRow(
                label: 'Số serial',
                value: widget.accountNumber,
                valueColor: AppColors.green400,
                showCopy: true,
                onCopy: () => _copyToClipboard(widget.accountNumber),
              ),
              const SizedBox(height: 12),
              _buildScratchCardDetailRow(
                label: 'Mã thẻ',
                value: widget.note,
                valueColor: AppColors.green400,
                showCopy: true,
                onCopy: () => _copyToClipboard(widget.note),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScratchCardDetailRow({
    required String label,
    required String value,
    required Color valueColor,
    required bool showCopy,
    VoidCallback? onCopy,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: AppTextStyles.labelSmall(color: AppColors.gray300),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.labelSmall(color: valueColor),
            textAlign: TextAlign.right,
          ),
        ),
        Visibility(
          visible: label == 'Số tiền',
          child: const Row(children: [Gap(4), SCoinIcon()]),
        ),
        if (showCopy)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: _buildCopyButton(onCopy ?? () {}),
          ),
      ],
    );
  }

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

  void _handleGoBack() {
    if (!mounted) return;
    DepositNavigator().closeAll<void>(context);
  }

  Widget _buildHeader() => Container(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
    child: Row(
      children: [
        const SizedBox(width: 28),
        Expanded(
          child: Text(
            'Đang chờ xác nhận thanh toán',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.headingSmall(color: AppColors.gray25),
          ),
        ),
        InkWell(
          onTap: SoundTap.wrap(() async {
            _handleGoBack();
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
      onPressed: () async {
        _handleGoBack();
      },
    ),
  );
}
