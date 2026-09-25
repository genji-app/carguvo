import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/sound_effects.dart';
import 'package:sun_sports/core/utils/styles/app_audios.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/cards/inner_shadow_card.dart';

enum AppToastType { error, success, generic }

class AppToast extends StatefulWidget {
  static OverlayEntry? _activeToastEntry;
  static Completer<void>? _activeToastCompleter;

  static OverlayEntry? get activeEntry => _activeToastEntry;

  static void _dismissActiveToast() {
    final entry = _activeToastEntry;
    final pending = _activeToastCompleter;
    _activeToastEntry = null;
    _activeToastCompleter = null;
    if (entry != null) {
      try {
        if (entry.mounted) {
          entry.remove();
        }
      } catch (_) {
      }
    }
    if (pending != null && !pending.isCompleted) {
      pending.complete();
    }
  }

  final AppToastType type;
  final String message;
  final String? title;
  final Duration? duration;

  const AppToast({
    required this.type,
    required this.message,
    super.key,
    this.title,
    this.duration,
  });

  static Future<void> showError(
    BuildContext context, {
    required String message,
    String? title,
    Duration? duration,
  }) {
    return show(
      context,
      type: AppToastType.error,
      message: '$message!',
      title: title,
      duration: duration,
    );
  }

  static Future<void> showSuccess(
    BuildContext context, {
    required String message,
    String? title,
    Duration? duration,
    bool playSound = true,
  }) {
    return show(
      context,
      type: AppToastType.success,
      message: '$message!',
      title: title,
      duration: duration,
      playSound: playSound,
    );
  }

  static Future<void> showGeneric(
    BuildContext context, {
    required String message,
    String? title,
    Duration? duration,
  }) {
    return show(
      context,
      type: AppToastType.generic,
      message: message,
      title: title,
      duration: duration,
    );
  }

  static Future<void> show(
    BuildContext context, {
    required AppToastType type,
    required String message,
    String? title,
    Duration? duration,
    bool playSound = true,
  }) {
    _dismissActiveToast();

    if (playSound) {
      SoundEffects.instance.play(switch (type) {
        AppToastType.error => AppSound.pushNotificationFailed,
        AppToastType.success ||
        AppToastType.generic => AppSound.pushNotificationSucceed,
      });
    }

    final overlayState = Overlay.of(context, rootOverlay: true);
    final completer = Completer<void>();

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) {
        return _AppToastOverlay(
          type: type,
          message: message,
          title: title,
          duration: duration,
          onDismiss: () {
            if (identical(_activeToastEntry, overlayEntry)) {
              _activeToastEntry = null;
              _activeToastCompleter = null;
            }
            if (overlayEntry.mounted) {
              overlayEntry.remove();
            }
            if (!completer.isCompleted) {
              completer.complete();
            }
          },
        );
      },
    );

    _activeToastEntry = overlayEntry;
    _activeToastCompleter = completer;
    overlayState.insert(overlayEntry);

    return completer.future;
  }

  @override
  State<AppToast> createState() => _AppToastState();
}

