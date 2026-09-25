import 'package:adaptive_overlay/adaptive_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/providers/main_content_provider.dart';
import 'package:sun_sports/core/providers/live_chat_expanded_provider.dart';
import 'package:sun_sports/core/providers/scroll_controller_provider.dart';
import 'package:sun_sports/core/providers/scroll_hide_provider.dart';
import 'package:sun_sports/core/providers/slider_drawer_provider.dart';
import 'package:sun_sports/providers/app_init_provider.dart';
import 'package:sun_sports/core/services/maintenance/sb_maintenance_provider.dart';
import 'package:sun_sports/core/utils/keyboard_visibility.dart';
import 'package:sun_sports/core/utils/platform_utils.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/spacing_styles.dart';

import 'package:sun_sports/features/my_bet_hub/my_bet_hub.dart';
import 'package:sun_sports/features/profile/deposit/presentation/web_tablet/deposit_overlay.dart';
import 'package:sun_sports/features/profile/withdraw/presentation/web_tablet/withdraw_overlay.dart';
import 'dart:async';
import 'package:sun_sports/features/profile_hub/profile_hub.dart';
import 'package:sun_sports/features/game/cocos/widgets/cocos_download_listener.dart';
import 'package:sun_sports/features/game/game.dart';

import 'package:sun_sports/features/onboarding/onboarding.dart';
import 'package:sun_sports/shared/widgets/livestream/pip_manager.dart';
import 'package:sun_sports/shared/layouts/animated_shell_header.dart';
import 'package:sun_sports/shared/layouts/shell_bottom_navigation.dart';
import 'package:sun_sports/shared/layouts/shell_content_switcher.dart';
import 'package:sun_sports/shared/layouts/shell_desktop_header.dart';
import 'package:sun_sports/shared/layouts/shell_desktop_right_sidebar.dart';
import 'package:sun_sports/shared/layouts/shell_desktop_sidebar.dart';
import 'package:sun_sports/shared/layouts/shell_rive_loading.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';
import 'package:sun_sports/shared/responsive/responsive_layout.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/listeners/kick_event_listener.dart';
import 'package:sun_sports/shared/widgets/livestream/livestream_overlay_blocker.dart';
import 'package:sun_sports/shared/widgets/snackbars/bet_success_snackbar.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';

class MainShellLayout extends ConsumerWidget {
  const MainShellLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(profileHubControllerProvider);
    final navigatorKey = ref.watch(profileNavigatorKeyProvider);
    final routeRegistry = ref.watch(profileRouteRegistryProvider);

    return SpotlightHost(
      keepBelow: () => AppToast.activeEntry,
      child: _MainShellOverlayManager(
        child: MyBetHub(
          child: ProfileHub(
            controller: controller,
            navigatorKey: navigatorKey,
            initialRoute: ProfileHub.root,
            onGenerateRoute: (settings) =>
                ProfileHub.generateRoute(settings, routeRegistry),
            child: const _ProfileLivestreamBlocker(
              child: KickEventListener(
                child: GameLastJoinListener(
                  child: CocosDownloadListener(
                    child: ResponsiveLayout(
                      mobile: _MobileLayout(),
                      tablet: _MobileLayout(),
                      desktop: _DesktopLayout(),
                    ),
                  ),
                ),
              ),

            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileLivestreamBlocker extends ConsumerStatefulWidget {
  const _ProfileLivestreamBlocker({required this.child});

  final Widget child;

  @override
  ConsumerState<_ProfileLivestreamBlocker> createState() =>
      _ProfileLivestreamBlockerState();
}

class _ProfileLivestreamBlockerState
    extends ConsumerState<_ProfileLivestreamBlocker> {
  AdaptiveOverlayController? _controller;
  bool _blocked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = ref.read(profileHubControllerProvider);
    if (controller != _controller) {
      _controller?.removeListener(_sync);
      _controller = controller..addListener(_sync);
    }
    _sync();
  }

  void _sync() {
    if (!mounted) return;
    final shouldBlock =
        (_controller?.isVisible ?? false) &&
        ResponsiveBuilder.isMobile(context);
    if (shouldBlock && !_blocked) {
      _blocked = true;
      pushLivestreamOverlayBlock();
    } else if (!shouldBlock && _blocked) {
      _blocked = false;
      popLivestreamOverlayBlock();
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_sync);
    if (_blocked) popLivestreamOverlayBlock();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _DesktopLayout extends ConsumerWidget {
  const _DesktopLayout();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInitializing = ref.watch(isAppInitializingProvider);

    if (isInitializing) {
      return const ShellRiveLoading();
    }

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.black,
          appBar: const ShellDesktopHeader(),
          body: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF11100F),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: const Row(
                  children: [
                    ShellDesktopSidebar(),
                    Gap(AppSpacingStyles.space300),
                    Expanded(child: ShellContentSwitcher()),
                    Gap(AppSpacingStyles.space300),
                    ShellDesktopRightSidebar(),
                  ],
                ),
              ),
            ],
          ),
        ),
        const DepositOverlay(),
        const WithdrawOverlay(),
      ],
    );
  }
}

