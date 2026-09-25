import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'adaptive_overlay_controller.dart';
import 'animated_overlay.dart';
import 'fade_bottom_sheet.dart';

class _InheritedAdaptiveOverlay extends InheritedWidget {
  const _InheritedAdaptiveOverlay({
    required this.controller,
    required super.child,
    this.sheetBreakpoint = 733.0,
  });

  final AdaptiveOverlayController controller;
  final double sheetBreakpoint;

  @override
  bool updateShouldNotify(_InheritedAdaptiveOverlay oldWidget) {
    return controller != oldWidget.controller ||
        sheetBreakpoint != oldWidget.sheetBreakpoint;
  }
}

class AdaptiveOverlay extends StatefulWidget {
  const AdaptiveOverlay({
    required this.controller,
    super.key,
    this.child,
    this.overlay,
    this.overlayBuilder,
    this.overlayConstraints = const BoxConstraints.tightFor(width: 430),
    this.overlayAlignment = Alignment.centerRight,
    this.sheetBreakpoint = 733.0,
    this.onOverlayDismissed,
    this.sheetBottomPassThrough,
    this.sheetBottomPassThroughSuspended,
  }) : assert(
         overlay != null || overlayBuilder != null,
         'Either overlay or overlayBuilder must be provided.',
       );

  final Widget? child;

  final AdaptiveOverlayController controller;

  final Widget? overlay;

  final AdaptiveOverlayBuilder? overlayBuilder;

  final BoxConstraints overlayConstraints;

  final Alignment overlayAlignment;

  final double sheetBreakpoint;

  final VoidCallback? onOverlayDismissed;

  final ValueListenable<double>? sheetBottomPassThrough;

  final bool Function(BuildContext context)? sheetBottomPassThroughSuspended;

  static AdaptiveOverlayController of(BuildContext context) {
    final result = context
        .dependOnInheritedWidgetOfExactType<_InheritedAdaptiveOverlay>();
    if (result != null) {
      return result.controller;
    }
    throw FlutterError(
      'AdaptiveOverlay.of() called with a context that does not '
      'contain an AdaptiveOverlay.\n'
      'No AdaptiveOverlay found in context. This widget must be used '
      'within an AdaptiveOverlay subtree.',
    );
  }

  static AdaptiveOverlayController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedAdaptiveOverlay>()
        ?.controller;
  }

  static double breakpointOf(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<_InheritedAdaptiveOverlay>()
            ?.sheetBreakpoint ??
        733.0;
  }

  static bool isMobile(BuildContext context) {
    return MediaQuery.sizeOf(context).width < breakpointOf(context);
  }

  @override
  State<AdaptiveOverlay> createState() => _AdaptiveOverlayState();
}

class _AdaptiveOverlayState extends State<AdaptiveOverlay> {
  late final AnimatedOverlayController _animatedOverlayController;
  bool _isSheetShown = false;
  bool _isMobile = false;

  FadeBottomSheetRoute<void>? _currentSheetRoute;

  @override
  void initState() {
    super.initState();
    _animatedOverlayController = AnimatedOverlayController();

    if (widget.controller.isVisible) {
      _animatedOverlayController.open();
    }

    widget.controller.addListener(_handleControllerChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChange);
    _animatedOverlayController.dispose();
    _currentSheetRoute = null;
    super.dispose();
  }

  void _handleControllerChange() {
    final isVisible = widget.controller.isVisible;

    if (isVisible) {
      _animatedOverlayController.open();
    } else {
      _animatedOverlayController.close();
    }

    if (_isMobile) {
      _syncBottomSheet(isVisible);
    } else {
      setState(() {});
    }
  }

  Widget _buildOverlayContent(BuildContext context) {
    return widget.overlayBuilder != null
        ? widget.overlayBuilder!(context, widget.controller)
        : widget.overlay!;
  }

  Future<void> _showAsBottomSheet() {
    final navigator = Navigator.of(context);

    _currentSheetRoute = FadeBottomSheetRoute<void>(
      builder: (sessionContext) => _InheritedAdaptiveOverlay(
        controller: widget.controller,
        child: _buildOverlayContent(sessionContext),
      ),
      capturedThemes: InheritedTheme.capture(
        from: context,
        to: navigator.context,
      ),
      useSafeArea: true,
      barrierLabelValue: MaterialLocalizations.of(
        context,
      ).scrimOnTapHint(MaterialLocalizations.of(context).bottomSheetLabel),
      bottomPassThrough: widget.sheetBottomPassThrough,
      bottomPassThroughSuspended: widget.sheetBottomPassThroughSuspended,
    );

    navigator.push(_currentSheetRoute!);

    return _currentSheetRoute!.completed.then((_) {});
  }

  void _syncBottomSheet(bool isVisible) {
    if (isVisible && !_isSheetShown) {
      final route = ModalRoute.of(context);
      if (route != null && !route.isCurrent) {
        return;
      }

      _isSheetShown = true;
      _showAsBottomSheet().whenComplete(() {
        if (!mounted) return;

        _currentSheetRoute = null;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _isSheetShown) {
            setState(() {
              _isSheetShown = false;
            });

            if (MediaQuery.sizeOf(context).width < widget.sheetBreakpoint) {
              widget.controller.close();
            }
          }
        });
      });
    } else if (!isVisible && _isSheetShown) {
      _popSheetRoute();
    }
  }

  void _popSheetRoute() {
    if (!mounted) return;

    final route = _currentSheetRoute;
    if (route != null && route.isActive) {
      route.navigator?.pop();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isMobile = MediaQuery.sizeOf(context).width < widget.sheetBreakpoint;
    final isVisible = widget.controller.isVisible;

    if (_isMobile) {
      if (isVisible && !_isSheetShown) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && widget.controller.isVisible) {
            _syncBottomSheet(true);
          }
        });
      }
    } else if (_isSheetShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _isSheetShown) {
          _popSheetRoute();
        }
      });
    }

    if (isVisible) {
      _animatedOverlayController.open();
    } else {
      _animatedOverlayController.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    final showStackOverlay = !_isMobile && !_isSheetShown;

    final overlayUI = showStackOverlay
        ? AnimatedOverlay(
            controller: _animatedOverlayController,
            alignment: widget.overlayAlignment,
            constraints: widget.overlayConstraints,
            backdropColor: Colors.transparent,
            onDismissed: widget.onOverlayDismissed,
            child: _buildOverlayContent(context),
          )
        : const SizedBox.shrink();

    return _InheritedAdaptiveOverlay(
      controller: widget.controller,
      sheetBreakpoint: widget.sheetBreakpoint,
      child: widget.child == null
          ? overlayUI
          : Stack(
              clipBehavior: Clip.none,
              children: [
                widget.child!,
                if (showStackOverlay) Positioned.fill(child: overlayUI),
              ],
            ),
    );
  }
}
