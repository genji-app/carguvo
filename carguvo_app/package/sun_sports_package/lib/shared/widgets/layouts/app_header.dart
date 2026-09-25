import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;

  const AppHeader({super.key, this.title, this.actions, this.leading});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title != null ? Text(title!) : null,
      leading: leading,
      actions: actions,
      elevation: 1,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
