import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/providers/main_content_provider.dart';
import 'package:sun_sports/core/services/maintenance/sb_maintenance_provider.dart';
import 'package:sun_sports/core/utils/styles/spacing_styles.dart';
import 'package:sun_sports/features/bet_detail/presentation/desktop/screens/bet_detail_desktop_screen.dart';
import 'package:sun_sports/features/bet_detail/presentation/mobile/screens/bet_detail_mobile_v2_screen.dart';
import 'package:sun_sports/features/casino/casino_screen.dart';
import 'package:sun_sports/features/game/game.dart';
import 'package:sun_sports/features/home/presentation/desktop/widgets/home_desktop_banner_section.dart';
import 'package:sun_sports/features/home/presentation/desktop/widgets/home_desktop_hot_bets_section.dart';
import 'package:sun_sports/features/home/presentation/desktop/widgets/home_desktop_ncc_section.dart';
import 'package:sun_sports/features/home/presentation/desktop/widgets/home_desktop_sports_section.dart';
import 'package:sun_sports/features/home/presentation/desktop/widgets/home_desktop_welcome_section.dart';
import 'package:sun_sports/features/home/presentation/mobile/screens/home_mobile_screen.dart';
import 'package:sun_sports/features/home/presentation/tablet/screens/home_tablet_screen.dart';
import 'package:sun_sports/features/home/presentation/widgets/count_down_event/count_down_event_deadline.dart';
import 'package:sun_sports/features/home/presentation/widgets/count_down_event/count_down_event_screen.dart';
import 'package:sun_sports/features/sport/presentation/desktop/screens/league_detail_desktop_screen.dart';
import 'package:sun_sports/features/sport/presentation/desktop/screens/live_event_desktop_screen.dart';
import 'package:sun_sports/features/sport/presentation/desktop/screens/sport_desktop_screen.dart';
import 'package:sun_sports/features/sport/presentation/desktop/screens/top_league_desktop_screen.dart';
import 'package:sun_sports/features/sport/presentation/desktop/screens/upcoming_event_desktop_screen.dart';
import 'package:sun_sports/features/sport/presentation/mobile/screens/league_detail_mobile_screen.dart';
import 'package:sun_sports/features/sport/presentation/mobile/screens/live_event_mobile_screen.dart';
import 'package:sun_sports/features/sport/presentation/mobile/screens/top_league_mobile_screen.dart';
import 'package:sun_sports/features/sport/presentation/mobile/screens/upcoming_event_mobile_screen.dart';
import 'package:sun_sports/features/sport/presentation/mobile/widgets/sport_mobile_main_content.dart';
import 'package:sun_sports/features/sport_detail/presentation/desktop/screens/sport_detail_desktop_screen.dart';
import 'package:sun_sports/features/sport_detail/presentation/mobile/screens/sport_detail_mobile_screen.dart';
import 'package:sun_sports/features/sun_247/presentation/desktop/sun_247_desktop.dart';
import 'package:sun_sports/shared/widgets/maintenance/sb_maintenance_view.dart';

class ShellContentSwitcher extends ConsumerWidget {
  final bool isTablet;
  final bool isMobile;

  const ShellContentSwitcher({
    super.key,
    this.isTablet = false,
    this.isMobile = false,
  });

  static const _sportbookContentTypes = <MainContentType>{
    MainContentType.sport,
    MainContentType.sportDetail,
    MainContentType.betDetail,
    MainContentType.tournaments,
    MainContentType.live,
    MainContentType.upcoming,
    MainContentType.leagueDetail,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentType = ref.watch(mainContentProvider);

    if (_sportbookContentTypes.contains(contentType) &&
        ref.watch(sbMaintenanceProvider)) {
      return const SbMaintenancePanel();
    }

    if (isMobile || isTablet) {
      return _buildMobileContent(contentType, ref);
    }

    return RepaintBoundary(child: _buildDesktopContent(contentType));
  }

