import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/shared/widgets/tab_layout/s88_tab.dart';

class SearchTabs extends StatelessWidget {
  const SearchTabs({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
    this.tabs,
    this.backgroundColor = Colors.transparent,
    this.defaultColor,
    this.selectedColor,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w700,
    this.borderColor,
  });

  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  final List<S88TabItem>? tabs;

  final Color backgroundColor;
  final Color? defaultColor;
  final Color? selectedColor;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? borderColor;

  static List<S88TabItem> get defaultTabs => [
    S88TabItem(text: 'Thể thao', iconPath: AppIcons.iconSoccer),
    S88TabItem(text: 'Casino', iconPath: AppIcons.iconCasino),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: borderColor ?? AppColorStyles.borderPrimary,
            width: 1,
          ),
        ),
      ),
      child: S88Tab(
        tabs: tabs ?? defaultTabs,
        selectedIndex: selectedIndex,
        onTabChanged: onTabChanged,
        backgroundColor: backgroundColor,
        defaultColor: defaultColor ?? AppColorStyles.contentSecondary,
        selectedColor: selectedColor ?? AppColors.yellow300,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
  }
}
