import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class AppSidebar extends StatelessWidget {
  final List<SidebarItem> items;
  final int? selectedIndex;
  final void Function(int)? onItemSelected;

  const AppSidebar({
    super.key,
    required this.items,
    this.selectedIndex,
    this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 236,
      color: Colors.grey.shade50,
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = selectedIndex == index;
          return ListTile(
            selected: isSelected,
            selectedTileColor: Colors.orange.shade50,
            leading: item.icon,
            title: Text(
              item.label,
              style:
                  AppTextStyles.labelSmall(
                    color: isSelected ? Colors.orange : Colors.black87,
                  ).copyWith(
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
            ),
            onTap: SoundTap.wrap(() => onItemSelected?.call(index)),
          );
        },
      ),
    );
  }
}

class SidebarItem {
  final String label;
  final Widget? icon;

  SidebarItem({required this.label, this.icon});
}
