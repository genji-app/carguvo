import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/search/presentation/desktop/search_desktop_screen.dart';
import 'package:sun_sports/features/search/presentation/mobile/search_mobile_screen.dart';
import 'package:sun_sports/features/search/presentation/tablet/search_tablet_screen.dart';
import 'package:sun_sports/shared/responsive/responsive_layout.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => const ResponsiveLayout(
    mobile: SearchMobileScreen(),
    tablet: SearchTabletScreen(),
    desktop: SearchDesktopScreen(),
  );
}
