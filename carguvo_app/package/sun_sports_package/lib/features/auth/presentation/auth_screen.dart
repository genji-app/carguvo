import 'package:flutter/material.dart';
import 'package:sun_sports/features/auth/presentation/desktop/screens/auth_desktop_screen.dart';
import 'package:sun_sports/features/auth/presentation/tablet/screens/auth_tablet_screen.dart';
import 'package:sun_sports/shared/responsive/responsive_layout.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const ResponsiveLayout(
    mobile: AuthDesktopScreen(),
    tablet: AuthTabletScreen(),
    desktop: AuthDesktopScreen(),
  );
}
