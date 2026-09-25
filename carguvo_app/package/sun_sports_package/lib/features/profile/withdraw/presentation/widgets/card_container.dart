import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/error/app_error_messages.dart';
import 'package:sun_sports/core/services/repositories/transaction_repository/transaction_repository.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/models/cashout_gift_card.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/models/cashout_gift_card_item.dart';
import 'package:sun_sports/features/profile/deposit/presentation/providers/deposit_providers.dart';
import 'package:sun_sports/features/profile/deposit/presentation/utils/payment_util.dart';
import 'package:sun_sports/features/profile/withdraw/domain/entities/withdraw_card_request.dart';
import 'package:sun_sports/features/profile/withdraw/presentation/providers/withdraw_card_form_provider.dart';
import 'package:sun_sports/features/profile/withdraw/presentation/providers/withdraw_overlay_provider.dart';
import 'package:sun_sports/features/profile/withdraw/presentation/providers/withdraw_providers.dart';
import 'package:sun_sports/features/profile/withdraw/presentation/mobile/withdraw_waiting_payment_confirm_bottom_sheet.dart';
import 'package:sun_sports/features/profile/withdraw/presentation/web_tablet/withdraw_waiting_payment_confirm_overlay.dart';
import 'package:sun_sports/features/profile/withdraw/presentation/withdraw_waiting_payment_confirm_container.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';
import 'package:sun_sports/shared/widgets/buttons/deposit_action_button.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';
import 'package:sun_sports/shared/widgets/forms/selection_field.dart';
import 'package:sun_sports/shared/widgets/forms/selection_menu.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/features/profile/shared/money_flow_success.dart';

class WithdrawCardContainer extends ConsumerStatefulWidget {
  const WithdrawCardContainer({super.key});

  @override
  ConsumerState<WithdrawCardContainer> createState() =>
      _WithdrawCardContainerState();
}

class _WithdrawCardContainerState extends ConsumerState<WithdrawCardContainer> {
  bool _isSubmitting = false;

  String? get _selectedCardType => ref.read(withdrawCardFormProvider).cardType;
  String? get _selectedDenomination =>
      ref.read(withdrawCardFormProvider).denomination;
  int get _quantity => ref.read(withdrawCardFormProvider).quantity;

  @override
  Widget build(BuildContext context) {
    final cardTypesAsync = ref.watch(cardTypeListProvider);
    final formState = ref.watch(withdrawCardFormProvider);
    final denominations = ref.watch(
      denominationListProvider(formState.cardType),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                cardTypesAsync.when(
                  data: (cardTypes) => _buildCardTypeSelectionForm(cardTypes),
                  loading: () => _buildCardTypeSelectionForm([]),
                  error: (_, __) => _buildCardTypeSelectionForm([]),
                ),
                const SizedBox(height: 24),
                _buildDenominationForm(denominations),
                const SizedBox(height: 24),
                _buildQuantityForm(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        _buildBottomButton(),
      ],
    );
  }

