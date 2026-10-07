import 'package:flutter/foundation.dart';

class SmartTooltipController extends ChangeNotifier {
  bool _isShowing = false;

  VoidCallback? _showCallback;
  VoidCallback? _hideCallback;

  bool get isShowing => _isShowing;

  void attach({required VoidCallback onShow, required VoidCallback onHide}) {
    _showCallback = onShow;
    _hideCallback = onHide;
  }

  void detach() {
    _showCallback = null;
    _hideCallback = null;
  }

  void updateState(bool showing) {
    if (_isShowing != showing) {
      _isShowing = showing;
      notifyListeners();
    }
  }

  void show() {
    _showCallback?.call();
  }

  void hide() {
    _hideCallback?.call();
  }

  void toggle() {
    if (_isShowing) {
      hide();
    } else {
      show();
    }
  }

  @override
  void dispose() {
    _showCallback = null;
    _hideCallback = null;
    super.dispose();
  }
}
