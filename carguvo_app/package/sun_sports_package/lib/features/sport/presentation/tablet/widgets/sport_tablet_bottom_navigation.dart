import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/utils/extensions/enums/bottom_navigation_item.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/features/my_bet_hub/my_bet_hub_providers.dart';
import 'package:sun_sports/features/mini_game/presentation/mini_game_floating_overlay.dart'
    show miniGameMenuOpenProvider;
import 'package:sun_sports/features/mini_game/presentation/widgets/mini_game_nav_badge.dart';
import 'package:sun_sports/core/utils/platform_utils.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/onboarding/onboarding.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/providers/parlay_state_provider.dart';
import 'package:sun_sports/shared/utils/auth_gate.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/flying_bet_animation.dart';

class SportTabletBottomNavigation extends ConsumerStatefulWidget {
  final int selectedIndex;
  final bool isMobile;
  final ValueChanged<int>? onItemSelected;

  final bool isOverlayCopy;

  const SportTabletBottomNavigation({
    super.key,
    this.selectedIndex =
        3,
    this.onItemSelected,
    this.isMobile = false,
    this.isOverlayCopy = false,
  });

  @override
  ConsumerState<SportTabletBottomNavigation> createState() =>
      _SportTabletBottomNavigationState();
}

class _SportTabletBottomNavigationState
    extends ConsumerState<SportTabletBottomNavigation>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _positionAnimation;
  int _currentIndex = 3;
  double _lastContainerWidth = 0.0;
  static const double _containerWidth = 477.0;
  static const double _horizontalPadding = 8.0;
  static const int _itemCount = 5;

  double _getContainerWidth(BuildContext context) {
    if (widget.isMobile) {
      final screenWidth = MediaQuery.of(context).size.width;
      return screenWidth;
    }
    return _containerWidth;
  }

  double _getContentWidth(BuildContext context) {
    return _getContainerWidth(context) - (_horizontalPadding * 2);
  }

  double _getItemWidth(BuildContext context) {
    return _getContentWidth(context) / _itemCount;
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex;
    _animationController = AnimationController(
      vsync: this,
      duration: widget.isMobile
          ? const Duration(milliseconds: 250)
          : const Duration(milliseconds: 300),
    );
    _positionAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: widget.isMobile ? Curves.fastOutSlowIn : Curves.easeInOut,
      ),
    );
  }

  @override
  void didUpdateWidget(SportTabletBottomNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.selectedIndex != oldWidget.selectedIndex &&
        widget.selectedIndex != _currentIndex) {
      setState(() {
        _currentIndex = widget.selectedIndex;
      });
    }

    if (widget.isMobile != oldWidget.isMobile) {
      _animationController.duration = widget.isMobile
          ? const Duration(milliseconds: 250)
          : const Duration(milliseconds: 300);
    }
  }

  void _updateAnimation(int fromIndex, int toIndex, BuildContext context) {
    if (!mounted) return;
    final startPosition = _getItemPosition(fromIndex, context);
    final targetPosition = _getItemPosition(toIndex, context);
    _positionAnimation =
        Tween<double>(begin: startPosition, end: targetPosition).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
  }

  void _handleItemTap(int index, BuildContext context) {
    final tappedItem = BottomNavigationItem.all[index];
    if (tappedItem == BottomNavigationItem.bettingTickets &&
        ref.read(myBetHubControllerProvider).isVisible) {
      widget.onItemSelected?.call(index);
      return;
    }
    if (tappedItem == BottomNavigationItem.miniGames &&
        ref.read(miniGameMenuOpenProvider)) {
      widget.onItemSelected?.call(index);
      return;
    }
    if (tappedItem == BottomNavigationItem.bettingTickets ||
        tappedItem == BottomNavigationItem.miniGames) {
      if (!requireLogin(context, ref)) return;
    }
    if (tappedItem == BottomNavigationItem.bettingTickets ||
        tappedItem == BottomNavigationItem.menu ||
        tappedItem == BottomNavigationItem.miniGames ||
        (widget.isMobile && tappedItem == BottomNavigationItem.sun247)) {
      widget.onItemSelected?.call(index);
      return;
    }

    if (index != _currentIndex) {
      final previousIndex = _currentIndex;
      setState(() {
        _currentIndex = index;
        _updateAnimation(previousIndex, index, context);
        _animationController.reset();
        _animationController.forward();
      });
      widget.onItemSelected?.call(index);
    } else if (widget.isOverlayCopy) {
      widget.onItemSelected?.call(index);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  double _getItemPosition(int index, BuildContext context) {
    return _horizontalPadding + (index * _getItemWidth(context));
  }

  List<_NavItemData> _buildNavItems(int betTicketCount) =>
      BottomNavigationItem.all.map((item) {
        String? badge;
        if (item == BottomNavigationItem.bettingTickets && betTicketCount > 0) {
          badge = betTicketCount > 99 ? '99+' : betTicketCount.toString();
        }
        return _NavItemData(
          icon: item.iconPath,
          iconSelected: item.iconSelectedPath,
          label: item.label,
          badge: badge,
          badgeWidget: item == BottomNavigationItem.miniGames
              ? const MiniGameNavBadge()
              : null,
          iconSize: item == BottomNavigationItem.miniGames ? 32 : 24,
        );
      }).toList();

  @override
  Widget build(BuildContext context) {
    final singleBetsCount = ref.watch(singleBetsCountProvider);
    final comboBetsCount = ref.watch(comboBetsCountProvider);
    final minMatches = ref.watch(minMatchesProvider);
    final hasValidCombo = comboBetsCount >= minMatches;
    final totalBetCount = singleBetsCount + (hasValidCombo ? 1 : 0);
    final navItems = _buildNavItems(totalBetCount);

    final containerWidth = _getContainerWidth(context);
    final itemWidth = _getItemWidth(context);
    final currentPosition = _getItemPosition(_currentIndex, context);
    final hasSelection = _currentIndex >= 0;

    if (_lastContainerWidth != 0.0 && _lastContainerWidth != containerWidth) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _positionAnimation = Tween<double>(
              begin: currentPosition,
              end: currentPosition,
            ).animate(_animationController);
            _animationController.value = 1.0;
          });
        }
      });
    }
    _lastContainerWidth = containerWidth;

    return Container(
      margin: !widget.isMobile ? const EdgeInsets.only(bottom: 16) : null,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      width: containerWidth,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.77327],
          colors: [Color(0xFF1A1A17), Color(0xFF000000)],
        ),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(widget.isMobile ? 0 : 16),
          bottomRight: Radius.circular(widget.isMobile ? 0 : 16),
        ),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -0.65),
            blurRadius: 0.5,
            spreadRadius: 0.05,
            blurStyle: BlurStyle.inner,
            color: Colors.white.withOpacity(0.12),
          ),
        ],
      ),
      child: RepaintBoundary(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (hasSelection)
              AnimatedBuilder(
                animation: _positionAnimation,
                child: RepaintBoundary(
                  child: ImageHelper.load(
                    path: AppIcons.bottomNavSelected,
                    fit: BoxFit.contain,
                  ),
                ),
                builder: (context, cachedSvg) {
                  final position = _animationController.isAnimating
                      ? _positionAnimation.value
                      : currentPosition;
                  return Positioned(
                    left: position - 5,
                    width: itemWidth,
                    top: (PlatformUtils.isMobile) ? 0 : 0,
                    bottom: 0,
                    child: cachedSvg!,
                  );
                },
              ),
            if (hasSelection)
              AnimatedBuilder(
                animation: _positionAnimation,
                child: RepaintBoundary(
                  child: ImageHelper.load(
                    path: AppIcons.bottomNavGlow,
                    fit: BoxFit.fill,
                  ),
                ),
                builder: (context, cachedGlow) {
                  final position = _animationController.isAnimating
                      ? _positionAnimation.value
                      : currentPosition;
                  return Positioned(
                    left: position - 50,
                    width: itemWidth + (_currentIndex != 4 ? 100 : 50),
                    top: PlatformUtils.isMobile ? -1.5 : 0,
                    bottom: 0,
                    child: cachedGlow!,
                  );
                },
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: navItems.asMap().entries.map((entry) {
                final index = entry.key;
                final _NavItemData item = entry.value;
                final isBetSlipIcon =
                    BottomNavigationItem.all[index] ==
                    BottomNavigationItem.bettingTickets;
                final isSelected = _currentIndex == index;
                final navItem = _BottomNavItem(
                  key: ValueKey('nav_${index}_$isSelected'),
                  icon: item.icon,
                  iconSelected: item.iconSelected,
                  label: item.label,
                  isSelected: isSelected,
                  badge: item.badge,
                  badgeWidget: item.badgeWidget,
                  iconSize: item.iconSize,
                  onTap: () => _handleItemTap(index, context),
                  spotlightId: isBetSlipIcon && !widget.isOverlayCopy
                      ? SpotlightTargetId.betSlipButton
                      : null,
                );
                if (isBetSlipIcon && !widget.isOverlayCopy) {
                  return KeyedSubtree(
                    key: FlyingBetController.instance.betSlipIconKey,
                    child: navItem,
                  );
                }
                return navItem;
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItemData {
  final String icon;
  final String iconSelected;
  final String label;
  final String? badge;
  final Widget? badgeWidget;
  final double iconSize;

  const _NavItemData({
    required this.icon,
    required this.iconSelected,
    required this.label,
    this.badge,
    this.badgeWidget,
    this.iconSize = 24,
  });
}

class _BottomNavItem extends StatelessWidget {
  final String icon;
  final String iconSelected;
  final String label;
  final bool isSelected;
  final String? badge;

  final Widget? badgeWidget;

  final double iconSize;
  final VoidCallback onTap;
  final SpotlightTargetId? spotlightId;

  const _BottomNavItem({
    required this.icon,
    required this.iconSelected,
    required this.label,
    required this.onTap,
    super.key,
    this.isSelected = false,
    this.badge,
    this.badgeWidget,
    this.iconSize = 24,
    this.spotlightId,
  });

  Widget _maybeAnchor({required Widget child}) {
    final id = spotlightId;
    if (id == null) return child;
    return SpotlightAnchor(id: id, child: child);
  }

  @override
  Widget build(BuildContext context) {
    final textColor = isSelected
        ? const Color(0xFFFFD791)
        : const Color(0xFFAAA49B);
    final iconPath = isSelected ? iconSelected : icon;

    return Expanded(
      child: GestureDetector(
        onTap: SoundTap.wrap(onTap),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: _maybeAnchor(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Center(
                        child: OverflowBox(
                          maxWidth: iconSize,
                          maxHeight: iconSize,
                          child: ImageHelper.load(
                            path: iconPath,
                            width: iconSize,
                            height: iconSize,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    if (badgeWidget != null)
                      Positioned(right: -19.6, top: -10.7, child: badgeWidget!),
                    if (badge != null)
                      Positioned(
                        right: -12,
                        top: -6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.green200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 14,
                          ),
                          child: Text(
                            badge!,
                            style: AppTextStyles.labelXXSmall(
                              color: AppColors.gray950,
                            ).copyWith(fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                const Gap(8),
                Text(
                  label,
                  style: AppTextStyles.labelXSmall(color: textColor),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
