import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/sport/presentation/providers/market_status_provider.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/platform_utils.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/providers/parlay_state_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/odds_change_provider.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/shared/domain/enums/betting_enums.dart'
    hide OddsChangeDirection;
import 'package:sun_sports/shared/widgets/bet_details/bet_details_bottom_sheet.dart';
import 'package:sun_sports/shared/widgets/bet_details/models/betting_popup_data.dart';
import 'package:sun_sports/shared/utils/auth_gate.dart';
import 'package:sun_sports/shared/widgets/flying_bet_animation.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/features/bet_detail/presentation/providers/detail_swap_guard_provider.dart';

class BetCard extends StatelessWidget {
  final String? label;
  final String? value;
  final VoidCallback? onTap;
  final bool isSelected;

  final String? selectionId;

  final bool isUpRange;

  final bool isDownRange;

  final BettingPopupData? bettingPopupData;

  const BetCard({
    super.key,
    this.label,
    this.value,
    this.onTap,
    this.isSelected = false,
    this.selectionId,
    this.isUpRange = false,
    this.isDownRange = false,
    this.bettingPopupData,
  });

  static const _defaultBgColor = Color(0x66000000);
  static const _selectedBgColor = AppColors.yellow600;
  static const _upRangeBgColor = Color(0x33669F2A);
  static const _downRangeBgColor = Color(0x33F04438);
  static const _hoverBgColor = Color.fromRGBO(54, 48, 38, 1);
  static const _labelColor = Color(0xFF9C9B95);
  static const _selectedLabelColor = Colors.black;
  static const _valueColor = Color(0xFFFDE272);
  static const _selectedValueColor = Colors.white;
  static const _padding = EdgeInsets.symmetric(horizontal: 8, vertical: 11.5);
  static const _borderRadius = BorderRadius.all(Radius.circular(8));

  static const _lockedOpacity = 0.5;
  static const _lockIconSize = 12.0;
  static const _lockIconColor = Colors.white54;

