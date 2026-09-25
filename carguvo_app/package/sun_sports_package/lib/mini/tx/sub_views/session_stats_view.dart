import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import 'package:sun_sports/core/utils/extensions/currency_helper.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/utils/styles/mini_game_icons.dart';
import 'package:sun_sports/features/mini_game/presentation/state/tai_xiu_state_provider.dart';
import 'package:sun_sports/mini/component/mini_loading_gate.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/texts/texts.dart';

import 'tai_xiu_sub_view_scaffold.dart';

class SessionStatsView extends ConsumerStatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onClose;

  const SessionStatsView({
    required this.onBack,
    required this.onClose,
    super.key,
  });

  @override
  ConsumerState<SessionStatsView> createState() => _SessionStatsViewState();
}

class _SessionStatsViewState extends ConsumerState<SessionStatsView> {
  static const int _pageSize = 5;
  bool _selectedTai = true;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () =>
          ref.read(taiXiuSocketStateProvider.notifier).requestSessionAnalytic(),
    );
  }

  void _selectTai(bool value) {
    if (_selectedTai == value) return;
    setState(() {
      _selectedTai = value;
      _page = 1;
    });
  }

  void _requestSession(int sessionId) {
    if (sessionId <= 0) return;
    setState(() => _page = 1);
    ref
        .read(taiXiuSocketStateProvider.notifier)
        .requestSessionAnalytic(sessionId: sessionId);
  }

  void _prevPage() {
    if (_page <= 1) return;
    setState(() => _page--);
  }

  void _nextPage(int pageCount) {
    if (_page >= pageCount) return;
    setState(() => _page++);
  }

  @override
  Widget build(BuildContext context) {
    final txState = ref.watch(taiXiuSocketStateProvider);
    final data = txState.sessionStats;
    final loading = txState.sessionStatsLoading;

    final showLoading = data == null && loading;
    final Widget child;
    if (showLoading) {
      child = const SizedBox.shrink();
    } else if (data == null) {
      child = const Center(child: Text('Chưa có dữ liệu thống kê phiên'));
    } else {
      final filtered = data.bets.where((e) => e.isTai == _selectedTai).toList();
      final pageCount = filtered.isEmpty
          ? 1
          : ((filtered.length + _pageSize - 1) ~/ _pageSize);
      final page = _page.clamp(1, pageCount);
      final start = (page - 1) * _pageSize;
      final pageBets = filtered.skip(start).take(_pageSize).toList();
      child = _SessionStatsBody(
        stats: _SessionStats(
          sessionId: '${data.sessionId}',
          page: page,
          pageCount: pageCount,
          selectedTai: _selectedTai,
          dice: [data.d1 ?? 1, data.d2 ?? 1, data.d3 ?? 1],
          totalBet: filtered.fold(0, (sum, e) => sum + e.amount),
          totalReturn: filtered.fold(0, (sum, e) => sum + e.refund),
          bets: pageBets.map(_sessionBetFromData).toList(growable: false),
        ),
        onSelectTai: _selectTai,
        onPrevSession: () => _requestSession(data.sessionId - 1),
        onNextSession: () => _requestSession(data.sessionId + 1),
        onPrevPage: _prevPage,
        onNextPage: () => _nextPage(pageCount),
      );
    }

    return TaiXiuSubViewScaffold(
      title: TaiXiuSubView.sessionStats.title,
      onBack: widget.onBack,
      onClose: widget.onClose,
      child: MiniLoadingGate(loading: showLoading, child: child),
    );
  }
}

_SessionBet _sessionBetFromData(TaiXiuSessionBetLine line) => _SessionBet(
  time: _formatTimestamp(line.createdAt, hoursOnly: true),
  username: line.username.isEmpty ? '--' : line.username,
  amount: line.amount,
);

class _SessionBet {
  final String time;
  final String username;
  final int amount;

  const _SessionBet({
    required this.time,
    required this.username,
    required this.amount,
  });
}

class _SessionStats {
  final String sessionId;
  final int page;
  final int pageCount;

  final bool selectedTai;

  final List<int> dice;
  final int totalBet;
  final int totalReturn;
  final List<_SessionBet> bets;

  const _SessionStats({
    required this.sessionId,
    required this.page,
    required this.pageCount,
    required this.selectedTai,
    required this.dice,
    required this.totalBet,
    required this.totalReturn,
    required this.bets,
  });

  int get diceSum => dice.fold(0, (sum, v) => sum + v);

  bool get isTai => diceSum >= 11;
}

class _SessionStatsBody extends StatelessWidget {
  final _SessionStats stats;
  final void Function(bool selectedTai) onSelectTai;
  final VoidCallback onPrevSession;
  final VoidCallback onNextSession;
  final VoidCallback onPrevPage;
  final VoidCallback onNextPage;

