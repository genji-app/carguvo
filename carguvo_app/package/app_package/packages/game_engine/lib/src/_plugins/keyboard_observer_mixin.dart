import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

mixin KeyboardObserverMixin<T extends StatefulWidget> on State<T>, WidgetsBindingObserver {
  double _lastBottomInset = 0.0;
  bool? _isLandscape;

  void onKeyboardDismissed();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();

    if (kIsWeb) return;

    final view = View.of(context);

    final isLandscapeNow = view.physicalSize.width > view.physicalSize.height;
    if (_isLandscape != null && _isLandscape != isLandscapeNow) {
      _print(
        'Screen rotated to ${isLandscapeNow ? "Landscape" : "Portrait"}! Unfocusing keyboard.',
      );
      FocusManager.instance.primaryFocus?.unfocus();
    }
    _isLandscape = isLandscapeNow;

    final viewInsets = EdgeInsets.fromViewPadding(
      view.viewInsets,
      view.devicePixelRatio,
    );
    final currentBottomInset = viewInsets.bottom;
    _print('currentBottomInset: $currentBottomInset, lastBottomInset: $_lastBottomInset');

    if (_lastBottomInset > 0 && currentBottomInset == 0) {
      _print('Keyboard closed! Triggering onKeyboardDismissed with 300ms delay.');
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;

        final checkView = View.of(context);
        final checkInset = EdgeInsets.fromViewPadding(
          checkView.viewInsets,
          checkView.devicePixelRatio,
        ).bottom;

        if (checkInset == 0) {
          _print('Executing onKeyboardDismissed()');
          onKeyboardDismissed();
        } else {
          _print('Aborted onKeyboardDismissed! Keyboard is open again.');
        }
      });
    }

    _lastBottomInset = currentBottomInset;
  }

  void _print(String message) {
    if (kDebugMode) {
      debugPrint('[KeyboardObserver] $message');
    }
  }
}