  Widget _buildDesktopContent(MainContentType contentType) {
    switch (contentType) {
      case MainContentType.sport:
        return const SportDesktopScreen();
      case MainContentType.casino:
        return const CasinoScreen(backgroundColor: Colors.transparent);
      case MainContentType.home:
        return const _HomeDesktopContent();
      case MainContentType.betDetail:
        return const BetDetailDesktopScreen();
      case MainContentType.sportDetail:
        return const SportDetailDesktopScreen();
      case MainContentType.sun247:
        return const Sun247Desktop();
      case MainContentType.tournaments:
        return const TopLeagueDesktopScreen();
      case MainContentType.live:
        return const LiveEventDesktopScreen();
      case MainContentType.upcoming:
        return const UpcomingEventDesktopScreen();
      case MainContentType.leagueDetail:
        return const LeagueDetailDesktopScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTabletContent(MainContentType contentType, WidgetRef ref) {
    switch (contentType) {
      case MainContentType.sport:
        return const SportMobileMainContent();
      case MainContentType.casino:
        return const CasinoScreen();
      case MainContentType.home:
        return const _HomeMobileContent();
      case MainContentType.betDetail:
        return const BetDetailMobileV2Screen();
      case MainContentType.sportDetail:
        return const _SportDetailMobileContent();
      case MainContentType.sun247:
        return const Sun247Desktop();
      case MainContentType.tournaments:
        return TopLeagueMobileScreen(
          onBackPressed: () {
            final prev = ref.read(previousContentProvider);
            if (prev != null) {
              ref.read(mainContentProvider.notifier).switchTo(prev);
              ref.read(previousContentProvider.notifier).state = null;
            }
          },
        );
      case MainContentType.live:
        return LiveEventMobileScreen(
          onBackPressed: () {
            final prev = ref.read(previousContentProvider);
            if (prev != null) {
              ref.read(mainContentProvider.notifier).switchTo(prev);
              ref.read(previousContentProvider.notifier).state = null;
            }
          },
        );
      case MainContentType.upcoming:
        return UpcomingEventMobileScreen(
          onBackPressed: () {
            final prev = ref.read(previousContentProvider);
            if (prev != null) {
              ref.read(mainContentProvider.notifier).switchTo(prev);
              ref.read(previousContentProvider.notifier).state = null;
            }
          },
        );
      case MainContentType.leagueDetail:
        return LeagueDetailMobileScreen(
          onBackPressed: () {
            final prev = ref.read(previousContentProvider);
            if (prev != null) {
              ref.read(mainContentProvider.notifier).switchTo(prev);
              ref.read(previousContentProvider.notifier).state = null;
            }
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

Widget _buildMobileContent(MainContentType contentType, WidgetRef ref) {
  switch (contentType) {
    case MainContentType.sport:
      return const SportMobileMainContent();
    case MainContentType.casino:
      return const CasinoScreen(showLiveChat: true);
    case MainContentType.home:
      return const _HomeMobileContent();
    case MainContentType.betDetail:
      return const BetDetailMobileV2Screen();
    case MainContentType.sportDetail:
      return const _SportDetailMobileContent();
    case MainContentType.sun247:
      return const Sun247Desktop();
    case MainContentType.tournaments:
      return TopLeagueMobileScreen(
        onBackPressed: () {
          final prev = ref.read(previousContentProvider);
          if (prev != null) {
            ref.read(mainContentProvider.notifier).switchTo(prev);
            ref.read(previousContentProvider.notifier).state = null;
          }
        },
      );
    case MainContentType.live:
      return LiveEventMobileScreen(
        onBackPressed: () {
          final prev = ref.read(previousContentProvider);
          if (prev != null) {
            ref.read(mainContentProvider.notifier).switchTo(prev);
            ref.read(previousContentProvider.notifier).state = null;
          }
        },
      );
    case MainContentType.upcoming:
      return UpcomingEventMobileScreen(
        onBackPressed: () {
          final prev = ref.read(previousContentProvider);
          if (prev != null) {
            ref.read(mainContentProvider.notifier).switchTo(prev);
            ref.read(previousContentProvider.notifier).state = null;
          }
        },
      );
    case MainContentType.leagueDetail:
      return LeagueDetailMobileScreen(
        onBackPressed: () {
          final prev = ref.read(previousContentProvider);
          if (prev != null) {
            ref.read(mainContentProvider.notifier).switchTo(prev);
            ref.read(previousContentProvider.notifier).state = null;
          }
        },
      );
    default:
      return const SizedBox.shrink();
  }
}

class _SportDetailMobileContent extends ConsumerWidget {
  const _SportDetailMobileContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) => SportDetailMobileScreen(
    onBackPressed: () {
      final previousContent = ref.read(previousContentProvider);
      if (previousContent == MainContentType.home) {
        ref.read(mainContentProvider.notifier).goToHome();
      } else {
        ref.read(mainContentProvider.notifier).goToSport();
      }
      ref.read(previousContentProvider.notifier).state = null;
    },
  );
}

class _HomeDesktopContent extends ConsumerStatefulWidget {
  const _HomeDesktopContent();

  @override
  ConsumerState<_HomeDesktopContent> createState() =>
      _HomeDesktopContentState();
}

class _HomeDesktopContentState extends ConsumerState<_HomeDesktopContent> {
  double _cacheExtent = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _cacheExtent = 3000);
    });
  }

  @override
  Widget build(BuildContext context) {
    final sections = <Widget>[
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
      const Gap(12),
      const HomeDesktopBannerSection(),
      const Gap(12),
      const GameGroupView.liveCasino(),
    ];

    return Container(
      alignment: Alignment.topCenter,
      margin: const EdgeInsets.only(top: AppSpacingStyles.space300),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacingStyles.space800,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1140, minWidth: 960),
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: ListView.builder(
            cacheExtent: _cacheExtent,
            padding: EdgeInsets.zero,
            itemCount: sections.length,
            itemBuilder: (context, index) => sections[index],
          ),
        ),
      ),
    );
  }
}

class _HomeTabletContent extends StatelessWidget {
  const _HomeTabletContent();

  @override
  Widget build(BuildContext context) {
    return const HomeTabletContent();
  }
}

class _HomeMobileContent extends StatelessWidget {
  const _HomeMobileContent();

  @override
  Widget build(BuildContext context) {
    return const HomeMobileContent();
  }
}
