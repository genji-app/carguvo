import 'package:flutter/material.dart';
import 'package:sun_sports/core/services/repositories/repositories.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/transaction/transaction.dart';

class TransactionStatusBadge extends StatelessWidget {
  final String statusDescription;
  final TransactionStatus status;

  const TransactionStatusBadge({
    required this.status,
    required this.statusDescription,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final color = status.color;

    return SizedBox(
      height: 24,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: ShapeDecoration(
          color: color.withValues(alpha: 0.12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        child: DefaultTextStyle(
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: AppTextStyles.labelSmall(
            color: color,
          ).copyWith(fontWeight: FontWeight.w500),
          child: Text(statusDescription),
        ),
      ),
    );
  }
}
