import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/error/app_error_messages.dart';
import 'package:sun_sports/core/services/repositories/transaction_repository/transaction_repository.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/bank_transaction_slip_request.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/models/bank_account_item.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/payment_method.dart';
import 'package:sun_sports/features/profile/deposit/domain/state/deposit_state.dart';
import 'package:sun_sports/features/profile/deposit/mobile_waiting_payment_confirm_bottom_sheet.dart';
import 'package:sun_sports/features/profile/deposit/presentation/providers/deposit_form_providers.dart';
import 'package:sun_sports/features/profile/deposit/presentation/providers/deposit_providers.dart';
import 'package:sun_sports/features/profile/deposit/presentation/utils/deposit_navigator.dart';
import 'package:sun_sports/features/profile/deposit/presentation/web_tablet/deposit_waiting_payment_confirm_overlay.dart';
import 'package:sun_sports/features/profile/shared/money_flow_success.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';
import 'package:sun_sports/shared/widgets/buttons/deposit_action_button.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/forms/amount_input_section.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';

class BankConfirmMoneyTransferContainer extends ConsumerStatefulWidget {
  final BankAccountItem bankAccountItem;
  final PaymentMethod paymentMethod;
  final BuildContext parentContext;

  const BankConfirmMoneyTransferContainer({
    super.key,
    required this.bankAccountItem,
    required this.paymentMethod,
    required this.parentContext,
  });

  @override
  ConsumerState<BankConfirmMoneyTransferContainer> createState() =>
      _BankConfirmMoneyTransferContainerState();
}

