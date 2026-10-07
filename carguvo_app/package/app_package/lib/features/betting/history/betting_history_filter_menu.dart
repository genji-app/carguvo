import 'package:flutter/material.dart';
import 'package:app_package/core/constants/i18n.dart';
import 'package:gap/gap.dart';
import 'package:app_package/features/transaction/history_config/history_config.dart';
import 'package:app_package/shared/widgets/menu/menu.dart';

enum BettingHistoryFilter { sports, casino }

extension BettingHistoryFilterEx on BettingHistoryFilter {
  String get label => switch (this) {
    BettingHistoryFilter.sports => I18n.txtSports,
    BettingHistoryFilter.casino => I18n.txtCasino,
  };
}

class BettingHistoryFilterMenu extends StatefulWidget
    implements PreferredSizeWidget {
  const BettingHistoryFilterMenu({
    super.key,
    this.onChanged,
    this.initialValue = BettingHistoryFilter.sports,
    this.minWidth = 160.0,
  });

  final ValueChanged<BettingHistoryFilter>? onChanged;
  final BettingHistoryFilter initialValue;
  final double minWidth;

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  State<BettingHistoryFilterMenu> createState() =>
      _BettingHistoryFilterMenuState();
}

class _BettingHistoryFilterMenuState extends State<BettingHistoryFilterMenu> {
  late BettingHistoryFilter _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  @override
  void didUpdateWidget(covariant BettingHistoryFilterMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _selectedValue = widget.initialValue;
    }
  }

  void _onChanged(BettingHistoryFilter selection) {
    if (_selectedValue == selection) return;
    setState(() {
      _selectedValue = selection;
    });
    widget.onChanged?.call(selection);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          StyledMenu<BettingHistoryFilter>(
            items: BettingHistoryFilter.values,
            selectedValue: _selectedValue,
            onChanged: _onChanged,
            minWidth: widget.minWidth,
            configBuilder: (item) => StyledMenuConfig(label: item.label),
          ),
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [HistoryConfigMenu(), Gap(8), HistoryConfigInfoButton()],
          ),
        ],
      ),
    );
  }
}
