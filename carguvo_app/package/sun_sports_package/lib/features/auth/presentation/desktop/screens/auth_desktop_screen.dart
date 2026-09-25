import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sun_sports/core/providers/pending_toast_provider.dart';
import 'package:sun_sports/router/auth_navigation.dart';
import 'package:sun_sports/providers/auth_provider.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/features/auth/presentation/providers/auth_providers.dart';
import 'package:sun_sports/features/auth/presentation/desktop/widgets/auth_desktop_login_form.dart';
import 'package:sun_sports/features/auth/presentation/desktop/widgets/auth_desktop_register_form.dart';
import 'package:sun_sports/router/router_location.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/livestream/livestream_overlay_blocker.dart';

class AuthDesktopScreen extends ConsumerStatefulWidget {
  const AuthDesktopScreen({super.key, this.showLogin = true});

  final bool showLogin;

  @override
  ConsumerState<AuthDesktopScreen> createState() => _AuthDesktopScreenState();
}

class _AuthDesktopScreenState extends ConsumerState<AuthDesktopScreen> {
  late bool _showLogin;

  ModalRoute<dynamic>? _route;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _route = ModalRoute.of(context);
    authScreenRoute = _route;
  }

  Timer? _exitRetryTimer;

  static const _exitRetryInterval = Duration(milliseconds: 500);

  void _scheduleAuthedExit() {
    if (_exitRetryTimer != null) return;
    SchedulerBinding.instance.addPostFrameCallback((_) => _tryAuthedExit());
    _exitRetryTimer = Timer.periodic(
      _exitRetryInterval,
      (_) => _tryAuthedExit(),
    );
  }

  void _cancelAuthedExit() {
    _exitRetryTimer?.cancel();
    _exitRetryTimer = null;
  }

  void _tryAuthedExit() {
    if (!mounted || !ref.read(isAuthenticatedProvider)) {
      _cancelAuthedExit();
      return;
    }
    final goRouter = GoRouter.maybeOf(context);
    final location = currentRouterLocation(goRouter);
    try {
      if (location != null && !location.startsWith('/auth')) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        context.go('/');
      }
    } catch (_) {
    }
  }

  @override
  void initState() {
    super.initState();
    _showLogin = widget.showLogin;
    markAuthScreenMounted();
    pushLivestreamOverlayBlock();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _showPendingToast();
    });
  }

  @override
  void dispose() {
    markAuthScreenUnmounted();
    if (identical(authScreenRoute, _route)) authScreenRoute = null;
    authOpenIntentional = false;
    popLivestreamOverlayBlock();
    _cancelAuthedExit();
    super.dispose();
  }

  void _showPendingToast() {
    final pendingToast = ref.read(pendingToastProvider);
    if (pendingToast != null) {
      ref.read(pendingToastProvider.notifier).state = null;

      if (mounted) {
        if (pendingToast.isError) {
          AppToast.showError(
            context,
            message: pendingToast.message,
            title: pendingToast.title,
            duration: pendingToast.duration ?? const Duration(seconds: 5),
          );
        } else {
          AppToast.showSuccess(
            context,
            message: pendingToast.message,
            title: pendingToast.title,
            duration: pendingToast.duration ?? const Duration(seconds: 5),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    if (isAuthenticated) {
      _scheduleAuthedExit();
      return const Scaffold(
        backgroundColor: AppColorStyles.backgroundPrimary,
      );
    }
    _cancelAuthedExit();

    final isSubmitting = _showLogin
        ? ref.watch(
            loginFormNotifierProvider.select((s) => s.isSubmitting),
          )
        : ref.watch(
            registerFormNotifierProvider.select((s) => s.isSubmitting),
          );

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: SoundTap.wrap(() {
            FocusScope.of(context).unfocus();
          }),
          child: Scaffold(
            backgroundColor: AppColorStyles.backgroundPrimary,
            body: Stack(
              clipBehavior: Clip.none,
              children: [
                if (constraints.maxHeight >= 828)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: ImageHelper.load(
                      path: AppImages.headerShadow,
                      fit: BoxFit.fill,
                    ),
                  ),

                Positioned.fill(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Container(
                        height: constraints.maxHeight,
                        padding: MediaQuery.viewPaddingOf(context),
                        margin: const EdgeInsets.only(bottom: 100),
                        constraints: const BoxConstraints(
                          maxHeight: 828,
                          minHeight: 664,
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: _showLogin
                                    ? AuthDesktopLoginForm(
                                        key: const ValueKey('login'),
                                        onSwitchToRegister: () {
                                          ref
                                              .read(
                                                loginFormNotifierProvider
                                                    .notifier,
                                              )
                                              .reset();
                                          setState(() {
                                            _showLogin = false;
                                          });
                                        },
                                      )
                                    : AuthDesktopRegisterForm(
                                        key: const ValueKey('register'),
                                        onSwitchToLogin: () {
                                          ref
                                              .read(
                                                registerFormNotifierProvider
                                                    .notifier,
                                              )
                                              .reset();
                                          setState(() {
                                            _showLogin = true;
                                          });
                                        },
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: MediaQuery.viewPaddingOf(context).top + 12,
                  left: 16,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: SoundTap.wrap(() => context.go('/')),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0x1AFFFFFF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 18,
                          color: AppColorStyles.contentPrimary,
                        ),
                      ),
                    ),
                  ),
                ),

                if (isSubmitting)
                  const Positioned.fill(
                    child: AbsorbPointer(
                      child: SizedBox.expand(),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
