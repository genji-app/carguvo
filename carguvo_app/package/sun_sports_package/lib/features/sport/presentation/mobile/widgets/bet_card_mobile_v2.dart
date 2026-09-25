import 'package:adaptive_overlay/adaptive_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/bet_detail/presentation/providers/detail_swap_guard_provider.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/sound_effects.dart';
import 'package:sun_sports/core/utils/styles/app_audios.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/providers/parlay_state_provider.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/screens/parlay_mobile_screen.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/sport/presentation/providers/bet_cell_state_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/odds_change_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/league_provider.dart';
import 'package:sun_sports/core/services/models/api_v2/odds_style_model_v2.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/shared/domain/enums/betting_enums.dart'
    hide OddsChangeDirection;
import 'package:sun_sports/shared/widgets/bet_details/bet_details_bottom_sheet_v2.dart';
import 'package:sun_sports/shared/widgets/bet_details/models/betting_popup_data_v2.dart';
import 'package:sun_sports/shared/widgets/flying_bet_animation.dart';
import 'package:sun_sports/shared/widgets/livestream/livestream_overlay_blocker.dart';
import 'package:sun_sports/shared/widgets/rive_vibrating/rive_vibrating.dart';
import 'package:sun_sports/shared/widgets/snackbars/providers/bet_success_snackbar_provider.dart';
import 'package:sun_sports/shared/utils/auth_gate.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/scroll_blocked_tap.dart';

class BetCardMobileV2 extends ConsumerStatefulWidget {
  final String? label;
  final String? value;
  final VoidCallback? onTap;
  final bool isSelected;

  final String? selectionId;

  final bool isUpRange;

  final bool isDownRange;

  final BettingPopupDataV2? bettingPopupData;

  final bool isVertical;

  final bool isDesktop;

  final bool isSetHeightOdds;

  final bool isCompact;

  final bool? eventLevelLocked;

  const BetCardMobileV2({
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
    this.isCompact = false,
    this.eventLevelLocked,
  });

  static const defaultBgColor = AppColorStyles.backgroundTertiary;
  static const selectedBgColor = AppColors.yellow600;
  static const upRangeBgColor = Color(0x33669F2A);
  static const downRangeBgColor = Color(0x33F04438);
  static const lockedOpacity = 1.0;
  static const lockIconSize = 20.0;
  static const lockIconColor = Colors.white54;

  @override
  ConsumerState<BetCardMobileV2> createState() => _BetCardMobileV2State();
}

class _BetCardMobileV2State extends ConsumerState<BetCardMobileV2> {
  final GlobalKey _cardKey = GlobalKey();

  bool _isProcessingTap = false;

  String? _getBetKey() {
    if (widget.bettingPopupData == null) return null;
    final eventId = widget.bettingPopupData!.eventData.eventId;
    final selId = widget.bettingPopupData!.getSelectionId();
    if (selId == null) return null;
    return '${eventId}_$selId';
  }

