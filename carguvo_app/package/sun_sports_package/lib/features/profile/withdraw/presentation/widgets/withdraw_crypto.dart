import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/error/app_error_messages.dart';
import 'package:sun_sports/core/services/repositories/transaction_repository/transaction_repository.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/models/fetch_bank_account_data.dart';
import 'package:sun_sports/features/profile/deposit/presentation/providers/deposit_providers.dart';
import 'package:sun_sports/features/profile/deposit/presentation/utils/clipboard_utils.dart';
import 'package:sun_sports/features/profile/withdraw/domain/entities/withdraw_crypto_request.dart';
import 'package:sun_sports/features/profile/withdraw/presentation/providers/withdraw_overlay_provider.dart';
import 'package:sun_sports/features/profile/withdraw/presentation/providers/withdraw_providers.dart';
import 'package:sun_sports/features/profile/withdraw/domain/state/withdraw_state.dart';
import 'package:sun_sports/features/profile/withdraw/presentation/mobile/withdraw_waiting_payment_confirm_bottom_sheet.dart';
import 'package:sun_sports/features/profile/withdraw/presentation/web_tablet/withdraw_waiting_payment_confirm_overlay.dart';
import 'package:sun_sports/features/profile/withdraw/presentation/withdraw_waiting_payment_confirm_container.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/features/profile/deposit/presentation/utils/payment_util.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';
import 'package:sun_sports/shared/widgets/buttons/deposit_action_button.dart';
import 'package:sun_sports/shared/widgets/scoin_icon.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';
import 'package:sun_sports/features/profile/withdraw/domain/models/withdraw_crypto_option.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/forms/amount_input_section.dart'
    show ThousandsSeparatorInputFormatter;
import 'package:sun_sports/features/profile/shared/money_flow_success.dart';

class WithdrawCrypto extends ConsumerStatefulWidget {
  final WithdrawCryptoOption selectedCrypto;

  const WithdrawCrypto({super.key, required this.selectedCrypto});

  @override
  ConsumerState<WithdrawCrypto> createState() => _WithdrawCryptoState();
}

class _WithdrawCryptoState extends ConsumerState<WithdrawCrypto> {
  final TextEditingController _walletAddressController =
      TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _walletAddressController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final depositConfigAsync = ref.watch(configDepositProvider);

    ref.listen<CryptoWithdrawSubmitState>(
      cryptoWithdrawSubmitNotifierProvider,
      (previous, next) {
        next.maybeWhen(
          success: () => _handleSubmitSuccess(),
          error: (message) => _handleSubmitError(message),
          orElse: () {},
        );
      },
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildWarningBanner(),
                  const SizedBox(height: 24),
                  _buildCryptoDisplay(),
                  const SizedBox(height: 24),
                  _buildAmountInput(depositConfigAsync),
                  const SizedBox(height: 24),
                  _buildWalletAddressInput(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
        _buildBottomButton(),
      ],
    );

