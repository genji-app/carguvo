import 'package:flutter/widgets.dart';

typedef AdaptiveOverlayBuilder =
    Widget Function(BuildContext context, AdaptiveOverlayController controller);

class AdaptiveOverlayController extends ChangeNotifier {
  AdaptiveOverlayController();

  bool _isVisible = false;

  bool get isVisible => _isVisible;

  void open() {
    if (!_isVisible) {
      _isVisible = true;
      notifyListeners();
    }
  }

  void close() {
    if (_isVisible) {
      _isVisible = false;
      notifyListeners();
    }
  }

  void toggle() {
    _isVisible = !_isVisible;
    notifyListeners();
  }
}
