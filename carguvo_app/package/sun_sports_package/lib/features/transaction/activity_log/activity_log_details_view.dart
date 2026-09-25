// ignore_for_file: unused_element_parameter
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/services/repositories/repositories.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/texts/currency_text.dart';

import 'extensions.dart';

class ActivityLogDetailsView extends StatelessWidget {
  const ActivityLogDetailsView(this.transaction, {super.key});

  final ActivityTransaction transaction;

  @override
  Widget build(BuildContext context) {
    const backgroundColor = AppColorStyles.backgroundTertiary;

    final dateTxt = transaction.displayTime;
    final serviceName = transaction.displayServiceName;
    final serviceIcon = transaction.displayIcon;

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionContainer(
          children: [
            if (serviceName.isNotEmpty)
              _SectionRow(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: [
                    if (serviceIcon != null)
                      SizedBox.square(dimension: 20, child: serviceIcon),
                    Text(
                      serviceName,
                      style: AppTextStyles.labelSmall(
                        color: AppColorStyles.contentPrimary,
                      ),
                    ),
                  ],
                ),
                value: CurrencyText.fromNumber(
                  transaction.amount,
                  prefixText: transaction.prefixText,
                  style: AppTextStyles.labelSmall(
                    color: transaction.amountColor,
                  ),
                ),
                backgoundColor: backgroundColor,
              ),
            const Gap(8),
            _SectionRow(label: const Text('Thời gian'), value: Text(dateTxt)),
            if (serviceName.isNotEmpty)
              _SectionRow(
                label: const Text('Dịch vụ'),
                value: Text(serviceName),
              ),
            const Gap(8),
          ],
        ),
        _SectionContainer(
          children: [
            const _SectionRow(
              label: Text('Chi tiết'),
              backgoundColor: backgroundColor,
            ),
            const Gap(8),
            _DescriptionRow(text: transaction.displayDescription),
            const Gap(8),
          ],
        ),
      ],
    );
  }
}

class _DescriptionRow extends StatelessWidget {
  const _DescriptionRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: _SectionRow.kPadding,
      width: double.infinity,
      child: Text(
        text,
        style: AppTextStyles.labelSmall(color: AppColorStyles.contentPrimary),
      ),
    );
  }
}

class _SectionContainer extends StatelessWidget {
  const _SectionContainer({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    const borderColor = AppColorStyles.borderSecondary;
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 0.5, color: borderColor),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

class _SectionRow extends StatelessWidget {
  const _SectionRow({
    this.label,
    this.value,
    this.trailing,
    this.padding = kPadding,
    this.backgoundColor,
    super.key,
  });

  final Widget? label;
  final Widget? value;
  final Widget? trailing;
  final Color? backgoundColor;
  final EdgeInsetsGeometry? padding;

  static const kPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 10);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      color: backgoundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DefaultTextStyle(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelSmall(
              color: AppColorStyles.contentSecondary,
            ),
            child: label ?? const SizedBox.shrink(),
          ),

          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 16,
              children: [
                DefaultTextStyle(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelSmall(
                    color: AppColorStyles.contentPrimary,
                  ),
                  child: value ?? const SizedBox.shrink(),
                ),

                if (trailing != null) trailing!,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
