import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import 'package:sun_sports/core/error/app_error_messages.dart';
import 'package:sun_sports/core/services/repositories/transaction_repository/transaction_repository.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/payment_method.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/models/codepay_bank.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/codepay_create_qr_request.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/codepay_create_qr_response.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/check_codepay_request.dart';
import 'package:sun_sports/features/profile/deposit/presentation/providers/deposit_form_providers.dart';
import 'package:sun_sports/features/profile/deposit/presentation/providers/deposit_overlay_provider.dart';
import 'package:sun_sports/features/profile/deposit/presentation/notifiers/codepay_qr_timer_notifier.dart';
import 'package:sun_sports/features/profile/deposit/presentation/providers/deposit_providers.dart';
import 'package:sun_sports/features/profile/deposit/domain/state/deposit_state.dart';
import 'package:sun_sports/features/profile/deposit/presentation/utils/deposit_navigator.dart';
import 'package:sun_sports/features/profile/deposit/presentation/utils/payment_util.dart';
import 'package:sun_sports/features/profile/deposit/presentation/mobile/verify_bank_bottom_sheet.dart';
import 'package:sun_sports/features/profile/deposit/presentation/mobile/deposit_mobile_bottom_sheet.dart';
import 'package:sun_sports/features/profile/deposit/presentation/web_tablet/verify_bank_overlay.dart';
import 'package:sun_sports/features/profile/deposit/presentation/mobile/ewallet/ewallet_confirm_money_transfer_bottom_sheet.dart';
import 'package:sun_sports/features/profile/deposit/presentation/web_tablet/ewallet_confirm_money_transfer_overlay.dart';
import 'package:sun_sports/features/profile/deposit/presentation/widgets/codepay_transfer_section.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';
import 'package:sun_sports/shared/widgets/buttons/buttons.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';
import 'package:sun_sports/shared/widgets/forms/amount_input_section.dart';
import 'package:sun_sports/shared/widgets/forms/selection_field.dart';
import 'package:sun_sports/shared/widgets/forms/selection_menu.dart';
import 'package:sun_sports/features/profile/shared/money_flow_success.dart';

class EWalletContainer extends ConsumerStatefulWidget {
  const EWalletContainer({super.key});

  @override
  ConsumerState<EWalletContainer> createState() => _EWalletContainerState();
}

class _EWalletContainerState extends ConsumerState<EWalletContainer> {
  final TextEditingController _amountController = TextEditingController();
  CodepayCreateQrResponse? _savedResponse;
  String?
  _lastCheckedWalletName;
  String?
  _expiredHandledFor;

  @override
  void initState() {
    super.initState();
    final savedAmount = ref.read(ewalletFormProvider).amount;
    if (savedAmount.isNotEmpty) {
      _amountController.text = savedAmount;
    }
    _amountController.addListener(() {
      ref
          .read(ewalletFormProvider.notifier)
          .updateAmount(_amountController.text);
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(ewalletFormProvider);
    final walletsAsync = ref.watch(walletListProvider);
    final deviceType = ResponsiveBuilder.getDeviceType(context);

    ref.listen<CodepaySubmitState>(codepaySubmitNotifierProvider, (
      previous,
      next,
    ) {
      next.maybeWhen(
        success: () => _handleSubmitSuccess(),
        error: (message) => _handleSubmitError(message),
        orElse: () {},
      );
    });

    if (_savedResponse != null) {
      final timerState = ref.watch(
        codepayQrTimerProvider(
          CodepayQrTimerArgs(
            id: _savedResponse!.codepay,
            remainingTime: _savedResponse!.remainingTime,
          ),
        ),
      );
      if (timerState.isExpired &&
          _expiredHandledFor != _savedResponse!.codepay) {
        _expiredHandledFor = _savedResponse!.codepay;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _checkSavedResponseAfterExpiry(formState, walletsAsync);
          }
        });
      }
    }

