import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class CollapseAllToggle extends ConsumerWidget {
  final StateProvider<bool> provider;

  final double iconSize;

  final EdgeInsetsGeometry padding;

  const CollapseAllToggle({
    required this.provider,
    this.iconSize = 24,
    this.padding = const EdgeInsets.symmetric(horizontal: 7, vertical: 7.5),
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collapseAll = ref.watch(provider);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: SoundTap.wrap(() {
          final notifier = ref.read(provider.notifier);
          notifier.state = !notifier.state;
        }),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: const Color(0x1486CB3C),
            borderRadius: BorderRadius.circular(12),
          ),
          child: AnimatedRotation(
            duration: const Duration(milliseconds: 200),
            turns: collapseAll ? 0.5 : 0,
            child: ImageHelper.load(
              path: AppIcons.iconCollapse,
              width: iconSize,
              height: iconSize,
            ),
          ),
        ),
      ),
    );
  }
}
