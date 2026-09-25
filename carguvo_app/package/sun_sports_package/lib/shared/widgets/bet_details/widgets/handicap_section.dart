import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/sport/presentation/providers/event_live_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/league_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/odds_change_provider.dart';
import 'package:sun_sports/shared/domain/enums/betting_enums.dart'
    hide OddsChangeDirection;
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/bet_detail/domain/helpers/market_layout_helper.dart';
import 'package:sun_sports/features/bet_detail/presentation/providers/bet_detail_v2_provider.dart';
import 'package:sun_sports/features/preferences/bet/odds_info.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';
import 'package:sun_sports/shared/widgets/bet_details/models/betting_popup_data.dart';
import 'package:sun_sports/shared/widgets/bet_details/hint_bubble/hint_bubble.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class HandicapSection extends ConsumerStatefulWidget {
  final BettingPopupData? data;
  final double? currentOdds;
  final int stake;

  const HandicapSection({
    super.key,
    this.data,
    this.currentOdds,
    this.stake = 100,
  });

  @override
  ConsumerState<HandicapSection> createState() => _HandicapSectionState();
}

class _HandicapSectionState extends ConsumerState<HandicapSection>
    with SingleTickerProviderStateMixin {
  static const _upRangeBgColor = Color(0x33669F2A);
  static const _downRangeBgColor = Color(0x33F04438);

  late final AnimationController _animationController;
  late final Animation<double> _opacityAnimation;
  OddsChangeDirection _lastDirection = OddsChangeDirection.none;

  BettingPopupData? get data => widget.data;
  double? get currentOdds => widget.currentOdds;
  int get stake => widget.stake;

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
    if (!mounted) return;
    if (shouldAnimate) {
      if (!_animationController.isAnimating) {
        _animationController.repeat(reverse: true);
      }
    } else {
      _animationController.stop();
      _animationController.reset();
    }
  }

  String? _rawSelectionId(BettingPopupData popup) {
    return switch (popup.oddsType) {
      OddsType.home => popup.oddsData.selectionHomeId,
      OddsType.away => popup.oddsData.selectionAwayId,
      OddsType.draw => popup.oddsData.selectionDrawId,
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return const SizedBox.shrink();
    }

    final oddsStyle = ref.watch(oddsStyleProvider);

    final selectionId = _rawSelectionId(data!);
    final direction = (selectionId != null && selectionId.isNotEmpty)
        ? ref.watch(oddsDirectionProvider(selectionId))
        : OddsChangeDirection.none;

    if (direction != _lastDirection) {
      _lastDirection = direction;
      final shouldAnimate = direction != OddsChangeDirection.none;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateAnimation(shouldAnimate);
      });
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColorStyles.backgroundQuaternary,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        data?.getMarketNameViDisplay() ??
                            'Toàn trận - Kèo chấp',
                        style: AppTextStyles.labelXSmall(
                          color: AppColorStyles.contentSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: SoundTap.wrap(
                          () => _showHintBubble(context, ref),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          child: ImageHelper.load(
                            path: AppIcons.iconInfo,
                            width: 16,
                            height: 16,
                            color: AppColors.yellow300,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: AppColors.yellow300.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          data != null ? _buildSelectionLabel(data!) : '-',
                          style: AppTextStyles.labelMedium(
                            color: AppColors.yellow300,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    if (data?.isLive == true) ...[
                      const SizedBox(width: 8),
                      _MatchInfoLabel(
                        data: data!,
                        color: AppColorStyles.contentSecondary,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          _buildOddsDisplay(oddsStyle, direction),
        ],
      ),
    );
  }

  Widget _buildOddsDisplay(OddsStyle oddsStyle, OddsChangeDirection direction) {
    final showUpRange = direction == OddsChangeDirection.up;
    final showDownRange = direction == OddsChangeDirection.down;

    final oddsBgColor = showUpRange
        ? _upRangeBgColor
        : showDownRange
        ? _downRangeBgColor
        : Colors.transparent;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: oddsBgColor,
            borderRadius: BorderRadius.circular(100),
          ),
          child: _buildOddsText(oddsStyle),
        ),
        if (showUpRange)
          Positioned(
            right: -5,
            top: 0,
            child: AnimatedBuilder(
              animation: _opacityAnimation,
              builder: (context, child) => Opacity(
                opacity: _opacityAnimation.value,
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
              animation: _opacityAnimation,
              builder: (context, child) => Opacity(
                opacity: _opacityAnimation.value,
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
    );
  }

  String _buildSelectionLabel(BettingPopupData popup) {
    final teamName = popup.getDisplaySelectionLabel();
    final marketId = popup.marketData.marketId;
    if (MarketLayoutHelper.isCorrectScore(marketId) ||
        MarketLayoutHelper.isTotalScore(marketId) ||
        MarketLayoutHelper.isExactGoals(marketId) ||
        MarketLayoutHelper.isCornerRange(marketId)) {
      return teamName;
    }
    final pointsDisplay = popup.getSelectedPointsDisplay();
    if (pointsDisplay.isEmpty) return teamName;
    if (double.tryParse(pointsDisplay) == 0) return teamName;
    return '$teamName ($pointsDisplay)';
  }

  Widget _buildOddsText(OddsStyle oddsStyle) {
    final oddsStyleText = AppTextStyles.labelMedium(
      color: AppColors.yellow300,
    );
    if (data == null) {
      return Text('-', style: oddsStyleText);
    }
    final oddsValueForType = data!.oddsType == OddsType.home
        ? data!.oddsData.oddsHome
        : data!.oddsType == OddsType.away
        ? data!.oddsData.oddsAway
        : data!.oddsData.oddsDraw;
    final effective = MarketLayoutHelper.getEffectiveOddsStyle(
      data!.marketData.marketId,
      oddsStyle,
    );
    final resolved = MarketLayoutHelper.resolveOddsWithStyle(
      oddsValueForType,
      effective,
    );
    final effectiveValue = (resolved?.style == effective && currentOdds != null)
        ? currentOdds!
        : resolved?.value;
    final effectiveStyle = resolved?.style ?? effective;

    if (effectiveValue == null ||
        effectiveValue == 0 ||
        effectiveValue == -100) {
      return Text('-', style: oddsStyleText);
    }
    final formatted = effectiveValue.toStringAsFixed(2);
    final showSuffix = !MarketLayoutHelper.isAlwaysDecimal(
      data!.marketData.marketId,
    );
    if (!showSuffix) {
      return Text(formatted, style: oddsStyleText);
    }
    return Text.rich(
      TextSpan(
        style: oddsStyleText,
        children: [
          TextSpan(text: formatted),
          TextSpan(
            text: ' (${effectiveStyle.displaySuffix})',
            style: AppTextStyles.labelMedium(
              color: AppColorStyles.contentSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showHintBubble(BuildContext context, WidgetRef ref) {
    if (data == null) return;

    final oddsStyle = ref.read(oddsStyleProvider);
    final oddsValueForType = data!.oddsType == OddsType.home
        ? data!.oddsData.oddsHome
        : data!.oddsType == OddsType.away
        ? data!.oddsData.oddsAway
        : data!.oddsData.oddsDraw;
    final effective = MarketLayoutHelper.getEffectiveOddsStyle(
      data!.marketData.marketId,
      oddsStyle,
    );
    final resolved = MarketLayoutHelper.resolveOddsWithStyle(
      oddsValueForType,
      effective,
    );
    final useRealtime =
        resolved?.style == effective && currentOdds != null;
    final odds = useRealtime
        ? currentOdds!
        : (resolved?.value ?? data!.getSelectedOddsValue());
    final effectiveStyle = resolved?.style ?? effective;

    final stakeInVND = stake.toDouble();

    final selectedEvent = ref.read(selectedEventV2Provider);
    final scoreV2 =
        (selectedEvent != null &&
            selectedEvent.eventId == data!.eventData.eventId)
        ? selectedEvent.score
        : null;

    final hintData = HintDataFactory.fromBettingPopup(
      popupData: data!,
      currentOdds: odds,
      stake: stakeInVND,
      scoreV2: scoreV2,
      styleOverride: effectiveStyle,
    );

    showHintBubble(context: context, hintData: hintData);
  }
}

class _MatchInfoLabel extends ConsumerWidget {
  final BettingPopupData data;
  final Color color;

  const _MatchInfoLabel({required this.data, required this.color});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventId = data.eventData.eventId;
    final label = ref.watch(
      eventLiveDataProvider(eventId).select(
        (live) => data.liveMatchInfoLabel(
          homeScore: live?.homeScore ?? data.eventData.homeScore,
          awayScore: live?.awayScore ?? data.eventData.awayScore,
          cornersHome: live?.cornersHome ?? data.eventData.cornersHome,
          cornersAway: live?.cornersAway ?? data.eventData.cornersAway,
          yellowCardsHome:
              live?.yellowCardsHome ?? data.eventData.yellowCardsHome,
          yellowCardsAway:
              live?.yellowCardsAway ?? data.eventData.yellowCardsAway,
          redCardsHome: live?.redCardsHome ?? data.eventData.redCardsHome,
          redCardsAway: live?.redCardsAway ?? data.eventData.redCardsAway,
        ),
      ),
    );

    if (label.isEmpty) return const SizedBox.shrink();
    return Text('[$label]', style: AppTextStyles.labelMedium(color: color));
  }
}