  Widget _buildCardTypeSelectionForm(List<CashoutGiftCard> cardTypes) {
    if (cardTypes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'Không có loại thẻ nào',
            style: AppTextStyles.labelMedium(color: AppColors.gray300),
          ),
        ),
      );
    }

    if (_selectedCardType == null && cardTypes.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(withdrawCardFormProvider.notifier).state = ref
              .read(withdrawCardFormProvider)
              .copyWith(cardType: cardTypes.first.name);
        }
      });
    }

    final menuItems = cardTypes
        .map(
          (cardType) => SelectionMenuItem(
            value: cardType.name,
            label: cardType.name,
            iconUrl: PaymentUtil.getIconPayment(
              name: cardType.name,
              patchIconDefault: cardType.url.toString().toLowerCase(),
            ),
          ),
        )
        .toList();

    return SelectionField(
      label: 'Chọn thẻ',
      placeholder: 'Chọn thẻ',
      selectedValue: _selectedCardType,
      items: menuItems,
      onSelected: (value) {
        ref.read(withdrawCardFormProvider.notifier).state = ref
            .read(withdrawCardFormProvider)
            .copyWith(cardType: value, clearDenomination: true);
      },
      iconStyle: SelectionIconStyle.defaultStyle,
    );
  }

  Widget _buildDenominationForm(List<String> denominations) {
    if (denominations.isEmpty) {
      return const SizedBox.shrink();
    }

    final denominationButtons = denominations.take(8).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mệnh giá',
          style: AppTextStyles.labelSmall(color: AppColors.gray25),
        ),
        const SizedBox(height: 6),
        Column(
          children: [
            Row(
              children: [
                for (
                  int i = 0;
                  i < 3 && i < denominationButtons.length;
                  i++
                ) ...[
                  Expanded(
                    child: _buildDenominationButton(denominationButtons[i]),
                  ),
                  if (i < 2 && i < denominationButtons.length - 1) const Gap(8),
                ],
              ],
            ),
            if (denominationButtons.length > 3) ...[
              const Gap(8),
              Row(
                children: [
                  for (
                    int i = 3;
                    i < 6 && i < denominationButtons.length;
                    i++
                  ) ...[
                    Expanded(
                      child: _buildDenominationButton(denominationButtons[i]),
                    ),
                    if (i < 5 && i < denominationButtons.length - 1)
                      const Gap(8),
                  ],
                ],
              ),
            ],
            if (denominationButtons.length > 6) ...[
              const Gap(8),
              Row(
                children: [
                  for (int i = 6; i < denominationButtons.length; i++) ...[
                    Expanded(
                      child: _buildDenominationButton(denominationButtons[i]),
                    ),
                    if (i < denominationButtons.length - 1) const Gap(8),
                  ],
                ],
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildDenominationButton(String denomination) {
    final isSelected = _selectedDenomination == denomination;

    return GestureDetector(
      onTap: SoundTap.wrap(() {
        ref.read(withdrawCardFormProvider.notifier).state = ref
            .read(withdrawCardFormProvider)
            .copyWith(denomination: denomination);
      }),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.gray700,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.yellow700 : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            denomination,
            style: AppTextStyles.paragraphMedium(color: AppColors.yellow200),
            textAlign: TextAlign.center,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.visible,
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityForm() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Số lượng thẻ muốn rút',
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: SoundTap.wrap(() {
                if (_quantity > 1) {
                  ref.read(withdrawCardFormProvider.notifier).state = ref
                      .read(withdrawCardFormProvider)
                      .copyWith(quantity: _quantity - 1);
                }
              }),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.yellow300,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.remove, size: 16, color: Colors.black),
              ),
            ),
            const Gap(8),
            Text(
              _quantity.toString(),
              style: AppTextStyles.paragraphMedium(color: AppColors.gray25),
            ),
            const Gap(8),
            GestureDetector(
              onTap: SoundTap.wrap(() {
                ref.read(withdrawCardFormProvider.notifier).state = ref
                    .read(withdrawCardFormProvider)
                    .copyWith(quantity: _quantity + 1);
              }),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.yellow300,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, size: 16, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _buildBottomButton() {
    final isValid = _selectedCardType != null && _selectedDenomination != null;

    return DepositActionButton(
      text: _isSubmitting ? 'Đang xử lý...' : 'Rút tiền',
      isEnabled: isValid && !_isSubmitting,
      onTap: isValid && !_isSubmitting ? _handleSubmit : null,
    );
  }

  String? _findItemId(String? cardTypeName, String? denomination) {
    if (cardTypeName == null || denomination == null) {
      return null;
    }

    final depositDataAsync = ref.read(configDepositProvider);
    return depositDataAsync.when(
      data: (depositData) {
        try {
          final selectedCard = depositData.cashoutGiftCards.firstWhere(
            (CashoutGiftCard card) => card.name == cardTypeName,
          );

          final denominationAmount = int.tryParse(
            denomination.replaceAll(',', '').replaceAll(' VND', ''),
          );

          if (denominationAmount == null) {
            return null;
          }

          final matchingItem = selectedCard.items.firstWhere(
            (CashoutGiftCardItem item) =>
                item.amount == denominationAmount && item.active,
            orElse: () => selectedCard.items.first,
          );

          return matchingItem.id;
        } catch (e) {
          return null;
        }
      },
      loading: () => null,
      error: (_, __) => null,
    );
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;

    final rootContext = Navigator.of(context, rootNavigator: true).context;
    final deviceType = ResponsiveBuilder.getDeviceType(context);

    final itemId = _findItemId(_selectedCardType, _selectedDenomination);
    if (itemId == null) {
      if (mounted) {
        AppToast.showError(
          context,
          message: 'Không tìm thấy thông tin thẻ. Vui lòng thử lại.',
        );
      }
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final useCase = ref.read(submitWithdrawCardUseCaseProvider);
      final request = WithdrawCardRequest(itemId: itemId);
      final result = await useCase(request);

      result.fold(
        (failure) {
          if (mounted) {
            AppToast.showError(
              context,
              message: localizedMoneyError('Rút thẻ', failure.message),
            );
          }
        },
        (response) {
          notifyMoneyFlowSuccess(
            ref,
            source: TransactionSource.cardWithdraw,
            watchBalance: false,
          );

          final denominationString = _selectedDenomination!
              .replaceAll(',', '')
              .replaceAll(' VND', '');
          final denominationValue = int.tryParse(denominationString) ?? 0;
          final totalAmount = (denominationValue * _quantity).toString();

          final confirmationData = WithdrawConfirmationData(
            amount: totalAmount,
            id: response.data.message ?? '',
            methodType: WithdrawPaymentMethodType.card,
            cardType: _selectedCardType,
            quantity: _quantity,
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
              WithdrawMobileWaitingPaymentConfirmBottomSheet.show(rootContext);
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
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
