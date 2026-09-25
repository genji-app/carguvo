import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderAbstractViewport;
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/services/models/api_v2/sport_constants.dart'
    show SportType;
import 'package:sun_sports/features/sport/presentation/providers/league_provider.dart';
import 'package:sun_sports/providers/user_provider/user_provider.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/money_formatter.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/parlay/domain/models/single_bet_data.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/providers/parlay_state_provider.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/widgets/parlay_explanation_button.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/widgets/parlay_not_supported_banner.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/widgets/stake_status_slot.dart';
import 'package:sun_sports/features/preferences/bet/odds_info.dart';
import 'package:sun_sports/features/sport/presentation/providers/odds_change_provider.dart';
import 'package:sun_sports/shared/domain/enums/betting_enums.dart'
    hide OddsChangeDirection;
import 'package:sun_sports/shared/domain/enums/league_enums.dart'
    show OddsStyle;
import 'package:sun_sports/shared/widgets/bet_explanation/bet_explanation.dart';
import 'package:sun_sports/shared/widgets/dashed_divider_widget.dart';
import 'package:sun_sports/shared/widgets/stake_keypad/stake_keypad.dart';
import 'package:sun_sports/shared/widgets/stake_keypad/stake_keypad_controller.dart';
import 'package:sun_sports/shared/widgets/stake_keypad/stake_keypad_field.dart';
import 'package:sun_sports/shared/widgets/stake_keypad/stake_keypad_math.dart';
import 'package:sun_sports/shared/widgets/status_information/status_information.dart';
import 'package:sun_sports/shared/widgets/texts/texts.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class ParlayStakeSection extends ConsumerStatefulWidget {
  const ParlayStakeSection({super.key});

  @override
  ConsumerState<ParlayStakeSection> createState() => _ParlayStakeSectionState();
}

class _ParlayStakeSectionState extends ConsumerState<ParlayStakeSection> {
  static const String _keypadId = StakeKeypadController.slipComboId;

  Timer? _normalizeDebounce;
  final _formatter = NumberFormat('#,###');

  @override
  void dispose() {
    _normalizeDebounce?.cancel();
    super.dispose();
  }

  void _normalizeStake() {
    final stake = ref.read(parlayStateProvider).stake;
    final floored = MoneyFormatter.floorToThousand(stake);
    if (floored == stake) return;
    if (floored <= 0) return;
    ref.read(parlayStateProvider.notifier).setStake(floored);
  }

  void _onKeypadClosed() {
    _normalizeDebounce?.cancel();
    _normalizeStake();
  }

  void _onKeypadChanged(int value, StakeKey key) {
    _scheduleNormalize();
    final notifier = ref.read(parlayStateProvider.notifier);
    var next = value;
    if (key is StakeAddKey) {
      final maxStake = ref.read(parlayStateProvider).maxStake;
      final balanceInVnd = ref.read(balanceInVNDProvider).floor();
      final effectiveMax = MoneyFormatter.floorToThousand(
        balanceInVnd > 0 && balanceInVnd < maxStake ? balanceInVnd : maxStake,
      );
      if (effectiveMax > 0) next = next.clamp(0, effectiveMax);
    }
    notifier.setStake(next);
    final applied = ref.read(parlayStateProvider).stake;
    if (applied != value) {
      StakeKeypadController.instance.adopt(_keypadId, applied);
    }
  }

  void _scheduleNormalize() {
    _normalizeDebounce?.cancel();
    _normalizeDebounce = Timer(MoneyFormatter.stakeNormalizeDebounce, () {
      if (mounted) _normalizeStake();
    });
  }

