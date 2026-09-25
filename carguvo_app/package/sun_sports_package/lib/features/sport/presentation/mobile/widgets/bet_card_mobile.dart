import 'package:flutter/foundation.dart';
import 'package:adaptive_overlay/adaptive_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/sport/presentation/providers/market_status_provider.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/scroll_aware_controller.dart';
import 'package:sun_sports/core/utils/sound_effects.dart';
import 'package:sun_sports/core/utils/styles/app_audios.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/providers/parlay_state_provider.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/screens/parlay_mobile_screen.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/sport/presentation/providers/odds_change_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/vibrating_odds_provider.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/shared/domain/enums/betting_enums.dart'
    hide OddsChangeDirection;
import 'package:sun_sports/shared/widgets/bet_details/bet_details_bottom_sheet.dart';
import 'package:sun_sports/shared/widgets/bet_details/models/betting_popup_data.dart';
import 'package:sun_sports/shared/widgets/flying_bet_animation.dart';
import 'package:sun_sports/shared/widgets/livestream/livestream_overlay_blocker.dart';
import 'package:sun_sports/shared/widgets/rive_vibrating/rive_vibrating.dart';
import 'package:sun_sports/shared/utils/auth_gate.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/features/bet_detail/presentation/providers/detail_swap_guard_provider.dart';

class BetCardMobile extends ConsumerStatefulWidget {
  final String? label;
  final String? value;
  final VoidCallback? onTap;
  final bool isSelected;

  final String? selectionId;

  final bool isUpRange;

  final bool isDownRange;

  final BettingPopupData? bettingPopupData;

  final bool isVertical;

  final bool isDesktop;

  final bool isSetHeightOdds;

  const BetCardMobile({
    super.key,
    this.label,
    this.value,
    this.onTap,
    this.isSelected = false,
    this.selectionId,
    this.isUpRange = false,
    this.isDownRange = false,
    this.bettingPopupData,
    this.isVertical = false,
    this.isDesktop = false,
    this.isSetHeightOdds = false,
  });

  static const defaultBgColor =
      AppColorStyles.backgroundTertiary;
  static const selectedBgColor = AppColors.yellow600;
  static const upRangeBgColor = Color(0x33669F2A);
  static const downRangeBgColor = Color(0x33F04438);

  static const lockedOpacity = 1.0;
  static const lockIconSize = 20.0;
  static const lockIconColor = Colors.white54;

  @override
  ConsumerState<BetCardMobile> createState() => _BetCardMobileState();
}

