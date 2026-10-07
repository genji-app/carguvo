import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_package/core/constants/app_version.dart';
import 'package:app_package/core/utils/extensions/image_helper.dart';
import 'package:app_package/core/utils/styles/app_color.dart';
import 'package:app_package/core/utils/styles/app_color_styles.dart';
import 'package:app_package/core/utils/styles/app_images.dart';
import 'package:app_package/core/utils/styles/app_text_styles.dart';

class ProviderReturnSplashController extends StateNotifier<int?> {
  ProviderReturnSplashController() : super(null);

  static const Duration duration = Duration(seconds: 1);

  Timer? _hideTimer;
  int _token = 0;

  void show() {
    if (!mounted) return;
    _hideTimer?.cancel();
    state = ++_token;
    _hideTimer = Timer(duration, () {
      if (mounted) state = null;
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }
}

final providerReturnSplashProvider =
    StateNotifierProvider<ProviderReturnSplashController, int?>(
      (ref) => ProviderReturnSplashController(),
    );

class ProviderReturnSplashOverlay extends ConsumerStatefulWidget {
  const ProviderReturnSplashOverlay({super.key});

  @override
  ConsumerState<ProviderReturnSplashOverlay> createState() =>
      _ProviderReturnSplashOverlayState();
}

class _ProviderReturnSplashOverlayState
    extends ConsumerState<ProviderReturnSplashOverlay> {
  bool _fadeCompleted = true;
  int _lastToken = 0;

  @override
  Widget build(BuildContext context) {
    final token = ref.watch(providerReturnSplashProvider);
    final visible = token != null;
    if (token != null) _lastToken = token;

    if (visible && _fadeCompleted) _fadeCompleted = false;
    if (!visible && _fadeCompleted) return const SizedBox.shrink();

    return Positioned.fill(
      child: IgnorePointer(
        ignoring: !visible,
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: visible
              ? Duration.zero
              : const Duration(milliseconds: 288),
          curve: Curves.easeOutCubic,
          onEnd: () {
            if (mounted && !visible && !_fadeCompleted) {
              setState(() => _fadeCompleted = true);
            }
          },
          child: Material(
            color: AppColorStyles.backgroundSecondary,
            child: _SplashBody(key: ValueKey(_lastToken)),
          ),
        ),
      ),
    );
  }
}

class _SplashBody extends StatelessWidget {
  const _SplashBody({super.key});

  @override
  Widget build(BuildContext context) {
    final logoUrl = AppImages.logoUrl;
    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: logoUrl.isEmpty
                    ? null
                    : ImageHelper.load(
                        path: logoUrl,
                        width: 200,
                        height: 200,
                        fit: BoxFit.contain,
                        errorWidget: const SizedBox.shrink(),
                      ),
              ),
              const SizedBox(height: 56),
              const _ProgressBar(),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                'Versions: v${AppVersion.code}',
                textAlign: TextAlign.center,
                style: AppTextStyles.labelXXSmall(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 6,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColorStyles.backgroundQuaternary,
        borderRadius: BorderRadius.circular(1000),
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: ProviderReturnSplashController.duration,
        curve: Curves.easeOut,
        builder: (context, value, _) => FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: value <= 0 ? 0.0001 : value,
          heightFactor: 1,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF644202), AppColors.yellow600],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