  @override
  Widget build(BuildContext context) {
    final comboBets = ref.watch(parlayStateProvider.select((s) => s.comboBets));
    final minMatches = ref.watch(
      parlayStateProvider.select((s) => s.minMatches),
    );
    final notifier = ref.read(parlayStateProvider.notifier);

    ref.listen(parlayStateProvider.select((s) => s.stake), (previous, next) {
      StakeKeypadController.instance.adopt(_keypadId, next);
    });

    ref.listen(parlayStateProvider.select((s) => s.isComboValid), (_, isValid) {
      if (!isValid && ref.read(parlayStateProvider).stake != 0) {
        ref.read(parlayStateProvider.notifier).setStake(0);
      }
    });

    if (comboBets.isEmpty) {
      return const _EmptyComboState();
    }

    final eventOrder = <int>[];
    final groups = <int, List<_ComboLeg>>{};
    for (var i = 0; i < comboBets.length; i++) {
      final eventId = comboBets[i].eventData.eventId;
      groups
          .putIfAbsent(eventId, () {
            eventOrder.add(eventId);
            return <_ComboLeg>[];
          })
          .add(_ComboLeg(bet: comboBets[i], index: i));
    }

    var activeEventCount = 0;
    var validMatchCount = 0;
    var hasMultiActiveEvent = false;
    var hasSoleUnsupportedLeg = false;
    for (final legs in groups.values) {
      final active = legs.where((l) => !l.bet.isDisabled).toList();
      if (active.isNotEmpty) activeEventCount++;
      if (active.length == 1) {
        validMatchCount++;
        if (!active.first.bet.marketData.isParlay) hasSoleUnsupportedLeg = true;
      }
      if (active.length > 1) hasMultiActiveEvent = true;
    }

    final _ComboHeaderStatus headerStatus;
    final String headerText;
    if (activeEventCount < minMatches) {
      headerStatus = _ComboHeaderStatus.needMoreMatches;
      headerText = 'Cần tối thiểu $minMatches trận để cược xiên';
    } else if (hasMultiActiveEvent) {
      headerStatus = _ComboHeaderStatus.oneBetPerMatch;
      headerText = 'Chỉ được chọn 1 kèo trong 1 trận để cược xiên';
    } else if (hasSoleUnsupportedLeg) {
      headerStatus = _ComboHeaderStatus.betNotAvailable;
      headerText = 'Kèo không khả dụng';
    } else {
      headerStatus = _ComboHeaderStatus.valid;
      headerText = 'Xiên $validMatchCount Chân';
    }

    return Column(
      children: [
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColorStyles.backgroundTertiary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: _StickyHeaderStack(
            header: _ComboStatusHeader(status: headerStatus, text: headerText),
            children: [
              _StakeCard(
                formatter: _formatter,
                notifier: notifier,
                onKeypadChanged: _onKeypadChanged,
                onKeypadClosed: _onKeypadClosed,
              ),
              for (final eventId in eventOrder)
                _EventGroupTile(
                  legs: groups[eventId]!,
                  onRemove: notifier.removeFromComboParlay,
                ),
              Container(
                width: double.infinity,
                height: 12,
                decoration: const BoxDecoration(
                  color: AppColorStyles.backgroundQuaternary,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StickyHeaderStack extends StatefulWidget {
  final Widget header;
  final List<Widget> children;

  const _StickyHeaderStack({required this.header, required this.children});

  @override
  State<_StickyHeaderStack> createState() => _StickyHeaderStackState();
}

class _StickyHeaderStackState extends State<_StickyHeaderStack> {
  static const double _topGap = 10;

  static const double _listGap = 0;

  final ValueNotifier<double> _shift = ValueNotifier<double>(0);
  final GlobalKey _headerKey = GlobalKey();
  ScrollPosition? _position;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final position = Scrollable.maybeOf(context)?.position;
    if (!identical(position, _position)) {
      _position?.removeListener(_recomputeShift);
      _position = position;
      _position?.addListener(_recomputeShift);
    }
  }

  @override
  void dispose() {
    _position?.removeListener(_recomputeShift);
    _shift.dispose();
    super.dispose();
  }

  void _recomputeShift() {
    final position = _position;
    if (position == null || !position.hasPixels) return;
    final box = context.findRenderObject();
    final headerBox = _headerKey.currentContext?.findRenderObject();
    if (box is! RenderBox ||
        headerBox is! RenderBox ||
        !box.attached ||
        !box.hasSize ||
        !headerBox.hasSize) {
      return;
    }
    final viewport = RenderAbstractViewport.maybeOf(box);
    if (viewport == null) return;
    final revealOffset = viewport.getOffsetToReveal(box, 0).offset;
    final maxShift = (box.size.height - headerBox.size.height).clamp(
      0.0,
      double.infinity,
    );
    _shift.value = (position.pixels - revealOffset + _topGap).clamp(
      0.0,
      maxShift,
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _recomputeShift();
    });
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Visibility(
              visible: false,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: widget.header,
            ),
            ...widget.children,
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: ValueListenableBuilder<double>(
            valueListenable: _shift,
            builder: (context, shift, child) {
              if (shift <= 0) return child!;
              return Transform.translate(
                offset: Offset(0, shift - _topGap),
                child: Container(
                  color: AppColorStyles.backgroundSecondary,
                  padding: const EdgeInsets.only(top: _topGap, bottom: _listGap),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: child,
                  ),
                ),
              );
            },
            child: KeyedSubtree(key: _headerKey, child: widget.header),
          ),
        ),
      ],
    );
  }
}

class _EmptyComboState extends StatelessWidget {
  const _EmptyComboState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(48),
      child: const BetSlipBlank(),
    );
  }
}

