import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class TextInputSection extends StatelessWidget {
  final String label;

  final TextEditingController controller;

  final String? placeholder;

  final TextInputType keyboardType;

  final bool showClearButton;

  const TextInputSection({
    super.key,
    required this.label,
    required this.controller,
    this.placeholder,
    this.keyboardType = TextInputType.text,
    this.showClearButton = true,
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
                  keyboardType: keyboardType,
                  style: AppTextStyles.paragraphMedium(color: AppColors.gray25),
                  decoration: InputDecoration(
                    hintText: placeholder ?? 'Nhập thông tin',
                    hintStyle: AppTextStyles.paragraphMedium(
                      color: AppColors.gray400,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (showClearButton)
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
            ],
          ),
        ),
      ],
    );
  }
}
