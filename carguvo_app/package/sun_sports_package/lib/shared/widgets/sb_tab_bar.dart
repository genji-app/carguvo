import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class SBTab {
  final String label;

  final String? icon;
  final String? badge;

  SBTab({required this.label, this.icon, this.badge});
}

class SBTabBar extends StatefulWidget {
  const SBTabBar({
    required this.tabs,
    required this.initialIndex,
    this.onChanged,
    super.key,
  });

  final List<SBTab> tabs;
  final int initialIndex;
  final ValueChanged<int>? onChanged;

  @override
  State<SBTabBar> createState() => _SBTabBarState();
}

class _SBTabBarState extends State<SBTabBar> {
  late ValueNotifier<int> selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = ValueNotifier(widget.initialIndex);
  }

  @override
  void dispose() {
    selectedIndex.dispose();
    super.dispose();
  }

  void onTabPressed(int index) {
    selectedIndex.value = index;
    widget.onChanged?.call(index);
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: AppColorStyles.backgroundTertiary,
      borderRadius: BorderRadius.circular(100),
    ),
    child: ListenableBuilder(
      listenable: selectedIndex,
      builder: (context, child) {
        final children = <Widget>[];
        for (var i = 0; i < widget.tabs.length; i++) {
          final tab = widget.tabs[i];
          final selected = i == selectedIndex.value;
          children.add(
            _TabItem(
              selected: selected,
              label: tab.label,
              icon: tab.icon,
              badge: tab.badge,
              onPressed: selected ? null : () => onTabPressed(i),
            ),
          );
        }
        return Row(children: children);
      },
    ),
  );
}

class _TabItem extends StatelessWidget {
  final String label;
  final String? icon;
  final String? badge;
  final bool selected;
  final VoidCallback? onPressed;

  const _TabItem({
    required this.label,
    this.selected = false,
    this.onPressed,
    this.icon,
    this.badge,
    // ignore: unused_element_parameter
    super.key,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: InkWell(
      onTap: SoundTap.wrap(onPressed),
      borderRadius: BorderRadius.circular(100),
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? const Color.fromRGBO(249, 219, 175, 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                ImageHelper.load(path: icon!, width: 20, height: 20),
                const Gap(4),
              ],
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: AppTextStyles.labelSmall(
                    color: selected
                        ? AppColorStyles.contentPrimary
                        : AppColorStyles.contentSecondary,
                  ),
                ),
              ),
              if (badge != null) ...[
                const Gap(4),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.orange300,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Center(
                    child: Text(
                      badge!,
                      style: AppTextStyles.labelXSmall(
                        color: AppColors.gray950,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}
