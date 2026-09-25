import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/error/app_error_messages.dart';
import 'package:sun_sports/core/services/repositories/transaction_repository/transaction_repository.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/profile/deposit/domain/constants/deposit_constants.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/card_deposit_request.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/models/cashout_gift_card.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/models/fetch_bank_account_data.dart';
import 'package:sun_sports/features/profile/deposit/presentation/providers/deposit_overlay_provider.dart';
import 'package:sun_sports/features/profile/deposit/presentation/providers/deposit_providers.dart';
import 'package:sun_sports/features/profile/deposit/presentation/providers/deposit_form_providers.dart';
import 'package:sun_sports/features/profile/deposit/domain/state/deposit_state.dart';
import 'package:sun_sports/features/profile/deposit/presentation/utils/clipboard_utils.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/features/profile/deposit/presentation/utils/payment_util.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';
import 'package:sun_sports/shared/widgets/buttons/buttons.dart';
import 'package:sun_sports/shared/widgets/scoin_icon.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';
import 'package:sun_sports/shared/widgets/forms/selection_field.dart';
import 'package:sun_sports/shared/widgets/forms/selection_menu.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/features/profile/shared/money_flow_success.dart';

class CardContainer extends ConsumerStatefulWidget {
  const CardContainer({super.key});

  @override
  ConsumerState<CardContainer> createState() => _CardContainerState();
}

class _CardContainerState extends ConsumerState<CardContainer> {
  final TextEditingController _serialNumberController = TextEditingController();
  final TextEditingController _cardCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final cardState = ref.read(cardFormProvider);
    if (cardState.serialNumber.isNotEmpty) {
      _serialNumberController.text = cardState.serialNumber;
    }
    if (cardState.cardCode.isNotEmpty) {
      _cardCodeController.text = cardState.cardCode;
    }

