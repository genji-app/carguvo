import 'package:flutter/material.dart';

enum OddsDirection {
  none,

  up,

  down,
}

extension OddsDirectionX on OddsDirection {
  bool get isUp => this == OddsDirection.up;
  bool get isDown => this == OddsDirection.down;
  bool get hasChange => this != OddsDirection.none;

  Color? get color {
    switch (this) {
      case OddsDirection.up:
        return const Color(0xFF4CAF50);
      case OddsDirection.down:
        return const Color(0xFFF44336);
      case OddsDirection.none:
        return null;
    }
  }

  Color? backgroundColor([double opacity = 0.2]) {
    return color?.withOpacity(opacity);
  }

  IconData? get icon {
    switch (this) {
      case OddsDirection.up:
        return Icons.arrow_drop_up;
      case OddsDirection.down:
        return Icons.arrow_drop_down;
      case OddsDirection.none:
        return null;
    }
  }

  static OddsDirection fromChange({
    required double? current,
    required double? previous,
  }) {
    if (previous == null || current == null) return OddsDirection.none;
    if (current > previous) return OddsDirection.up;
    if (current < previous) return OddsDirection.down;
    return OddsDirection.none;
  }
}
