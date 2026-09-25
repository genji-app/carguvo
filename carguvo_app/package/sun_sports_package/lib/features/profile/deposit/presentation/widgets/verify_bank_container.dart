import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/error/app_error_messages.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/bank.dart';
import 'package:sun_sports/features/profile/deposit/presentation/providers/deposit_form_providers.dart';
import 'package:sun_sports/features/profile/deposit/presentation/providers/deposit_overlay_provider.dart';
import 'package:sun_sports/features/profile/deposit/presentation/providers/deposit_providers.dart';
import 'package:sun_sports/features/profile/deposit/domain/state/deposit_state.dart';
import 'package:sun_sports/features/profile/deposit/presentation/utils/deposit_navigator.dart';
import 'package:sun_sports/features/profile/deposit/presentation/utils/payment_util.dart';
import 'package:sun_sports/features/profile/deposit/presentation/mobile/deposit_mobile_bottom_sheet.dart';
import 'package:sun_sports/features/profile/deposit/presentation/mobile/verify_bank_completion_bottom_sheet.dart';
import 'package:sun_sports/features/profile/deposit/presentation/web_tablet/verify_bank_completion.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';
import 'package:sun_sports/shared/widgets/buttons/deposit_action_button.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';
import 'package:sun_sports/shared/widgets/forms/selection_field.dart';
import 'package:sun_sports/shared/widgets/forms/selection_menu.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class DigitsOnlyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.length < oldValue.text.length) {
      return newValue;
    }

    final filteredText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (filteredText != newValue.text) {
      return oldValue;
    }

    return newValue;
  }
}

class VerifyBankContainer extends ConsumerStatefulWidget {
  final String? selectedBankId;

  const VerifyBankContainer({super.key, this.selectedBankId});

  @override
  ConsumerState<VerifyBankContainer> createState() =>
      _VerifyBankContainerState();
}

