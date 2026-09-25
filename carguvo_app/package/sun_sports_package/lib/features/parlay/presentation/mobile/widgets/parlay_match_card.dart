import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show NumberFormat;
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/services/models/api_v2/sport_constants.dart'
    show SportType;
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/money_formatter.dart';
import 'package:sun_sports/core/utils/styles/app_audios.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/parlay/domain/models/single_bet_data.dart';
import 'package:sun_sports/features/preferences/bet/odds_info.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/providers/parlay_state_provider.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/providers/parlay_live_odds_provider.dart';
import 'package:sun_sports/features/parlay/presentation/providers/parlay_overlay_provider.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/widgets/parlay_explanation_button.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/widgets/parlay_not_supported_banner.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/widgets/stake_status_slot.dart';
import 'package:sun_sports/features/sport/presentation/providers/odds_change_provider.dart';
import 'package:sun_sports/features/sport/data/adapters/sport_socket_adapter_provider.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/shared/domain/enums/betting_enums.dart'
    hide OddsChangeDirection;
import 'package:sun_sports/shared/domain/enums/league_enums.dart';
import 'package:sun_sports/shared/widgets/bet_explanation/bet_explanation.dart';
import 'package:sun_sports/shared/widgets/status_information/status_information.dart';
import 'package:sun_sports/shared/widgets/texts/texts.dart';
import 'package:sun_sports/providers/user_provider/user_provider.dart';
import 'package:sun_sports/shared/widgets/stake_keypad/stake_keypad.dart';
import 'package:sun_sports/shared/widgets/stake_keypad/stake_keypad_controller.dart';
import 'package:sun_sports/shared/widgets/stake_keypad/stake_keypad_field.dart';
import 'package:sun_sports/shared/widgets/stake_keypad/stake_keypad_math.dart';
import 'package:sun_sports/providers/main_content_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/league_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/market_status_provider.dart';
import 'package:sun_sports/features/bet_detail/presentation/providers/bet_detail_v2_provider.dart';
import 'package:sun_sports/core/services/models/api_v2/legacy_to_v2_adapter.dart';
import 'package:sun_sports/core/services/models/api_v2/league_model_v2.dart';
import 'package:sun_sports/features/sport/presentation/providers/event_live_provider.dart';
import 'package:sun_sports/shared/widgets/sport/enums/event_status.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class ParlayMatchCard extends ConsumerWidget {
  const ParlayMatchCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final singleBets = ref.watch(singleBetsProvider);

    if (singleBets.isEmpty) {
      return const _EmptyState();
    }

    return Column(
      children: [
        for (int i = singleBets.length - 1; i >= 0; i--) ...[
          _SingleBetCard(
            key: ValueKey(_stakeKeyOf(singleBets[i])),
            index: i,
            singleBet: singleBets[i],
          ),
          if (i > 0) const Gap(8),
        ],
      ],
    );
  }
}

String _stakeKeyOf(SingleBetData bet) =>
    bet.selectionId ??
    bet.offerId ??
    '${bet.eventData.eventId}:${bet.marketData.marketId}:${bet.oddsType.name}';

class _SingleBetCard extends ConsumerStatefulWidget {
  final int index;
  final SingleBetData singleBet;

  const _SingleBetCard({
    required this.index,
    required this.singleBet,
    super.key,
  });

  @override
  ConsumerState<_SingleBetCard> createState() => _SingleBetCardState();
}

class _SingleBetCardState extends ConsumerState<_SingleBetCard> {
  final _formatter = NumberFormat('#,###');
  Timer? _normalizeDebounce;

  String get _keypadId =>
      StakeKeypadController.slipId(_stakeKeyOf(widget.singleBet));

  @override
  void dispose() {
    _normalizeDebounce?.cancel();
    super.dispose();
  }

  void _normalizeStake() {
    final bets = ref.read(parlayStateProvider).singleBets;
    if (widget.index < 0 || widget.index >= bets.length) return;
    final stake = bets[widget.index].stake;
    final floored = MoneyFormatter.floorToThousand(stake);
    if (floored == stake) return;
    if (floored <= 0) return;

    _writeStake(floored);
  }

  void _onKeypadClosed() {
    _normalizeDebounce?.cancel();
    _normalizeStake();
  }

  void _scheduleNormalize() {
    _normalizeDebounce?.cancel();
    _normalizeDebounce = Timer(MoneyFormatter.stakeNormalizeDebounce, () {
      if (mounted) _normalizeStake();
    });
  }

