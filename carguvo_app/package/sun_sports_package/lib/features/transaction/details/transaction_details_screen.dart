import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/transaction/transaction.dart';

class TransactionDetailsScreen extends StatelessWidget {
  const TransactionDetailsScreen({required this.transaction, super.key});

  static MaterialPageRoute<void> route(UnifiedTransaction transaction) =>
      MaterialPageRoute(
        builder: (_) => TransactionDetailsScreen(transaction: transaction),
      );

  final UnifiedTransaction transaction;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorStyles.backgroundSecondary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          transaction.detailsTitle,
          style: AppTextStyles.headingXSmall(
            color: AppColorStyles.contentPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColorStyles.contentPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: TransactionDetailsBody(transaction: transaction),
    );
  }
}
