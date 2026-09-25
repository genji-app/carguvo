import 'package:flutter/material.dart' hide CloseButton;
import 'package:intl/intl.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/services/repositories/repositories.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/transaction/transaction.dart';
import 'package:sun_sports/shared/widgets/divider/divider.dart';

sealed class _FlatItem {
  const _FlatItem();
}

final class _HeaderItem extends _FlatItem {
  const _HeaderItem(this.date);
  final DateTime date;
}

final class _DividerItem extends _FlatItem {
  const _DividerItem();
}

final class _TransactionItem extends _FlatItem {
  const _TransactionItem(this.transaction);
  final UnifiedTransaction transaction;
}

class DateGroupedSliverList extends StatefulWidget {
  const DateGroupedSliverList(this.data, {super.key, this.onItemPressed});

  final List<UnifiedTransaction> data;

  final ValueChanged<UnifiedTransaction>? onItemPressed;

  @override
  State<DateGroupedSliverList> createState() => _DateGroupedSliverListState();
}

class _DateGroupedSliverListState extends State<DateGroupedSliverList> {
  List<_FlatItem> _flatItems = const [];

  @override
  void initState() {
    super.initState();
    _flatItems = _buildFlatList(widget.data);
  }

  @override
  void didUpdateWidget(covariant DateGroupedSliverList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.data, widget.data)) {
      _flatItems = _buildFlatList(widget.data);
    }
  }

  static List<_FlatItem> _buildFlatList(List<UnifiedTransaction> data) {
    if (data.isEmpty) return const [];

    final items = <_FlatItem>[];
    DateTime? lastGroupDate;

    for (final tx in data) {
      final groupDate = DateTime(tx.date.year, tx.date.month, tx.date.day);

      if (lastGroupDate == null || groupDate != lastGroupDate) {
        items.add(_HeaderItem(groupDate));
        lastGroupDate = groupDate;
      } else {
        items.add(const _DividerItem());
      }

      items.add(_TransactionItem(tx));
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: _flatItems.length,
      itemBuilder: (context, index) => switch (_flatItems[index]) {
        _HeaderItem(:final date) => _DateTimeHeaderWidget(date),
        _DividerItem() => const SBDivider.thin(indent: 28, endIndent: 28),
        _TransactionItem(:final transaction) =>
          _buildTransactionTile(transaction),
      },
    );
  }

  Widget _buildTransactionTile(UnifiedTransaction item) {
    final onPressed =
        widget.onItemPressed != null ? () => widget.onItemPressed!(item) : null;

    return item.map(
      slip: (slipTx) => TransactionListTile(
        transaction: slipTx,
        onPressed: onPressed,
      ),
      cardDeposit: (cardDepositTx) => TransactionListTile(
        transaction: cardDepositTx,
        onPressed: onPressed,
      ),
      cardWithdraw: (cardWithdrawTx) => TransactionListTile(
        transaction: cardWithdrawTx,
        onPressed: onPressed,
      ),
      activity: (activityTx) => ActivityLogListTile(
        transaction: activityTx,
        onPressed: onPressed,
      ),
    );
  }
}

class _DateTimeHeaderWidget extends StatelessWidget {
  const _DateTimeHeaderWidget(this.date);

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayUtc = DateTime.utc(now.year, now.month, now.day);
    final dateUtc = DateTime.utc(date.year, date.month, date.day);
    final differenceInDays = todayUtc.difference(dateUtc).inDays;

    final label = switch (differenceInDays) {
      0 => I18n.txtToday,
      1 => I18n.txtYesterday,
      _ => DateFormat('EEE, dd MMM yyyy').format(date),
    };

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
      child: DefaultTextStyle(
        style: AppTextStyles.labelSmall(color: AppColorStyles.contentTertiary),
        child: Text(label),
      ),
    );
  }
}
