import 'package:flutter/material.dart';
import 'package:app_package/core/utils/critical_svg_icons.dart';
import 'package:app_package/core/utils/extensions/image_helper.dart';

class SvgIconKeeper extends StatelessWidget {
  const SvgIconKeeper({super.key});

  static Widget wrap(BuildContext context, Widget? child) {
    return Stack(
      fit: StackFit.expand,
      children: [child ?? const SizedBox.shrink(), const SvgIconKeeper()],
    );
  }

  @override
  Widget build(BuildContext context) {
    final paths = CriticalSvgIcons.paths;
    return Offstage(
      child: TickerMode(
        enabled: false,
        child: Wrap(
          children: [
            for (final p in paths)
              ImageHelper.load(path: p, width: 24, height: 24),
          ],
        ),
      ),
    );
  }
}
