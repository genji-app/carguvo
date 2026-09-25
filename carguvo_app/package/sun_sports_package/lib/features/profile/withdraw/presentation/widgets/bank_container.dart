import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/error/app_error_messages.dart';
import 'package:sun_sports/core/services/repositories/transaction_repository/transaction_repository.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/models/bank_account_item.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/models/fetch_bank_account_data.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/models/verified_bank_account.dart';
import 'package:sun_sports/features/profile/deposit/presentation/providers/deposit_providers.dart';
import 'package:sun_sports/features/profile/deposit/presentation/utils/payment_util.dart';
import 'package:sun_sports/features/profile/withdraw/presentation/providers/withdraw_overlay_provider.dart';
import 'package:sun_sports/features/profile/withdraw/presentation/providers/withdraw_providers.dart';
import 'package:sun_sports/features/profile/withdraw/domain/entities/withdraw_bank_request.dart';
import 'package:sun_sports/features/profile/withdraw/domain/state/withdraw_state.dart';
import 'package:sun_sports/features/profile/withdraw/presentation/mobile/withdraw_waiting_payment_confirm_bottom_sheet.dart';
import 'package:sun_sports/features/profile/withdraw/presentation/web_tablet/withdraw_waiting_payment_confirm_overlay.dart';
import 'package:sun_sports/features/profile/withdraw/presentation/withdraw_waiting_payment_confirm_container.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';
import 'package:sun_sports/shared/widgets/buttons/deposit_action_button.dart';
import 'package:sun_sports/shared/widgets/scoin_icon.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';
import 'package:sun_sports/shared/widgets/forms/selection_field.dart';
import 'package:sun_sports/shared/widgets/forms/selection_menu.dart';
import 'package:sun_sports/shared/widgets/forms/amount_input_section.dart'
    show ThousandsSeparatorInputFormatter;
import 'package:sun_sports/features/profile/shared/money_flow_success.dart';

class WithdrawBankContainer extends ConsumerStatefulWidget {
  const WithdrawBankContainer({super.key});

  @override
  ConsumerState<WithdrawBankContainer> createState() =>
      _WithdrawBankContainerState();
}

class _WithdrawBankContainerState extends ConsumerState<WithdrawBankContainer> {
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _accountNameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  bool _isAccountNumberReadOnly = false;
  bool _isAccountNameReadOnly = true;
  bool _isSubmitting = false;
  bool _isUpdatingProgrammatically =
      false;
  String?
  _lastUpdatedBankId;
  bool _isAccountNameInitialized = false;

  @override
  void initState() {
    super.initState();

    final savedAmount = ref.read(withdrawBankFormProvider).amount;
    if (savedAmount.isNotEmpty) {
      _amountController.text = savedAmount;
    }
  }

  void _onAccountNumberChanged(String value) {
    if (_isUpdatingProgrammatically) return;
    ref.read(withdrawBankFormProvider.notifier).updateAccountNumber(value);
  }

  void _onAccountNameChanged(String value) {
    if (_isUpdatingProgrammatically) return;
    ref.read(withdrawBankFormProvider.notifier).updateAccountName(value);
  }

  void _onAmountChanged(String value) {
    if (_isUpdatingProgrammatically) return;
    ref.read(withdrawBankFormProvider.notifier).updateAmount(value);
  }

  void _initializeAccountName(FetchBankAccountsData depositData) {
    if (_isAccountNameInitialized) return;
    _isAccountNameInitialized = true;

    try {
      final verifiedAccounts = depositData.verifiedBankAccounts;
      _isUpdatingProgrammatically = true;

      if (verifiedAccounts.isEmpty) {
        setState(() {
          _isAccountNameReadOnly = false;
        });
        _isUpdatingProgrammatically = false;
        return;
      }

      final firstVerifiedAccount = verifiedAccounts.first;
      final accountHolder = firstVerifiedAccount.accountHolder;

      _accountNameController.text = accountHolder;
      ref
          .read(withdrawBankFormProvider.notifier)
          .updateAccountName(accountHolder);

      setState(() {
        _isAccountNameReadOnly = true;
      });

      _isUpdatingProgrammatically = false;
    } catch (e) {
      debugPrint('Error initializing account name: $e');
      setState(() {
        _isAccountNameReadOnly = false;
      });
      _isUpdatingProgrammatically = false;
    }
  }