class _BetCardMobileState extends ConsumerState<BetCardMobile>
    with SingleTickerProviderStateMixin {
  final GlobalKey _cardKey = GlobalKey();

  late final AnimationController _animationController;

  late final Animation<double> _opacityAnimation;

  bool _prevShowUpRange = false;
  bool _prevShowDownRange = false;
  bool _prevIsLocked = false;

  late final VoidCallback _scrollListener;

  bool _isProcessingTap = false;

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

    _scrollListener = _onScrollStateChanged;
    ScrollAwareController.instance.addListener(_scrollListener);

    if (widget.isUpRange || widget.isDownRange) {
      _prevShowUpRange = widget.isUpRange;
      _prevShowDownRange = widget.isDownRange;
      if (!ScrollAwareController.instance.isScrolling) {
        _animationController.repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    ScrollAwareController.instance.removeListener(_scrollListener);
    _animationController.dispose();
    super.dispose();
  }

  void _onScrollStateChanged() {
    if (ScrollAwareController.instance.isScrolling) {
      if (_animationController.isAnimating) {
        _animationController.stop();
      }
    } else {
      if (_prevShowUpRange || _prevShowDownRange) {
        _animationController.repeat(reverse: true);
      }
    }
  }

  String? _getBetKey() {
    if (widget.bettingPopupData == null) return null;
    final eventId = widget.bettingPopupData!.eventData.eventId;
    final selId = widget.bettingPopupData!.getSelectionId();
    if (selId == null) return null;
    return '${eventId}_$selId';
  }

  void _updateAnimation(bool showUpRange, bool showDownRange, bool isLocked) {
    if (showUpRange == _prevShowUpRange &&
        showDownRange == _prevShowDownRange &&
        isLocked == _prevIsLocked) {
      return;
    }

    _prevShowUpRange = showUpRange;
    _prevShowDownRange = showDownRange;
    _prevIsLocked = isLocked;

    if (isLocked || ScrollAwareController.instance.isScrolling) {
      if (_animationController.isAnimating) {
        _animationController.stop();
        _animationController.reset();
      }
      return;
    }

    if (showUpRange || showDownRange) {
      if (!_animationController.isAnimating) {
        _animationController.repeat(reverse: true);
      }
    } else {
      if (_animationController.isAnimating) {
        _animationController.stop();
        _animationController.reset();
      }
    }
  }

  bool _isOddsLocked(WidgetRef ref) {
    if (widget.bettingPopupData == null) return false;

    final eventData = widget.bettingPopupData!.eventData;
    final eventId = eventData.eventId;
    final marketId = widget.bettingPopupData!.marketData.marketId;

    final isEventSuspended = ref.watch(isEventSuspendedProvider(eventId));
    if (isEventSuspended) return true;

    if (eventData.isSuspended) return true;

    if (ref.watch(detailSwapGuardProvider) != ListBettingGuard.open) {
      return true;
    }

    final isMarketSuspended = ref.watch(
      isMarketSuspendedProvider((eventId, marketId)),
    );
    if (isMarketSuspended) return true;

    if (widget.bettingPopupData!.oddsData.isSuspended) return true;

    return false;
  }

  @override
  Widget build(BuildContext context) {

    final isLocked = _isOddsLocked(ref);

    final betKey = _getBetKey();
    final isInSlip = betKey != null
        ? ref.watch(isBetInSlipProvider(betKey))
        : false;

    final direction = widget.selectionId != null
        ? ref.watch(oddsDirectionProvider(widget.selectionId!))
        : OddsChangeDirection.none;

    final wsOddsValue = widget.selectionId != null
        ? ref.watch(oddsValueProvider(widget.selectionId!))
        : null;
    final displayValue = wsOddsValue ?? widget.value;

    final isVibrating = widget.selectionId != null
        ? ref.watch(isVibratingProvider(widget.selectionId!))
        : false;

    final showUpRange =
        direction == OddsChangeDirection.up ||
        (direction == OddsChangeDirection.none && widget.isUpRange);
    final showDownRange =
        direction == OddsChangeDirection.down ||
        (direction == OddsChangeDirection.none && widget.isDownRange);

    _updateAnimation(showUpRange, showDownRange, isLocked);

    final bgColor = isInSlip
        ? BetCardMobile.selectedBgColor
        : showUpRange
        ? BetCardMobile.upRangeBgColor
        : showDownRange
        ? BetCardMobile.downRangeBgColor
        : BetCardMobile.defaultBgColor;

    final labelColor = isInSlip ? Colors.black : const Color(0xFFAAA49B);
    final isNegativeOdds = displayValue != null && displayValue.startsWith('-');
    final valueColor = isInSlip
        ? Colors.white
        : isNegativeOdds
        ? AppColors.orange400
        : AppColors.green300;

    return IgnorePointer(
      ignoring: isLocked,
      child: Opacity(
        opacity: isLocked ? BetCardMobile.lockedOpacity : 1.0,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: isLocked
                ? null
                : (widget.onTap != null
                      ? SoundTap.wrap(widget.onTap)
                      : () => _handleTap(context, betKey)),
            child: Stack(
              key: _cardKey,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  padding: widget.isVertical && widget.isDesktop == false
                      ? const EdgeInsets.symmetric(horizontal: 4, vertical: 4)
                      : const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: widget.isVertical && widget.isDesktop == false
                      ? _buildVerticalLayout(
                          labelColor,
                          valueColor,
                          displayValue,
                          isInSlip,
                        )
                      : _buildHorizontalLayout(
                          labelColor,
                          valueColor,
                          displayValue,
                          isInSlip,
                        ),
                ),
                if (isLocked)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColorStyles.backgroundTertiary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.lock,
                        size: BetCardMobile.lockIconSize,
                        color: BetCardMobile.lockIconColor,
                      ),
                    ),
                  ),
                if (isVibrating && !isInSlip && !isLocked)
                  const PositionedRiveVibratingOverlay(isVisible: true),
                if (showUpRange && !isInSlip && !isLocked)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: FadeTransition(
                      opacity: _opacityAnimation,
                      child: RepaintBoundary(
                        child: ImageHelper.load(
                          path: AppIcons.upRangeBet,
                          width: 8,
                          height: 8,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                if (showDownRange && !isInSlip && !isLocked)
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: FadeTransition(
                      opacity: _opacityAnimation,
                      child: RepaintBoundary(
                        child: ImageHelper.load(
                          path: AppIcons.downRangeBet,
                          width: 8,
                          height: 8,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleTap(BuildContext context, String? betKey) async {
    if (_isProcessingTap) {
      debugPrint('[BetCardMobile] tap ignored - previous tap still processing');
      return;
    }
    _isProcessingTap = true;
    try {
      await _handleTapInternal(context, betKey);
    } finally {
      _isProcessingTap = false;
    }
  }

  Future<void> _handleTapInternal(
    BuildContext context,
    String? betKey,
  ) async {
    if (widget.bettingPopupData != null) {
      debugPrint('[BetCardMobile] bettingPopupData available');
      debugPrint(
        '[BetCardMobile] offerId: ${widget.bettingPopupData!.getOfferId()}',
      );
      debugPrint(
        '[BetCardMobile] selectionId: ${widget.bettingPopupData!.getSelectionId()}',
      );

      if (!requireLogin(context, ref)) return;

      final isVibrating = widget.selectionId != null
          ? ref.read(isVibratingProvider(widget.selectionId!))
          : false;
      if (isVibrating) {
        SoundEffects.instance.playTap();
        BetDetailsBottomSheet.show(
          context,
          data: widget.bettingPopupData,
          isVibrating: true,
        );
        return;
      }

      final isInSlip = betKey != null
          ? ref.read(isBetInSlipProvider(betKey))
          : false;

      if (betKey != null && isInSlip) {
        final index = ref.read(betIndexInSlipProvider(betKey));
        if (index >= 0) {
          SoundEffects.instance.play(AppSound.removeFromBetslip);
          ref.read(parlayStateProvider.notifier).removeSingleBetAt(index);
        }
      } else {

        final parlayState = ref.read(parlayStateProvider);
        final singleBetsCount = parlayState.singleBets.length;
        final isBetSlipEmpty = singleBetsCount == 0;
        debugPrint(
          '[BetCardMobile] singleBets.length = $singleBetsCount, isBetSlipEmpty = $isBetSlipEmpty',
        );

        final result = await ref
            .read(parlayStateProvider.notifier)
            .addSingleBetFromPopupData(widget.bettingPopupData!);

        if (!result.success) {
          if (context.mounted) {
            AppToast.showError(
              context,
              message: result.errorMessage ?? 'Không thể thêm cược',
            );
          }
          return;
        }

        SoundEffects.instance.play(AppSound.addToBetslip);

        if (isBetSlipEmpty) {
          debugPrint(
            '[BetCardMobile] Bet slip was empty - showing bet detail popup',
          );
          if (context.mounted) {
            BetDetailsBottomSheet.show(context, data: widget.bettingPopupData);
          }
        } else {
          debugPrint(
            '[BetCardMobile] Bet slip has items - showing flying animation',
          );
          if (context.mounted) {
            _triggerFlyingAnimation(context);
          }
        }
      }
    } else {
      SoundEffects.instance.playTap();
      pushLivestreamOverlayBlock();
      showFadeBottomSheet<void>(
        context: context,
        useSafeArea: false,
        liftForKeyboard: true,
        builder: (ctx) => const FractionallySizedBox(
          heightFactor: 0.9,
          widthFactor: 1,
          child: ParlayMobileScreen(),
        ),
      ).whenComplete(popLivestreamOverlayBlock);
    }
  }

  void _triggerFlyingAnimation(BuildContext context) {
    final renderBox = _cardKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    FlyingBetController.instance.fly(
      context: context,
      sourcePosition: Offset(
        position.dx + size.width / 2,
        position.dy + size.height / 2,
      ),
      sourceSize: size,
      label: widget.label ?? '',
      value: widget.value ?? '',
    );
  }

  String _formatValue(String value) {
    if (value.endsWith('.00')) {
      return value.substring(0, value.length - 3);
    }
    return value;
  }

  Widget _buildVerticalLayout(
    Color labelColor,
    Color valueColor,
    String? displayValue,
    bool isInSlip,
  ) => SizedBox(
    height: double.infinity,
    child: FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.label != null && widget.label!.isNotEmpty)
            Text(
              widget.label!,
              textAlign: TextAlign.center,
              style: AppTextStyles.labelXSmall(color: labelColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          if (displayValue != null)
            Text(
              _formatValue(displayValue),
              textAlign: TextAlign.center,
              style: AppTextStyles.labelSmall(color: valueColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    ),
  );

  Widget _buildHorizontalLayout(
    Color labelColor,
    Color valueColor,
    String? displayValue,
    bool isInSlip,
  ) {
    return Container(
      height: widget.isSetHeightOdds ? double.infinity : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.label != null &&
                  widget.label!.isNotEmpty &&
                  displayValue != null)
                Flexible(
                  child: Text(
                    widget.label!,
                    textAlign: TextAlign.left,
                    style: AppTextStyles.textStyle(
                      fontSize: widget.isDesktop ? 12 : 11.5,
                      fontWeight: isInSlip ? FontWeight.w600 : FontWeight.w400,
                      color: labelColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              else
                const SizedBox.shrink(),
              if (displayValue != null)
                widget.isSelected && !isInSlip
                    ? ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Color(0xFFF4FFC0),
                            Color(0xFFB9CF55),
                          ],
                        ).createShader(bounds),
                        child: Text(
                          _formatValue(displayValue),
                          textAlign: TextAlign.right,
                          style: AppTextStyles.displayStyle(
                            fontSize: widget.isDesktop ? 14 : 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        _formatValue(displayValue),
                        textAlign: TextAlign.right,
                        style: AppTextStyles.displayStyle(
                          fontSize: widget.isDesktop ? 14 : 13,
                          fontWeight: isInSlip
                              ? FontWeight.w700
                              : FontWeight.w700,
                          color: valueColor,
                        ),
                      ),
            ],
          ),
        ],
      ),
    );
  }
}
