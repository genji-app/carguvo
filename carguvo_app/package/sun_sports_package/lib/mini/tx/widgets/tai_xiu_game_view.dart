import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rive/rive.dart' as rive;

import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_rive.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/utils/styles/mini_game_icons.dart';
import 'package:sun_sports/features/mini_game/presentation/state/tai_xiu_state_provider.dart';
import 'package:sun_sports/shared/widgets/buttons/shine_button.dart';
import 'package:sun_sports/shared/widgets/texts/texts.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

import 'package:sun_sports/mini/tx/sub_views/tai_xiu_sub_view_scaffold.dart';
import 'package:sun_sports/mini/tx/widgets/tai_xiu_bowl_overlay.dart';
import 'package:sun_sports/mini/tx/widgets/tai_xiu_game_logic.dart';
import 'package:sun_sports/mini/tx/widgets/tai_xiu_rive_widgets.dart';
import 'package:sun_sports/mini/tx/widgets/tai_xiu_square_button.dart';
import 'package:sun_sports/mini/tx/widgets/tai_xiu_history_dots.dart';
import 'package:sun_sports/mini/tx/widgets/tai_xiu_win_banner.dart';

class TaiXiuGameView extends ConsumerStatefulWidget {
  final VoidCallback onClose;

  const TaiXiuGameView({required this.onClose, super.key});

  @override
  ConsumerState<TaiXiuGameView> createState() => _TaiXiuGameViewState();
}