    _serialNumberController.addListener(() {
      ref
          .read(cardFormProvider.notifier)
          .updateSerialNumber(_serialNumberController.text);
    });
    _cardCodeController.addListener(() {
      ref
          .read(cardFormProvider.notifier)
          .updateCardCode(_cardCodeController.text);
    });
  }

  @override
  void dispose() {
    _serialNumberController.dispose();
    _cardCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCardType = ref.watch(
      cardFormProvider.select((state) => state.selectedCardType),
    );
    final formState = ref.watch(cardFormProvider);
    final cardTypesAsync = ref.watch(telcoListProvider);
    final denominations = ref.watch(
      telcoDenominationListProvider(selectedCardType),
    );

    ref.listen<CardSubmitState>(cardSubmitNotifierProvider, (previous, next) {
      next.maybeWhen(
        success: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _handleSubmitSuccess();
          });
        },
        error: (message) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _handleSubmitError(message);
          });
        },
        orElse: () {},
      );
    });

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
                SizedBox(height: DepositUIConstants.defaultSpacing),
                cardTypesAsync.when(
                  data: (card) => _buildCardSelectionForm(formState, card),
                  loading: () => _buildCardSelectionForm(formState, []),
                  error: (_, __) => _buildCardSelectionForm(formState, []),
                ),
                if (cardTypesAsync.maybeWhen(
                  data: (cardTypes) =>
                      cardTypes.isNotEmpty && selectedCardType != null,
                  orElse: () => false,
                )) ...[
                  SizedBox(height: DepositUIConstants.defaultSpacing),
                  _buildDenominationForm(formState, denominations),
                  SizedBox(height: 6),
                  _buildActualReceivedAmount(formState),
                ],
                SizedBox(height: DepositUIConstants.defaultSpacing),
                _buildSerialNumberForm(),
                SizedBox(height: DepositUIConstants.defaultSpacing),
                _buildCardCodeForm(),
                SizedBox(height: DepositUIConstants.bottomSpacing),
              ],
            ),
          ),
        ),
        _buildBottomButton(formState),
      ],
    );
  }

  Widget _buildCardSelectionForm(
    CardFormState formState,
    List<CashoutGiftCard> cardTypes,
  ) {
    if (cardTypes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'Không có thẻ nào',
            style: AppTextStyles.labelMedium(color: AppColors.gray300),
          ),
        ),
      );
    } else {
      String? selectedCardType = formState.selectedCardType;
      if (selectedCardType == null && cardTypes.isNotEmpty) {
        selectedCardType = cardTypes.first.name;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ref
                .read(cardFormProvider.notifier)
                .updateCardType(selectedCardType);
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
                patchIconDefault: cardType.url.isNotEmpty ? cardType.url : '',
              ),
            ),
          )
          .toList();

      return SelectionField(
        label: 'Chọn thẻ',
        placeholder: 'Chọn thẻ',
        selectedValue: formState.selectedCardType,
        errorMessage: formState.cardTypeError,
        items: menuItems,
        onSelected: (value) =>
            ref.read(cardFormProvider.notifier).updateCardType(value),
        iconStyle: SelectionIconStyle.defaultStyle,
      );
    }
  }

  Widget _buildDenominationForm(
    CardFormState formState,
    List<String> denominations,
  ) {
    final menuItems = denominations
        .map(
          (denomination) =>
              SelectionMenuItem(value: denomination, label: denomination),
        )
        .toList();

    return SelectionField(
      label: 'Mệnh giá',
      placeholder: 'Chọn mệnh giá',
      selectedValue: formState.selectedDenomination,
      errorMessage: formState.denominationError,
      items: menuItems,
      onSelected: (value) =>
          ref.read(cardFormProvider.notifier).updateDenomination(value),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    );
  }

  Widget _buildActualReceivedAmount(CardFormState formState) {
    final depositConfigAsync = ref.watch(configDepositProvider);

    return depositConfigAsync.when(
      data: (depositData) {
        final actualReceived = _calculateActualReceivedAmount(
          depositData,
          formState.selectedCardType,
          formState.selectedDenomination,
        );

        if (actualReceived == null) {
          return const SizedBox.shrink();
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Thực nhận',
              style: AppTextStyles.labelXSmall(color: AppColors.gray25),
            ),
            Row(
              children: [
                Text(
                  _formatAmount(actualReceived),
                  style: AppTextStyles.labelXSmall(color: AppColors.yellow400),
                ),
                const Gap(4),
                const SCoinIcon(),
              ],
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  int? _calculateActualReceivedAmount(
    FetchBankAccountsData depositData,
    String? selectedCard,
    String? selectedDenomination,
  ) {
    if (selectedCard == null || selectedDenomination == null) {
      return null;
    }

    try {
      final denominationAmount = int.tryParse(
        selectedDenomination.replaceAll(',', '').replaceAll('.', ''),
      );

      if (denominationAmount == null) {
        return null;
      }

      if (depositData.telcos.isEmpty) {
        return null;
      }

      final telco = depositData.telcos.firstWhere(
        (CashoutGiftCard telco) => telco.name == selectedCard,
        orElse: () => depositData.telcos.first,
      );

      if (telco.exchangeRates.isEmpty) {
        return null;
      }

      final exchangeRate = telco.exchangeRates.firstWhere((
        Map<String, dynamic> rate,
      ) {
        final rateAmount = rate['amount'];
        if (rateAmount is int) {
          return rateAmount == denominationAmount;
        } else if (rateAmount is String) {
          final parsed = int.tryParse(
            rateAmount.replaceAll(',', '').replaceAll('.', ''),
          );
          return parsed == denominationAmount;
        }
        return false;
      }, orElse: () => <String, dynamic>{});

      if (exchangeRate.isEmpty) {
        return null;
      }

      final gold = exchangeRate['gold'];
      if (gold is int) {
        return gold;
      } else if (gold is String) {
        return int.tryParse(gold.replaceAll(',', '').replaceAll('.', ''));
      } else if (gold is num) {
        return gold.toInt();
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  String _formatAmount(int amount) {
    final formatted = amount.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return '$formatted';
  }

  Widget _buildSerialNumberForm() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Số Seri',
        style: AppTextStyles.labelSmall(
          color: AppColors.gray300,
        ),
      ),
      const SizedBox(height: 8),
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
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _serialNumberController,
                style: AppTextStyles.paragraphMedium(color: AppColors.gray25),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.number,
                scrollPadding: EdgeInsets.only(
                  bottom: (MediaQuery.viewInsetsOf(context).bottom - 88)
                      .clamp(0.0, double.infinity),
                ),
              ),
            ),
            const Gap(8),
            InkWell(
              onTap: SoundTap.wrap(() => _pasteSerialNumber()),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  'Dán',
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

  Widget _buildCardCodeForm() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Mã thẻ',
        style: AppTextStyles.labelSmall(
          color: AppColors.gray300,
        ),
      ),
      const SizedBox(height: 8),
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
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _cardCodeController,
                style: AppTextStyles.paragraphMedium(color: AppColors.gray25),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.number,
                scrollPadding: EdgeInsets.only(
                  bottom: (MediaQuery.viewInsetsOf(context).bottom - 88)
                      .clamp(0.0, double.infinity),
                ),
              ),
            ),
            const Gap(8),
            InkWell(
              onTap: SoundTap.wrap(() => _pasteCardCode()),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  'Dán',
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

  static final RegExp _digitsOnlyReg = RegExp(r'^[0-9]+$');

  Future<void> _pasteSerialNumber() async {
    await ClipboardUtils.pasteToController(
      controller: _serialNumberController,
      onPaste: (text) {
        if (!_digitsOnlyReg.hasMatch(text)) {
          _serialNumberController.clear();
          ref.read(cardFormProvider.notifier).updateSerialNumber('');
          if (mounted) {
            AppToast.showError(context, message: 'Số seri chỉ chứa số');
          }
          return;
        }
        ref.read(cardFormProvider.notifier).updateSerialNumber(text);
      },
    );
  }

  Future<void> _pasteCardCode() async {
    await ClipboardUtils.pasteToController(
      controller: _cardCodeController,
      onPaste: (text) {
        if (!_digitsOnlyReg.hasMatch(text)) {
          _cardCodeController.clear();
          ref.read(cardFormProvider.notifier).updateCardCode('');
          if (mounted) {
            AppToast.showError(context, message: 'Mã thẻ chỉ chứa số');
          }
          return;
        }
        ref.read(cardFormProvider.notifier).updateCardCode(text);
      },
    );
  }

  Widget _buildBottomButton(CardFormState formState) {
    final submitState = ref.watch(cardSubmitNotifierProvider);

    final isSubmitting = submitState.maybeWhen(
      submitting: () => true,
      orElse: () => false,
    );

    final isEnabled = formState.isValid && !isSubmitting;

    return DepositActionButton(
      text: isSubmitting ? 'Đang xử lý...' : 'Xác nhận',
      isEnabled: isEnabled,
      onTap: () => _handleSubmit(formState),
    );
  }

  Future<void> _handleSubmit(CardFormState formState) async {
    if (!ref.read(cardFormProvider.notifier).validate()) return;

    final depositDataAsync = ref.read(configDepositProvider.future);
    final depositData = await depositDataAsync;

    if (depositData.telcos.isEmpty) {
      if (mounted) {
        AppToast.showError(context, message: 'Không có loại thẻ nào');
      }
      return;
    }

    final selectedTelco = depositData.telcos.firstWhere(
      (CashoutGiftCard telco) => telco.name == formState.selectedCardType,
      orElse: () => depositData.telcos.first,
    );

    final denominationAmount = int.tryParse(
      formState.selectedDenomination!.replaceAll(',', '').replaceAll('.', ''),
    );

    if (denominationAmount == null) {
      if (mounted) {
        AppToast.showError(
          context,
          message: DepositErrorMessages.invalidDenomination,
        );
      }
      return;
    }

    final request = CardDepositRequest(
      serial: formState.serialNumber.trim(),
      code: formState.cardCode.trim(),
      telcoId: selectedTelco.id,
      amount: denominationAmount,
    );

    await ref.read(cardSubmitNotifierProvider.notifier).submit(request);
  }

  void _handleSubmitSuccess() {
    if (!mounted) return;

    try {
      final response = ref
          .read(cardSubmitNotifierProvider.notifier)
          .cardDepositResponse;
      final additionalData = response?.additionalData;

      final status = additionalData?['status'];

      String? apiMessage;
      final data = additionalData?['data'];
      if (data is Map<String, dynamic>) {
        final raw = data['message']?.toString();
        if (raw != null && raw.isNotEmpty) apiMessage = raw;
      }
      apiMessage ??= additionalData?['processing_message']?.toString();
      final toastMessage = (apiMessage != null && apiMessage.isNotEmpty)
          ? apiMessage
          : DepositErrorMessages.processing;

      notifyMoneyFlowSuccess(
        ref,
        source: TransactionSource.cardDeposit,
        refreshBalance: status == 0,
        firstWatchInterval: const Duration(seconds: 10),
      );

      AppToast.showSuccess(context, message: toastMessage);

      _dismissDepositForm();
    } catch (e) {
      if (mounted) {
        AppToast.showError(
          context,
          message: logAndGenericError('_handleSubmitSuccess', e),
        );
      }
    }
  }

  void _dismissDepositForm() {
    final isMobile = ResponsiveBuilder.isMobile(context);
    if (isMobile) {
      Navigator.of(context).pop();
    } else {
      ref.read(depositOverlayVisibleProvider.notifier).state = false;
    }
  }

  void _handleSubmitError(String message) {
    if (!mounted) return;
    AppToast.showError(
      context,
      message: localizedMoneyError('Nạp thẻ cào', message),
    );
  }
}
