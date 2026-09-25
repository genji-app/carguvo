import 'package:flutter/widgets.dart';

class GameLayoutScope extends InheritedWidget {
  const GameLayoutScope({
    required this.availableWidth,
    required super.child,
    super.key,
  });

  final double availableWidth;

  static double? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<GameLayoutScope>()
        ?.availableWidth;
  }

  @override
  bool updateShouldNotify(GameLayoutScope oldWidget) {
    return availableWidth != oldWidget.availableWidth;
  }
}