  @override
  void didUpdateWidget(covariant _SingleBetCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.singleBet.stake != widget.singleBet.stake) {
      StakeKeypadController.instance.adopt(_keypadId, widget.singleBet.stake);
    }
  }

  void _onKeypadChanged(int value, StakeKey key) {
    _scheduleNormalize();

    var parsed = value;
    final maxStakeActual = widget.singleBet.maxStakeActual;
    if (parsed > maxStakeActual && maxStakeActual > 0) parsed = maxStakeActual;

    _writeStake(parsed);
  }

  void _selectStake(int value) {
    _normalizeDebounce?.cancel();
    final maxStakeActual = widget.singleBet.maxStakeActual;
    var parsed = value;
    if (maxStakeActual > 0 && parsed > maxStakeActual) parsed = maxStakeActual;

    _writeStake(parsed);
  }

  void _writeStake(int value) {
    final notifier = ref.read(parlayStateProvider.notifier);
    notifier.setSingleBetStakeAt(widget.index, value);
    final bets = ref.read(parlayStateProvider).singleBets;
    if (widget.index < 0 || widget.index >= bets.length) return;
    StakeKeypadController.instance.adopt(_keypadId, bets[widget.index].stake);
  }

  @override
  Widget build(BuildContext context) {
    final singleBet = widget.singleBet;

    final isBetDisabled = singleBet.isDisabled;

    final isEventHidden = ref.watch(
      eventLiveDataProvider(
        singleBet.eventData.eventId,
      ).select((data) => EventStatusX.fromString(data?.status).isHidden),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        color: AppColorStyles.backgroundTertiary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: _TicketHeader(
                singleBet: singleBet,
                isDisabled: isBetDisabled || isEventHidden,
                onRemove: () => ref
                    .read(parlayStateProvider.notifier)
                    .removeSingleBetAt(widget.index),
                onMatchTitleTap: (isBetDisabled || isEventHidden)
                    ? null
                    : () => _navigateToBetDetail(context),
              ),
            ),
            _SelectionStakeCard(
              singleBet: singleBet,
              isCalculating: singleBet.isCalculating,
              isDisabled: isBetDisabled,
              formatter: _formatter,
              keypadId: _keypadId,
              onKeypadChanged: _onKeypadChanged,
              onKeypadClosed: _onKeypadClosed,
              onQuickStake: _selectStake,
            ),
            if (!isBetDisabled &&
                !isEventHidden &&
                !singleBet.marketData.isParlay)
              const _ParlayNotSupportedNotification(),
          ],
        ),
      ),
    );
  }

  void _navigateToBetDetail(BuildContext context) {
    final singleBet = widget.singleBet;
    final sportId = singleBet.sportId;
    final leagueId = singleBet.leagueData?.leagueId ?? 0;

    ref.read(selectedEventV2Provider.notifier).state = singleBet.eventData
        .toEventModelV2(leagueId: leagueId, sportId: sportId);

    final leagueData = singleBet.leagueData;
    ref.read(selectedLeagueV2Provider.notifier).state = leagueData != null
        ? leagueData.toLeagueModelV2(sportId: sportId)
        : LeagueModelV2(
            events: const [],
            sportId: sportId,
            leagueId: leagueId,
            leagueName: '',
            leagueNameEn: '',
            leagueLogo: '',
          );

    if (ResponsiveBuilder.isDesktop(context)) {
      ref.read(parlayOverlayVisibleProvider.notifier).state = false;
    } else {
      Navigator.of(context).pop();
    }

    ref.read(mainContentProvider.notifier).goToBetDetail();
  }
}

class _TicketHeader extends StatelessWidget {
  final SingleBetData singleBet;
  final bool isDisabled;
  final VoidCallback onRemove;
  final VoidCallback? onMatchTitleTap;