    return _buildSizedContainer(child: content);
  }

  Widget _buildSizedContainer({required Widget child}) {
    final deviceType = ResponsiveBuilder.getDeviceType(context);
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;

    if (deviceType == DeviceType.mobile) {
      const radius = BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      );
      return Container(
        width: size.width,
        constraints: BoxConstraints(
          maxHeight: size.height - mediaQuery.padding.top,
        ),
        decoration: const BoxDecoration(
          color: AppColorStyles.backgroundSecondary,
          borderRadius: radius,
        ),
        child: ClipRRect(borderRadius: radius, child: child),
      );
    }

    return Container(
      width: 640,
      height: 823,
      constraints: BoxConstraints(maxHeight: size.height * 0.9),
      decoration: BoxDecoration(
        color: AppColorStyles.backgroundSecondary,
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
            blurStyle: BlurStyle.inner,
            color: Colors.white.withValues(alpha: 0.12),
          ),
        ],
        border: Border.all(color: AppColors.gray700, width: 1),
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(24), child: child),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          InkWell(
            onTap: SoundTap.wrap(() => Navigator.of(context).pop()),
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.arrow_back, color: AppColors.gray25, size: 24),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Rút tiền điện tử',
                style: AppTextStyles.headingSmall(color: AppColors.gray25),
              ),
            ),
          ),
          InkWell(
            onTap: SoundTap.wrap(() => Navigator.of(context).pop()),
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.close, color: AppColors.gray25, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.yellow400.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.info_outline,
                size: 20,
                color: AppColors.yellow400,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Nhập chính xác mã ví nhận tiền. Chúng tôi không chịu trách nhiệm nếu bạn nhập sai mã ví.',
              style: AppTextStyles.paragraphSmall(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCryptoDisplay() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(32)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: ImageHelper.load(
                path: PaymentUtil.getCryptoIconPath(
                  widget.selectedCrypto.name,
                ),
                width: 64,
                height: 64,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.selectedCrypto.name,
            style: AppTextStyles.headingMedium(color: AppColors.gray25),
          ),
          const SizedBox(height: 4),
          Text(
            widget.selectedCrypto.network,
            style: AppTextStyles.paragraphSmall(color: AppColors.gray300),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInput(
    AsyncValue<FetchBankAccountsData> depositConfigAsync,
  ) {
    return depositConfigAsync.when(
      data: (depositData) {
        final availableBalance =
            '20,000,000';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Số tiền',
              style: AppTextStyles.labelSmall(color: AppColors.gray25),
            ),
            const SizedBox(height: 6),
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.gray900,
                border: Border.all(color: AppColors.gray700, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      style: AppTextStyles.paragraphMedium(
                        color: AppColors.gray25,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Tối thiểu 200,000',
                        hintStyle: AppTextStyles.paragraphMedium(
                          color: AppColors.gray400,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      inputFormatters: [ThousandsSeparatorInputFormatter()],
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _amountController,
                    builder: (context, value, child) {
                      if (value.text.isNotEmpty) {
                        return GestureDetector(
                          onTap: SoundTap.wrap(() => _amountController.clear()),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.close,
                                  size: 20,
                                  color: AppColors.gray25,
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const Gap(4),
                  const SCoinIcon(),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: SoundTap.wrap(() {
                      _amountController.text = availableBalance;
                    }),
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Text(
                        'Tối đa',
                        style: AppTextStyles.labelSmall(
                          color: AppColors.yellow400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildWalletAddressInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Địa chỉ ví',
          style: AppTextStyles.labelSmall(color: AppColors.gray25),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.gray900,
            border: Border.all(color: AppColors.gray700, width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _walletAddressController,
                  style: AppTextStyles.paragraphMedium(color: AppColors.gray25),
                  decoration: InputDecoration(
                    hintText: 'Nhập địa chỉ ví',
                    hintStyle: AppTextStyles.paragraphMedium(
                      color: AppColors.gray400,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  keyboardType: TextInputType.text,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: SoundTap.wrap(() => _pasteWalletAddress()),
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Text(
                    'Dán',
                    style: AppTextStyles.labelSmall(color: AppColors.yellow400),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pasteWalletAddress() async {
    await ClipboardUtils.pasteToController(
      controller: _walletAddressController,
    );
  }

  Widget _buildBottomButton() {
    final submitState = ref.watch(cryptoWithdrawSubmitNotifierProvider);

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _walletAddressController,
      builder: (context, walletValue, _) {
        return ValueListenableBuilder<TextEditingValue>(
          valueListenable: _amountController,
          builder: (context, amountValue, _) {
            final isValid =
                walletValue.text.trim().isNotEmpty &&
                amountValue.text.trim().isNotEmpty;

            final isSubmitting = submitState.maybeWhen(
              submitting: () => true,
              orElse: () => false,
            );

            return DepositActionButton(
              text: isSubmitting ? 'Đang xử lý...' : 'Rút tiền',
              isEnabled: isValid && !isSubmitting,
              onTap: isValid && !isSubmitting ? _handleSubmit : null,
            );
          },
        );
      },
    );
  }

  Future<void> _handleSubmit() async {
    final rootContext = context;
    final walletAddress = _walletAddressController.text.trim();
    final amountText = _amountController.text.trim();

    if (walletAddress.isEmpty) {
      AppToast.showError(rootContext, message: 'Vui lòng nhập địa chỉ ví');
      return;
    }

    if (amountText.isEmpty) {
      AppToast.showError(rootContext, message: 'Vui lòng nhập số tiền');
      return;
    }

    final amountInt = int.tryParse(
      amountText.replaceAll(',', '').replaceAll('.', ''),
    );

    if (amountInt == null || amountInt <= 0) {
      AppToast.showError(rootContext, message: 'Số tiền không hợp lệ');
      return;
    }

    final network = widget.selectedCrypto.network.toUpperCase();
    final cryptoCurrency = widget.selectedCrypto.name.toUpperCase();

    final request = WithdrawCryptoRequest(
      network: network,
      cryptoCurrency: cryptoCurrency,
      fiatCurrency: 'VND',
      amount: amountInt,
      address: walletAddress,
    );

    await ref
        .read(cryptoWithdrawSubmitNotifierProvider.notifier)
        .submit(request);
  }

  void _handleSubmitSuccess() {
    if (!mounted) return;

    notifyMoneyFlowSuccess(ref, source: TransactionSource.paymentSlip);

    final rootContext = Navigator.of(context, rootNavigator: true).context;
    final deviceType = ResponsiveBuilder.getDeviceType(context);
    final walletAddress = _walletAddressController.text.trim();
    final amount = _amountController.text.trim();

    final confirmationData = WithdrawConfirmationData(
      amount: amount,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      methodType: WithdrawPaymentMethodType.crypto,
      currencyType: widget.selectedCrypto.name,
      network: widget.selectedCrypto.fullName,
      walletAddress: walletAddress,
    );

    ref.read(withdrawConfirmationDataProvider.notifier).state =
        confirmationData;

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    if (deviceType == DeviceType.mobile) {
    } else {
      ref.read(withdrawOverlayVisibleProvider.notifier).state = false;
    }

    Future<void>.delayed(const Duration(milliseconds: 300), () {
      if (!rootContext.mounted) return;

      if (deviceType == DeviceType.mobile) {
        final navigatorState = Navigator.of(rootContext);
        if (navigatorState.canPop()) {
          navigatorState.pop();
        }
        Future<void>.delayed(const Duration(milliseconds: 300), () {
          if (!rootContext.mounted) return;
          WithdrawMobileWaitingPaymentConfirmBottomSheet.show(rootContext);
        });
      } else {
        showGeneralDialog(
          context: rootContext,
          barrierColor: Colors.black.withValues(alpha: 0.5),
          barrierDismissible: true,
          barrierLabel: MaterialLocalizations.of(
            rootContext,
          ).modalBarrierDismissLabel,
          transitionDuration: const Duration(milliseconds: 200),
          pageBuilder: (dialogContext, animation, secondaryAnimation) {
            return const WithdrawWaitingPaymentConfirmOverlayWeb();
          },
        );
      }
    });
  }

  void _handleSubmitError(String message) {
    if (!mounted) return;
    AppToast.showError(
      context,
      message: localizedMoneyError('Rút crypto', message),
    );
  }
}