  void _updateAccountNumberForBank(
    FetchBankAccountsData depositData,
    String bankId,
  ) {
    if (_lastUpdatedBankId == bankId) {
      return;
    }
    _lastUpdatedBankId = bankId;

    try {
      final verifiedAccounts = depositData.verifiedBankAccounts;
      _isUpdatingProgrammatically = true;

      VerifiedBankAccount? matchedAccount;
      if (verifiedAccounts.isNotEmpty) {
        try {
          matchedAccount = verifiedAccounts.firstWhere(
            (account) => account.bankId == bankId,
          );
        } catch (e) {
          matchedAccount = null;
        }
      }

      if (matchedAccount != null) {
        final accountNo = matchedAccount.accountNo;
        _accountNumberController.text = accountNo;
        ref
            .read(withdrawBankFormProvider.notifier)
            .updateAccountNumber(accountNo);

        setState(() {
          _isAccountNumberReadOnly =
              true;
        });
      } else {
        if (_accountNumberController.text.isNotEmpty) {
          _accountNumberController.clear();
          ref.read(withdrawBankFormProvider.notifier).updateAccountNumber('');
        }

        setState(() {
          _isAccountNumberReadOnly = false;
        });
      }

      _isUpdatingProgrammatically = false;
    } catch (e) {
      debugPrint('Error updating account number for bank: $e');
      setState(() {
        _isAccountNumberReadOnly = false;
      });
      _isUpdatingProgrammatically = false;
    }
  }

