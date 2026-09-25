import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/utils/styles/spacing_styles.dart';
import 'package:sun_sports/features/sport/presentation/desktop/widgets/sport_desktop_header.dart';
import 'package:sun_sports/features/sport/presentation/providers/sport_navigation_provider.dart';
import '../widgets/sport_tablet_main_content.dart';
import '../widgets/sport_tablet_bottom_navigation.dart';

class SportTabletScreen extends ConsumerWidget {
  const SportTabletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    backgroundColor: Colors.black,
    appBar: const SportDesktopHeader(),
    body: Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Color(0xFF11100F),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: const Row(
            children: [
              Gap(AppSpacingStyles.space300),
              SportTabletMainContent(),
              Gap(AppSpacingStyles.space300),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SportTabletBottomNavigation(
              selectedIndex: ref.watch(sportNavigationProvider),
              onItemSelected: (index) {
                ref.read(sportNavigationProvider.notifier).selectItem(index);
              },
            ),
          ),
        ),
      ],
    ),
  );
}
