import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/providers/main_content_provider.dart';
import 'package:sun_sports/core/providers/scroll_controller_provider.dart';
import 'package:sun_sports/core/providers/scroll_hide_provider.dart';
import 'package:sun_sports/core/providers/slider_drawer_provider.dart';
import 'package:sun_sports/core/services/config/sb_config.dart';
import 'package:sun_sports/providers/auth_provider.dart';
import 'package:sun_sports/core/utils/extensions/enums/bottom_navigation_item.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/features/betting/betting.dart';
import 'package:sun_sports/features/download_app/footer_download_fade.dart';
import 'package:sun_sports/features/mini_game/presentation/mini_game_floating_overlay.dart'
    show miniGameMenuOpenProvider, toggleMiniGameLobbyFromNav;
import 'package:sun_sports/features/preferences/preferences.dart';
import 'package:sun_sports/features/sport/presentation/tablet/widgets/sport_tablet_bottom_navigation.dart';
import 'package:sun_sports/shared/layouts/shell_bottom_block.dart';
import 'package:sun_sports/shared/layouts/shell_desktop_sidebar.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';
import 'package:sun_sports/shared/utils/auth_gate.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/collapsed_betting_ticket.dart';
import 'package:sun_sports/shared/widgets/flying_bet_animation.dart';
import 'package:sun_sports/shared/widgets/maintenance/sb_maintenance_view.dart';
import 'package:url_launcher/url_launcher.dart';

class ShellBottomNavigation extends ConsumerStatefulWidget {
  final bool isMobile;

  const ShellBottomNavigation({super.key, this.isMobile = false});

  static int selectedIndexFor(MainContentType contentType) {
    switch (contentType) {
      case MainContentType.home:
        return 0;
      case MainContentType.sport:
      case MainContentType.sportDetail:
      case MainContentType.betDetail:
        return 1;
      case MainContentType.tournaments:
        return 0;
      case MainContentType.sun247:
        return 3;
      case MainContentType.casino:
        return -1;
      default:
        return 0;
    }
  }

  @override
  ConsumerState<ShellBottomNavigation> createState() =>
      _ShellBottomNavigationState();
}

