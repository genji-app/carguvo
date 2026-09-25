import 'package:flutter/material.dart' hide CloseButton;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/services/repositories/transaction_repository/transaction_repository.dart';
import 'package:sun_sports/features/transaction/history_clear/history_clear.dart';
import 'package:sun_sports/features/transaction/history_config/history_config.dart';
import 'package:sun_sports/shared/widgets/menu/styled_menu.dart';

import 'views/activity_log_transaction_view.dart';
import 'views/card_deposit_transaction_view.dart';
import 'views/card_withdraw_transaction_view.dart';
import 'views/slip_transaction_view.dart';

class TransactionHistoryFlowView extends ConsumerStatefulWidget {
  const TransactionHistoryFlowView({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const TransactionHistoryFlowView());

  @override
  ConsumerState<TransactionHistoryFlowView> createState() =>
      _TransactionHistoryFlowViewState();
}

class _TransactionHistoryFlowViewState
    extends ConsumerState<TransactionHistoryFlowView> {
  TransactionFilter _currentFilter = TransactionFilter.activityLog;

  final List<TransactionFilter> _visibleFilters = const [
    TransactionFilter.activityLog,
    TransactionFilter.slip,
    TransactionFilter.cardDeposit,
    TransactionFilter.cardWithdraw,
  ];

  final Set<TransactionFilter> _visitedFilters = {
    TransactionFilter.activityLog,
  };

  String _getFilterLabel(TransactionFilter filter) {
    return switch (filter) {
      TransactionFilter.activityLog => 'Tất cả giao dịch',
      TransactionFilter.slip => 'Codepay/Crypto/Giftcode',
      TransactionFilter.cardDeposit => 'Nạp thẻ cào',
      TransactionFilter.cardWithdraw => 'Rút thẻ cào',
      _ => 'Khác',
    };
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _visibleFilters.indexOf(_currentFilter);

    return Column(
      children: [
        const Gap(16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StyledMenu<TransactionFilter>(
                items: _visibleFilters,
                configBuilder: (filter) =>
                    StyledMenuConfig(label: _getFilterLabel(filter)),
                selectedValue: _currentFilter,
                onChanged: (filter) {
                  setState(() {
                    _currentFilter = filter;
                    _visitedFilters.add(filter);
                  });
                },
                minWidth: 180.0,
                maxWidth: 180.0,
                menuWidth: 230.0,
              ),
              if (_currentFilter == TransactionFilter.activityLog)
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [HistoryConfigMenu(), Gap(8), HistoryClearButton()],
                ),
            ],
          ),
        ),
        const Gap(8),
        Expanded(
          child: IndexedStack(
            index: currentIndex >= 0 ? currentIndex : 0,
            children: [
              _visitedFilters.contains(TransactionFilter.activityLog)
                  ? const ActivityLogTransactionView()
                  : const SizedBox.shrink(),
              _visitedFilters.contains(TransactionFilter.slip)
                  ? const SlipTransactionView()
                  : const SizedBox.shrink(),
              _visitedFilters.contains(TransactionFilter.cardDeposit)
                  ? const CardDepositTransactionView()
                  : const SizedBox.shrink(),
              _visitedFilters.contains(TransactionFilter.cardWithdraw)
                  ? const CardWithdrawTransactionView()
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ],
    );
  }
}
