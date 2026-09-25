import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/services/repositories/repositories.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/betting/betting.dart';
import 'package:sun_sports/shared/widgets/buttons/buttons.dart';
import 'package:sun_sports/shared/widgets/sb_bottom_navigation_bar.dart';

class BetSlipDetailsView extends ConsumerWidget {
  const BetSlipDetailsView({
    required this.slip,
    this.scaffoldBuilder,
    super.key,
  });

  final BetSlip slip;
  final Widget Function(
    BuildContext context,
    Widget body,
    Widget? bottomNavigationBar,
  )?
  scaffoldBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const horizontalPadding = EdgeInsets.symmetric(horizontal: 12);
    final resellState = ref.watch(betResellProvider);

    BetSlip currentBet = slip;
    bool canSell = slip.isCashoutAvailable;
    num cashoutAmount = slip.cashOutAbleAmount ?? 0;

    resellState.maybeWhen(
      quoteFetched: (stateBet, quote) {
        if (stateBet.ticketId == slip.ticketId) {
          canSell = quote.isCashoutAvailable;
          cashoutAmount = quote.cashoutAmount?.toDouble() ?? 0;
        }
      },
      success: (stateBet, response) {
        if (stateBet.ticketId == slip.ticketId) {
          currentBet = slip.applyCashout(response);
          canSell = false;
          cashoutAmount = 0;
        }
      },
      orElse: () {},
    );

    Widget? bottomNavigationBar;
    if (canSell && cashoutAmount > 0) {
      bottomNavigationBar = SBBottomNavigationBar.withDivider(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BetSlipResellButton(
            buttonKey: currentBet.ticketId,
            amount: cashoutAmount,
            onConfirm: () => ref
                .read(betResellControllerProvider)(ref)
                .startResellFlow(context, currentBet),
          ),
        ),
      );
    }

    final content = SingleChildScrollView(
      padding: horizontalPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Gap(20),

          _HeaderInfo(id: currentBet.ticketId),
          const Gap(12),

          BetSlipCard.details(currentBet),

          const Gap(12),
        ],
      ),
    );

    if (scaffoldBuilder != null) {
      return scaffoldBuilder!(context, content, bottomNavigationBar);
    }

    return Scaffold(bottomNavigationBar: bottomNavigationBar, body: content);
  }
}

class _HeaderInfo extends StatelessWidget {
  const _HeaderInfo({required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            I18n.txtSportsFootball,
            style: AppTextStyles.headingXSmall(color: AppColors.gray25),
          ),

          const Gap(8),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              Text(
                '${I18n.txtID} $id',
                style: AppTextStyles.labelMedium(color: AppColors.gray25),
              ),
              ClipboradCopyField.iconButton(copyvalue: id),
            ],
          ),
        ],
      ),
    );
  }
}