  BetCellKey _cellKey(String? betKey) {
    final popupData = widget.bettingPopupData;
    return BetCellKey(
      selectionId: widget.selectionId,
      betKey: betKey,
      eventId: popupData?.eventData.eventId,
      marketId: popupData?.marketData.marketId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final betKey = _getBetKey();
    final cellKey = _cellKey(betKey);

    return _buildLockedConsumer(
      cellKey: cellKey,
      builder: (context, isLocked) {
        return IgnorePointer(
          ignoring: isLocked,
          child: _buildCardContent(context, cellKey, isLocked),
        );
      },
    );
  }

  Widget _buildLockedConsumer({
    required BetCellKey cellKey,
    required Widget Function(BuildContext context, bool isLocked) builder,
  }) {
    if (widget.bettingPopupData == null) {
      return builder(context, false);
    }

    final eventData = widget.bettingPopupData!.eventData;

    final eventLocked = widget.eventLevelLocked;
    if (eventLocked != null) {
      if (eventLocked) return builder(context, true);
      return Consumer(
        builder: (context, ref, child) {
          final isMarketSuspended = ref.watch(
            betCellStateProvider(cellKey).select((s) => s.isMarketSuspended),
          );
          return builder(context, isMarketSuspended);
        },
      );
    }

    if (eventData.isSuspended) {
      return builder(context, true);
    }

    return Consumer(
      builder: (context, ref, child) {
        final swapGuard = ref.watch(detailSwapGuardProvider);
        if (swapGuard != ListBettingGuard.open) return builder(context, true);

        final isSuspended = ref.watch(
          betCellStateProvider(cellKey).select(
            (s) => s.isEventSuspended || s.isMarketSuspended,
          ),
        );
        return builder(context, isSuspended);
      },
    );
  }

  Widget _buildCardContent(
    BuildContext context,
    BetCellKey cellKey,
    bool isLocked,
  ) {
    final betKey = cellKey.betKey;
    return Consumer(
      builder: (context, ref, _) {
        final isInSlip = betKey != null
            ? ref.watch(betCellStateProvider(cellKey).select((s) => s.isInSlip))
            : false;

        return ScrollBlockedTap(
          showClickCursor: true,
          behavior: HitTestBehavior.deferToChild,
          onTap: isLocked
              ? null
              : (widget.onTap != null
                    ? SoundTap.wrap(widget.onTap)
                    : () => _handleTap(context, isInSlip, cellKey)),
          child: Stack(
              key: _cardKey,
              children: [
                _buildMainCard(cellKey, isInSlip, isLocked),
                if (isLocked) _buildLockOverlay(),
                if (!isInSlip && !isLocked) _buildVibratingConsumer(cellKey),
              ],
          ),
        );
      },
    );
  }

  Widget _buildMainCard(BetCellKey cellKey, bool isInSlip, bool isLocked) {
    return Consumer(
      builder: (context, ref, _) {
        final (wsOddsValue, direction) = widget.selectionId == null
            ? (null, OddsChangeDirection.none)
            : ref.watch(
                betCellStateProvider(cellKey).select(
                  (s) => (s.oddsValue, s.direction),
                ),
              );

        String? displayValue;
        if (wsOddsValue != null) {
          displayValue = wsOddsValue;
        } else if (widget.bettingPopupData != null) {
          final oddsStyle = ref.watch(oddsStyleProvider);
          displayValue =
              _getOddsValueByStyle(widget.bettingPopupData!, oddsStyle);
        }
        displayValue ??= widget.value;

        final showUpRange =
            direction == OddsChangeDirection.up ||
            (direction == OddsChangeDirection.none && widget.isUpRange);
        final showDownRange =
            direction == OddsChangeDirection.down ||
            (direction == OddsChangeDirection.none && widget.isDownRange);

        final bgColor = isInSlip
            ? BetCardMobileV2.selectedBgColor
            : showUpRange
            ? BetCardMobileV2.upRangeBgColor
            : showDownRange
            ? BetCardMobileV2.downRangeBgColor
            : BetCardMobileV2.defaultBgColor;

        final labelColor = isInSlip ? Colors.black : const Color(0xFFAAA49B);
        final isNegativeOdds =
            displayValue != null && displayValue.startsWith('-');
        final valueColor = isInSlip
            ? Colors.white
            : isNegativeOdds
            ? AppColors.orange400
            : AppColors.green300;

        final card = Container(
          width: double.infinity,
          padding: widget.isVertical && widget.isDesktop == false
              ? (widget.isCompact
                    ? const EdgeInsets.symmetric(horizontal: 4)
                    : const EdgeInsets.symmetric(horizontal: 4, vertical: 4))
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
        );

        final showIndicators =
            !isInSlip && !isLocked && (showUpRange || showDownRange);
        if (!showIndicators) return card;

        return Stack(
          children: [
            card,
            if (showUpRange)
              Positioned(
                top: 4,
                right: 4,
                child: ImageHelper.load(
                  path: AppIcons.upRangeBet,
                  width: 8,
                  height: 8,
                  fit: BoxFit.fill,
                ),
              ),
            if (showDownRange)
              Positioned(
                bottom: 4,
                right: 4,
                child: ImageHelper.load(
                  path: AppIcons.downRangeBet,
                  width: 8,
                  height: 8,
                  fit: BoxFit.fill,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildLockOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: AppColorStyles.backgroundTertiary,
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.lock,
          size: BetCardMobileV2.lockIconSize,
          color: BetCardMobileV2.lockIconColor,
        ),
      ),
    );
  }

  Widget _buildVibratingConsumer(BetCellKey cellKey) {
    if (widget.selectionId == null) return const SizedBox.shrink();

    return Consumer(
      builder: (context, ref, _) {
        final isVibrating = ref.watch(
          betCellStateProvider(cellKey).select((s) => s.isVibrating),
        );
        return PositionedRiveVibratingOverlay(isVisible: isVibrating);
      },
    );
  }

  Future<void> _handleTap(
    BuildContext context,
    bool isInSlip,
    BetCellKey cellKey,
  ) async {
    final betKey = cellKey.betKey;
    if (_isProcessingTap) return;

    if (widget.bettingPopupData != null) {
      if (!requireLogin(context, ref)) return;

      final isVibrating = widget.selectionId != null
          ? ref.read(betCellStateProvider(cellKey)).isVibrating
          : false;

      if (isVibrating) {
        SoundEffects.instance.playTap();
        if (context.mounted) {
          final oddsFormat = ref.read(oddsStyleProvider).toOddsFormatV2();
          BetDetailsBottomSheetV2.show(
            context,
            data: widget.bettingPopupData!.copyWith(oddsFormat: oddsFormat),
            isVibrating: true,
          );
        }
        return;
      }

      final currentlyInSlip = betKey != null
          ? ref.read(betCellStateProvider(cellKey)).isInSlip
          : isInSlip;

      if (currentlyInSlip && betKey != null) {
        final index = ref.read(betIndexInSlipProvider(betKey));
        if (index >= 0) {
          SoundEffects.instance.play(AppSound.removeFromBetslip);
          ref.read(parlayStateProvider.notifier).removeSingleBetAt(index);
        }
      } else {
        _isProcessingTap = true;
        try {
          final isBetSlipEmpty = ref.read(parlayStateProvider).singleBets.isEmpty;

          final result = await ref
              .read(parlayStateProvider.notifier)
              .addSingleBetFromPopupDataV2(widget.bettingPopupData!);

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

          if (!context.mounted) return;

          if (isBetSlipEmpty) {
            final oddsFormat = ref.read(oddsStyleProvider).toOddsFormatV2();
            BetDetailsBottomSheetV2.show(
              context,
              data: widget.bettingPopupData!.copyWith(oddsFormat: oddsFormat),
            );
          } else {
            _triggerFlyingAnimation(context);

            final updatedParlayState = ref.read(parlayStateProvider);
            if (updatedParlayState.singleBets.isNotEmpty) {
              final addedBet = updatedParlayState.singleBets.last;
              ref.read(betSuccessSnackBarProvider.notifier).show(addedBet);
            }
          }
        } finally {
          _isProcessingTap = false;
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

  String? _getOddsValueByStyle(BettingPopupDataV2 data, OddsStyle style) {
    final format = switch (style) {
      OddsStyle.malay => OddsFormatV2.malay,
      OddsStyle.indo => OddsFormatV2.indo,
      OddsStyle.decimal => OddsFormatV2.decimal,
      OddsStyle.hongKong => OddsFormatV2.hk,
    };

    final oddsData = data.oddsData;
    double value;
    switch (data.oddsType) {
      case OddsType.home:
        value = oddsData.getHomeOdds(format);
      case OddsType.away:
        value = oddsData.getAwayOdds(format);
      case OddsType.draw:
        value = oddsData.getDrawOdds(format) ?? 0.0;
      default:
        value = 0.0;
    }

    if (value == 0) return null;
    return value.toStringAsFixed(2);
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
              style: widget.isCompact
                  ? AppTextStyles.labelXXSmall(color: labelColor)
                  : AppTextStyles.labelXSmall(color: labelColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          if (displayValue != null)
            Text(
              _formatValue(displayValue),
              textAlign: TextAlign.center,
              style: widget.isCompact
                  ? AppTextStyles.labelXSmall(color: valueColor)
                  : AppTextStyles.labelSmall(color: valueColor),
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
      alignment: Alignment.center,
      child: Row(
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
                      colors: [Color(0xFFF4FFC0), Color(0xFFB9CF55)],
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
                      fontWeight: isInSlip ? FontWeight.w700 : FontWeight.w700,
                      color: valueColor,
                    ),
                  ),
        ],
      ),
    );
  }
}