class _MobileLayout extends ConsumerStatefulWidget {
  const _MobileLayout();

  @override
  ConsumerState<_MobileLayout> createState() => _MobileLayoutState();
}

class _MobileLayoutState extends ConsumerState<_MobileLayout> {
  final ValueNotifier<double> _drawerProgress = ValueNotifier<double>(0.0);
  AnimationController? _drawerAnim;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _hookDrawerAnim());
  }

  void _hookDrawerAnim() {
    if (!mounted) return;
    final state = ref.read(sliderDrawerKeyProvider).currentState;
    if (state == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _hookDrawerAnim());
      return;
    }
    _drawerAnim = state.animationController..addListener(_onDrawerAnim);
    _onDrawerAnim();
  }

  void _onDrawerAnim() {
    _drawerProgress.value = _drawerAnim?.value ?? 0.0;
  }

  @override
  void dispose() {
    _drawerAnim?.removeListener(_onDrawerAnim);
    _drawerProgress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isInitializing = ref.watch(isAppInitializingProvider);

    if (isInitializing) {
      return const ShellRiveLoading();
    }

    final scrollHide = ref.read(scrollHideProvider);

    ref.listen(mainContentProvider, (prev, next) {
      scrollHide.show();
      scrollHide.pauseDetection(const Duration(milliseconds: 500));
    });

    ref.listen<bool>(liveChatExpandedProvider, (prev, next) {
      if (prev == true || !next) return;
      if (!migratedHeaderContentTypes.contains(ref.read(mainContentProvider))) {
        return;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && scrollHide.hide()) {
          ref.read(bottomNavVisibilityProvider.notifier).collapse();
        }
      });
    });

    final sliderKey = ref.watch(sliderDrawerKeyProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    return Form(
      canPop: false,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.paddingOf(context).top,
            child: const ColoredBox(color: Colors.black),
          ),
          _buildSafeArea(sliderKey, screenWidth, scrollHide),
        ],
      ),
    );
  }

  Widget _buildSafeArea(
    GlobalKey<SliderDrawerState> sliderKey,
    double screenWidth,
    ScrollHideNotifier scrollHide,
  ) {
    return SafeArea(
        bottom: PlatformUtils.isAndroid,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black, AppColorStyles.backgroundSecondary],
              stops: [0.01, 0.05],
            ),
          ),
          child: SliderDrawer(
            key: sliderKey,
            appBar: const SizedBox.shrink(),
            slider: const MenuDrawerContent(),
            sliderOpenSize: screenWidth * 0.8,
            animationDuration: 300,
            slideDirection: SlideDirection.leftToRight,
            sliderBoxShadow: SliderBoxShadow(color: Colors.black12),
            backgroundColor: Colors.transparent,
            isDraggable: !PlatformUtils.isWeb,
            child: Stack(
              children: [
                Scaffold(
                  backgroundColor: Colors.transparent,
                  resizeToAvoidBottomInset: false,
                  body: NotificationListener<ScrollMetricsNotification>(
                    onNotification: (notification) {
                      scrollHide.handleScrollMetricsNotification(notification);
                      return false;
                    },
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        scrollHide.handleScrollNotification(notification);
                        ref
                            .read(bottomNavVisibilityProvider.notifier)
                            .handleScrollNotification(notification);
                        return false;
                      },
                      child: Stack(
                        children: [
                          const Positioned.fill(
                            child: _ShellContentWithHeaderSpacer(),
                          ),
                          const Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: AnimatedShellHeader(),
                          ),
                          const Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: HideOnKeyboard(
                                child: ShellBottomNavigation(isMobile: true),
                              ),
                            ),
                          ),
                          Builder(
                            builder: (context) {
                              final visibility = ref.watch(
                                bottomNavVisibilityProvider,
                              );
                              final isCollapsed =
                                  visibility == BottomNavVisibility.collapsed;
                              final bottomOffset = isCollapsed ? 60.0 : 80.0;

                              return AnimatedPositioned(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                left: 0,
                                right: 0,
                                bottom: bottomOffset,
                                child: const BetSuccessSnackBar(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: ValueListenableBuilder<double>(
                    valueListenable: _drawerProgress,
                    builder: (context, progress, _) {
                      final isActive = progress > 0.001;
                      return IgnorePointer(
                        ignoring: !isActive,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: SoundTap.wrap(
                            () => sliderKey.currentState?.closeSlider(),
                          ),
                          child: const ColoredBox(color: Colors.transparent),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }
}

class _ShellContentWithHeaderSpacer extends ConsumerWidget {
  const _ShellContentWithHeaderSpacer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentType = ref.watch(mainContentProvider);
    final hasShellHeader = migratedHeaderContentTypes.contains(contentType);

    if (!hasShellHeader) {
      return const ShellContentSwitcher(isMobile: true);
    }

    return const RepaintBoundary(
      child: ShellContentSwitcher(isMobile: true),
    );
  }
}

class _MainShellOverlayManager extends ConsumerWidget {
  const _MainShellOverlayManager({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(spotlightShowAfterRegisterProvider)) {
      final isMobile = ResponsiveBuilder.isMobile(context);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!ref.read(spotlightShowAfterRegisterProvider)) return;
        ref.read(spotlightShowAfterRegisterProvider.notifier).state = false;
        Future<void>.delayed(const Duration(milliseconds: 700), () {
          ref
              .read(spotlightControllerProvider.notifier)
              .start(isMobile ? sun88QuickGuideTourMobile : sun88QuickGuideTour);
        });
      });
    }

    ref.listen<bool>(sbMaintenanceProvider, (previous, next) {
      if (next) ref.read(myBetHubControllerProvider).close();
    });

    ref.listen<bool>(
      myBetOverlayVisibleProvider,
      (previous, next) {
        if (next) {
          ref.read(profileHubControllerProvider).close();
        }
      },
    );

    ref.listen<bool>(
      profileHubVisibleProvider,
      (previous, next) {
        if (next) {
          ref.read(myBetHubControllerProvider).close();
        }
      },
    );

    ref.listen<GameLauncherState>(
      gameLauncherProvider,
      (previous, next) {
        if (next.status == GameLauncherStatus.active) {
          ref.read(profileHubControllerProvider).close();
          ref.read(myBetHubControllerProvider).close();

          final pipManager = PipManager();
          if (pipManager.hasContent || pipManager.isPiPMode) {
            unawaited(pipManager.dispose());
          }
        }
      },
    );

    return child;
  }
}