class _TaiXiuGameViewState extends ConsumerState<TaiXiuGameView>
    with TaiXiuGameLogicMixin {
  @override
  VoidCallback get onGameClose => widget.onClose;

  static const double _kDiceOverflow = 25;

  static const double _kBowlSize = 180;

  @override
  Widget build(BuildContext context) {
    registerGameStateListeners();
    final txState = ref.watch(taiXiuSocketStateProvider);
    final nanActive = ref.watch(taiXiuNanActiveProvider);
    final sessionLabel = txState.sessionId == 0
        ? '#------'
        : '#${txState.sessionId}';
    final centerResult = txState.remainingTimeSec > 0
        ? txState.remainingTimeSec.toString().padLeft(2, '0')
        : '00';
    final diceTotal = txState.diceTotal;
    final hasDice =
        txState.d1 != null && txState.d2 != null && txState.d3 != null;
    final showBowl = nanArmed && !nanOpened && hasDice && resultRevealed;
    final bowlMounted = (nanActive || nanArmed) && !nanOpened;
    final revealed = resultRevealed && !showBowl;
    final latestResult = revealed ? diceTotal : null;
    final taiWon = revealed && diceTotal != null && diceTotal > 10;
    final xiuWon = revealed && diceTotal != null && diceTotal <= 10;
    final diceSettled = txState.resultStatic || resultRevealed;
    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColorStyles.backgroundQuaternary,
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.only(top: 33),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _Header(onClose: widget.onClose, onOpenSubView: openSubView),
              const SizedBox(height: 12),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          _DiceArea(
                            sessionId: sessionLabel,
                            result: hasDice ? '' : centerResult,
                            resultColor:
                                txState.remainingTimeSec <=
                                    TaiXiuSocketNotifier.kBetLockSec
                                ? AppColors.red400
                                : AppColors.green400,
                            payingTime: txState.payingTimeSec > 0
                                ? txState.payingTimeSec
                                : null,
                            nanActive: nanActive,
                            onNanChanged: (v) =>
                                ref.read(taiXiuNanActiveProvider.notifier).state =
                                    v,
                          ),
                          if (hasDice)
                            Positioned(
                              left: 0,
                              right: 0,
                              top: diceSettled ? 3 : -_kDiceOverflow,
                              bottom: diceSettled ? 3 : -_kDiceOverflow,
                              child: IgnorePointer(
                                child: diceSettled
                                    ? TaiXiuDiceStaticRive(
                                        d1: txState.d1!,
                                        d2: txState.d2!,
                                        d3: txState.d3!,
                                      )
                                    : TaiXiuDiceResultRive(
                                        d1: txState.d1!,
                                        d2: txState.d2!,
                                        d3: txState.d3!,
                                      ),
                              ),
                            ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: -4,
                            child: Center(
                              child: TaiXiuWinBanner(
                                winToken: winToken,
                                amount: winBannerAmount,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _BetOption(
                                side: TaiXiuSide.tai,
                                label: 'TÀI',
                                bettors: '${txState.taiUsers}',
                                total: txState.taiTotalBet,
                                thisBet: txState.taiThisBet,
                                pendingStake: stake,
                                selected: selectedSide == TaiXiuSide.tai,
                                won: taiWon,
                                onBet: () => selectSide(TaiXiuSide.tai),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _BetOption(
                                side: TaiXiuSide.xiu,
                                label: 'XỈU',
                                bettors: '${txState.xiuUsers}',
                                total: txState.xiuTotalBet,
                                thisBet: txState.xiuThisBet,
                                pendingStake: stake,
                                selected: selectedSide == TaiXiuSide.xiu,
                                won: xiuWon,
                                onBet: () => selectSide(TaiXiuSide.xiu),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (bowlMounted)
                    Positioned(
                      top: -3,
                      left: 0,
                      right: 0,
                      height: _DiceArea.kHeight,
                      child: IgnorePointer(
                        ignoring: !showBowl,
                        child: Opacity(
                          opacity: showBowl ? 1 : 0,
                          child: TaiXiuDiceBowlOverlay(
                            bowlSize: _kBowlSize,
                            onOpened: onBowlOpened,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColorStyles.backgroundTertiary,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColorStyles.borderTertiary),
                ),
                child: Column(
                  children: [
                    _HistoryBar(history: txState.history, latest: latestResult),
                    if (selectedSide != null) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: ImageHelper.load(
                          path: AppIcons.hr,
                          width: double.infinity,
                          height: 2,
                          fit: BoxFit.fill,
                        ),
                      ),
                      _QuickBetRow(onAdd: addStake),
                      const SizedBox(height: 12),
                      _ActionBar(
                        stake: stake,
                        onAllIn: allIn,
                        onCancel: cancelStake,
                        onConfirm: stake > 0 && effectiveSide(txState) != null
                            ? confirmBet
                            : null,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (activeSubView != null)
          Positioned.fill(child: buildSubView(activeSubView!)),

        Positioned(
          top: 3,
          child: ImageHelper.load(
            path: MiniGameIcons.txHeader,
            width: 162,
            fit: BoxFit.fitHeight,
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onClose;
  final void Function(TaiXiuSubView view) onOpenSubView;

  const _Header({required this.onClose, required this.onOpenSubView});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12.0),
    margin: const EdgeInsets.only(top: 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TaiXiuSquareButton(
              iconPath: MiniGameIcons.txChart,
              onTap: () => onOpenSubView(TaiXiuSubView.sessionHistory),
            ),
            const SizedBox(width: 8),
            TaiXiuSquareButton(
              iconPath: MiniGameIcons.txSearch,
              onTap: () => onOpenSubView(TaiXiuSubView.sessionStats),
            ),
            const SizedBox(width: 8),
            TaiXiuSquareButton(
              iconPath: MiniGameIcons.txHistory,
              onTap: () => onOpenSubView(TaiXiuSubView.betHistory),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TaiXiuSquareButton(
              iconPath: MiniGameIcons.txQa,
              onTap: () => onOpenSubView(TaiXiuSubView.guide),
            ),
            const SizedBox(width: 8),
            TaiXiuSquareButton(
              iconPath: MiniGameIcons.txRanking,
              onTap: () => onOpenSubView(TaiXiuSubView.ranking),
            ),
            const SizedBox(width: 8),
            TaiXiuSquareButton(icon: Icons.close_rounded, onTap: onClose),
          ],
        ),
      ],
    ),
  );
}

class _DiceArea extends StatelessWidget {
  static const double kHeight = 140;

  final String sessionId;

  final String result;

  final int? payingTime;

  final Color resultColor;

  final bool nanActive;

  final ValueChanged<bool> onNanChanged;

  const _DiceArea({
    required this.sessionId,
    required this.result,
    required this.resultColor,
    required this.nanActive,
    required this.onNanChanged,
    this.payingTime,
  });

  @override
  Widget build(BuildContext context) => Container(
    height: kHeight,
    padding: const EdgeInsets.all(12),
    margin: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: AppColorStyles.backgroundTertiary,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColorStyles.borderTertiary),
    ),
    child: Stack(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Text(
            sessionId,
            style: AppTextStyles.textStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColorStyles.contentTertiary,
            ),
          ),
        ),
        if (payingTime != null)
          Align(
            alignment: Alignment.topRight,
            child: Text(
              '$payingTime',
              style: AppTextStyles.labelSmall(color: AppColors.green400),
            ),
          ),

        Align(
          alignment: Alignment.bottomRight,
          child: SizedBox(
            width: 40,
            height: 40,
            child: TaiXiuBtnNanRive(active: nanActive, onChanged: onNanChanged),
          ),
        ),
        Center(
          child: Text(
            result,
            style: AppTextStyles.displayStyle(
              fontSize: 64,
              fontWeight: FontWeight.w800,
              color: resultColor,
              height: 1,
            ),
          ),
        ),
      ],
    ),
  );
}

class _BetOption extends StatelessWidget {
  final TaiXiuSide side;
  final String label;
  final String bettors;
  final int total;
  final int thisBet;

  final int pendingStake;
  final bool selected;

  final bool won;
  final VoidCallback onBet;

  const _BetOption({
    required this.side,
    required this.label,
    required this.bettors,
    required this.total,
    required this.thisBet,
    required this.pendingStake,
    required this.selected,
    required this.won,
    required this.onBet,
  });

  bool get _isTai => side == TaiXiuSide.tai;

  ShineButtonStyle get _buttonStyle => _isTai
      ? ShineButtonStyle.primaryGray
      : ShineButtonStyle.primaryYellowDark;
  
  String get  taiRive => kIsWeb ? AppRive.txAnimBaseTai : AppRive.txAnimBaseTai;

  String get  xiuRive => kIsWeb ? AppRive.txAnimBaseXiu : AppRive.txAnimBaseXiu;

  static const double _kCardRatio = 151 / 164;

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: _kCardRatio,
    child: Container(
      decoration: BoxDecoration(
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: TaiXiuRiveAnim(
              url: _isTai ? taiRive : xiuRive,
              selected: selected,
              win: won,
              fit: rive.Fit.fill,
            ),
          ),
          _buildContent(),
        ],
      ),
    ),
  );

  Widget _buildContent() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Align(
        alignment: _isTai ? Alignment.topLeft : Alignment.topRight,
        child: _buildBettorsChip(),
      ),
      const SizedBox(height: 30),
      _buildTotalStrip(),
      const Spacer(),
      Padding(
        padding: EdgeInsets.fromLTRB(12, 0, 12, selected ? 12 : 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: selected ? 36 : 48,
              child: thisBet > 0
                  ? _buildThisBetPill()
                  : ShineButton(
                      text: 'Đặt cược',
                      style: _buttonStyle,
                      height: selected ? 36 : 48,
                      width: double.infinity,
                      onPressed: onBet,
                    ),
            ),
            if (selected) ...[
              const SizedBox(height: 8),
              _buildPendingStakeBox(),
            ],
          ],
        ),
      ),
    ],
  );

  Widget _buildPendingStakeBox() => Container(
    height: 24,
    width: double.infinity,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: const Color(0x99070606),
      borderRadius: BorderRadius.circular(100),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: GradientText(
          NumberFormat('#,###').format(pendingStake),
          style: AppTextStyles.textStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
      ),
    ),
  );

  Widget _buildBettorsChip() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.people,
          size: 16,
          color: AppColorStyles.contentPrimary,
        ),
        const SizedBox(width: 4),
        Text(
          bettors,
          style: AppTextStyles.textStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 18 / 12,
            color: AppColorStyles.contentPrimary,
          ),
        ),
      ],
    ),
  );

  Widget _buildTotalStrip() => SizedBox(
    height: 24,
    child: Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: GradientText(
            NumberFormat('#,###').format(total),
            style: AppTextStyles.textStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),
      ),
    ),
  );

  Widget _buildThisBetPill() => MouseRegion(
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: SoundTap.wrap(onBet),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0x99070606),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: AppColors.yellow400,
            width: selected ? 2 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: GradientText(
              NumberFormat('#,###').format(thisBet),
              style: AppTextStyles.textStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _HistoryBar extends StatelessWidget {
  final List<TaiXiuSessionHistoryLine> history;

  final int? latest;

  const _HistoryBar({required this.history, required this.latest});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: TaiXiuLatestCircle.kSize,
    child: Row(
      children: [
        Expanded(child: TaiXiuHistoryDots(history: history)),
        if (latest != null) const SizedBox(width: 8),
        if (latest != null) TaiXiuLatestCircle(total: latest),
      ],
    ),
  );
}