  @override
  void dispose() {
    _accountNumberController.dispose();
    _accountNameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(withdrawBankFormProvider);
    final depositConfigAsync = ref.watch(configDepositProvider);

    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: keyboardInset),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _buildBankSelectionForm(formState, depositConfigAsync),
                const SizedBox(height: 24),
                _buildAccountNumberForm(),
                const SizedBox(height: 24),
                _buildAccountNameForm(),
                const SizedBox(height: 24),
                _buildAmountForm(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        _buildBottomButton(),
      ],
    );
  }

  Widget _buildBankSelectionForm(
    WithdrawBankFormState formState,
    AsyncValue<FetchBankAccountsData> depositConfigAsync,
  ) => depositConfigAsync.when(
    data: (depositData) {
      final banksWithAccounts = depositData.items
          .toList();

      if (banksWithAccounts.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text(
              'Không có ngân hàng nào',
              style: AppTextStyles.labelMedium(color: AppColors.gray300),
            ),
          ),
        );
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _initializeAccountName(depositData);
        }
      });

      if (formState.selectedBank == null && banksWithAccounts.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            final firstBankId = banksWithAccounts.first.id;
            ref.read(withdrawBankFormProvider.notifier).updateBank(firstBankId);
            _updateAccountNumberForBank(depositData, firstBankId);
          }
        });
      } else if (formState.selectedBank != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _updateAccountNumberForBank(depositData, formState.selectedBank!);
          }
        });
      }

      final menuItems = banksWithAccounts
          .map(
            (BankAccountItem bank) => SelectionMenuItem(
              value: bank.id,
              label: bank.name,
              iconUrl: PaymentUtil.getIconPayment(
                name: bank.name,
                patchIconDefault: bank.url.toString().toLowerCase(),
              ),
            ),
          )
          .toList();

      return SelectionField(
        label: 'Ngân hàng',
        placeholder: 'Chọn ngân hàng',
        selectedValue: formState.selectedBank,
        errorMessage: formState.bankError,
        items: menuItems,
        onSelected: (value) {
          ref.read(withdrawBankFormProvider.notifier).updateBank(value);
          _updateAccountNumberForBank(depositData, value);
        },
        iconStyle: SelectionIconStyle.defaultStyle,
        isLoading: false,
      );
    },
    loading: () => SelectionField(
      label: 'Ngân hàng',
      placeholder: 'Đang tải...',
      selectedValue: null,
      items: const [],
      onSelected: (_) {},
      isLoading: true,
    ),
    error: (error, stack) => SelectionField(
      label: 'Ngân hàng',
      placeholder: 'Lỗi tải dữ liệu',
      selectedValue: null,
      items: const [],
      onSelected: (_) {},
      errorMessage: logAndGenericError('WithdrawBankList', error),
    ),
  );

  Widget _buildAccountNumberForm() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Số tài khoản',
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
        child: TextField(
          controller: _accountNumberController,
          readOnly: _isAccountNumberReadOnly,
          style: AppTextStyles.paragraphMedium(color: AppColors.gray25),
          decoration: InputDecoration(
            hintText: 'Nhập số tài khoản',
            hintStyle: AppTextStyles.paragraphMedium(color: AppColors.gray400),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          keyboardType: TextInputType.number,
          onChanged: _onAccountNumberChanged,
          scrollPadding: EdgeInsets.only(
            bottom: (MediaQuery.viewInsetsOf(context).bottom - 88)
                .clamp(0.0, double.infinity),
          ),
        ),
      ),
    ],
  );

  Widget _buildAccountNameForm() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Chủ tài khoản',
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
        child: TextField(
          controller: _accountNameController,
          readOnly: _isAccountNameReadOnly,
          style: AppTextStyles.paragraphMedium(color: AppColors.gray25),
          decoration: InputDecoration(
            hintText: 'Nhập tên tài khoản',
            hintStyle: AppTextStyles.paragraphMedium(color: AppColors.gray400),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
          ],
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.characters,
          onChanged: _onAccountNameChanged,
          scrollPadding: EdgeInsets.only(
            bottom: (MediaQuery.viewInsetsOf(context).bottom - 88)
                .clamp(0.0, double.infinity),
          ),
        ),
      ),
    ],
  );

  Widget _buildAmountForm() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Số tiền', style: AppTextStyles.labelSmall(color: AppColors.gray25)),
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
                style: AppTextStyles.paragraphMedium(color: AppColors.gray25),
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
                onChanged: _onAmountChanged,
                scrollPadding: EdgeInsets.only(
                  bottom: (MediaQuery.viewInsetsOf(context).bottom - 88)
                      .clamp(0.0, double.infinity),
                ),
              ),
            ),
            const Gap(4),
            const SCoinIcon(),
          ],
        ),
      ),
    ],
  );

  Widget _buildBottomButton() {
    final formState = ref.watch(withdrawBankFormProvider);
    final isValid = formState.isValid;

    return DepositActionButton(
      text: _isSubmitting ? 'Đang xử lý...' : 'Rút tiền',
      isEnabled: isValid && !_isSubmitting,
      onTap: isValid && !_isSubmitting ? _handleSubmit : null,
    );
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _isSubmitting = true;
    });

    final formState = ref.read(withdrawBankFormProvider);
    final depositConfigAsync = ref.read(configDepositProvider);

    final rootContext = Navigator.of(context, rootNavigator: true).context;
    final deviceType = ResponsiveBuilder.getDeviceType(context);

    try {
      await depositConfigAsync.whenData((depositData) async {
        final selectedBank = depositData.items.firstWhere(
          (bank) => bank.id == formState.selectedBank,
          orElse: () => depositData.items.first,
        );

        final amountInt =
            int.tryParse(
              formState.amount.replaceAll(',', '').replaceAll('.', ''),
            ) ??
            0;
        if (amountInt <= 0) {
          if (mounted) {
            AppToast.showError(context, message: 'Số tiền không hợp lệ');
          }
          return;
        }

        final request = WithdrawBankRequest(
          bankId: selectedBank.id,
          accountNumber: formState.accountNumber,
          accountName: formState.accountName,
          amount: amountInt,
          slipType: 2,
        );

        final usecase = ref.read(submitWithdrawBankUseCaseProvider);
        final result = await usecase(request);

        result.fold(
          (failure) {
            if (mounted) {
              AppToast.showError(
                context,
                message: localizedMoneyError('Rút ngân hàng', failure.message),
              );
            }
          },
          (response) {
            notifyMoneyFlowSuccess(
              ref,
              source: TransactionSource.paymentSlip,
              watchBalance: false,
            );

            final transactionId = DateTime.now().millisecondsSinceEpoch
                .toString();

            final confirmationData = WithdrawConfirmationData(
              amount: formState.amount,
              id: transactionId,
              methodType: WithdrawPaymentMethodType.bank,
              bankName: selectedBank.name,
              accountName: formState.accountName,
              accountNumber: formState.accountNumber,
            );

            ref.read(withdrawConfirmationDataProvider.notifier).state =
                confirmationData;

            if (deviceType == DeviceType.mobile) {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            } else {
              ref.read(withdrawOverlayVisibleProvider.notifier).state = false;
            }

            Future<void>.delayed(const Duration(milliseconds: 300), () {
              if (!rootContext.mounted) return;
              if (deviceType == DeviceType.mobile) {
                WithdrawMobileWaitingPaymentConfirmBottomSheet.show(
                  rootContext,
                );
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
          },
        );
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
