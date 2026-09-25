library;

import 'package:flutter/widgets.dart';
import 'package:game_volta_core/volta_layout_spec.dart';

export 'package:game_volta_core/volta_layout_spec.dart';

class VoltaLayoutScope extends InheritedWidget {
  const VoltaLayoutScope({
    required this.spec,
    required super.child,
    super.key,
  });

  final VoltaLayoutSpec spec;

  static VoltaLayoutSpec of(BuildContext context) {
    final VoltaLayoutScope? scope =
        context.dependOnInheritedWidgetOfExactType<VoltaLayoutScope>();
    assert(scope != null, 'Thiếu VoltaLayoutScope phía trên widget này');
    return scope?.spec ?? VoltaLayoutSpec.mobile;
  }

  @override
  bool updateShouldNotify(VoltaLayoutScope oldWidget) => oldWidget.spec != spec;
}