class _ActionBar extends StatelessWidget {
  final int stake;
  final VoidCallback onAllIn;
  final VoidCallback onCancel;
  final VoidCallback? onConfirm;

  const _ActionBar({
    required this.stake,
    required this.onAllIn,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final confirmLabel = stake > 0
        ? 'Cược ${taiXiuCompactAmount(stake)}'
        : 'Cược';
    return Row(
      children: [
        ShineButton(
          text: 'All in',
          style: ShineButtonStyle.primaryPurple,
          height: 48,
          width: 80,
          onPressed: onAllIn,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ShineButton(
            text: confirmLabel,
            style: ShineButtonStyle.minigameGold,
            height: 48,
            width: double.infinity,
            autoSizeText: true,
            isEnabled: onConfirm != null,
            onPressed: onConfirm,
          ),
        ),
        const SizedBox(width: 8),
        ShineButton(
          text: 'Hủy',
          style: ShineButtonStyle.minigameRed,
          height: 48,
          width: 80,
          onPressed: onCancel,
        ),
      ],
    );
  }
}

class _QuickBetRow extends StatelessWidget {
  final void Function(int amount) onAdd;

  const _QuickBetRow({required this.onAdd});

  static const List<int> _amounts = [5000, 50000, 500000, 5000000, 50000000];

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (var i = 0; i < _amounts.length; i++) ...[
        if (i > 0) const SizedBox(width: 8),
        Expanded(
          child: _QuickChip(
            label: taiXiuCompactAmount(_amounts[i]),
            onTap: () => onAdd(_amounts[i]),
          ),
        ),
      ],
    ],
  );
}

class _QuickChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      onTap: SoundTap.wrap(onTap),
      child: Container(
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.yellow300.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(100),
        ),
        child: GradientText(label, style: AppTextStyles.buttonSmall()),
      ),
    ),
  );
}
