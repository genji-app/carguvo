import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/shared/widgets/divider/divider.dart';

class SBBottomNavigationBar extends StatelessWidget {
  const SBBottomNavigationBar({super.key, this.child}) : _showDivider = false;

  const SBBottomNavigationBar.withDivider({super.key, this.child})
    : _showDivider = true;

  final Widget? child;
  final bool _showDivider;

  @override
  Widget build(BuildContext context) {
    final paddingBottom = MediaQuery.of(context).padding.bottom;

    return Container(
      color: AppColorStyles.backgroundSecondary,
      padding: MediaQuery.viewInsetsOf(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_showDivider) const SBDivider.bottomNavigation(),
          if (child != null) child!,

          Gap(paddingBottom),
        ],
      ),
    );
  }
}