class _BankConfirmMoneyTransferContainerState
    extends ConsumerState<BankConfirmMoneyTransferContainer> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _senderNameController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  bool _hasSubmitted = false;

  String? get _accountId => widget.bankAccountItem.accounts.isNotEmpty
      ? widget.bankAccountItem.accounts.first.id
      : null;

  int? get _accountType => widget.bankAccountItem.accounts.isNotEmpty
      ? widget.bankAccountItem.accounts.first.type
      : null;

  @override
  void dispose() {
    _amountController.removeListener(() {});
    _senderNameController.removeListener(() {});
    _noteController.removeListener(() {});
    _amountController.dispose();
    _senderNameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    ref.read(bankTransactionSlipNotifierProvider.notifier).reset();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.listenManual<BankTransactionSlipState>(
          bankTransactionSlipNotifierProvider,
          (previous, next) {
            if (!_hasSubmitted) {
              return;
            }

            next.maybeWhen(
              success: () {
                _handleSubmitSuccess();
                _hasSubmitted = false;
              },
              error: (message) {
                _handleSubmitError(message);
                _hasSubmitted = false;
              },
              orElse: () {},
            );
          },
        );
      }
    });

    final bankState = ref.read(bankFormProvider);
    if (bankState.amount.isNotEmpty) {
      _amountController.text = bankState.amount;
    }
    if (bankState.senderName.isNotEmpty) {
      _senderNameController.text = bankState.senderName;
    }
    if (bankState.note.isNotEmpty) {
      _noteController.text = bankState.note;
    }

    _amountController.addListener(() {
      ref.read(bankFormProvider.notifier).updateAmount(_amountController.text);
    });
    _senderNameController.addListener(() {
      ref
          .read(bankFormProvider.notifier)
          .updateSenderName(_senderNameController.text.trim());
    });
    _noteController.addListener(() {
      ref
          .read(bankFormProvider.notifier)
          .updateNote(_noteController.text.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(bankFormProvider);
    final submitState = ref.watch(bankTransactionSlipNotifierProvider);

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
                _buildAmountInput(formState),
                const SizedBox(height: 24),
                _buildSenderNameInput(formState),
                const SizedBox(height: 24),
                _buildNoteInput(formState),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        _buildBottomButton(formState, submitState),
      ],
    );
  }

  Widget _buildHeader() => Container(
    padding: const EdgeInsets.fromLTRB(17, 12, 16, 12),
    child: Row(
      children: [
        InkWell(
          onTap: SoundTap.wrap(() {
            DepositNavigator().pop<void>(context);
          }),
          child: Container(
            width: 20,
            height: 20,
            color: Colors.transparent,
            child: ImageHelper.load(
              path: AppIcons.icBack,
              width: 20,
              height: 20,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Nạp tiền ngân hàng',
            style: AppTextStyles.headingXSmall(color: AppColors.gray25),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: 32),
        InkWell(
          onTap: SoundTap.wrap(() {
            DepositNavigator().closeAll<void>(context);
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

  Widget _buildInfoBanner() => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.yellow400.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ImageHelper.load(path: AppIcons.icWarning, width: 20, height: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Sau khi chuyển khoản thành công, vui lòng nhập các thông tin dưới đây để xác nhận chuyển khoản',
            style: AppTextStyles.paragraphXSmall(color: AppColors.gray25),
          ),
        ),
      ],
    ),
  );

  Widget _buildAmountInput(BankFormState formState) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AmountInputSection(
        label: 'Số tiền',
        controller: _amountController,
        placeholder: 'Nhập số tiền đã chuyển',
        quickAmountButtons: DefaultQuickAmountButtons.defaultAmounts,
      ),
      if (formState.amountError != null) ...[
        const SizedBox(height: 4),
        Text(
          formState.amountError!,
          style: AppTextStyles.labelSmall(color: Colors.red),
        ),
      ],
    ],
  );

  Widget _buildSenderNameInput(BankFormState formState) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Người gửi',
        style: AppTextStyles.labelSmall(color: AppColors.gray25),
      ),
      if (formState.senderNameError != null) ...[
        const SizedBox(height: 4),
        Text(
          formState.senderNameError!,
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
            color: formState.senderNameError != null
                ? Colors.red
                : AppColors.gray700,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _senderNameController,
          style: AppTextStyles.paragraphMedium(color: AppColors.gray25),
          decoration: InputDecoration(
            hintText: 'Nhập tên người gửi tiền',
            hintStyle: AppTextStyles.paragraphMedium(color: AppColors.gray400),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    ],
  );

  Widget _buildNoteInput(BankFormState formState) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Ghi chú', style: AppTextStyles.labelSmall(color: AppColors.gray25)),
      if (formState.noteError != null) ...[
        const SizedBox(height: 4),
        Text(
          formState.noteError!,
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
            color: formState.noteError != null ? Colors.red : AppColors.gray700,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _noteController,
          style: AppTextStyles.paragraphMedium(color: AppColors.gray25),
          decoration: InputDecoration(
            hintText: 'Điền mã chính xác mã giao dịch',
            hintStyle: AppTextStyles.paragraphMedium(color: AppColors.gray400),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    ],
  );

  Widget _buildBottomButton(
    BankFormState formState,
    BankTransactionSlipState submitState,
  ) {
    final isSubmitting = submitState.maybeWhen(
      submitting: () => true,
      orElse: () => false,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 40),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.gray700, width: 0.5)),
      ),
      child: DepositActionButton(
        text: isSubmitting ? 'Đang xử lý...' : 'Xác nhận',
        isEnabled: !isSubmitting && formState.isConfirmFormValid,
        onTap: _handleConfirm,
      ),
    );
  }

  Future<void> _handleConfirm() async {
    if (!ref.read(bankFormProvider.notifier).validateConfirmForm()) {
      AppToast.showError(context, message: 'Vui lòng kiểm tra lại thông tin');
      return;
    }

    final formState = ref.read(bankFormProvider);

    if (_accountId == null || _accountType == null) {
      AppToast.showError(
        context,
        message: 'Không tìm thấy thông tin tài khoản',
      );
      return;
    }

    final cleanedAmount = formState.amount
        .replaceAll(',', '')
        .replaceAll('.', '');
    final amountValue = int.tryParse(cleanedAmount);

    if (amountValue == null || amountValue <= 0) {
      AppToast.showError(context, message: 'Số tiền không hợp lệ');
      return;
    }

    final senderName = formState.senderName.trim();
    final transactionCode = formState.note.trim();

    final request = BankTransactionSlipRequest(
      bankAccountId: _accountId!,
      amount: amountValue,
      accountName: senderName,
      transactionCode: transactionCode,
      type: _accountType!,
    );

    _hasSubmitted = true;

    await ref
        .read(bankTransactionSlipNotifierProvider.notifier)
        .createTransactionSlip(request);
  }

  void _handleSubmitSuccess() {
    final transactionCode = _noteController.text.trim();
    final amountText = _amountController.text.trim();
    final cleanedAmount = amountText.replaceAll(',', '').replaceAll('.', '');

    if (!mounted) {
      return;
    }

    notifyMoneyFlowSuccess(
      ref,
      source: TransactionSource.paymentSlip,
      watchBalance: false,
    );

    final rootContext = Navigator.of(context, rootNavigator: true).context;
    final deviceType = ResponsiveBuilder.getDeviceType(context);

    Navigator.of(rootContext).pop();

    Future<void>.delayed(const Duration(milliseconds: 300), () async {
      if (!rootContext.mounted) {
        return;
      }

      final accounts = widget.bankAccountItem.accounts;
      final firstAccount = accounts.isNotEmpty ? accounts.first : null;

      if (deviceType == DeviceType.mobile) {
        DepositMobileWaitingPaymentConfirmBottomSheet.show(
          rootContext,
          amount: cleanedAmount,
          paymentMethod: widget.paymentMethod,
          transactionCode: transactionCode,
          bankName: widget.bankAccountItem.name,
          accountName: firstAccount?.accountName ?? '',
          accountNumber: firstAccount?.accountNumber ?? '',
          note: transactionCode,
          bankBranch: firstAccount?.bankBranch,
        );
      } else {
        await showGeneralDialog(
          context: rootContext,
          barrierColor: Colors.transparent,
          barrierDismissible: true,
          barrierLabel: MaterialLocalizations.of(
            rootContext,
          ).modalBarrierDismissLabel,
          transitionDuration: const Duration(milliseconds: 200),
          pageBuilder: (dialogContext, animation, secondaryAnimation) =>
              DepositWaitingPaymentConfirmOverlayWeb(
                amount: cleanedAmount,
                paymentMethod: widget.paymentMethod,
                transactionCode: transactionCode,
                bankName: widget.bankAccountItem.name,
                accountName: firstAccount?.accountName ?? '',
                accountNumber: firstAccount?.accountNumber ?? '',
                note: transactionCode,
                bankBranch: firstAccount?.bankBranch,
              ),
        );
      }
    });
  }

  void _handleSubmitError(String message) {
    AppToast.showError(
      context,
      message: localizedMoneyError('Xác nhận chuyển khoản', message),
    );
  }
}