class _AppToastState extends State<AppToast>
    with SingleTickerProviderStateMixin {
  Timer? _autoDismissTimer;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    final duration = widget.duration ?? const Duration(seconds: 3);

    _progressController = AnimationController(duration: duration, vsync: this);
    _progressAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.linear),
    );

    _progressController.forward();
    _startAutoDismiss();
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    if (_progressController.isAnimating) {
      _progressController.stop();
    }
    _progressController.dispose();
    super.dispose();
  }

  void _startAutoDismiss() {
    final duration = widget.duration ?? const Duration(seconds: 3);
    _autoDismissTimer = Timer(duration, () {
      if (mounted && _progressController.isAnimating) {
        _progressController.stop();
      }
      if (mounted && Navigator.of(context, rootNavigator: false).canPop()) {
        Navigator.of(context, rootNavigator: false).pop();
      }
    });
  }

  void _handleClose() {
    _autoDismissTimer?.cancel();
    if (mounted && _progressController.isAnimating) {
      _progressController.stop();
    }
    if (mounted && Navigator.of(context, rootNavigator: false).canPop()) {
      Navigator.of(context, rootNavigator: false).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        final isMobile = deviceType == DeviceType.mobile;
        return isMobile ? _buildMobile(context) : _buildWebTablet(context);
      },
    );
  }

  Widget _buildMobile(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final safeTop = statusBarHeight + 16;

    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Dialog(
        backgroundColor: Colors.transparent,
        alignment: Alignment.topCenter,
        insetPadding: EdgeInsets.only(top: safeTop, left: 16, right: 16),
        child: _buildAlertContent(context, isMobile: true),
      ),
    );
  }

  Widget _buildWebTablet(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final safeTop = statusBarHeight + 24;

    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Dialog(
        backgroundColor: Colors.transparent,
        alignment: Alignment.topCenter,
        insetPadding: EdgeInsets.only(top: safeTop, left: 24, right: 24),
        child: _buildAlertContent(context, isMobile: false),
      ),
    );
  }

  Widget _buildAlertContent(BuildContext context, {required bool isMobile}) {
    final maxWidth = isMobile ? double.infinity : 640.0;
    final backgroundColor = switch (widget.type) {
      AppToastType.success => AppColors.green900,
      AppToastType.generic => AppColorStyles.backgroundQuaternary,
      AppToastType.error => AppColors.red900,
    };
    final borderColor = switch (widget.type) {
      AppToastType.success => AppColors.green700,
      AppToastType.generic => AppColorStyles.borderPrimary,
      AppToastType.error => AppColors.red700,
    };
    final iconData = switch (widget.type) {
      AppToastType.success => Icons.check_circle,
      AppToastType.generic => Icons.error,
      AppToastType.error => Icons.error,
    };

    return Material(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: InnerShadowCard(
          child: Stack(
            children: [
              Container(
                width: maxWidth,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  border: Border.all(color: borderColor, width: 1),
                  borderRadius: BorderRadius.circular(16),
                ),
                constraints: const BoxConstraints(maxWidth: 640),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: switch (widget.type) {
                            AppToastType.success => AppColors.green600,
                            AppToastType.generic => AppColors.blue500,
                            AppToastType.error => AppColors.red600,
                          },
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(iconData, size: 24, color: Colors.white),
                      ),
                      const Gap(16),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.title != null) ...[
                              Text(
                                widget.title!,
                                style: AppTextStyles.labelMedium(
                                  color: AppColors.gray25,
                                ),
                              ),
                              const Gap(4),
                            ],
                            Text(
                              widget.message,
                              style: AppTextStyles.paragraphMedium(
                                color: switch (widget.type) {
                                  AppToastType.generic =>
                                    AppColorStyles.contentTertiary,
                                  _ => AppColors.gray25,
                                },
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const Gap(12),
                      InkWell(
                        onTap: SoundTap.wrap(_handleClose),
                        borderRadius: BorderRadius.circular(8),
                        child: const SizedBox(
                          width: 32,
                          height: 32,
                          child: Center(
                            child: Icon(
                              Icons.close,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return SizedBox(
                      height: 4,
                      child: Stack(
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(16),
                              ),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: _progressAnimation.value,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ],
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

class _AppToastOverlay extends StatefulWidget {
  final AppToastType type;
  final String message;
  final String? title;
  final Duration? duration;
  final VoidCallback onDismiss;

  const _AppToastOverlay({
    required this.type,
    required this.message,
    required this.onDismiss,
    this.title,
    this.duration,
  });

  @override
  State<_AppToastOverlay> createState() => _ToastOverlayState();
}

class _ToastOverlayState extends State<_AppToastOverlay>
    with TickerProviderStateMixin {
  Timer? _autoDismissTimer;
  late AnimationController _slideController;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    final duration = widget.duration ?? const Duration(seconds: 3);

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _progressController = AnimationController(duration: duration, vsync: this);
    _progressAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.linear),
    );

    _slideController.forward();
    _progressController.forward();
    _startAutoDismiss();
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    if (_progressController.isAnimating) {
      _progressController.stop();
    }
    if (_slideController.isAnimating) {
      _slideController.stop();
    }
    _progressController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _startAutoDismiss() {
    final duration = widget.duration ?? const Duration(seconds: 3);
    _autoDismissTimer = Timer(duration, () {
      if (mounted && _progressController.isAnimating) {
        _progressController.stop();
      }
      widget.onDismiss();
    });
  }

  void _handleClose() {
    _autoDismissTimer?.cancel();
    if (mounted && _progressController.isAnimating) {
      _progressController.stop();
    }
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        final isMobile = deviceType == DeviceType.mobile;
        final statusBarHeight = MediaQuery.of(context).padding.top;
        final safeTop = isMobile ? statusBarHeight + 16 : statusBarHeight + 24;
        final horizontalPadding = isMobile ? 16.0 : 24.0;

        return Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: EdgeInsets.only(
                top: safeTop,
                left: horizontalPadding,
                right: horizontalPadding,
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: _buildToastContent(context, isMobile),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildToastContent(BuildContext context, bool isMobile) {
    final maxWidth = isMobile ? double.infinity : 640.0;
    final backgroundColor = switch (widget.type) {
      AppToastType.success => AppColors.green900,
      AppToastType.generic => AppColorStyles.backgroundQuaternary,
      AppToastType.error => AppColors.red900,
    };
    final borderColor = switch (widget.type) {
      AppToastType.success => AppColors.green700,
      AppToastType.generic => AppColorStyles.borderPrimary,
      AppToastType.error => AppColors.red700,
    };
    final iconData = switch (widget.type) {
      AppToastType.success => AppIcons.iconToastSuccess,
      AppToastType.generic => AppIcons.iconToastError,
      AppToastType.error => AppIcons.iconToastError,
    };

    return Material(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: InnerShadowCard(
          child: Stack(
            children: [
              Container(
                width: maxWidth,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  border: Border.all(color: borderColor, width: 1),
                  borderRadius: BorderRadius.circular(16),
                ),
                constraints: const BoxConstraints(maxWidth: 640),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: switch (widget.type) {
                            AppToastType.success => AppColors.green600,
                            AppToastType.generic => AppColors.blue500,
                            AppToastType.error => AppColors.red600,
                          },
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ImageHelper.load(path: iconData, width: 24, height: 24, color: Colors.white),
                      ),
                      const Gap(16),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.title != null) ...[
                              Text(
                                widget.title!,
                                style: AppTextStyles.labelMedium(
                                  color: AppColors.gray25,
                                ),
                              ),
                              const Gap(4),
                            ],
                            Text(
                              widget.message,
                              style: AppTextStyles.paragraphMedium(
                                color: switch (widget.type) {
                                  AppToastType.generic =>
                                    AppColorStyles.contentTertiary,
                                  _ => AppColors.gray25,
                                },
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const Gap(12),
                      InkWell(
                        onTap: SoundTap.wrap(_handleClose),
                        borderRadius: BorderRadius.circular(8),
                        child: const SizedBox(
                          width: 32,
                          height: 32,
                          child: Center(
                            child: Icon(
                              Icons.close,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return SizedBox(
                      height: 4,
                      child: Stack(
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(16),
                              ),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: _progressAnimation.value,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ],
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
