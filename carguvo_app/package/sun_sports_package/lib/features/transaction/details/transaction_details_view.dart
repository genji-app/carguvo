import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/services/sportbook_api.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/transaction/transaction.dart';
import 'package:sun_sports/shared/widgets/buttons/buttons.dart';
import 'package:sun_sports/shared/widgets/texts/currency_text.dart';

import '../payment_config/payment_config.dart';

class TransactionDetailsView extends ConsumerWidget {
  const TransactionDetailsView(this.transaction, {super.key});

  final UnifiedTransaction transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const backgroundColor = AppColorStyles.backgroundTertiary;

    final accountName = transaction.accountName;
    final accountNumber = transaction.accountNumber;
    final bankId = transaction.bankId;

    final amount = transaction.actualAmount;
    final paymentMethod = transaction.paymentMethod;
    final status = transaction.status;
    final date = transaction.date;
    final transferContent = transaction.transactionCode;

    final idTxt = transaction.id;
    final statusTxt = transaction.statusDescription;
    final dateTxt = DateFormat('HH:mm - dd/MM/yyyy').format(date);
    final paymentMethodTxt = paymentMethod.label;

    final paymentInfo = ref.watch(paymentMethodInfoProvider(bankId));
    final bankNameTxt = paymentInfo?.displayName ?? I18n.txtNotAvailable;

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionContainer(
          children: [
            _SectionRow(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  SizedBox.square(
                    dimension: 20,
                    child: transaction.slipType.icon,
                  ),
                  Text(
                    transaction.slipType.label,
                    style: AppTextStyles.labelSmall(
                      color: AppColorStyles.contentPrimary,
                    ),
                  ),
                ],
              ),

              value: CurrencyText.fromNumber(
                amount,
                prefixText: transaction.amountPrefix,
                style: AppTextStyles.labelSmall(
                  color: transaction.slipType.amountColor,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              backgoundColor: backgroundColor,
            ),
            const Gap(8),

            _SectionRow(
              label: const Text(I18n.txtStatus),
              value: TransactionStatusBadge(
                statusDescription: statusTxt,
                status: status,
              ),
            ),

            _SectionRow(label: const Text('Thời gian'), value: Text(dateTxt)),

            _SectionRow(
              label: const Text(I18n.txtMethod),
              value: Text(paymentMethodTxt),
            ),

            _SectionRow(label: const Text(I18n.txtID), value: Text(idTxt)),

            const Gap(8),
          ],
        ),

        if (bankId.isNotEmpty || accountName != null || accountNumber != null)
          _SectionContainer(
            children: [
              if (bankId.isNotEmpty)
                _SectionRow(
                  label: const Text(I18n.txtBank),
                  value: Text(bankNameTxt),
                ),
              if (accountName != null)
                _SectionRow(
                  label: const Text(I18n.txtAccountName),
                  value: Text(accountName),
                ),
              if (accountNumber != null)
                _SectionRow(
                  label: const Text(I18n.txtAccountNumber),
                  value: Text(accountNumber),
                  trailing: ClipboradCopyField.iconButton(
                    copyvalue: accountNumber,
                  ),
                ),
              if (transferContent.isNotEmpty)
                _SectionRow(
                  label: const Text(I18n.txtContent),
                  value: Text(transferContent),
                  trailing: ClipboradCopyField.iconButton(
                    copyvalue: transferContent,
                  ),
                ),
            ],
          )
        else if (transaction.cardCode != null || transaction.cardSerial != null)
          _SectionContainer(
            children: [
              if (transaction.cardTelcoName != null)
                _SectionRow(
                  label: const Text('Loại thẻ'),
                  value: Text(transaction.cardTelcoName!),
                ),
              if (transaction.cardCode != null)
                _SectionRow(
                  label: const Text('Mã thẻ'),
                  value: Text(transaction.cardCode!),
                  trailing: ClipboradCopyField.iconButton(
                    copyvalue: transaction.cardCode!,
                  ),
                ),
              if (transaction.cardSerial != null)
                _SectionRow(
                  label: const Text('Số serial'),
                  value: Text(transaction.cardSerial!),
                  trailing: ClipboradCopyField.iconButton(
                    copyvalue: transaction.cardSerial!,
                  ),
                ),
            ],
          )
        else if (transferContent.isNotEmpty)
          _SectionContainer(
            children: [
              _SectionRow(
                label: const Text(I18n.txtContent),
                value: Text(transferContent),
                trailing: ClipboradCopyField.iconButton(
                  copyvalue: transferContent,
                ),
              ),
            ],
          ),

        if (transaction.notes != null && transaction.notes!.isNotEmpty)
          _SectionContainer(
            children: [
              _SectionRow(
                label: Text(
                  'Ghi chú',
                  style: AppTextStyles.labelSmall(
                    color: AppColorStyles.contentPrimary,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                backgoundColor: backgroundColor,
              ),
              _SectionRow(label: Text(transaction.notes!)),
              const Gap(8),
            ],
          ),
      ],
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
  });

  final Widget? label;
  final Widget? value;
  final Widget? trailing;
  final Color? backgoundColor;
  final EdgeInsetsGeometry? padding;

  static const kPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 10);

  @override
  Widget build(BuildContext context) => Container(
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

class _SectionContainer extends StatelessWidget {
  const _SectionContainer({required this.children});

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
