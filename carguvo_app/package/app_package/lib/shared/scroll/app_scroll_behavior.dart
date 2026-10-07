import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  static const String _rawFlag = String.fromEnvironment(
    'SCROLL_PHYSICS',
    defaultValue: 'auto',
  );

  static const Set<String> _allowedFlags = {'auto', 'clamping', 'bouncing'};

  String get _flag {
    if (_allowedFlags.contains(_rawFlag)) return _rawFlag;
    assert(
      false,
      'AppScrollBehavior: SCROLL_PHYSICS="$_rawFlag" không hợp lệ — chỉ nhận '
      'auto|clamping|bouncing. Fallback về "auto".',
    );
    return 'auto';
  }

  static const ScrollPhysics _bouncingWeb = BouncingScrollPhysics(
    decelerationRate: ScrollDecelerationRate.normal,
    parent: RangeMaintainingScrollPhysics(),
  );

  static const ScrollPhysics _clampingWeb = ClampingScrollPhysics(
    parent: RangeMaintainingScrollPhysics(),
  );

  static const Set<PointerDeviceKind> _webDragDevices = {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.invertedStylus,
  };

  @override
  Set<PointerDeviceKind> get dragDevices {
    if (!kIsWeb) return super.dragDevices;
    return _webDragDevices;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    if (!kIsWeb) return super.getScrollPhysics(context);

    switch (_flag) {
      case 'clamping':
        return _clampingWeb;
      case 'bouncing':
        return _bouncingWeb;
      case 'auto':
      default:
        final TargetPlatform platform = getPlatform(context);
        final bool isWebMobile =
            platform == TargetPlatform.iOS ||
            platform == TargetPlatform.android;
        if (isWebMobile) return _bouncingWeb;
        return super.getScrollPhysics(context);
    }
  }
}
