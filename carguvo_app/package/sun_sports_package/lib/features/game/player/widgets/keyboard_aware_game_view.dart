import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class KeyboardAwareGameView extends StatelessWidget {
  const KeyboardAwareGameView({required this.child, this.enabled, super.key});

  final Widget child;

  final bool? enabled;

  static bool get defaultEnabled =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  @override
  Widget build(BuildContext context) {
    final shouldWrap = enabled ?? defaultEnabled;
    if (!shouldWrap) return child;

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: child,
    );
  }
}
