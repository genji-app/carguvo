import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import 'package:sun_sports/core/utils/extensions/currency_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/mini_game/presentation/state/tai_xiu_state_provider.dart';
import 'package:sun_sports/mini/component/mini_loading_gate.dart';
import 'package:sun_sports/shared/widgets/texts/texts.dart';

import 'tai_xiu_sub_view_scaffold.dart';

enum TaiXiuDoor {
  tai('TÀI'),
  xiu('XỈU');

  const TaiXiuDoor(this.label);

  final String label;

  Color get color => this == TaiXiuDoor.tai
      ? AppColorStyles.contentPrimary
      : AppColors.yellow400;
}

class BetHistoryEntry {
  final String sessionId;
  final String time;
  final TaiXiuDoor door;
  final String betAmount;
  final String balanceReturn;
  final int winAmount;
  final int resultPoint;
  final TaiXiuDoor resultDoor;

  const BetHistoryEntry({
    required this.sessionId,
    required this.time,
    required this.door,
    required this.betAmount,
    required this.balanceReturn,
    required this.winAmount,
    required this.resultPoint,
    required this.resultDoor,
  });
}

const double _kTimeColumnWidth = 90;

class BetHistoryView extends ConsumerStatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onClose;

  const BetHistoryView({
    required this.onBack,
    required this.onClose,
    super.key,
  });

  @override
  ConsumerState<BetHistoryView> createState() => _BetHistoryViewState();
}

class _BetHistoryViewState extends ConsumerState<BetHistoryView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(taiXiuSocketStateProvider.notifier).requestBetHistory(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final txState = ref.watch(taiXiuSocketStateProvider);
    final entries = txState.betHistory.map(_historyEntryFromData).toList();
    final showLoading = txState.betHistoryLoading && entries.isEmpty;
    final Widget child;
    if (showLoading) {
      child = const SizedBox.shrink();
    } else if (entries.isEmpty) {
      child = const Center(
        child: Text(
          'Chưa có lịch sử cược',
          style: TextStyle(color: AppColorStyles.contentSecondary),
        ),
      );
    } else {
      child = _BetHistoryTable(entries: entries);
    }
    return TaiXiuSubViewScaffold(
      title: TaiXiuSubView.betHistory.title,
      onBack: widget.onBack,
      onClose: widget.onClose,
      child: MiniLoadingGate(loading: showLoading, child: child),
    );
  }
}

BetHistoryEntry _historyEntryFromData(TaiXiuBetHistoryLine item) {
  final resultDoor = item.resultTai ? TaiXiuDoor.tai : TaiXiuDoor.xiu;
  return BetHistoryEntry(
    sessionId: '#${item.sessionId}',
    time: _formatTimestamp(item.createdAt, hoursOnly: true),
    door: item.isTai ? TaiXiuDoor.tai : TaiXiuDoor.xiu,
    betAmount: _formatShortAmount(item.amount),
    balanceReturn: item.refund > 0 ? _formatShortAmount(item.refund) : '--',
    winAmount: item.payout,
    resultPoint: item.diceTotal,
    resultDoor: resultDoor,
  );
}

class _BetHistoryTable extends StatelessWidget {
  final List<BetHistoryEntry> entries;

  const _BetHistoryTable({required this.entries});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const Gap(12),
      const _HeaderRow(),
      Expanded(
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(
            context,
          ).copyWith(dragDevices: PointerDeviceKind.values.toSet()),
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: entries.length,
            itemBuilder: (context, i) => _BetHistoryRow(
              entry: entries[i],
              showDivider: i != entries.length - 1,
            ),
          ),
        ),
      ),
    ],
  );
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) => const ColoredBox(
    color: AppColorStyles.backgroundSecondary,
    child: Row(
      children: [
        SizedBox(
          width: _kTimeColumnWidth,
          child: _HeaderCell(label: 'Thời gian', alignment: Alignment.center),
        ),
        Expanded(
          child: _HeaderCell(
            label: 'Chi tiết',
            alignment: Alignment.centerLeft,
          ),
        ),
        Expanded(
          child: _HeaderCell(
            label: 'Tiền thắng',
            alignment: Alignment.centerRight,
          ),
        ),
      ],
    ),
  );
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final Alignment alignment;

  const _HeaderCell({required this.label, required this.alignment});

  @override
  Widget build(BuildContext context) => Container(
    alignment: alignment,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    child: Text(
      label,
      style: AppTextStyles.textStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        height: 18 / 12,
        color: AppColorStyles.contentSecondary,
      ),
    ),
  );
}

