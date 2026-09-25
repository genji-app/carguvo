import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class GamePlayerScaffold extends StatelessWidget {
  const GamePlayerScaffold({
    required this.child,
    this.showControls = false,
    this.useSafeArea = false,
    this.onGoBack,
    super.key,
  });

  final Widget child;
  final bool showControls;
  final bool useSafeArea;
  final VoidCallback? onGoBack;

  @override
  Widget build(BuildContext context) {
    final viewPadding = MediaQuery.viewPaddingOf(context);

    return OrientationBuilder(
      builder: (context, orientation) {
        final isPortrait = orientation == Orientation.portrait;

        return _AdaptiveGameLayout(
          isPortrait: isPortrait,
          viewPadding: viewPadding,
          showControls: showControls,
          useSafeArea: useSafeArea,
          onGoBack: onGoBack,
          child: child,
        );
      },
    );
  }
}

class _AdaptiveGameLayout extends StatelessWidget {
  const _AdaptiveGameLayout({
    required this.isPortrait,
    required this.viewPadding,
    required this.showControls,
    required this.useSafeArea,
    required this.child,
    this.onGoBack,
  });

  final bool isPortrait;
  final EdgeInsets viewPadding;
  final bool showControls;
  final bool useSafeArea;
  final VoidCallback? onGoBack;
  final Widget child;

  static const _kAppBarContentHeight = 48.0;

  static const _kSidebarContentWidth = 56.0;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Colors.black;
    final isIOS = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

    final topInset = isPortrait
        ? (showControls
              ? _kAppBarContentHeight + viewPadding.top
              : (useSafeArea ? viewPadding.top : 0.0))
        : 0.0;
    final bottomInset = isPortrait
        ? ((useSafeArea && isIOS) || (showControls && isPortrait)
              ? viewPadding.bottom
              : 0.0)
        : 0.0;

    final safeSidePadding = math.max(viewPadding.left, viewPadding.right);
    final leftInset = !isPortrait
        ? (showControls
              ? _kSidebarContentWidth + viewPadding.left
              : (useSafeArea ? safeSidePadding : 0.0))
        : 0.0;
    final rightInset = !isPortrait
        ? (showControls
              ? _kSidebarContentWidth + viewPadding.right
              : (useSafeArea ? safeSidePadding : 0.0))
        : 0.0;

    return Stack(
      children: [
        AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          top: topInset,
          left: leftInset,
          right: rightInset,
          bottom: bottomInset,
          child: child,
        ),

        if (showControls) ...[
          if (isPortrait) ...[
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: _kAppBarContentHeight + viewPadding.top,
              child: ColoredBox(
                color: backgroundColor,
                child: Align(
                  alignment: AlignmentDirectional.bottomStart,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      vertical: 4,
                      horizontal: 16,
                    ),
                    child: _BackButton(onPressed: onGoBack),
                  ),
                ),
              ),
            ),
          ] else ...[
            Positioned(
              top: 0,
              left: 0,
              bottom: 0,
              width: _kSidebarContentWidth + viewPadding.left,
              child: ColoredBox(
                color: backgroundColor,
                child: Align(
                  alignment: AlignmentDirectional.topCenter,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      vertical: 16,
                      horizontal: 4,
                    ),
                    child: _BackButton(onPressed: onGoBack),
                  ),
                ),
              ),
            ),

            Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              width: _kSidebarContentWidth + viewPadding.right,
              child: ColoredBox(color: backgroundColor),
            ),
          ],
        ],
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: 18,
      style: IconButton.styleFrom(
        fixedSize: const Size.square(40),
        padding: EdgeInsetsGeometry.zero,
        foregroundColor: AppColorStyles.contentSecondary,
        backgroundColor: AppColorStyles.backgroundQuaternary,
      ),
      onPressed: SoundTap.wrap(onPressed ?? () => Navigator.of(context).pop()),
      icon: const Icon(Icons.arrow_back_ios_new),
    );
  }
}