  String? _getBetKey() {
    if (bettingPopupData == null) return null;
    final eventId = bettingPopupData!.eventData.eventId;
    final selId = bettingPopupData!.getSelectionId();
    if (selId == null) return null;
    return '${eventId}_$selId';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final betCardData = _getBetCardData(ref);

        if (PlatformUtils.isMobile) {
          return _buildCard(_defaultBgColor, context, ref, betCardData);
        }

        return _HoverableCard(
          defaultColor: betCardData.isInSlip
              ? _selectedBgColor
              : betCardData.showUpRange
              ? _upRangeBgColor
              : betCardData.showDownRange
              ? _downRangeBgColor
              : _defaultBgColor,
          hoverColor: betCardData.isInSlip ? _selectedBgColor : _hoverBgColor,
          isUpRange: betCardData.showUpRange && !betCardData.isInSlip,
          isDownRange: betCardData.showDownRange && !betCardData.isInSlip,
          isInSlip: betCardData.isInSlip,
          isLocked: betCardData.isLocked,
          label: label ?? '',
          value: betCardData.effectiveValue ?? '',
          bettingPopupData: bettingPopupData,
          onTapWithAnimation: (triggerAnimation) {
            if (betCardData.isLocked) return;
            if (!requireLogin(context, ref)) return;
            if (onTap != null) {
              onTap!();
            } else {
              _handleTapWithAnimation(
                context,
                ref,
                betCardData.isInSlip,
                betCardData.betKey,
                triggerAnimation,
              );
            }
          },
          child: _buildCardContent(
            context,
            betCardData.effectiveValue,
            betCardData.isInSlip,
          ),
        );
      },
    );
  }

  _BetCardData _getBetCardData(WidgetRef ref) {
    final betKey = _getBetKey();

    final isLocked = _isOddsLocked(ref);

    final direction = selectionId != null
        ? ref.watch(oddsDirectionProvider(selectionId!))
        : OddsChangeDirection.none;

    final liveValue = selectionId != null
        ? ref.watch(oddsValueProvider(selectionId!))
        : null;

    final effectiveValue = liveValue ?? value;

    final showUpRange =
        direction == OddsChangeDirection.up ||
        (direction == OddsChangeDirection.none && isUpRange);
    final showDownRange =
        direction == OddsChangeDirection.down ||
        (direction == OddsChangeDirection.none && isDownRange);

    final isInSlip = betKey != null
        ? ref.watch(isBetInSlipProvider(betKey))
        : false;

    return _BetCardData(
      betKey: betKey,
      isLocked: isLocked,
      effectiveValue: effectiveValue,
      showUpRange: showUpRange,
      showDownRange: showDownRange,
      isInSlip: isInSlip,
    );
  }

  bool _isOddsLocked(WidgetRef ref) {
    if (bettingPopupData == null) return false;

    final eventData = bettingPopupData!.eventData;
    final eventId = eventData.eventId;
    final marketId = bettingPopupData!.marketData.marketId;

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

    if (bettingPopupData!.oddsData.isSuspended) return true;

    return false;
  }

  Future<void> _handleTapWithAnimation(
    BuildContext context,
    WidgetRef ref,
    bool isInSlip,
    String? betKey,
    void Function() triggerAnimation,
  ) async {
    if (bettingPopupData != null) {
      if (isInSlip && betKey != null) {
        debugPrint('[BetCard] Removing bet from slip');
        final index = ref.read(betIndexInSlipProvider(betKey));
        if (index >= 0) {
          ref.read(parlayStateProvider.notifier).removeSingleBetAt(index);
        }
      } else {
        debugPrint('[BetCard] Adding bet to slip');

        final singleBets = ref.read(singleBetsProvider);
        final isBetSlipEmpty = singleBets.isEmpty;

        final result = await ref
            .read(parlayStateProvider.notifier)
            .addSingleBetFromPopupData(bettingPopupData!);

        if (!result.success) {
          if (context.mounted) {
            AppToast.showError(
              context,
              message: result.errorMessage ?? 'Không thể thêm cược',
            );
          }
          return;
        }

        if (isBetSlipEmpty) {
          debugPrint('[BetCard] Bet slip was empty - showing bet detail popup');
          if (context.mounted) {
            BetDetailsBottomSheet.show(context, data: bettingPopupData);
          }
        } else {
          debugPrint('[BetCard] Bet slip has items - showing flying animation');
          triggerAnimation();
        }
      }
    } else {
      BetDetailsBottomSheet.show(context, data: bettingPopupData);
    }
  }

  Widget _buildCard(
    Color bgColor,
    BuildContext context,
    WidgetRef ref,
    _BetCardData data,
  ) {
    final effectiveBgColor = data.isInSlip
        ? _selectedBgColor
        : data.showUpRange
        ? _upRangeBgColor
        : data.showDownRange
        ? _downRangeBgColor
        : bgColor;

    return IgnorePointer(
      ignoring: data.isLocked,
      child: Opacity(
        opacity: data.isLocked ? _lockedOpacity : 1.0,
        child: GestureDetector(
          onTap: SoundTap.wrap(data.isLocked
              ? null
              : (onTap ??
                    () => BetDetailsBottomSheet.show(
                      context,
                      data: bettingPopupData,
                    ))),
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: _padding,
                decoration: BoxDecoration(
                  color: effectiveBgColor,
                  borderRadius: _borderRadius,
                ),
                child: _buildCardContent(
                  context,
                  data.effectiveValue,
                  data.isInSlip,
                ),
              ),
              if (data.isLocked)
                const Positioned(
                  top: 4,
                  right: 4,
                  child: Icon(
                    Icons.lock,
                    size: _lockIconSize,
                    color: _lockIconColor,
                  ),
                ),
              if (data.showUpRange && !data.isInSlip && !data.isLocked)
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
              if (data.showDownRange && !data.isInSlip && !data.isLocked)
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
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent(
    BuildContext context,
    String? displayValue,
    bool isInSlip,
  ) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      if (label != null)
        Expanded(
          child: Text(
            label!,
            style: AppTextStyles.displayStyle(
              fontSize: 11,
              fontWeight: isInSlip ? FontWeight.w600 : FontWeight.w500,
              color: isInSlip ? _selectedLabelColor : _labelColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        )
      else
        const SizedBox.shrink(),
      if (displayValue != null)
        Text(
          displayValue,
          style: AppTextStyles.displayStyle(
            fontSize: 13,
            fontWeight: isInSlip ? FontWeight.w600 : FontWeight.w500,
            color: isInSlip ? _selectedValueColor : _valueColor,
          ),
          textAlign: TextAlign.right,
        ),
    ],
  );
}

class _BetCardData {
  final String? betKey;
  final bool isLocked;
  final String? effectiveValue;
  final bool showUpRange;
  final bool showDownRange;
  final bool isInSlip;

  const _BetCardData({
    required this.betKey,
    required this.isLocked,
    required this.effectiveValue,
    required this.showUpRange,
    required this.showDownRange,
    required this.isInSlip,
  });
}

class _HoverableCard extends StatefulWidget {
  final Color defaultColor;
  final Color hoverColor;
  final Widget child;
  final bool isUpRange;
  final bool isDownRange;
  final bool isInSlip;
  final bool isLocked;
  final String label;
  final String value;
  final BettingPopupData? bettingPopupData;

  final void Function(void Function() triggerAnimation) onTapWithAnimation;

  const _HoverableCard({
    required this.defaultColor,
    required this.hoverColor,
    required this.onTapWithAnimation,
    required this.label,
    required this.value,
    required this.child,
    this.isUpRange = false,
    this.isDownRange = false,
    this.isInSlip = false,
    this.isLocked = false,
    this.bettingPopupData,
  });

  @override
  State<_HoverableCard> createState() => _HoverableCardState();
}

class _HoverableCardState extends State<_HoverableCard> {
  bool _isHovered = false;
  final GlobalKey _cardKey = GlobalKey();

  static const _padding = EdgeInsets.symmetric(horizontal: 8, vertical: 11.5);
  static const _borderRadius = BorderRadius.all(Radius.circular(8));

  void _triggerFlyingAnimation() {
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
      label: widget.label,
      value: widget.value,
    );
  }

  void _handleTap() {
    widget.onTapWithAnimation(_triggerFlyingAnimation);
  }

  static const _lockedOpacity = 0.5;
  static const _lockIconSize = 12.0;
  static const _lockIconColor = Colors.white54;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    ignoring: widget.isLocked,
    child: Opacity(
      opacity: widget.isLocked ? _lockedOpacity : 1.0,
      child: MouseRegion(
        onEnter: widget.isLocked
            ? null
            : (_) => setState(() => _isHovered = true),
        onExit: widget.isLocked
            ? null
            : (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: SoundTap.wrap(widget.isLocked ? null : _handleTap),
          child: Stack(
            key: _cardKey,
            children: [
              Container(
                padding: _padding,
                decoration: BoxDecoration(
                  color: _isHovered && !widget.isLocked
                      ? widget.hoverColor
                      : widget.defaultColor,
                  borderRadius: _borderRadius,
                ),
                child: widget.child,
              ),
              if (widget.isLocked)
                const Positioned(
                  top: 4,
                  right: 4,
                  child: Icon(
                    Icons.lock,
                    size: _lockIconSize,
                    color: _lockIconColor,
                  ),
                ),
              if (widget.isUpRange && !widget.isLocked)
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
              if (widget.isDownRange && !widget.isLocked)
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
          ),
        ),
      ),
    ),
  );
}
