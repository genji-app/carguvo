import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/shared/widgets/buttons/quick_amount_buttons.dart';
import 'package:sun_sports/shared/widgets/scoin_icon.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  ThousandsSeparatorInputFormatter({this.maxDigits});

  final int? maxDigits;

  static final RegExp _nonDigit = RegExp(r'[^0-9]');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(_nonDigit, '');
    if (digits.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final normalized = digits.replaceFirst(RegExp(r'^0+(?=\d)'), '');

    final limit = maxDigits;
    if (limit != null && normalized.length > limit) return oldValue;

    final formatted = normalized.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class DefaultQuickAmountButtons {
  DefaultQuickAmountButtons._();

  static const Map<String, String> defaultAmounts = {
    '+50K': '50,000',
    '+100K': '100,000',
    '+500K': '500,000',
    '+1M': '1,000,000',
    '+5M': '5,000,000',
    '+10M': '10,000,000',
    '+50M': '50,000,000',
    '+100M': '100,000,000',
  };
}

class AmountInputSection extends StatelessWidget {
  final String label;

  final TextEditingController controller;

  final String? placeholder;

  final Map<String, String> quickAmountButtons;

  final double spacing;

  final int? maxDigits;

  const AmountInputSection({
    super.key,
    required this.label,
    required this.controller,
    this.placeholder,
    required this.quickAmountButtons,
    this.spacing = 16,
    this.maxDigits,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelSmall(color: AppColors.gray25)),
        const SizedBox(height: 6),
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
                  controller: controller,
                  style: AppTextStyles.paragraphMedium(color: AppColors.gray25),
                  decoration: InputDecoration(
                    hintText: placeholder ?? 'Nhập số tiền',
                    hintStyle: AppTextStyles.paragraphMedium(
                      color: AppColors.gray400,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  inputFormatters: [
                    ThousandsSeparatorInputFormatter(maxDigits: maxDigits),
                  ],
                  keyboardType: TextInputType.number,
                  scrollPadding: EdgeInsets.only(
                    bottom: (MediaQuery.viewInsetsOf(context).bottom - 88)
                        .clamp(0.0, double.infinity),
                  ),
                ),
              ),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, child) {
                  if (value.text.isNotEmpty) {
                    return GestureDetector(
                      onTap: SoundTap.wrap(() {
                        controller.clear();
                      }),
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
              const SCoinIcon(),
            ],
          ),
        ),
        SizedBox(height: spacing),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, child) => QuickAmountButtons(
            useExternalSelection: true,
            externalSelectedValue: value.text,
            buttons: quickAmountButtons.entries
                .map(
                  (entry) =>
                      QuickAmountButton(label: entry.key, value: entry.value),
                )
                .toList(),
            onButtonTap: (amount) {
              controller.value = TextEditingValue(
                text: amount,
                selection: TextSelection.collapsed(offset: amount.length),
              );
            },
          ),
        ),
      ],
    );
  }
}
