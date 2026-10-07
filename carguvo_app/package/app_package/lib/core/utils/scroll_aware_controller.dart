import 'dart:async';

import 'package:flutter/foundation.dart';

class ScrollAwareController extends ChangeNotifier {
  static final instance = ScrollAwareController._();
  ScrollAwareController._();

  bool _isScrolling = false;
  Timer? _scrollEndTimer;

  bool get isScrolling => _isScrolling;

  bool get isScrollActivityActive => _isScrolling;

  void onScrollStart() {
    _scrollEndTimer?.cancel();
    if (!_isScrolling) {
      _isScrolling = true;
      notifyListeners();
    }
  }

  void onScrollEnd() {
    _scrollEndTimer?.cancel();
    _scrollEndTimer = Timer(const Duration(milliseconds: 150), () {
      if (_isScrolling) {
        _isScrolling = false;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _scrollEndTimer?.cancel();
    super.dispose();
  }
}
