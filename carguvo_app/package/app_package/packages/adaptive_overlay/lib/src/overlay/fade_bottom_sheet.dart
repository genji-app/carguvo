import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FadeBottomSheetRoute<T> extends PopupRoute<T> {
  FadeBottomSheetRoute({
    required this.builder,
    this.capturedThemes,
    this.barrierColorValue = const Color(0x80000000),
    this.barrierDismissibleValue = true,
    this.barrierLabelValue = 'Dismiss',
    this.transitionDurationValue = const Duration(milliseconds: 50),
    this.useSafeArea = true,
    this.liftForKeyboard = false,
    this.maxWidth,
    this.bottomPassThrough,
    this.bottomPassThroughSuspended,
    super.settings,
  });

  final WidgetBuilder builder;

  final CapturedThemes? capturedThemes;

  final Color barrierColorValue;
  final bool barrierDismissibleValue;
  final String barrierLabelValue;
  final Duration transitionDurationValue;

  final bool useSafeArea;

  final bool liftForKeyboard;

  final double? maxWidth;

  final ValueListenable<double>? bottomPassThrough;

  final bool Function(BuildContext context)? bottomPassThroughSuspended;

  double _effectiveStrip(BuildContext context, double raw) {
    if (MediaQuery.viewInsetsOf(context).bottom > 0) return 0;
    if (bottomPassThroughSuspended?.call(context) ?? false) return 0;
    return raw < 0 ? 0 : raw;
  }

  @override
  Color get barrierColor => barrierColorValue;

  @override
  bool get barrierDismissible => barrierDismissibleValue;

  @override
  String get barrierLabel => barrierLabelValue;

  @override
  Duration get transitionDuration => transitionDurationValue;

  @override
  Widget buildModalBarrier() {
    final passThrough = bottomPassThrough;
    if (passThrough == null) return super.buildModalBarrier();
    return ValueListenableBuilder<double>(
      valueListenable: passThrough,
      builder: (context, raw, _) => Padding(
        padding: EdgeInsets.only(bottom: _effectiveStrip(context, raw)),
        child: super.buildModalBarrier(),
      ),
    );
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    Widget content = Builder(builder: builder);

    if (maxWidth != null) {
      content = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth!),
        child: content,
      );
    }

    content = _DragToDismissSheet(child: content);

    Widget aligned = Align(alignment: Alignment.bottomCenter, child: content);

    if (useSafeArea) {
      aligned = SafeArea(top: true, bottom: false, child: aligned);
    }

    if (liftForKeyboard) {
      final mediaQuery = MediaQuery.of(context);
      aligned = AnimatedPadding(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
        child: MediaQuery(
          data: mediaQuery.removeViewInsets(removeBottom: true),
          child: aligned,
        ),
      );
    }

    Widget page = Material(type: MaterialType.transparency, child: aligned);

    if (capturedThemes != null) {
      page = capturedThemes!.wrap(page);
    }

    return page;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final fade = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
    final slide =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: const Threshold(0),
          ),
        );

    final transition = FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: child),
    );

    final passThrough = bottomPassThrough;
    if (passThrough == null) return transition;

    return ValueListenableBuilder<double>(
      valueListenable: passThrough,
      builder: (context, raw, page) => Padding(
        padding: EdgeInsets.only(bottom: _effectiveStrip(context, raw)),
        child: ClipRect(child: page),
      ),
      child: transition,
    );
  }
}

Future<T?> showFadeBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color barrierColor = const Color(0x80000000),
  bool barrierDismissible = true,
  Duration transitionDuration = const Duration(milliseconds: 50),
  bool useSafeArea = true,
  bool liftForKeyboard = false,
  double? maxWidth,
  bool useRootNavigator = false,
}) {
  final navigator = Navigator.of(context, rootNavigator: useRootNavigator);
  return navigator.push<T>(
    FadeBottomSheetRoute<T>(
      builder: builder,
      capturedThemes: InheritedTheme.capture(
        from: context,
        to: navigator.context,
      ),
      barrierColorValue: barrierColor,
      barrierDismissibleValue: barrierDismissible,
      barrierLabelValue: MaterialLocalizations.of(
        context,
      ).modalBarrierDismissLabel,
      transitionDurationValue: transitionDuration,
      useSafeArea: useSafeArea,
      liftForKeyboard: liftForKeyboard,
      maxWidth: maxWidth,
    ),
  );
}

class _DragToDismissSheet extends StatefulWidget {
  const _DragToDismissSheet({required this.child});

  final Widget child;

  @override
  State<_DragToDismissSheet> createState() => _DragToDismissSheetState();
}

class _DragToDismissSheetState extends State<_DragToDismissSheet>
    with SingleTickerProviderStateMixin {
  static const double _dismissThreshold = 120;
  static const double _velocityThreshold = 700;

  double _dragOffset = 0;
  bool _disposed = false;
  late final AnimationController _settleController;
  Animation<double>? _settleAnimation;

  @override
  void initState() {
    super.initState();
    _settleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  NavigatorState? _navigator;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _navigator = Navigator.maybeOf(context);
  }

  @override
  void dispose() {
    _disposed = true;
    _settleAnimation?.removeListener(_onSettleTick);
    _settleController.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_settleController.isAnimating) {
      _settleController.stop();
      _settleAnimation?.removeListener(_onSettleTick);
    }
    setState(() {
      _dragOffset = (_dragOffset + details.delta.dy).clamp(0.0, double.infinity);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond.dy;
    if (_dragOffset > _dismissThreshold || velocity > _velocityThreshold) {
      if (mounted) _navigator?.maybePop();
      return;
    }
    _settleBackToRest();
  }

  void _settleBackToRest() {
    _settleAnimation =
        Tween<double>(begin: _dragOffset, end: 0).animate(
          CurvedAnimation(parent: _settleController, curve: Curves.easeOut),
        )..addListener(_onSettleTick);
    _settleController.forward(from: 0).whenComplete(() {
      if (_disposed) return;
      _settleAnimation?.removeListener(_onSettleTick);
      _settleController.reset();
    });
  }

  void _onSettleTick() {
    if (!mounted) return;
    setState(() => _dragOffset = _settleAnimation?.value ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onVerticalDragUpdate: _onDragUpdate,
      onVerticalDragEnd: _onDragEnd,
      child: Transform.translate(
        offset: Offset(0, _dragOffset),
        child: widget.child,
      ),
    );
  }
}