class _VerifyBankContainerState extends ConsumerState<VerifyBankContainer> {
  final TextEditingController _accountNameController = TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(VerifyBankContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedBankId != widget.selectedBankId) {
      _updateSelectedBank();
    }
  }

  void _updateSelectedBank() {
    final banksAsync = ref.read(bankListNoNeedAccountProvider);
    banksAsync.whenData((banks) {
      if (banks.isEmpty || !mounted) return;

      final bankIdToSelect =
          widget.selectedBankId != null &&
              banks.any((bank) => bank.id == widget.selectedBankId)
          ? widget.selectedBankId!
          : banks.first.id;

      final currentFormState = ref.read(verifyBankFormProvider);
      if (currentFormState.selectedBank != bankIdToSelect) {
        ref.read(verifyBankFormProvider.notifier).updateBank(bankIdToSelect);
      }
    });
  }

  @override
  void dispose() {
    _accountNameController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!mounted) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray950,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    'Vui lòng nhập thông tin ngân hàng để xác minh chính chủ cho giao dịch đầu tiên.',
                    style: AppTextStyles.paragraphMedium(
                      color: AppColors.gray25,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  _buildBankSelectionField(),
                  const SizedBox(height: 24),
                  _buildAccountNameField(),
                  const SizedBox(height: 24),
                  _buildAccountNumberField(),
                ],
              ),
            ),
          ),
          _buildConfirmButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() => Container(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
    child: Row(
      children: [
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Xác minh chính chủ',
            style: AppTextStyles.headingXSmall(color: AppColors.gray25),
            textAlign: TextAlign.center,
          ),
        ),
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

  Widget _buildBankSelectionField() {
    if (!mounted) {
      return const SizedBox.shrink();
    }

    final formState = ref.watch(verifyBankFormProvider);

    AsyncValue<List<Bank>> banksAsync;
    try {
      banksAsync = ref.watch(bankListNoNeedAccountProvider);
    } catch (e) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chọn ngân hàng',
          style: AppTextStyles.labelMedium(color: AppColors.gray25),
        ),
        if (formState.bankError != null) ...[
          const SizedBox(height: 4),
          Text(
            formState.bankError!,
            style: AppTextStyles.labelSmall(color: Colors.red),
          ),
        ],
        const SizedBox(height: 6),
        banksAsync.when(
          data: (banks) {
            if (banks.isEmpty) {
              return Container(
                height: 48,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.gray900,
                  border: Border.all(color: AppColors.gray700, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Không có ngân hàng nào',
                    style: AppTextStyles.paragraphMedium(
                      color: AppColors.gray400,
                    ),
                  ),
                ),
              );
            }

            if (banks.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                final currentFormState = ref.read(verifyBankFormProvider);
                if (currentFormState.selectedBank != null) return;

                final bankIdToSelect =
                    widget.selectedBankId != null &&
                        banks.any((bank) => bank.id == widget.selectedBankId)
                    ? widget.selectedBankId!
                    : banks.first.id;

                ref
                    .read(verifyBankFormProvider.notifier)
                    .updateBank(bankIdToSelect);
              });
            }

            final menuItems = banks
                .map(
                  (bank) => SelectionMenuItem(
                    value: bank.id,
                    label: bank.name,
                    iconUrl: PaymentUtil.getIconPayment(
                      name: bank.name,
                      patchIconDefault: bank.iconUrl?.toLowerCase() ?? '',
                    ),
                  ),
                )
                .toList();

            return SelectionField(
              label: '',
              placeholder: 'Chọn ngân hàng',
              selectedValue: formState.selectedBank,
              errorMessage: formState.bankError,
              items: menuItems,
              onSelected: (value) {
                ref.read(verifyBankFormProvider.notifier).updateBank(value);
              },
              iconStyle: SelectionIconStyle.defaultStyle,
              isLoading: false,
            );
          },
          loading: () => SelectionField(
            label: '',
            placeholder: 'Đang tải...',
            selectedValue: null,
            items: const [],
            onSelected: (_) {},
            isLoading: true,
          ),
          error: (error, stack) => SelectionField(
            label: '',
            placeholder: 'Lỗi tải dữ liệu',
            selectedValue: null,
            items: const [],
            onSelected: (_) {},
            errorMessage: logAndGenericError('VerifyBankList', error),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountNameField() {
    final formState = ref.watch(verifyBankFormProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tên Tài khoản',
          style: AppTextStyles.labelMedium(color: AppColors.gray25),
        ),
        if (formState.accountNameError != null) ...[
          const SizedBox(height: 4),
          Text(
            formState.accountNameError!,
            style: AppTextStyles.labelSmall(color: Colors.red),
          ),
        ],
        const SizedBox(height: 6),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.gray900,
            border: Border.all(
              color: formState.accountNameError != null
                  ? Colors.red
                  : AppColors.gray700,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _accountNameController,
            style: AppTextStyles.paragraphMedium(color: AppColors.gray25),
            decoration: InputDecoration(
              hintText: 'Nhập tên tài khoản',
              hintStyle: AppTextStyles.paragraphMedium(
                color: AppColors.gray400,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
            ],
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.characters,
            onChanged: (value) {
              ref
                  .read(verifyBankFormProvider.notifier)
                  .updateAccountName(value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAccountNumberField() {
    final formState = ref.watch(verifyBankFormProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Số tài khoản',
          style: AppTextStyles.labelMedium(color: AppColors.gray25),
        ),
        if (formState.accountNumberError != null) ...[
          const SizedBox(height: 4),
          Text(
            formState.accountNumberError!,
            style: AppTextStyles.labelSmall(color: Colors.red),
          ),
        ],
        const SizedBox(height: 6),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.gray900,
            border: Border.all(
              color: formState.accountNumberError != null
                  ? Colors.red
                  : AppColors.gray700,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _accountNumberController,
            style: AppTextStyles.paragraphMedium(color: AppColors.gray25),
            decoration: InputDecoration(
              hintText: 'Nhập số tài khoản',
              hintStyle: AppTextStyles.paragraphMedium(
                color: AppColors.gray400,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [DigitsOnlyInputFormatter()],
            onChanged: (value) {
              ref
                  .read(verifyBankFormProvider.notifier)
                  .updateAccountNumber(value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    final formState = ref.watch(verifyBankFormProvider);
    final submitState = ref.watch(verifyBankSubmitNotifierProvider);
    final isSubmitting = submitState.maybeWhen(
      submitting: () => true,
      orElse: () => false,
    );
    final isValid = formState.isValid && !isSubmitting;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      child: DepositActionButton(
        text: isSubmitting ? 'Đang xử lý...' : 'Xác nhận',
        isEnabled: isValid,
        onTap: isValid ? _handleConfirm : null,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Future<void> _handleConfirm() async {
    final formNotifier = ref.read(verifyBankFormProvider.notifier);
    final isValid = formNotifier.validate();

    if (!isValid) {
      return;
    }

    final formState = ref.read(verifyBankFormProvider);
    final bankId = formState.selectedBank;
    final accountHolder = formState.accountName.trim();
    final accountNo = formState.accountNumber.trim();

    if (bankId == null ||
        accountHolder.isEmpty ||
        accountNo.isEmpty ||
        !mounted) {
      return;
    }

    final submitNotifier = ref.read(verifyBankSubmitNotifierProvider.notifier);
    final success = await submitNotifier.submit(
      bankId: bankId,
      accountHolder: accountHolder,
      accountNo: accountNo,
    );

    final submitState = ref.read(verifyBankSubmitNotifierProvider);
    if (!success) {
      if (!mounted) return;
      final serverMsg = submitState.maybeWhen(
        error: (msg) => msg,
        orElse: () => null,
      );
      AppToast.showError(
        context,
        message: localizedMoneyError(
          'Xác minh tài khoản ngân hàng',
          serverMsg,
          fallback: 'Không thể xác minh tài khoản ngân hàng',
        ),
      );
      return;
    }

    final rootContext = Navigator.of(context, rootNavigator: true).context;
    final navigator = DepositNavigator();

    await navigator.push(
      context: rootContext,
      mobileShowMethod: (ctx) => VerifyBankCompletionBottomSheet.show(ctx),
      webShowMethod: (ctx) => VerifyBankCompletionOverlay.show(ctx),
      showPreviousDialog: (rootContext, deviceType) async {
        try {
          if (deviceType == DeviceType.mobile) {
            await DepositMobileBottomSheet.show(rootContext);
          } else {
            final container = ProviderScope.containerOf(
              rootContext,
              listen: false,
            );
            container.read(depositOverlayVisibleProvider.notifier).state = true;
            await Future<void>.delayed(const Duration(milliseconds: 100));
          }
        } catch (e) {
        }
      },
    );
  }
}