  const _SessionStatsBody({
    required this.stats,
    required this.onSelectTai,
    required this.onPrevSession,
    required this.onNextSession,
    required this.onPrevPage,
    required this.onNextPage,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const Gap(12),
      _SessionSelector(
        sessionId: stats.sessionId,
        selectedTai: stats.selectedTai,
        onSelectTai: onSelectTai,
        onPrevSession: onPrevSession,
        onNextSession: onNextSession,
      ),
      _DiceResultBar(dice: stats.dice, sum: stats.diceSum, isTai: stats.isTai),
      _BetReturnBand(totalBet: stats.totalBet, totalReturn: stats.totalReturn),
      Expanded(child: _StatsTable(bets: stats.bets)),
      _PagerBar(
        page: stats.page,
        pageCount: stats.pageCount,
        onPrev: onPrevPage,
        onNext: onNextPage,
      ),
    ],
  );
}

class _SessionSelector extends StatelessWidget {
  final String sessionId;
  final bool selectedTai;
  final void Function(bool selectedTai) onSelectTai;
  final VoidCallback onPrevSession;
  final VoidCallback onNextSession;

  const _SessionSelector({
    required this.sessionId,
    required this.selectedTai,
    required this.onSelectTai,
    required this.onPrevSession,
    required this.onNextSession,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 44,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColorStyles.backgroundSecondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    InkWell(
                      onTap: SoundTap.wrap(onPrevSession),
                      child: const Icon(
                        Icons.chevron_left_rounded,
                        size: 24,
                        color: AppColors.green400,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '#$sessionId',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.textStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 20 / 14,
                          color: AppColorStyles.contentPrimary,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: SoundTap.wrap(onNextSession),
                      child: const Icon(
                        Icons.chevron_right_rounded,
                        size: 24,
                        color: AppColors.green400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const Gap(12),
        Expanded(
          child: SizedBox(
            height: 44,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColorStyles.backgroundSecondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Row(
                  children: [
                    _ToggleSegment(
                      label: 'TÀI',
                      selected: selectedTai,
                      onTap: () => onSelectTai(true),
                    ),
                    _ToggleSegment(
                      label: 'XỈU',
                      selected: !selectedTai,
                      onTap: () => onSelectTai(false),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _ToggleSegment extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleSegment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: InkWell(
      onTap: SoundTap.wrap(onTap),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColorStyles.backgroundQuaternary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: AppTextStyles.textStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            height: 20 / 16,
            color: AppColorStyles.contentPrimary,
          ),
        ),
      ),
    ),
  );
}

class _DiceResultBar extends StatelessWidget {
  final List<int> dice;
  final int sum;
  final bool isTai;

  const _DiceResultBar({
    required this.dice,
    required this.sum,
    required this.isTai,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < dice.length; i++) ...[
          if (i > 0) const _OperatorIcon(Icons.add_rounded),
          _DiceFace(value: dice[i]),
        ],
        const _OperatorText('='),
        Text(
          '$sum',
          style: AppTextStyles.textStyle(
            fontSize: 27,
            fontWeight: FontWeight.w700,
            height: 30 / 27,
            color: AppColorStyles.contentPrimary,
          ),
        ),
        const Gap(6),
        Text(
          isTai ? '(TÀI)' : '(XỈU)',
          style: AppTextStyles.textStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            height: 17 / 13,
            color: AppColorStyles.contentSecondary,
          ),
        ),
      ],
    ),
  );
}

class _OperatorIcon extends StatelessWidget {
  final IconData icon;

  const _OperatorIcon(this.icon);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 6),
    child: Icon(icon, size: 14, color: AppColorStyles.contentSecondary),
  );
}

class _OperatorText extends StatelessWidget {
  final String text;

  const _OperatorText(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 6),
    child: Text(
      text,
      style: AppTextStyles.textStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColorStyles.contentSecondary,
      ),
    ),
  );
}

class _DiceFace extends StatelessWidget {
  final int value;

  const _DiceFace({required this.value});

  @override
  Widget build(BuildContext context) =>
      ImageHelper.load(path: _diceFaceIcon(value), width: 34, height: 34);

  static String _diceFaceIcon(int value) => switch (value) {
    1 => MiniGameIcons.txDice01,
    2 => MiniGameIcons.txDice02,
    3 => MiniGameIcons.txDice03,
    4 => MiniGameIcons.txDice04,
    5 => MiniGameIcons.txDice05,
    6 => MiniGameIcons.txDice06,
    _ => MiniGameIcons.txDice01,
  };
}

