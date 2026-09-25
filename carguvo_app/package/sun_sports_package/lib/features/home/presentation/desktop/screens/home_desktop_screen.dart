import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/services/storage/sport_storage.dart';
import 'package:sun_sports/features/game/game.dart';
import 'package:sun_sports/features/home/presentation/desktop/widgets/home_desktop_banner_section.dart';
import 'package:sun_sports/features/home/presentation/desktop/widgets/home_desktop_casino_section.dart';
import 'package:sun_sports/features/home/presentation/desktop/widgets/home_desktop_hot_bets_section.dart';
import 'package:sun_sports/features/home/presentation/desktop/widgets/home_desktop_ncc_section.dart';
import 'package:sun_sports/features/home/presentation/desktop/widgets/home_desktop_sports_section.dart';
import 'package:sun_sports/features/home/presentation/desktop/widgets/home_desktop_welcome_section.dart';
import 'package:sun_sports/features/home/presentation/widgets/home_footer_section.dart';
import 'package:sun_sports/features/home/presentation/widgets/count_down_event/count_down_event_deadline.dart';
import 'package:sun_sports/features/home/presentation/widgets/count_down_event/count_down_event_screen.dart';

class HomeDesktopScreen extends ConsumerStatefulWidget {
  const HomeDesktopScreen({super.key});

  @override
  ConsumerState<HomeDesktopScreen> createState() => _HomeDesktopScreenState();
}

class _HomeDesktopScreenState extends ConsumerState<HomeDesktopScreen> {
  @override
  void initState() {
    super.initState();
    SportStorage.instance.init();
  }

  static final List<Widget> _sections = [
    const HomeDesktopWelcomeSection(),
    const Gap(12),
    if (!isEventCupExpired()) ...[
      const RepaintBoundary(child: CountDownEventScreen()),
      const Gap(12),
    ],
    const HomeDesktopHotBetsSection(),
    const Gap(12),
    const HomeDesktopSportsSection(),
    const Gap(12),
    const HomeDesktopNccSection(),
    const Gap(12),
    const RepaintBoundary(child: GameGroupView.featured()),
    const HomeDesktopCasinoSection(),
    const Gap(12),
    const HomeDesktopBannerSection(),
    const Gap(12),
    const RepaintBoundary(child: GameGroupView.liveCasino()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList.builder(
              itemCount: _sections.length,
              itemBuilder: (context, index) => _sections[index],
            ),
          ),
          const SliverToBoxAdapter(
            child: HomeFooterSection(isDesktop: true),
          ),
        ],
      ),
    );
  }
}
