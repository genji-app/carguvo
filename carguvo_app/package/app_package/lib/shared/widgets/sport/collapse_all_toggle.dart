import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_package/core/utils/extensions/image_helper.dart';
import 'package:app_package/core/utils/styles/app_icons.dart';
import 'package:app_package/shared/widgets/buttons/sound_tap.dart';

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
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: AnimatedRotation(
            duration: const Duration(milliseconds: 200),
            turns: collapseAll ? 0.5 : 0,
            child: ImageHelper.load(
              path: AppIcons.iconCollapse,
              width: iconSize,
              height: iconSize,
              color: const Color(0x80FFFCDB),
            ),
          ),
        ),
      ),
    );
  }
}
