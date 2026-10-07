library;

import 'dart:async';

class TaiXiuNanFlags {
  TaiXiuNanFlags._();

  static bool active = false;

  static bool bowlOpened = false;

  static final StreamController<void> _bowlChanges =
      StreamController<void>.broadcast();

  static Stream<void> get onBowlOpened => _bowlChanges.stream;

  static void openBowl() {
    if (bowlOpened) return;
    bowlOpened = true;
    _bowlChanges.add(null);
  }
}