class _ComboLeg {
  final SingleBetData bet;
  final int index;

  const _ComboLeg({required this.bet, required this.index});
}

enum _ComboHeaderStatus {
  needMoreMatches,
  oneBetPerMatch,
  betNotAvailable,
  valid,
}

class _ComboStatusHeader extends StatelessWidget {
  final _ComboHeaderStatus status;
  final String text;

  const _ComboStatusHeader({required this.status, required this.text});

  @override
  Widget build(BuildContext context) {
    final isValid = status == _ComboHeaderStatus.valid;
    final iconPath = isValid ? AppIcons.iconParlay : AppIcons.iconInfoCircle;
    final iconColor = isValid
        ? AppColorStyles.contentSecondary
        : AppColors.orange500;
    final textColor = isValid
        ? AppColorStyles.contentSecondary
        : AppColors.orange200;

    return ColoredBox(
      color: AppColorStyles.backgroundTertiary,
      child: Stack(
        children: [
          if (!isValid)
            Positioned.fill(
              child: ImageHelper.load(
                path: AppIcons.ticketComboHeader,
                fit: BoxFit.fill,
              ),
            ),
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                SizedBox.square(
                  dimension: 20,
                  child: ImageHelper.load(path: iconPath, color: iconColor),
                ),
                const Gap(6),
                Expanded(
                  child: Text(
                    text,
                    style: AppTextStyles.labelSmall(color: textColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StakeCard extends ConsumerWidget {
  final NumberFormat formatter;
  final ParlayStateNotifier notifier;
  final StakeKeypadChanged onKeypadChanged;
  final VoidCallback onKeypadClosed;

  const _StakeCard({
    required this.formatter,
    required this.notifier,
    required this.onKeypadChanged,
    required this.onKeypadClosed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalOdds = ref.watch(parlayStateProvider.select((s) => s.totalOdds));
    final potentialWin = ref.watch(
      parlayStateProvider.select((s) => s.potentialWin),
    );
    final stake = ref.watch(parlayStateProvider.select((s) => s.stake));
    final minStake = ref.watch(parlayStateProvider.select((s) => s.minStake));
    final maxStake = ref.watch(parlayStateProvider.select((s) => s.maxStake));
    final isComboValid = ref.watch(
      parlayStateProvider.select((s) => s.isComboValid),
    );
    final stakeValue = stake.toInt();

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColorStyles.backgroundQuaternary,
      ),
      padding: const EdgeInsets.all(12).copyWith(bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Tổng tỷ lệ',
                  style: AppTextStyles.labelMedium(
                    color: AppColorStyles.contentPrimary,
                  ),
                ),
              ),
              Text(
                isComboValid ? totalOdds.toStringAsFixed(2) : '--',
                style: AppTextStyles.labelMedium(
                  color: isComboValid
                      ? const Color(0xFFACDC79)
                      : AppColorStyles.contentSecondary,
                ),
              ),
            ],
          ),
          const Gap(16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: StakeKeypadField(
                  id: StakeKeypadController.slipComboId,
                  value: stakeValue,
                  onChanged: onKeypadChanged,
                  onClosed: onKeypadClosed,
                  enabled: isComboValid,
                  hintText: 'Nhập số tiền',
                  height: 48,
                  suffix: const CurrencySymbol(size: 20),
                ),
              ),

              const Gap(12),

              Expanded(
                child: StakeStatusSlot(
                  stake: stake,
                  minStake: minStake,
                  maxStake: maxStake,
                  isCombo: true,
                  onMinTap: () => notifier.setStake(minStake),
                  onMaxTap: () => notifier.setStake(maxStake),
                  payout: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        I18n.txtEstimatedPayout,
                        style: AppTextStyles.labelSmall(
                          color: AppColorStyles.contentSecondary,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      const Gap(4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CurrencyText(
                            isComboValid
                                ? formatter.format(potentialWin)
                                : '--',
                            iconSize: 20,
                            style: AppTextStyles.labelMedium(
                              color: AppColorStyles.contentSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          StakeKeypadSlot(
            id: StakeKeypadController.slipComboId,
            maxStake: maxStake,
            balance: ref.watch(balanceInVNDProvider).floor(),
          ),
        ],
      ),
    );
  }
}

class _EventGroupTile extends StatelessWidget {
  final List<_ComboLeg> legs;
  final ValueChanged<int> onRemove;

  const _EventGroupTile({required this.legs, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final firstBet = legs.first.bet;
    final allDisabled = legs.every((l) => l.bet.isDisabled);

    return Container(
      color: AppColorStyles.backgroundQuaternary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Gap(12),
          const _Divider(),
          const Gap(12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _EventHeader(bet: firstBet, isDisabled: allDisabled),
          ),
          for (final leg in legs) ...[
            const Gap(12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _ComboBetRow(
                key: ValueKey(leg.bet.selectionId ?? 'leg-${leg.index}'),
                bet: leg.bet,
                onRemove: () => onRemove(leg.index),
              ),
            ),
            if (!leg.bet.isDisabled && !leg.bet.marketData.isParlay) ...[
              const Gap(8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: ParlayNotSupportedBanner(),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _EventHeader extends StatelessWidget {
  final SingleBetData bet;
  final bool isDisabled;

  const _EventHeader({required this.bet, required this.isDisabled});

  @override
  Widget build(BuildContext context) {
    final headerTextColor = isDisabled
        ? AppColorStyles.contentQuaternary
        : AppColorStyles.contentSecondary;

    return Row(
      children: [
        Opacity(
          opacity: isDisabled ? 0.12 : 1,
          child: SizedBox.square(
            dimension: 20,
            child: ImageHelper.load(
              path: SportType.fromId(bet.sportId)?.iconPath ?? '',
              color: AppColorStyles.contentSecondary,
            ),
          ),
        ),
        const Gap(6),
        if (bet.isLive) ...[
          isDisabled ? _DisabledPulseDot() : _PulseDot(),
          const Gap(6),
        ],
        Expanded(
          child: Text(
            '${bet.eventData.homeName} vs ${bet.eventData.awayName}',
            style: AppTextStyles.labelSmall(color: headerTextColor),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ComboBetRow extends ConsumerStatefulWidget {
  final SingleBetData bet;
  final VoidCallback onRemove;

  const _ComboBetRow({required this.bet, required this.onRemove, super.key});

  @override
  ConsumerState<_ComboBetRow> createState() => _ComboBetRowState();
}

class _ComboBetRowState extends ConsumerState<_ComboBetRow>
    with SingleTickerProviderStateMixin {
  static const _cancelledTextColor = Color(0xFFB42318);

  static const double _infoClearance = 32;

  late final AnimationController _animationController;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _opacityAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleDirectionChange(OddsChangeDirection direction) {
    final showRange =
        direction == OddsChangeDirection.up ||
        direction == OddsChangeDirection.down;
    if (showRange) {
      if (!_animationController.isAnimating) {
        _animationController.repeat(reverse: true);
      }
    } else {
      _animationController.stop();
      _animationController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bet = widget.bet;
    final isDisabled = bet.isDisabled;
    final selectionId = bet.selectionId;

    if (selectionId != null) {
      ref.listen<OddsChangeDirection>(
        oddsDirectionProvider(selectionId),
        (previous, next) => _handleDirectionChange(next),
      );
    }

    final marketNameColor = isDisabled
        ? AppColorStyles.contentQuaternary
        : AppColorStyles.contentTertiary;
    final selectionNameColor = isDisabled
        ? AppColorStyles.contentTertiary
        : AppColorStyles.contentPrimary;
    final infoIconColor = isDisabled
        ? AppColorStyles.contentQuaternary
        : AppColors.yellow300;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColorStyles.backgroundTertiary,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Gap(4),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bet.marketName,
                          style: AppTextStyles.labelXSmall(
                            color: marketNameColor,
                          ),
                        ),
                        Gap(isDisabled ? 8 : 14),
                        Text(
                          bet.displayName,
                          style: AppTextStyles.labelSmall(
                            color: selectionNameColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                Stack(
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: ParlayExplanationButton.tapTargetSize,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Gap(_infoClearance),
                          isDisabled
                              ? Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                    end: 12.0,
                                    bottom: 8,
                                  ),
                                  child: Text(
                                    ' Đã bị hủy',
                                    style: AppTextStyles.labelSmall(
                                      color: _cancelledTextColor,
                                    ),
                                  ),
                                )
                              : _ComboOddsDisplay(
                                  bet: bet,
                                  selectionId: selectionId,
                                  opacityAnimation: _opacityAnimation,
                                ),
                        ],
                      ),
                    ),
                    PositionedDirectional(
                      top: 0,
                      end: 0,
                      child: ParlayExplanationButton(
                        data: bet.toHintData(
                          oddsStyleOverride: ref.watch(oddsStyleProvider),
                        ),
                        color: infoIconColor,
                        iconPadding: const EdgeInsetsDirectional.fromSTEB(
                          15,
                          11,
                          11,
                          15,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const Gap(12),
        InkWell(
          onTap: SoundTap.wrap(widget.onRemove),
          borderRadius: BorderRadius.circular(20),
          child: SizedBox.square(
            dimension: 20,
            child: Center(child: ImageHelper.load(path: AppIcons.icRemove)),
          ),
        ),
      ],
    );
  }
}

class _ComboOddsDisplay extends ConsumerWidget {
  final SingleBetData bet;
  final String? selectionId;
  final Animation<double> opacityAnimation;

  const _ComboOddsDisplay({
    required this.bet,
    required this.selectionId,
    required this.opacityAnimation,
  });

  static const _upRangeBgColor = Color(0x33669F2A);
  static const _downRangeBgColor = Color(0x33F04438);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectionId = this.selectionId;

    final decimalSnapshot = bet.getOddsByStyle(OddsStyle.decimal);
    final fallbackOdds = (decimalSnapshot == 0 || decimalSnapshot == -100)
        ? '-'
        : decimalSnapshot.toStringAsFixed(2);

    final displayOdds = selectionId != null
        ? ref.watch(
            oddsValueDecimalProvider(
              selectionId,
            ).select((v) => v ?? fallbackOdds),
          )
        : fallbackOdds;
    final direction = selectionId != null
        ? ref.watch(oddsDirectionProvider(selectionId))
        : OddsChangeDirection.none;

    final isInvalidOdds = displayOdds == '-';
    final oddsValueColor = AppColors.green300;

    final styleSuffix = isInvalidOdds
        ? ''
        : ' (${OddsStyle.decimal.displaySuffix})';

    final showUpRange = direction == OddsChangeDirection.up;
    final showDownRange = direction == OddsChangeDirection.down;
    final oddsBgColor = showUpRange
        ? _upRangeBgColor
        : showDownRange
        ? _downRangeBgColor
        : Colors.transparent;

    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 12.0, bottom: 8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: oddsBgColor,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text.rich(
              TextSpan(
                style: AppTextStyles.labelSmall(color: oddsValueColor),
                children: [
                  TextSpan(text: displayOdds),
                  if (styleSuffix.isNotEmpty)
                    TextSpan(
                      text: styleSuffix,
                      style: AppTextStyles.labelSmall(
                        color: AppColorStyles.contentSecondary,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (showUpRange)
            Positioned(
              right: -5,
              top: 0,
              child: AnimatedBuilder(
                animation: opacityAnimation,
                builder: (context, child) =>
                    Opacity(opacity: opacityAnimation.value, child: child),
                child: ImageHelper.load(
                  path: AppIcons.upRangeBet,
                  width: 8,
                  height: 8,
                  fit: BoxFit.fill,
                ),
              ),
            ),
          if (showDownRange)
            Positioned(
              right: -5,
              bottom: 0,
              child: AnimatedBuilder(
                animation: opacityAnimation,
                builder: (context, child) =>
                    Opacity(opacity: opacityAnimation.value, child: child),
                child: ImageHelper.load(
                  path: AppIcons.downRangeBet,
                  width: 8,
                  height: 8,
                  fit: BoxFit.fill,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PulseDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        color: AppColors.red500,
      ),
      child: Text(
        'Trực tiếp',
        style: AppTextStyles.labelXXSmall(color: AppColorStyles.contentPrimary),
      ),
    );
  }
}

class _DisabledPulseDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Opacity(opacity: 0.12, child: _PulseDot());
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const DashedDivider.horizontal(
      thickness: 4,
      dashGap: 6,
      height: 20,
      color: AppColorStyles.backgroundTertiary,
    );
  }
}
