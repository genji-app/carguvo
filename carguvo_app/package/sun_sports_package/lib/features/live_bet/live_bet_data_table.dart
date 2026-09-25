import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/shared/widgets/buttons/buttons.dart';
import 'package:sun_sports/shared/widgets/tables/app_table.dart';
import 'package:sun_sports/shared/widgets/texts/currency_text.dart';

class LiveBetDataTable extends StatefulWidget {
  final List<LiveBetData> data;

  const LiveBetDataTable({required this.data, super.key});

  @override
  State<LiveBetDataTable> createState() => _LiveBetTableViewState();
}

class _LiveBetTableViewState extends State<LiveBetDataTable> {
  static const int _initialRowCount = 10;
  bool _showAll = false;

  @override
  void didUpdateWidget(LiveBetDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _showAll = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rowCount = widget.data.length;
    final rowsToShow = _showAll
        ? rowCount
        : (rowCount < _initialRowCount ? rowCount : _initialRowCount);
    final hasMore = rowCount > _initialRowCount;
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LiveBetTable(
          data: widget.data.take(rowsToShow).toList(),
          isTablet: isTablet,
        ),
        if (hasMore) ...[
          const Gap(12),
          _ToggleButton(
            isExpanded: _showAll,
            onPressed: () => setState(() => _showAll = !_showAll),
          ),
          const Gap(12),
        ],
      ],
    );
  }
}

class _LiveBetTable extends StatelessWidget {
  final List<LiveBetData> data;
  final bool isTablet;

  const _LiveBetTable({required this.data, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return AppTable(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      header: TableHeaderRow(
        columns: [
          const TableText('Thể thao', flex: 4),
          const TableText('Tỉ lệ', flex: 4),
          if (isTablet) const TableText('Tài khoản', flex: 4),
          const TableText('Thanh toán', flex: 5, textAlign: TextAlign.right),
        ],
      ),
      rows: data
          .map((item) => _LiveBetRow(item: item, isTablet: isTablet))
          .toList(),
    );
  }
}

class _LiveBetRow extends StatelessWidget {
  final LiveBetData item;
  final bool isTablet;

  const _LiveBetRow({required this.item, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return TableDataRow(
      columns: [
        Expanded(
          flex: 4,
          child: Row(
            children: [
              ImageHelper.load(
                path: AppIcons.iconSoccer,
                width: 16,
                height: 16,
              ),
              const Gap(4),
              Expanded(
                child: Text(
                  item.sport,
                  style: AppTextStyles.labelXSmall(
                    color: AppColorStyles.contentPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        TableText(
          item.odds,
          flex: 4,
          style: AppTextStyles.labelXSmall(color: const Color(0xFFACDC79)),
        ),
        if (isTablet)
          TableText(
            item.account,
            flex: 4,
            style: AppTextStyles.labelXSmall(
              color: AppColorStyles.contentSecondary,
            ),
          ),
        Flexible(
          flex: 5,
          child: Container(
            alignment: Alignment.centerRight,
            child: CurrencyText(
              item.payout,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: AppTextStyles.labelXSmall(
                color: AppColorStyles.contentPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onPressed;

  const _ToggleButton({required this.isExpanded, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SecondaryButton.gray(
      size: SecondaryButtonSize.md,
      onPressed: onPressed,
      label: Text(isExpanded ? 'Thu gọn' : 'Xem Thêm'),
    );
  }
}

class LiveBetData {
  final String sport;
  final String odds;
  final String account;
  final String payout;

  LiveBetData(this.sport, this.odds, this.account, this.payout);
}
