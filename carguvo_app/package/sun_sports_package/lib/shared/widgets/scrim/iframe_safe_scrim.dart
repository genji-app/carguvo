import 'package:flutter/material.dart';

import 'package:sun_sports/shared/widgets/scrim/iframe_safe_scrim_stub.dart'
    if (dart.library.js_interop) 'package:sun_sports/shared/widgets/scrim/iframe_safe_scrim_web.dart'
    as impl;

class IframeSafeScrim extends StatelessWidget {
  const IframeSafeScrim({
    required this.color,
    this.onTap,
    this.onTapUp,
    this.fade,
    super.key,
  });

  final Color color;

  final VoidCallback? onTap;

  final GestureTapUpCallback? onTapUp;

  final Animation<double>? fade;

  @override
  Widget build(BuildContext context) {
    return impl.buildIframeSafeScrim(
      color: color,
      onTap: onTap,
      onTapUp: onTapUp,
      fade: fade,
    );
  }
}
