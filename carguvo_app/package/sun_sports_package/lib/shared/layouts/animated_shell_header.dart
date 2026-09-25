import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/providers/main_content_provider.dart';
import 'package:sun_sports/core/providers/scroll_hide_provider.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/features/bet_detail/presentation/providers/bet_detail_mobile_v2_provider.dart';
import 'package:sun_sports/features/sport_detail/presentation/mobile/widgets/sport_detail_mobile_header.dart';
import 'package:sun_sports/shared/layouts/shell_mobile_header.dart';
import 'package:sun_sports/shared/layouts/shell_scroll_header_bar.dart';
import 'package:sun_sports/shared/layouts/shell_tablet_header.dart';
import 'package:sun_sports/shared/layouts/shell_top_block.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';
import 'package:sun_sports/providers/auth_provider.dart';
import 'package:sun_sports/features/sport/presentation/widgets/sport_live_chat.dart';
import 'package:sun_sports/shared/widgets/chat/chat_guest_lock_strip.dart';

const migratedHeaderContentTypes = {
  MainContentType.home,
  MainContentType.casino,
  MainContentType.sport,
  MainContentType.sportDetail,
  MainContentType.betDetail,
  MainContentType.tournaments,
  MainContentType.live,
  MainContentType.upcoming,
  MainContentType.leagueDetail,
};

final _headerBackActionProvider = Provider<VoidCallback?>((ref) {
  final contentType = ref.watch(mainContentProvider);

  switch (contentType) {
    case MainContentType.sportDetail:
      final previous = ref.read(previousContentProvider);
      final mainNotifier = ref.read(mainContentProvider.notifier);
      return () {
        if (previous == MainContentType.home) {
          mainNotifier.goToHome();
        } else {
          mainNotifier.goToSport();
        }
      };
    case MainContentType.betDetail:
      final betDetailNotifier = ref.read(betDetailMobileV2Provider.notifier);
      final mainNotifier = ref.read(mainContentProvider.notifier);
      return () {
        betDetailNotifier.clear();
        mainNotifier.goBackFromBetDetail();
      };
    case MainContentType.leagueDetail:
      final previous = ref.watch(previousContentProvider);
      if (previous == null) return null;
      final mainNotifier = ref.read(mainContentProvider.notifier);
      final previousNotifier = ref.read(previousContentProvider.notifier);
      return () {
        previousNotifier.state = null;
        mainNotifier.switchTo(previous);
      };
    default:
      return null;
  }
});

class AnimatedShellHeader extends ConsumerWidget {
  const AnimatedShellHeader({super.key});

  static Color _topBarBottomColor(WidgetRef ref, MainContentType content) {
    final detailHeader = switch (content) {
      MainContentType.sportDetail || MainContentType.betDetail => true,
      MainContentType.leagueDetail =>
        ref.watch(_headerBackActionProvider) != null,
      _ => false,
    };
    return detailHeader
        ? AppColorStyles.backgroundPrimary
        : ShellMobileHeader.bottomColor;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentType = ref.watch(mainContentProvider);

    if (!migratedHeaderContentTypes.contains(contentType)) {
      return const SizedBox.shrink();
    }

    final scrollHide = ref.watch(scrollHideProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final hasChat = ShellTopMetrics.hasChat(ref);
    final blockSlide = ShellTopMetrics.blockSlide(hasChat);
    final topBarLift = ScrollHideNotifier.maxOffset - blockSlide;

    return RepaintBoundary(
      child: SizedBox(
        height: ShellTopMetrics.blockHeight(ref),
        child: ClipRect(
          child: ValueListenableBuilder<double>(
            valueListenable: scrollHide.progress,
            builder: (context, progress, child) => Transform.translate(
              offset: Offset(0, -progress * blockSlide),
              child: child,
            ),
            child: Stack(
              children: [
                if (hasChat)
                  Positioned(
                    top:
                        ShellTopMetrics.header - ShellScrollHeaderBar.barHeight,
                    left: 0,
                    right: 0,
                    height: ShellScrollHeaderBar.barHeight,
                    child: ValueListenableBuilder<double>(
                      valueListenable: scrollHide.progress,
                      builder: (context, progress, child) =>
                          Transform.translate(
                            offset: Offset(0, blockSlide * (progress - 1)),
                            child: child,
                          ),
                      child: ShellScrollHeaderBar(
                        progress: scrollHide.progress,
                        showFade: false,
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Column(
                    children: [
                      Expanded(
                        child: ValueListenableBuilder<double>(
                          valueListenable: scrollHide.progress,
                          builder: (context, progress, child) =>
                              Transform.translate(
                                offset: Offset(0, -progress * topBarLift),
                                child: child,
                              ),
                          child: Consumer(
                            builder: (context, ref, _) {
                              final content = ref.watch(mainContentProvider);
                              switch (content) {
                                case MainContentType.home:
                                case MainContentType.casino:
                                case MainContentType.sport:
                                case MainContentType.tournaments:
                                case MainContentType.live:
                                case MainContentType.upcoming:
                                  return ResponsiveBuilder.isMobile(context)
                                      ? const ShellMobileHeader()
                                      : const ShellTabletHeader();
                                case MainContentType.leagueDetail:
                                  final onBackPressed = ref.watch(
                                    _headerBackActionProvider,
                                  );
                                  if (onBackPressed != null) {
                                    return SportDetailMobileHeader(
                                      onBackPressed: onBackPressed,
                                    );
                                  }
                                  return ResponsiveBuilder.isMobile(context)
                                      ? const ShellMobileHeader()
                                      : const ShellTabletHeader();
                                case MainContentType.sportDetail:
                                case MainContentType.betDetail:
                                  final onBackPressed = ref.watch(
                                    _headerBackActionProvider,
                                  );
                                  return SportDetailMobileHeader(
                                    onBackPressed: onBackPressed,
                                  );
                                default:
                                  return const SizedBox.shrink();
                              }
                            },
                          ),
                        ),
                      ),
                      if (ShellTopMetrics.hasChat(ref))
                        SizedBox(
                          height: ShellTopMetrics.chat(ref),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (isAuthenticated)
                                NotificationListener<ScrollMetricsNotification>(
                                  onNotification: (_) => true,
                                  child:
                                      NotificationListener<ScrollNotification>(
                                        onNotification: (_) => true,
                                        child: SportLiveChat(
                                          isMobile: true,
                                          headerColor: _topBarBottomColor(
                                            ref,
                                            contentType,
                                          ),
                                        ),
                                      ),
                                )
                              else
                                ChatGuestLockStrip(
                                  headerColor: _topBarBottomColor(
                                    ref,
                                    contentType,
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