class _ShellBottomNavigationState extends ConsumerState<ShellBottomNavigation>
    with SingleTickerProviderStateMixin {
  final GlobalKey _navBoxKey = GlobalKey();
  bool _navMeasureScheduled = false;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleNavMeasure();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _scheduleNavMeasure() {
    if (_navMeasureScheduled) return;
    _navMeasureScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navMeasureScheduled = false;
      if (!mounted) return;
      if (ref.read(scrollHideProvider).progress.value != 0.0) return;
      final renderObject = _navBoxKey.currentContext?.findRenderObject();
      if (renderObject is! RenderBox ||
          !renderObject.attached ||
          !renderObject.hasSize) {
        return;
      }
      final height = renderObject.size.height;
      if (height <= 0) return;
      final topY = renderObject.localToGlobal(Offset.zero).dy;
      ShellBottomMetrics.publish(
        height: height,
        topFromCanvasBottom: MediaQuery.sizeOf(context).height - topY,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isMobile) {
      return _buildMobile(context);
    }
    return _buildTablet(context);
  }

  Widget _buildMobile(BuildContext context) {
    final scrollHide = ref.watch(scrollHideProvider);
    ref.listen<bool>(
      myBetHubControllerProvider.select((c) => c.isVisible),
      (prev, next) {
        if (next) ref.read(scrollHideProvider).show();
      },
    );
    final currentContent = ref.watch(mainContentProvider);
    final selectedIndex = _getSelectedIndex(currentContent);
    final showDownloadApp =
        kIsWeb &&
        ResponsiveBuilder.isMobile(context) &&
        !ref.watch(isAuthenticatedProvider);

    return RepaintBoundary(
      child: ValueListenableBuilder<double>(
        valueListenable: scrollHide.progress,
        builder: (context, progress, child) {
          FlyingBetController.instance.collapsedTicketActive =
              progress >= ScrollHideNotifier.snapThreshold;

          if (progress == 0.0) _scheduleNavMeasure();

          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              if (progress < 1.0)
                Transform.translate(
                  offset: Offset(0, progress * 80),
                  child: Opacity(
                    opacity: (1.0 - progress).clamp(0.0, 1.0),
                    child: child,
                  ),
                ),
              if (progress > 0.0)
                Transform.translate(
                  offset: Offset(0, (1.0 - progress) * 28),
                  child: Opacity(
                    opacity: progress.clamp(0.0, 1.0),
                    child: IgnorePointer(
                      ignoring: progress < ScrollHideNotifier.snapThreshold,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: showDownloadApp
                            ? const _FadingDownloadAppButton()
                            : CollapsedBettingTicket(
                                onTap: () {
                                  if (!requireLogin(context, ref)) return;
                                  ref.read(scrollHideProvider).show();
                                  _showParlayBottomSheet(context);
                                },
                              ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
        child: RepaintBoundary(
          key: _navBoxKey,
          child: SportTabletBottomNavigation(
            selectedIndex: selectedIndex,
            isMobile: true,
            onItemSelected: (index) =>
                _handleItemSelected(context, ref, index),
          ),
        ),
      ),
    );
  }

  Widget _buildTablet(BuildContext context) {
    final currentContent = ref.watch(mainContentProvider);
    final visibility = ref.watch(bottomNavVisibilityProvider);
    final selectedIndex = _getSelectedIndex(currentContent);
    final showDownloadApp =
        kIsWeb &&
        ResponsiveBuilder.isMobile(context) &&
        !ref.watch(isAuthenticatedProvider);

    if (visibility == BottomNavVisibility.collapsed) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final isCollapsed = _animationController.value > 0.5;
        FlyingBetController.instance.collapsedTicketActive = isCollapsed;

        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            if (!isCollapsed)
              Opacity(
                opacity: _opacityAnimation.value,
                child: Transform.scale(
                  scaleX: _scaleAnimation.value,
                  alignment: Alignment.center,
                  child: SportTabletBottomNavigation(
                    selectedIndex: selectedIndex,
                    onItemSelected: (index) {
                      _handleItemSelected(context, ref, index);
                    },
                  ),
                ),
              ),
            if (isCollapsed)
              Opacity(
                opacity: 1.0 - _opacityAnimation.value,
                child: Transform.scale(
                  scale: 1.0 - _scaleAnimation.value,
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: showDownloadApp
                        ? const _FadingDownloadAppButton()
                        : CollapsedBettingTicket(
                            onTap: () {
                              if (!requireLogin(context, ref)) return;
                              ref
                                  .read(bottomNavVisibilityProvider.notifier)
                                  .expand();
                              _showParlayBottomSheet(context);
                            },
                          ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  int _getSelectedIndex(MainContentType contentType) {
    if (ref.watch(miniGameMenuOpenProvider)) {
      return BottomNavigationItem.all.indexOf(BottomNavigationItem.miniGames);
    }
    if (ref.watch(myBetHubControllerProvider.select((c) => c.isVisible))) {
      return BottomNavigationItem.all.indexOf(
        BottomNavigationItem.bettingTickets,
      );
    }
    return ShellBottomNavigation.selectedIndexFor(contentType);
  }

  void _handleItemSelected(BuildContext context, WidgetRef ref, int index) {
    final item = BottomNavigationItem.all[index];
    final notifier = ref.read(mainContentProvider.notifier);

    final myBetHub = ref.read(myBetHubControllerProvider);
    if (myBetHub.isVisible) {
      if (item == BottomNavigationItem.bettingTickets) {
        myBetHub.close();
        return;
      }
      if (item != BottomNavigationItem.sun247) myBetHub.close();
    }

    if (widget.isMobile) {
      ref.read(scrollHideProvider).show();
      ref.read(scrollHideProvider).pauseDetection();
    } else {
      ref.read(bottomNavVisibilityProvider.notifier).pauseDetection();
    }

    switch (item) {
      case BottomNavigationItem.home:
        notifier.goToHome();
        break;
      case BottomNavigationItem.casino:
        notifier.goToCasino();
        break;
      case BottomNavigationItem.sports:
        notifier.goToSport();
        break;
      case BottomNavigationItem.bettingTickets:
        _showParlayBottomSheet(context);
        break;
      case BottomNavigationItem.sun247:
        if (widget.isMobile) {
          launchUrl(
            Uri.parse(SbConfig.livechatUrl),
            mode: LaunchMode.externalApplication,
          );
        } else {
          notifier.goToSun247();
        }
        break;
      case BottomNavigationItem.miniGames:
        _toggleMiniGameLobby(context);
        break;
      case BottomNavigationItem.menu:
        _showMenuDrawer(context);
        break;
    }
  }

  void _toggleMiniGameLobby(BuildContext context) {
    if (!ref.read(miniGameMenuOpenProvider) && !requireLogin(context, ref)) {
      return;
    }
    toggleMiniGameLobbyFromNav(ref);
  }

  void _showParlayBottomSheet(BuildContext context) {
    if (blockedBySbMaintenance(context, ref)) return;
    ref
        .read(myBetHubControllerProvider)
        .open(initialMenu: MyBetMenu.bettingSlip);
  }

  void _showMenuDrawer(BuildContext context) {
    ref.read(sliderDrawerKeyProvider).currentState?.toggle();
  }
}

class MenuDrawerContent extends ConsumerWidget {
  const MenuDrawerContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<MainContentType>(mainContentProvider, (prev, next) {
      if (prev != next) {
        ref.read(sliderDrawerKeyProvider).currentState?.closeSlider();
      }
    });

    return Material(
      color: AppColorStyles.backgroundSecondary,
      child: SafeArea(
        child: Column(
          children: [
            const _DrawerHeader(),
            Expanded(
              child: ShellDesktopSidebar(
                isDesktop: false,
                    onItemTap: () {
                      ref
                          .read(sliderDrawerKeyProvider)
                          .currentState
                          ?.closeSlider();
                    },
                    onMyBetsTapForMobile: () {
                      ref
                          .read(sliderDrawerKeyProvider)
                          .currentState
                          ?.closeSlider();
                      ref
                          .read(myBetHubControllerProvider)
                          .open(initialMenu: MyBetMenu.myBets);
                    },
                    onTopTournamentsTapForMobile: () {
                      ref
                          .read(sliderDrawerKeyProvider)
                          .currentState
                          ?.closeSlider();
                      ref.read(previousContentProvider.notifier).state = ref
                          .read(mainContentProvider);
                      ref.read(mainContentProvider.notifier).goToTournaments();
                    },
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class _DrawerHeader extends ConsumerStatefulWidget {
  const _DrawerHeader();

  @override
  ConsumerState<_DrawerHeader> createState() => _DrawerHeaderState();
}

class _DrawerHeaderState extends ConsumerState<_DrawerHeader> {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _attach());
  }

  void _attach() {
    if (!mounted) return;
    final controller = ref
        .read(sliderDrawerKeyProvider)
        .currentState
        ?.animationController;
    if (controller == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _attach());
      return;
    }
    setState(() => _controller = controller);
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) {
      return const SizedBox.shrink();
    }
    return ValueListenableBuilder<double>(
      valueListenable: controller,
      builder: (context, value, _) {
        if (value < 0.01) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Row(
            children: [
              GestureDetector(
                onTap: SoundTap.wrap(() {
                  ref.read(mainContentProvider.notifier).goToHome();
                }),
                child: SizedBox(
                  child: ImageHelper.load(
                    path: AppImages.logoUrl,
                    width: 60,
                    height: 56,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: OddsStyleDropdown(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FadingDownloadAppButton extends StatelessWidget {
  const _FadingDownloadAppButton();

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<double>(
    valueListenable: FooterDownloadFade.instance.opacity,
    builder: (context, fade, child) => IgnorePointer(
      ignoring: fade < FooterDownloadFade.hitTestThreshold,
      child: Opacity(opacity: fade, child: child),
    ),
    child: const DownloadAppButton(),
  );
}
