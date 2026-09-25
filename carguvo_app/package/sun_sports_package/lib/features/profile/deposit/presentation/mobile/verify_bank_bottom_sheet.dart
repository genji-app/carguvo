import 'package:flutter/material.dart';
import 'package:sun_sports/features/profile/deposit/presentation/widgets/verify_bank_container.dart';
import 'package:sun_sports/shared/widgets/bottom_sheet/app_bottom_sheet.dart';

class VerifyBankBottomSheet extends StatelessWidget {
  final String? selectedBankId;

  const VerifyBankBottomSheet({super.key, this.selectedBankId});

  static Future<void> show(
    BuildContext context, {
    String? selectedBankId,
  }) => AppBottomSheet.show(
    context,
    barrierColor: Colors.transparent,
    builder: (_) => VerifyBankBottomSheet(selectedBankId: selectedBankId),
  );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return Dialog(
      backgroundColor: Colors.transparent,
      alignment: Alignment.bottomCenter,
      insetPadding: EdgeInsets.only(top: statusBarHeight),
      child: Container(
        constraints: BoxConstraints(maxHeight: size.height),
        child: VerifyBankContainer(selectedBankId: selectedBankId),
      ),
    );
  }
}