  const _TicketHeader({
    required this.singleBet,
    required this.onRemove,
    this.isDisabled = false,
    this.onMatchTitleTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDisabled
        ? AppColorStyles.contentQuaternary
        : AppColorStyles.contentSecondary;
    final titleStyle = AppTextStyles.labelSmall(
      color: textColor,
    ).copyWith(fontSize: 13, height: 18 / 13);

    if (singleBet.isLive) {
      final matchTitle =
          '${singleBet.homeName} ${singleBet.eventData.homeScore} - ${singleBet.eventData.awayScore} ${singleBet.awayName}';

      return Row(
        children: [
          SizedBox.square(
            dimension: 20,
            child: ImageHelper.load(
              path: SportType.fromId(singleBet.sportId)?.iconPath ?? '',
              color: AppColorStyles.contentSecondary,
            ),
          ),
          const Gap(6),
          isDisabled ? const _DisabledLiveDot() : const _LiveDot(),
          const Gap(6),
          Expanded(
            child: GestureDetector(
              onTap: SoundTap.wrap(onMatchTitleTap),
              child: Text(
                matchTitle,
                maxLines: 1,
                style: titleStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          _CloseButton(onTap: onRemove),
        ],
      );
    }

    final matchTitle = '${singleBet.homeName} - ${singleBet.awayName}';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox.square(
          dimension: 20,
          child: ImageHelper.load(
            path: SportType.fromId(singleBet.sportId)?.iconPath ?? '',
            color: AppColorStyles.contentSecondary,
          ),
        ),
        const Gap(6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: SoundTap.wrap(onMatchTitleTap),
                child: Text(
                  matchTitle,
                  style: titleStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        _CloseButton(onTap: onRemove),
      ],
    );
  }
}

class _CloseButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CloseButton({required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: SoundTap.wrap(onTap, sound: AppSound.removeFromBetslip),
    borderRadius: BorderRadius.circular(10),
    child: SizedBox.square(
      dimension: 20,
      child: Center(child: ImageHelper.load(path: AppIcons.icRemove)),
    ),
  );
}

class _SelectionStakeCard extends ConsumerStatefulWidget {
  final SingleBetData singleBet;
  final bool isCalculating;
  final bool isDisabled;
  final NumberFormat formatter;
  final String keypadId;
  final StakeKeypadChanged onKeypadChanged;
  final VoidCallback onKeypadClosed;
  final ValueChanged<int> onQuickStake;

  const _SelectionStakeCard({
    required this.singleBet,
    required this.isCalculating,
    required this.formatter,
    required this.keypadId,
    required this.onKeypadChanged,
    required this.onKeypadClosed,
    required this.onQuickStake,
    this.isDisabled = false,
  });

  @override
  ConsumerState<_SelectionStakeCard> createState() =>
      _SelectionStakeCardState();
}

class _SelectionStakeCardState extends ConsumerState<_SelectionStakeCard>
    with SingleTickerProviderStateMixin {
  static const _cancelledTextColor = Color(0xFFB42318);

  static const double _infoClearance = 32;

  late final AnimationController _animationController;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
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

  void _updateAnimation(bool shouldAnimate) {
    if (shouldAnimate) {
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
    final singleBet = widget.singleBet;
    final selectionId = singleBet.selectionId;
    final eventId = singleBet.eventData.eventId;
    final marketId = singleBet.marketData.marketId;

    final isMarketSuspended = ref.watch(
      isMarketSuspendedProvider((eventId, marketId)),
    );

    final isEventHidden = ref.watch(
      eventLiveDataProvider(
        eventId,
      ).select((data) => EventStatusX.fromString(data?.status).isHidden),
    );

    final isEffectivelyDisabled =
        widget.isDisabled || isMarketSuspended || isEventHidden;

    final marketNameColor = isEffectivelyDisabled
        ? AppColorStyles.contentQuaternary
        : AppColorStyles.contentSecondary;
    final selectionNameColor = isEffectivelyDisabled
        ? AppColorStyles.contentTertiary
        : AppColorStyles.contentPrimary;
    final infoIconColor = isEffectivelyDisabled
        ? AppColorStyles.contentQuaternary
        : AppColors.yellow300;

    return Container(
      color: AppColorStyles.backgroundQuaternary,
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(12),
                    Text(
                      singleBet.marketName,
                      style: AppTextStyles.paragraphXSmall(
                        color: marketNameColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Gap(4),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            singleBet.displayName,
                            style: AppTextStyles.labelSmall(
                              color: selectionNameColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (singleBet.isLive) ...[
                          const Gap(8),
                          _MatchInfoLabel(
                            singleBet: singleBet,
                            color: marketNameColor,
                          ),
                        ],
                      ],
                    ),
                    if (singleBet.errorMessage != null &&
                        !isEffectivelyDisabled) ...[
                      const Gap(4),
                      Text(
                        singleBet.errorMessage!,
                        style: AppTextStyles.labelXSmall(
                          color: const Color(0xFFFF5172),
                        ),
                      ),
                    ],
                  ],
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
                        if (widget.isDisabled || isEventHidden)
                          Padding(
                            padding: const EdgeInsetsDirectional.only(end: 12.0),
                            child: Text(
                              'Đã bị hủy',
                              style: AppTextStyles.labelSmall(
                                color: _cancelledTextColor,
                              ),
                            ),
                          )
                        else if (isMarketSuspended)
                          Padding(
                            padding: const EdgeInsetsDirectional.only(end: 12.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.lock_outline,
                                  size: 14,
                                  color: Color(0xFFAAA49B),
                                ),
                                const Gap(4),
                                Text(
                                  'Tạm khóa',
                                  style: AppTextStyles.labelSmall(
                                    color: const Color(0xFFAAA49B),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (widget.isCalculating)
                          const Padding(
                            padding: EdgeInsetsDirectional.only(end: 12.0),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFFFDE272),
                                ),
                              ),
                            ),
                          )
                        else
                          _OddsDisplay(
                            selectionId: selectionId,
                            singleBet: singleBet,
                            animationController: _animationController,
                            opacityAnimation: _opacityAnimation,
                            onDirectionChanged: _updateAnimation,
                          ),
                      ],
                    ),
                  ),
                  PositionedDirectional(
                    top: 0,
                    end: 0,
                    child: Consumer(
                      builder: (context, ref, _) => ParlayExplanationButton(
                        data: singleBet.toHintData(
                          oddsStyleOverride: ref.watch(oddsStyleProvider),
                          liveRatio: watchLiveOddsFor(ref, singleBet),
                        ),
                        color: infoIconColor,
                        iconPadding: const EdgeInsetsDirectional.fromSTEB(
                          11,
                          11,
                          15,
                          15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Gap(12),
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: _StakeInput(
                    keypadId: widget.keypadId,
                    singleBet: singleBet,
                    onChanged: widget.onKeypadChanged,
                    onClosed: widget.onKeypadClosed,
                    isDisabled: isEffectivelyDisabled,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: StakeStatusSlot(
                    stake: singleBet.stake,
                    minStake: singleBet.minStakeActual,
                    maxStake: singleBet.maxStakeActual,
                    disabled: isEffectivelyDisabled,
                    onMinTap: () =>
                        widget.onQuickStake(singleBet.minStakeActual),
                    onMaxTap: () =>
                        widget.onQuickStake(singleBet.maxStakeActual),
                    payout: _PotentialWinningsDisplay(
                      singleBet: singleBet,
                      formatter: widget.formatter,
                      isDisabled: isEffectivelyDisabled,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 12.0),
            child: Consumer(
              builder: (context, ref, _) => StakeKeypadSlot(
                id: widget.keypadId,
                maxStake: singleBet.maxStakeActual,
                balance: ref.watch(balanceInVNDProvider).floor(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchInfoLabel extends ConsumerWidget {
  final SingleBetData singleBet;
  final Color color;

  const _MatchInfoLabel({required this.singleBet, required this.color});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventId = singleBet.eventData.eventId;
    final label = ref.watch(
      eventLiveDataProvider(eventId).select(
        (data) => singleBet.liveMatchInfoLabel(
          homeScore: data?.homeScore ?? singleBet.eventData.homeScore,
          awayScore: data?.awayScore ?? singleBet.eventData.awayScore,
          cornersHome: data?.cornersHome ?? singleBet.eventData.cornersHome,
          cornersAway: data?.cornersAway ?? singleBet.eventData.cornersAway,
          yellowCardsHome:
              data?.yellowCardsHome ?? singleBet.eventData.yellowCardsHome,
          yellowCardsAway:
              data?.yellowCardsAway ?? singleBet.eventData.yellowCardsAway,
          redCardsHome: data?.redCardsHome ?? singleBet.eventData.redCardsHome,
          redCardsAway: data?.redCardsAway ?? singleBet.eventData.redCardsAway,
        ),
      ),
    );

    if (label.isEmpty) return const SizedBox.shrink();
    return Text('[$label]', style: AppTextStyles.paragraphXSmall(color: color));
  }
}

class _OddsDisplay extends ConsumerStatefulWidget {
  final String? selectionId;
  final SingleBetData singleBet;
  final AnimationController animationController;
  final Animation<double> opacityAnimation;
  final ValueChanged<bool> onDirectionChanged;

  const _OddsDisplay({
    required this.selectionId,
    required this.singleBet,
    required this.animationController,
    required this.opacityAnimation,
    required this.onDirectionChanged,
  });

  @override
  ConsumerState<_OddsDisplay> createState() => _OddsDisplayState();
}

class _OddsDisplayState extends ConsumerState<_OddsDisplay> {
  static const _upRangeBgColor = Color(0x33669F2A);
  static const _downRangeBgColor = Color(0x33F04438);

  OddsChangeDirection _lastDirection = OddsChangeDirection.none;

  @override
  Widget build(BuildContext context) {
    final selectionId = widget.selectionId;

    final direction = selectionId != null
        ? ref.watch(oddsDirectionProvider(selectionId))
        : OddsChangeDirection.none;

    final currentOddsStyle = ref.watch(oddsStyleProvider);

    final oddsChangeData = ref.watch(oddsChangeDataProvider(selectionId ?? ''));

    final adapter = ref.read(sportSocketAdapterProvider);
    final effectiveOdds = resolveEffectiveOdds(
      singleBet: widget.singleBet,
      wsValues: oddsChangeData?.oddsValues,
      style: currentOddsStyle,
      storeOdds: readStoreOdds(adapter, widget.singleBet, currentOddsStyle),
    );

    final isInvalidOdds = effectiveOdds == 0 || effectiveOdds == -100;
    final oddsValueString = isInvalidOdds
        ? '-'
        : effectiveOdds.toStringAsFixed(2);
    final effectiveStyle = widget.singleBet.resolvedStyleFor(currentOddsStyle);
    final styleSuffixString =
        !isInvalidOdds && !widget.singleBet.isAlwaysDecimalMarket
        ? ' (${effectiveStyle.displaySuffix})'
        : '';

    final isNegativeOdds = !isInvalidOdds && effectiveOdds < 0;
    final oddsValueColor = isNegativeOdds
        ? AppColors.orange400
        : AppColors.green300;

    final showUpRange = direction == OddsChangeDirection.up;
    final showDownRange = direction == OddsChangeDirection.down;

    if (direction != _lastDirection) {
      _lastDirection = direction;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onDirectionChanged(showUpRange || showDownRange);
      });
    }

    final oddsBgColor = showUpRange
        ? _upRangeBgColor
        : showDownRange
        ? _downRangeBgColor
        : Colors.transparent;

    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 12.0),
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
                style: AppTextStyles.labelSmall(
                  color: oddsValueColor,
                ),
                children: [
                  TextSpan(text: oddsValueString),
                  if (styleSuffixString.isNotEmpty)
                    TextSpan(
                      text: styleSuffixString,
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
                animation: widget.opacityAnimation,
                builder: (context, child) => Opacity(
                  opacity: widget.opacityAnimation.value,
                  child: child,
                ),
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
                animation: widget.opacityAnimation,
                builder: (context, child) => Opacity(
                  opacity: widget.opacityAnimation.value,
                  child: child,
                ),
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

class _PotentialWinningsDisplay extends ConsumerWidget {
  final SingleBetData singleBet;
  final NumberFormat formatter;
  final bool isDisabled;

  const _PotentialWinningsDisplay({
    required this.singleBet,
    required this.formatter,
    required this.isDisabled,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final potentialWinnings = watchLivePotentialWinnings(ref, singleBet);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          I18n.txtEstimatedPayout,
          style: AppTextStyles.labelSmall(
            color: isDisabled
                ? AppColorStyles.contentQuaternary
                : AppColorStyles.contentSecondary,
          ),
          textAlign: TextAlign.right,
        ),
        const Gap(4),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CurrencyText(
              isDisabled ? '0' : formatter.format(potentialWinnings.round()),
              iconSize: 20,
              style: AppTextStyles.labelMedium(
                color: isDisabled
                    ? AppColorStyles.contentQuaternary
                    : AppColorStyles.contentSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StakeInput extends StatelessWidget {
  final String keypadId;
  final SingleBetData singleBet;
  final StakeKeypadChanged onChanged;
  final VoidCallback onClosed;
  final bool isDisabled;

  const _StakeInput({
    required this.keypadId,
    required this.singleBet,
    required this.onChanged,
    required this.onClosed,
    this.isDisabled = false,
  });

  String get _hintText {
    final style = singleBet.sendOddsStyle;
    final value = singleBet.displayOdds;
    if ((style == OddsStyle.malay && value < 0) ||
        (style == OddsStyle.indo && value < -1)) {
      return 'Nhập mức thắng';
    }
    return 'Nhập số tiền';
  }

  @override
  Widget build(BuildContext context) => StakeKeypadField(
    id: keypadId,
    value: singleBet.stake,
    onChanged: onChanged,
    onClosed: onClosed,
    enabled: !isDisabled,
    hintText: _hintText,
    suffix: const CurrencySymbol(size: 20),
  );
}

class _LiveDot extends StatelessWidget {
  const _LiveDot();

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

class _DisabledLiveDot extends StatelessWidget {
  const _DisabledLiveDot();

  @override
  Widget build(BuildContext context) =>
      const Opacity(opacity: 0.12, child: _LiveDot());
}

class _ParlayNotSupportedNotification extends StatelessWidget {
  const _ParlayNotSupportedNotification();

  @override
  Widget build(BuildContext context) => Container(
    color: AppColorStyles.backgroundQuaternary,
    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
    child: const ParlayNotSupportedBanner(),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(48),
      child: const BetSlipBlank(),
    );
  }
}
