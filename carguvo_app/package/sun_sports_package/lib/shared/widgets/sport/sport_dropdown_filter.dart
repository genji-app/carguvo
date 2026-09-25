import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/tab_layout/s88_tab.dart' show S88TabItem;

class SportDropdownFilter extends StatefulWidget {
  const SportDropdownFilter({
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    super.key,
    this.menuWidth = 205,
  });

  final List<S88TabItem> items;

  final int selectedIndex;

  final ValueChanged<int> onChanged;

  final double menuWidth;

  @override
  State<SportDropdownFilter> createState() => _SportDropdownFilterState();
}

class _SportDropdownFilterState extends State<SportDropdownFilter> {
  final MenuController _controller = MenuController();
  bool _isOpen = false;

  static const _radius = 12.0;
  static const _iconSize = 20.0;

  int get _safeIndex =>
      (widget.selectedIndex < 0 || widget.selectedIndex >= widget.items.length)
      ? 0
      : widget.selectedIndex;

  void _select(int index) {
    _controller.close();
    if (index != _safeIndex) widget.onChanged(index);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();
    final selected = widget.items[_safeIndex];

    return MenuAnchor(
      controller: _controller,
      onOpen: () => setState(() => _isOpen = true),
      onClose: () => setState(() => _isOpen = false),
      alignmentOffset: const Offset(0, 4),
      style: MenuStyle(
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        ),
        backgroundColor: const WidgetStatePropertyAll(
          AppColorStyles.backgroundTertiary,
        ),
        shadowColor: const WidgetStatePropertyAll(Color(0x140A0D12)),
        elevation: const WidgetStatePropertyAll(8),
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(_radius)),
            side: BorderSide(color: AppColorStyles.borderSecondary),
          ),
        ),
        fixedSize: WidgetStatePropertyAll(Size.fromWidth(widget.menuWidth)),
      ),
      menuChildren: [
        for (var i = 0; i < widget.items.length; i++)
          _SportMenuRow(
            item: widget.items[i],
            isSelected: i == _safeIndex,
            onTap: () => _select(i),
          ),
      ],
      builder: (context, controller, _) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: SoundTap.wrap(
          () => controller.isOpen ? controller.close() : controller.open(),
        ),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColorStyles.backgroundTertiary,
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(color: AppColorStyles.borderSecondary),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D0A0D12),
                offset: Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SportIcon(path: selected.iconPath),
              const Gap(8),
              Text(
                selected.text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.paragraphMedium(
                  color: AppColorStyles.contentPrimary,
                ),
              ),
              const Gap(16),
              AnimatedRotation(
                turns: _isOpen ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: ImageHelper.load(
                  path: AppIcons.chevronDown,
                  width: _iconSize,
                  height: _iconSize,
                  color: AppColorStyles.contentPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SportMenuRow extends StatelessWidget {
  const _SportMenuRow({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final S88TabItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: SoundTap.wrap(onTap),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColorStyles.backgroundQuaternary : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _SportIcon(path: item.iconPath),
            const Gap(8),
            Expanded(
              child: Text(
                item.text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.paragraphMedium(
                  color: AppColorStyles.contentPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SportIcon extends StatelessWidget {
  const _SportIcon({required this.path});

  final String? path;

  @override
  Widget build(BuildContext context) {
    if (path == null) return const SizedBox(width: 20, height: 20);
    return RepaintBoundary(
      child: ImageHelper.load(
        path: path!,
        width: 20,
        height: 20,
        color: AppColorStyles.contentPrimary,
      ),
    );
  }
}