class _BetHistoryRow extends StatelessWidget {
  final BetHistoryEntry entry;
  final bool showDivider;

  const _BetHistoryRow({required this.entry, required this.showDivider});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      border: showDivider
          ? const Border(
              bottom: BorderSide(color: AppColorStyles.borderPrimary),
            )
          : null,
    ),
    child: Row(
      children: [
        SizedBox(
          width: _kTimeColumnWidth,
          child: _TimeCell(entry: entry),
        ),
        Expanded(child: _DetailCell(entry: entry)),
        Expanded(child: _WinCell(entry: entry)),
      ],
    ),
  );
}

class _TimeCell extends StatelessWidget {
  final BetHistoryEntry entry;

  const _TimeCell({required this.entry});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          entry.sessionId,
          style: AppTextStyles.textStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 18 / 12,
            color: AppColorStyles.contentSecondary,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            entry.time,
            style: AppTextStyles.textStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 20 / 14,
              color: AppColorStyles.contentSecondary,
            ),
          ),
        ),
      ],
    ),
  );
}

class _DetailCell extends StatelessWidget {
  final BetHistoryEntry entry;

  const _DetailCell({required this.entry});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailRow(
          label: 'Cửa đặt:',
          value: entry.door.label,
          valueColor: entry.door.color,
        ),
        const SizedBox(height: 4),
        _DetailRow(label: 'Đặt cược:', value: entry.betAmount),
        const SizedBox(height: 4),
        _DetailRow(label: 'Trả cân cửa:', value: entry.balanceReturn),
      ],
    ),
  );
}

class _WinCell extends StatelessWidget {
  final BetHistoryEntry entry;

  const _WinCell({required this.entry});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        GradientText(
          CurrencyHelper.formatCurrencyNoUnit(entry.winAmount),
          style: AppTextStyles.textStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 20 / 14,
          ),
        ),
        const SizedBox(height: 8),
        _DetailRow(
          label: 'Kết quả:',
          value: '${entry.resultPoint} - ${entry.resultDoor.label}',
          valueColor: entry.resultDoor.color,
        ),
      ],
    ),
  );
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final baseStyle = AppTextStyles.textStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 18 / 12,
      color: AppColorStyles.contentSecondary,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: baseStyle),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: valueColor == null
                ? baseStyle
                : baseStyle.copyWith(color: valueColor),
          ),
        ),
      ],
    );
  }
}

String _formatShortAmount(int amount) {
  if (amount >= 1000000000) {
    return '${_trim(amount / 1000000000)}B';
  }
  if (amount >= 1000000) {
    return '${_trim(amount / 1000000)}M';
  }
  if (amount >= 1000) {
    return '${_trim(amount / 1000)}K';
  }
  return '$amount';
}

String _trim(double value) {
  final fixed = value.toStringAsFixed(1);
  return fixed.endsWith('.0') ? fixed.substring(0, fixed.length - 2) : fixed;
}

String _formatTimestamp(int timestampMs, {bool hoursOnly = false}) {
  if (timestampMs <= 0) return '--';
  final date = DateTime.fromMillisecondsSinceEpoch(timestampMs);
  return DateFormat(
    hoursOnly ? 'HH:mm:ss' : 'dd/MM/yyyy HH:mm:ss',
  ).format(date);
}
