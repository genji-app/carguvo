import 'package:flutter/widgets.dart';
import 'package:sun_sports/core/utils/platform_utils.dart';

const double _kMinKeyboardInset = 1.0;

const double _kMinWindowShrink = 150.0;

bool isKeyboardVisible(BuildContext context) {
  if (!PlatformUtils.isAndroid) return false;
  if (MediaQuery.viewInsetsOf(context).bottom > _kMinKeyboardInset) return true;
  return _displayShrink(context) > _kMinWindowShrink;
}

double _displayShrink(BuildContext context) {
  final windowHeight = MediaQuery.sizeOf(context).height;
  final view = View.of(context);
  final dpr = view.display.devicePixelRatio;
  if (dpr <= 0) return 0;

  final displayHeight = view.display.size.height / dpr;
  if (displayHeight <= 0) return 0;

  return displayHeight - windowHeight;
}

class HideOnKeyboard extends StatelessWidget {
  const HideOnKeyboard({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!PlatformUtils.isAndroid) return child;
    return isKeyboardVisible(context) ? const SizedBox.shrink() : child;
  }
}