    final hasValidSavedResponse = _savedResponse != null;

    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: keyboardInset),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                walletsAsync.when(
                  data: (wallets) =>
                      _buildWalletSelectionForm(formState, wallets),
                  loading: () => _buildWalletSelectionForm(formState, []),
                  error: (_, __) => _buildWalletSelectionForm(formState, []),
                ),
                const SizedBox(height: 24),
                if (hasValidSavedResponse)
                  CodepayTransferSection(
                    qrResponse: _savedResponse!,
                    paymentMethod: PaymentMethod.eWallet,
                    layout: deviceType == DeviceType.mobile
                        ? CodepayTransferLayout.mobile
                        : CodepayTransferLayout.web,
                  )
                else
                  AmountInputSection(
                    label: 'Số tiền',
                    controller: _amountController,
                    placeholder: 'Nhập số tiền',
                    quickAmountButtons:
                        DefaultQuickAmountButtons.defaultAmounts,
                    maxDigits: 11,
                  ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        if (!hasValidSavedResponse) _buildBottomButton(formState),
      ],
    );
  }

  Widget _buildWalletSelectionForm(
    EWalletFormState formState,
    List<CodepayBank> wallets,
  ) {
    if (wallets.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'Không có ví điện tử nào',
            style: AppTextStyles.labelMedium(color: AppColors.gray300),
          ),
        ),
      );
    }

    if (formState.selectedWallet == null && wallets.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final firstWalletName = wallets.first.name;
          ref.read(ewalletFormProvider.notifier).updateWallet(firstWalletName);
          _checkSavedResponse(wallets, firstWalletName);
        }
      });
    } else if (formState.selectedWallet != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _checkSavedResponse(wallets, formState.selectedWallet);
        }
      });
    }

    final menuItems = wallets.map((wallet) {
      final iconPath = PaymentUtil.getIconPayment(name: wallet.name);

      return SelectionMenuItem(
        value: wallet.name,
        label: wallet.name,
        iconUrl: iconPath,
      );
    }).toList();

    return SelectionField(
      label: 'Chọn ví',
      placeholder: 'Chọn ví',
      selectedValue: formState.selectedWallet,
      errorMessage: formState.walletError,
      items: menuItems,
      onSelected: (value) {
        ref.read(ewalletFormProvider.notifier).updateWallet(value);
        _checkSavedResponse(wallets, value);
      },
      iconStyle: SelectionIconStyle.defaultStyle,
    );
  }

  Future<void> _checkSavedResponse(
    List<CodepayBank> wallets,
    String? selectedWalletName,
  ) async {
    if (selectedWalletName == null) {
      _lastCheckedWalletName = null;
      setState(() {
        _savedResponse = null;
      });
      return;
    }

    if (_lastCheckedWalletName == selectedWalletName) {
      return;
    }
    _lastCheckedWalletName = selectedWalletName;

    final selectedWallet = wallets.firstWhere(
      (wallet) => wallet.name == selectedWalletName,
      orElse: () => wallets.first,
    );

    if (selectedWallet.accounts.isEmpty) {
      setState(() {
        _savedResponse = null;
      });
      return;
    }

    final firstAccount = selectedWallet.accounts.first;
    final bankAccountId = firstAccount.bankId;

    final checkRequest = CheckCodePayRequest(
      bankAccountId: bankAccountId,
      bankId: selectedWallet.id,
      type: 'cc_v363',
    );

    final checkUseCase = ref.read(checkCodePayUseCaseProvider);
    final result = await checkUseCase(checkRequest);

    result.fold(
      (failure) {
        if (mounted) {
          setState(() {
            _savedResponse = null;
          });
        }
      },
      (response) {
        if (mounted) {
          setState(() {
            _savedResponse = response;
          });
        }
      },
    );
  }

  void _checkSavedResponseAfterExpiry(
    EWalletFormState formState,
    AsyncValue<List<CodepayBank>> walletsAsync,
  ) {
    walletsAsync.whenData((wallets) {
      if (wallets.isEmpty || formState.selectedWallet == null) {
        setState(() {
          _savedResponse = null;
        });
        return;
      }

      _lastCheckedWalletName = null;
      _checkSavedResponse(wallets, formState.selectedWallet);
    });
  }

  Widget _buildBottomButton(EWalletFormState formState) {
    final submitState = ref.watch(codepaySubmitNotifierProvider);

    final isSubmitting = submitState.maybeWhen(
      submitting: () => true,
      orElse: () => false,
    );

    final isEnabled = formState.isValid && !isSubmitting;

    return DepositActionButton(
      text: isSubmitting ? 'Đang xử lý...' : 'Nạp tiền',
      isEnabled: isEnabled,
      onTap: () => _handleSubmit(formState),
    );
  }

  Future<void> _handleSubmit(EWalletFormState formState) async {
    if (!ref.read(ewalletFormProvider.notifier).validate()) {
      return;
    }

    final walletsAsync = ref.read(walletListProvider.future);
    final wallets = await walletsAsync;
    final selectedWalletName = formState.selectedWallet;

    if (selectedWalletName == null || selectedWalletName.isEmpty) {
      return;
    }

    final selectedWallet = wallets.firstWhere(
      (wallet) => wallet.name == selectedWalletName,
      orElse: () => wallets.first,
    );

    if (selectedWallet.accounts.isEmpty) {
      if (mounted) {
        AppToast.showError(context, message: 'Ví không có tài khoản');
      }
      return;
    }

    final firstAccount = selectedWallet.accounts.first;
    final bankAccountId = firstAccount.id;

    final amountText = formState.amount.replaceAll(',', '').replaceAll('.', '');
    final amount = int.tryParse(amountText);

    if (amount == null || amount <= 0) {
      if (mounted) {
        AppToast.showError(context, message: 'Số tiền không hợp lệ');
      }
      return;
    }

    final needVerify = ref.read(needVerifyBankAccountProvider);

    if (needVerify) {
      final rootContext = Navigator.of(context, rootNavigator: true).context;
      final navigator = DepositNavigator();

      await navigator.push(
        context: rootContext,
        mobileShowMethod: (ctx) =>
            VerifyBankBottomSheet.show(ctx, selectedBankId: selectedWallet.id),
        webShowMethod: (ctx) => DepositNavigator.showWebDialog<void>(
          context: ctx,
          builder: (dialogContext, animation, secondaryAnimation) =>
              VerifyBankOverlay(selectedBankId: selectedWallet.id),
        ),
        showPreviousDialog: (rootContext, deviceType) async {
          final container = ProviderScope.containerOf(
            rootContext,
            listen: false,
          );
          if (deviceType == DeviceType.mobile) {
            await DepositMobileBottomSheet.show(rootContext);
            if (rootContext.mounted) {
              container
                  .read(depositSelectionProvider.notifier)
                  .selectPaymentMethod(PaymentMethod.eWallet);
            }
          } else {
            container.read(depositOverlayVisibleProvider.notifier).state = true;
            await Future<void>.delayed(const Duration(milliseconds: 100));
            if (rootContext.mounted) {
              container
                  .read(depositSelectionProvider.notifier)
                  .selectPaymentMethod(PaymentMethod.eWallet);
            }
          }
        },
      );

      return;
    }

    final request = CodepayCreateQrRequest(
      bankId: selectedWallet.id,
      amount: amount,
      bankAccountId: bankAccountId,
    );

    debugPrint('selectedWallet.id: ${selectedWallet.id}');
    debugPrint('bankAccountId: $bankAccountId');
    debugPrint('amount: $amount');

    await ref
        .read(codepaySubmitNotifierProvider.notifier)
        .createCodePay(
          request,
          paymentMethod: PaymentMethod.eWallet,
          walletName: selectedWallet.name,
        );
  }

  void _handleSubmitSuccess() {
    final codepayCreateResponse = ref
        .read(codepaySubmitNotifierProvider.notifier)
        .codepayCreateResponse;

    debugPrint('codepayCreateResponse: ${codepayCreateResponse?.bankAccount}');
    if (codepayCreateResponse == null) {
      return;
    }

    notifyMoneyFlowSuccess(ref, source: TransactionSource.paymentSlip);

    final formState = ref.read(ewalletFormProvider);
    if (formState.selectedWallet != null) {
      setState(() {
        _savedResponse = codepayCreateResponse;
      });
    }

    final rootContext = Navigator.of(context, rootNavigator: true).context;
    final navigator = DepositNavigator();

    navigator.push(
      context: rootContext,
      mobileShowMethod: (ctx) => EWalletConfirmMoneyTransferBottomSheet.show(
        ctx,
        qrResponse: codepayCreateResponse,
        paymentMethod: PaymentMethod.eWallet,
        hideButtons: false,
      ),
      webShowMethod: (ctx) => DepositNavigator.showWebDialog<void>(
        context: ctx,
        builder: (dialogContext, animation, secondaryAnimation) =>
            EWalletConfirmMoneyTransferOverlay(
              qrResponse: codepayCreateResponse,
              paymentMethod: PaymentMethod.eWallet,
              hideButtons: false,
            ),
      ),
      showPreviousDialog: (rootContext, deviceType) async {
        if (deviceType == DeviceType.mobile) {
          await DepositMobileBottomSheet.show(rootContext);
        } else {
          final container = ProviderScope.containerOf(
            rootContext,
            listen: false,
          );
          container.read(depositOverlayVisibleProvider.notifier).state = true;
          await Future<void>.delayed(const Duration(milliseconds: 50));
          if (rootContext.mounted) {
            container
                .read(depositSelectionProvider.notifier)
                .selectPaymentMethod(PaymentMethod.eWallet);
          }
        }
      },
    );
  }

  void _handleSubmitError(String message) {
    if (!mounted) return;

    AppToast.showError(
      context,
      message: localizedMoneyError('Nạp ví điện tử', message),
    );
  }
}
