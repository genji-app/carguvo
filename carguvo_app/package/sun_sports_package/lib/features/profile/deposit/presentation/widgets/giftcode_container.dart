import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/error/app_error_messages.dart';
import 'package:sun_sports/core/services/repositories/transaction_repository/transaction_repository.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/giftcode_deposit_request.dart';
import 'package:sun_sports/features/profile/deposit/presentation/providers/deposit_form_providers.dart';
import 'package:sun_sports/features/profile/deposit/presentation/providers/deposit_providers.dart';
import 'package:sun_sports/features/profile/deposit/domain/state/deposit_state.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/providers/user_provider/user_provider.dart';
import 'package:sun_sports/shared/widgets/buttons/buttons.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';
import 'package:sun_sports/features/profile/shared/money_flow_success.dart';

class GiftCodeContainer extends ConsumerStatefulWidget {
  const GiftCodeContainer({super.key});

  @override
  ConsumerState<GiftCodeContainer> createState() => _GiftCodeContainerState();
}

class _GiftCodeContainerState extends ConsumerState<GiftCodeContainer> {
  final TextEditingController _giftCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final savedGiftCode = ref.read(giftcodeFormProvider).giftCode;
    if (savedGiftCode.isNotEmpty) {
      _giftCodeController.text = savedGiftCode;
    }
    _giftCodeController.addListener(() {
      ref
          .read(giftcodeFormProvider.notifier)
          .updateGiftcode(_giftCodeController.text);
    });
  }

  @override
  void dispose() {
    _giftCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(giftcodeFormProvider);
    final submitState = ref.watch(giftcodeSubmitNotifierProvider);

    ref.listen<GiftcodeSubmitState>(giftcodeSubmitNotifierProvider, (
      previous,
      next,
    ) {
      next.maybeWhen(
        success: (message) {
          if (!mounted) return;
          AppToast.showSuccess(
            context,
            message: message ?? 'Sử dụng giftcode thành công',
          );

          notifyMoneyFlowSuccess(ref, source: TransactionSource.paymentSlip);

          _giftCodeController.clear();
          ref.read(giftcodeFormProvider.notifier).reset();
          ref.read(giftcodeSubmitNotifierProvider.notifier).reset();
        },
        error: (message) {
          if (!mounted) return;
          if (message.isNotEmpty) {
            AppToast.showError(
              context,
              message: localizedMoneyError('Nạp giftcode', message),
            );
          }
          ref.read(giftcodeSubmitNotifierProvider.notifier).reset();
        },
        orElse: () {},
      );
    });

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildGiftCodeForm(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          _buildBottomButton(formState, submitState),
        ],
      ),
    );
  }

  Widget _buildGiftCodeForm() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.gray900,
          border: Border.all(
            color: AppColors.gray700,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _giftCodeController,
          style: AppTextStyles.paragraphMedium(color: AppColors.gray25),
          decoration: InputDecoration(
            hintText: 'Nhập Giftcode',
            hintStyle: AppTextStyles.paragraphMedium(
              color: AppColors.gray400,
            ).copyWith(fontWeight: FontWeight.w400),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
          keyboardType: TextInputType.text,
        ),
      ),
    ],
  );

  Widget _buildBottomButton(
    GiftcodeFormState formState,
    GiftcodeSubmitState submitState,
  ) {
    final isSubmitting = submitState.maybeWhen(
      submitting: () => true,
      orElse: () => false,
    );
    return DepositActionButton(
      text: isSubmitting ? 'Đang xử lý...' : 'Xác nhận',
      isEnabled: formState.isValid && !isSubmitting,
      onTap: () => _handleSubmit(formState),
    );
  }

  Future<void> _handleSubmit(GiftcodeFormState formState) async {
    if (!ref.read(giftcodeFormProvider.notifier).validate()) return;

    final isSubmitting = ref
        .read(giftcodeSubmitNotifierProvider)
        .maybeWhen(submitting: () => true, orElse: () => false);
    if (isSubmitting) return;

    await ref
        .read(giftcodeSubmitNotifierProvider.notifier)
        .submit(GiftcodeDepositRequest(giftCode: formState.giftCode));
  }
}
