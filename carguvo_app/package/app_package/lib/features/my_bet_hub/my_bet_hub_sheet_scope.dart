import 'package:flutter/widgets.dart';

class MyBetHubSheetScope extends InheritedWidget {
  const MyBetHubSheetScope({
    required this.navPassThrough,
    required super.child,
    super.key,
  });

  final bool navPassThrough;

  static bool navPassThroughOf(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<MyBetHubSheetScope>()
            ?.navPassThrough ??
        false;
  }

  @override
  bool updateShouldNotify(MyBetHubSheetScope oldWidget) =>
      navPassThrough != oldWidget.navPassThrough;
}