class _BetReturnBand extends StatelessWidget {
  final int totalBet;
  final int totalReturn;

  const _BetReturnBand({required this.totalBet, required this.totalReturn});

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColorStyles.backgroundTertiary,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _BandColumn(
              label: 'Đặt cược',
              amount: totalBet,
              alignment: CrossAxisAlignment.start,
            ),
          ),
          Expanded(
            child: _BandColumn(
              label: 'Trả lại',
              amount: totalReturn,
              alignment: CrossAxisAlignment.end,
            ),
          ),
        ],
      ),
    ),
  );
}

class _BandColumn extends StatelessWidget {
  final String label;
  final int amount;
  final CrossAxisAlignment alignment;

  const _BandColumn({
    required this.label,
    required this.amount,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: alignment,
    children: [
      Text(
        label,
        style: AppTextStyles.textStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          height: 18 / 12,
          color: AppColorStyles.contentSecondary,
        ),
      ),
      const Gap(8),
      GradientText(
        CurrencyHelper.formatCurrencyNoUnit(amount),
        style: AppTextStyles.textStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          height: 20 / 14,
        ),
      ),
    ],
  );
}

class _StatsTable extends StatelessWidget {
  final List<_SessionBet> bets;

  const _StatsTable({required this.bets});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const _TableHeader(),
      Expanded(
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(
            context,
          ).copyWith(dragDevices: PointerDeviceKind.values.toSet()),
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: bets.length,
            itemBuilder: (context, index) => _TableRow(
              bet: bets[index],
              showDivider: index != bets.length - 1,
            ),
          ),
        ),
      ),
    ],
  );
}

const double _kTimeColumnWidth = 90;

const EdgeInsets _kHeaderPadding = EdgeInsets.symmetric(
  horizontal: 12,
  vertical: 8,
);

const EdgeInsets _kCellPadding = EdgeInsets.symmetric(
  horizontal: 12,
  vertical: 16,
);

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.textStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      height: 18 / 12,
      color: AppColorStyles.contentSecondary,
    );
    return ColoredBox(
      color: AppColorStyles.backgroundSecondary,
      child: Row(
        children: [
          SizedBox(
            width: _kTimeColumnWidth,
            child: Padding(
              padding: _kHeaderPadding,
              child: Text(
                'Thời gian',
                textAlign: TextAlign.center,
                style: style,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: _kHeaderPadding,
              child: Text('Tài khoản', style: style),
            ),
          ),
          Expanded(
            child: Padding(
              padding: _kHeaderPadding,
              child: Text('Đặt cược', textAlign: TextAlign.right, style: style),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  final _SessionBet bet;
  final bool showDivider;

  const _TableRow({required this.bet, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    final contentStyle = AppTextStyles.textStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 20 / 14,
      color: AppColorStyles.contentSecondary,
    );
    return DecoratedBox(
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
            child: Padding(
              padding: _kCellPadding,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(bet.time, style: contentStyle),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: _kCellPadding,
              child: Text(
                bet.username,
                style: contentStyle.copyWith(
                  color: AppColorStyles.contentPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: _kCellPadding,
              child: GradientText(
                _formatShortAmount(bet.amount),
                textAlign: TextAlign.right,
                style: AppTextStyles.textStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 20 / 14,
                ),
              ),
            ),
          ),
        ],
      ),
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

class _PagerBar extends StatelessWidget {
  final int page;
  final int pageCount;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _PagerBar({
    required this.page,
    required this.pageCount,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
    child: Row(
      children: [
        _PagerButton(Icons.chevron_left_rounded, onTap: onPrev),
        Expanded(
          child: Text(
            '$page/$pageCount',
            textAlign: TextAlign.center,
            style: AppTextStyles.textStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 20 / 14,
              color: AppColorStyles.contentTertiary,
            ),
          ),
        ),
        _PagerButton(Icons.chevron_right_rounded, onTap: onNext),
      ],
    ),
  );
}

class _PagerButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _PagerButton(this.icon, {required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: SoundTap.wrap(onTap),
    borderRadius: BorderRadius.circular(12),
    child: Container(
      width: 40,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColorStyles.backgroundQuaternary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColorStyles.borderPrimary, width: 0.5),
      ),
      child: Icon(icon, size: 16, color: AppColorStyles.contentSecondary),
    ),
  );
}

String _formatTimestamp(int timestampMs, {bool hoursOnly = false}) {
  if (timestampMs <= 0) return '--';
  final date = DateTime.fromMillisecondsSinceEpoch(timestampMs);
  return DateFormat(
    hoursOnly ? 'HH:mm:ss' : 'dd/MM/yyyy HH:mm:ss',
  ).format(date);
}
