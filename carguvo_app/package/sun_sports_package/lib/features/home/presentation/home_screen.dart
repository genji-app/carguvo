import 'package:flutter/material.dart';
import 'package:sun_sports/features/home/presentation/mobile/screens/home_mobile_screen.dart';
import 'package:sun_sports/shared/responsive/responsive_layout.dart';
import 'package:sun_sports/features/home/presentation/desktop/screens/home_desktop_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const ResponsiveLayout(
    mobile: HomeMobileScreen(),
    tablet: HomeMobileScreen(),
    desktop: HomeDesktopScreen(),
  );
}
