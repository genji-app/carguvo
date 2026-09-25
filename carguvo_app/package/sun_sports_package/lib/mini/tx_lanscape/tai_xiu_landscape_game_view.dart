import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rive/rive.dart' as rive;

import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
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
import 'package:sun_sports/mini/tx/widgets/tai_xiu_history_dots.dart';
import 'package:sun_sports/mini/tx/widgets/tai_xiu_rive_widgets.dart';
import 'package:sun_sports/mini/tx/widgets/tai_xiu_square_button.dart';
import 'package:sun_sports/mini/tx/widgets/tai_xiu_win_banner.dart';

class TaiXiuLandscapeGameView extends ConsumerStatefulWidget {
  final VoidCallback onClose;

  const TaiXiuLandscapeGameView({required this.onClose, super.key});

  @override
  ConsumerState<TaiXiuLandscapeGameView> createState() =>
      _TaiXiuLandscapeGameViewState();
}

class _TaiXiuLandscapeGameViewState
    extends ConsumerState<TaiXiuLandscapeGameView>
    with TaiXiuGameLogicMixin {
  @override
  VoidCallback get onGameClose => widget.onClose;

  static const double _kDiceOverflow = 25;

  static const double _kBowlSize = 180;

  static const double _kPlayHeight = 228;

  static const double _kCardWidth = 190;

  static const double _kPlayHPad = 16;
  static const double _kCardGap = 16;

  static const double _kCenterInset = _kCardWidth + _kCardGap;

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
    final diceInset = diceSettled ? 3.0 : -_kDiceOverflow;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColorStyles.backgroundQuaternary,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _LandscapeHeader(
                  sessionLabel: sessionLabel,
                  onClose: widget.onClose,
                  onOpenSubView: openSubView,
                ),
                SizedBox(
                  height: _kPlayHeight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: _kPlayHPad),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          top: 0,
                          bottom: 0,
                          left: _kCardWidth - _kCardGap - 20,
                          right: _kCardWidth - _kCardGap - 20,
                          child: ImageHelper.load(
                            path: AppImages.bgXXLanscape,
                            fit: BoxFit.fill,
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                              width: _kCardWidth,
                              child: _LandscapeBetOption(
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
                            Expanded(
                              child: _CenterArea(
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
                                    ref
                                            .read(
                                              taiXiuNanActiveProvider.notifier,
                                            )
                                            .state =
                                        v,
                              ),
                            ),
                            SizedBox(
                              width: _kCardWidth,
                              child: _LandscapeBetOption(
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
                        if (hasDice)
                          Positioned(
                            left: _kCenterInset + diceInset,
                            right: _kCenterInset + diceInset,
                            top: diceInset + 26,
                            bottom: diceInset + 16,
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
                          left: _kCenterInset,
                          right: _kCenterInset,
                          bottom: -4,
                          child: Center(
                            child: TaiXiuWinBanner(
                              winToken: winToken,
                              amount: winBannerAmount,
                            ),
                          ),
                        ),
                        if (bowlMounted)
                          Positioned(
                            left: _kCenterInset,
                            right: _kCenterInset,
                            top: 0,
                            bottom: 0,
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
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
                  decoration: const BoxDecoration(
                    color: AppColorStyles.backgroundTertiary,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: SizedBox(
                    height: 20,
                    child: Row(
                      children: [
                        Expanded(
                          child: TaiXiuHistoryDots(
                            history: txState.history,
                            maxDots: 18,
                          ),
                        ),
                        if (latestResult != null) ...[
                          const SizedBox(width: 12),
                          TaiXiuLatestCircle(total: latestResult, size: 20),
                        ],
                      ],
                    ),
                  ),
                ),
                if (selectedSide != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _LandscapeQuickBetRow(onAdd: addStake),
                        const SizedBox(height: 16),
                        _LandscapeActionRow(
                          stake: stake,
                          onAllIn: allIn,
                          onCancel: cancelStake,
                          onConfirm: stake > 0 && effectiveSide(txState) != null
                              ? confirmBet
                              : null,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (activeSubView != null)
          Positioned(
            left: 0,
            right: 0,
            top: -35,
            bottom: 0,
            child: buildSubView(activeSubView!),
          ),

        Positioned(
          top: -60,
          left: 0,
          right: 0,
          child: SizedBox(
            width: 300,
            height: 69,
            child: ImageHelper.load(
              path: MiniGameIcons.txHeader,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}

class _LandscapeHeader extends StatelessWidget {
  final String sessionLabel;
  final VoidCallback onClose;
  final void Function(TaiXiuSubView view) onOpenSubView;

  const _LandscapeHeader({
    required this.sessionLabel,
    required this.onClose,
    required this.onOpenSubView,
  });

  @override
  Widget build(BuildContext context) => Stack(
    alignment: Alignment.topCenter,
    children: [
      Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: 160,
          height: 32,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: ImageHelper.load(
                  path: MiniGameIcons.upDownBackgroundTotalMoney,
                  fit: BoxFit.fill,
                ),
              ),
              Text(
                sessionLabel,
                style: AppTextStyles.textStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColorStyles.contentTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TaiXiuSquareButton(
                  iconPath: MiniGameIcons.txChart,
                  size: 40,
                  iconSize: 20,
                  onTap: () => onOpenSubView(TaiXiuSubView.sessionHistory),
                ),
                const SizedBox(width: 8),
                TaiXiuSquareButton(
                  iconPath: MiniGameIcons.txSearch,
                  size: 40,
                  iconSize: 20,
                  onTap: () => onOpenSubView(TaiXiuSubView.sessionStats),
                ),
                const SizedBox(width: 8),
                TaiXiuSquareButton(
                  iconPath: MiniGameIcons.txHistory,
                  size: 40,
                  iconSize: 20,
                  onTap: () => onOpenSubView(TaiXiuSubView.betHistory),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TaiXiuSquareButton(
                  iconPath: MiniGameIcons.txQa,
                  size: 40,
                  iconSize: 20,
                  onTap: () => onOpenSubView(TaiXiuSubView.guide),
                ),
                const SizedBox(width: 8),
                TaiXiuSquareButton(
                  iconPath: MiniGameIcons.txRanking,
                  size: 40,
                  iconSize: 20,
                  onTap: () => onOpenSubView(TaiXiuSubView.ranking),
                ),
                const SizedBox(width: 8),
                TaiXiuSquareButton(
                  icon: Icons.close_rounded,
                  size: 40,
                  iconSize: 20,
                  onTap: onClose,
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}

class _CenterArea extends StatelessWidget {
  final String result;
  final Color resultColor;
  final int? payingTime;
  final bool nanActive;
  final ValueChanged<bool> onNanChanged;

  const _CenterArea({
    required this.result,
    required this.resultColor,
    required this.nanActive,
    required this.onNanChanged,
    this.payingTime,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
    ),
    child: Stack(
      children: [
        if (payingTime != null)
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                '$payingTime',
                style: AppTextStyles.labelSmall(color: AppColors.green400),
              ),
            ),
          ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: SizedBox(
              width: 40,
              height: 40,
              child: TaiXiuBtnNanRive(
                active: nanActive,
                onChanged: onNanChanged,
              ),
            ),
          ),
        ),
        Center(
          child: Text(
            result,
            style: AppTextStyles.displayStyle(
              fontSize: 72,
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

class _LandscapeBetOption extends StatelessWidget {
  final TaiXiuSide side;
  final String label;
  final String bettors;
  final int total;
  final int thisBet;

  final int pendingStake;
  final bool selected;

  final bool won;
  final VoidCallback onBet;

  const _LandscapeBetOption({
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

  static const LinearGradient _whiteGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFFFF), Color(0xFFBFBDB9)],
  );

  static const LinearGradient _totalStripGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF5C1011), Color(0xFF340708)],
  );

  BorderRadius get _radius => _isTai
      ? const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(80),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        )
      : const BorderRadius.only(
          topLeft: Radius.circular(80),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        );

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          Positioned.fill(
            child: TaiXiuRiveAnim(
              url: _isTai ? AppRive.txAnimBaseTaiWeb : AppRive.txAnimBaseXiuWeb,
              selected: selected,
              win: won,
              fit: rive.Fit.fill,
            ),
          ),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 30,
          child: Align(
            alignment: _isTai ? Alignment.topLeft : Alignment.topRight,
            child: _buildBettorsBadge(),
          ),
        ),
        const Spacer(),
        _buildTotalStrip(),
        const Spacer(),
        Padding(
          padding: EdgeInsets.fromLTRB(12, 0, 12, selected ? 12 : 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: selected ? 36 : 44,
                child: thisBet > 0
                    ? _buildThisBetPill()
                    : ShineButton(
                        text: 'Đặt cược',
                        style: _buttonStyle,
                        height: selected ? 36 : 44,
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
  }

  Widget _buildBettorsBadge() => Container(
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

  Widget _buildTotalStrip() => Container(
    margin: EdgeInsets.only(top: selected ? 50 : 28),
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

class _LandscapeQuickBetRow extends StatelessWidget {
  final void Function(int amount) onAdd;

  const _LandscapeQuickBetRow({required this.onAdd});

  static const List<int> _amounts = [
    1000,
    10000,
    50000,
    100000,
    500000,
    5000000,
    10000000,
    50000000,
  ];

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (var i = 0; i < _amounts.length; i++) ...[
        if (i > 0) const SizedBox(width: 8),
        Expanded(
          child: _LandscapeQuickChip(
            label: taiXiuCompactAmount(_amounts[i]),
            onTap: () => onAdd(_amounts[i]),
          ),
        ),
      ],
    ],
  );
}

class _LandscapeQuickChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _LandscapeQuickChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      onTap: SoundTap.wrap(onTap),
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColorStyles.backgroundTertiary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: GradientText(label, style: AppTextStyles.buttonSmall()),
      ),
    ),
  );
}

class _LandscapeActionRow extends StatelessWidget {
  final int stake;
  final VoidCallback onAllIn;
  final VoidCallback onCancel;
  final VoidCallback? onConfirm;

  const _LandscapeActionRow({
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
        Expanded(
          child: ShineButton(
            text: 'All in',
            style: ShineButtonStyle.primaryPurple,
            height: 48,
            width: double.infinity,
            onPressed: onAllIn,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: onConfirm != null
              ? ShineButton(
                  text: confirmLabel,
                  style: ShineButtonStyle.minigameGold,
                  height: 48,
                  width: double.infinity,
                  autoSizeText: true,
                  isEnabled: onConfirm != null,
                  onPressed: onConfirm,
                )
              : Container(
                  height: 48,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.gray500),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Cược',
                    style: AppTextStyles.buttonMedium(color: AppColors.gray500),
                  ),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ShineButton(
            text: 'Hủy',
            style: ShineButtonStyle.minigameRed,
            height: 48,
            width: double.infinity,
            onPressed: onCancel,
          ),
        ),
      ],
    );
  }
}
