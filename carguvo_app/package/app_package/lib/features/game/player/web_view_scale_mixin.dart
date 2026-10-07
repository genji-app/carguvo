import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

mixin WebViewScaleMixin<T extends StatefulWidget> on State<T> {
  double? _initialWidth;
  double _scaleX = 1.0;

  double get webViewScaleX => _scaleX;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!kIsWeb) return;

    final containerSize = MediaQuery.sizeOf(context);

    if (_initialWidth == null) {
      if (containerSize.width <= 0) return;

      try {
        final view = View.maybeOf(context);
        if (view != null) {
          _initialWidth = view.physicalSize.width / view.devicePixelRatio;
        }

        if (_initialWidth == null || _initialWidth == 0) {
          _initialWidth = containerSize.width;
        }
      } catch (_) {
        _initialWidth = containerSize.width;
      }

      _scaleX = containerSize.width / _initialWidth!;
    } else {
      final scaleX = containerSize.width / _initialWidth!;
      if ((scaleX - _scaleX).abs() > 0.001) {
        _scaleX = scaleX;
      }
    }
  }

  Widget applyWebViewScale(Widget child) {
    if (!kIsWeb) return child;

    return Transform.scale(
      scaleX: _scaleX,
      alignment: Alignment.topLeft,
      child: child,
    );
  }
}
