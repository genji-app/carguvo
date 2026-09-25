import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/providers/main_content_provider.dart';
import 'package:sun_sports/core/services/models/api_v2/event_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/event_model_v2_extensions.dart'
    show ftHandicapMarketIds;
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/core/services/models/api_v2/v2_to_legacy_adapter.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/features/bet_detail/presentation/providers/detail_swap_guard_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/events_v2_filter_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/league_provider.dart';
import 'package:sun_sports/features/bet_detail/presentation/providers/bet_detail_v2_provider.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/utils/styles/spacing_styles.dart';
import 'package:sun_sports/features/bet_detail/presentation/providers/bet_detail_mobile_v2_provider.dart';
import 'package:sun_sports/shared/widgets/sport/match/match_row_shared_v2.dart'
    show extractCurrentSet;
import 'package:sun_sports/features/bet_detail/presentation/desktop/widgets/match_header_desktop_widget.dart';
import 'package:sun_sports/features/bet_detail/presentation/mobile/widgets/market_drawer_v2_mobile_widget.dart';
import 'package:sun_sports/shared/widgets/cards/inner_shadow_card.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

const Set<PointerDeviceKind> _horizontalDragDevices = {
  PointerDeviceKind.touch,
  PointerDeviceKind.mouse,
  PointerDeviceKind.trackpad,
  PointerDeviceKind.stylus,
  PointerDeviceKind.invertedStylus,
};

class BetDetailDesktopScreen extends ConsumerStatefulWidget {
  const BetDetailDesktopScreen({super.key});

  @override
  ConsumerState<BetDetailDesktopScreen> createState() =>
      _BetDetailDesktopScreenState();
}

class _BetDetailDesktopScreenState
    extends ConsumerState<BetDetailDesktopScreen> {
  late final DetailSwapGuardNotifier _swapGuard;

  @override
  void initState() {
    super.initState();
    _swapGuard = ref.read(detailSwapGuardProvider.notifier);
    _initBetDetail();
  }

  @override
  void dispose() {
    _swapGuard.exitDetail();
    super.dispose();
  }

  void _initBetDetail() {
    if (!mounted) return;

    final selectedEventV2 = ref.read(selectedEventV2Provider);
    final selectedLeagueV2 = ref.read(selectedLeagueV2Provider);
    final sportId =
        selectedLeagueV2?.sportId ?? ref.read(selectedSportV2Provider).id;

    if (selectedEventV2 != null && selectedLeagueV2 != null) {
      final selectedEvent = selectedEventV2.toLegacy();
      final selectedLeague = selectedLeagueV2.toLegacy();
      final currentSet = extractCurrentSet(selectedEventV2) ?? 1;

      _swapGuard.enterDetail(selectedEventV2.eventId);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref
            .read(betDetailMobileV2Provider.notifier)
            .init(
              eventData: selectedEvent,
              leagueData: selectedLeague,
              sportId: sportId,
              currentSet: currentSet,
            );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<EventModelV2?>(selectedEventV2Provider, (previous, next) {
      if (next == null) return;
      if (previous?.eventId == next.eventId) return;
      Future.microtask(_initBetDetail);
    });

    return Container(
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacingStyles.space800,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1140, minWidth: 860),
        child: const _BetDetailContentConsumer(),
      ),
    );
  }
}

class _BetDetailContentConsumer extends ConsumerWidget {
  const _BetDetailContentConsumer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventData = ref.watch(
      betDetailMobileV2Provider.select((state) => state.eventData),
    );
    final leagueData = ref.watch(
      betDetailMobileV2Provider.select((state) => state.leagueData),
    );

    final displayEventData =
        eventData ?? ref.read(selectedEventV2Provider)?.toLegacy();
    final displayLeagueData =
        leagueData ?? ref.read(selectedLeagueV2Provider)?.toLegacy();

    if (displayEventData == null) {
      return Container(
        height: 300,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(color: Color(0xFFFFD700)),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _BetDetailHeader(eventData: displayEventData),
        Expanded(
          child: SizedBox(
            width: 824,
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(
                context,
              ).copyWith(scrollbars: false),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    MatchHeaderDesktopWidget(
                      key: ValueKey(
                        'match-header-${displayEventData.eventId}',
                      ),
                      eventData: displayEventData,
                      leagueData: displayLeagueData,
                      sportId:
                          ref.read(selectedLeagueV2Provider)?.sportId ??
                          ref.read(selectedSportV2Provider).id,
                      isDesktop: true,
                    ),
                    const SizedBox(height: 12),
                    if (eventData != null)
                      _BetTabsConsumer(
                        eventData: displayEventData,
                        leagueData: displayLeagueData,
                      ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BetDetailHeader extends ConsumerWidget {
  final LeagueEventData eventData;

  const _BetDetailHeader({required this.eventData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: const Color(0xFF111111),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: SoundTap.wrap(() {
                ref.read(mainContentProvider.notifier).goBackFromBetDetail();
              }),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1A19),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(5),
                child: const Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: 13,
                    color: AppColorStyles.contentPrimary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1B1A19),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Center(child: _buildTeamNames()),
          ),
        ],
      ),
    );
  }

  double get _ftHandicapPoints {
    for (final market in eventData.markets) {
      if (ftHandicapMarketIds.contains(market.marketId)) {
        return market.mainLineOdds?.pointsValue ?? 0;
      }
    }
    return 0;
  }

  Widget _buildTeamNames() {
    const greyColor = Color(0xFF9C9B95);

    final baseStyle = AppTextStyles.textStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: greyColor,
      height: 20 / 14,
    );

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: eventData.homeName, style: baseStyle),
          const TextSpan(text: ' - '),
          TextSpan(text: eventData.awayName, style: baseStyle),
        ],
      ),
      style: baseStyle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.justify,
    );
  }
}

class _BetTabsConsumer extends StatelessWidget {
  final LeagueEventData eventData;
  final LeagueData? leagueData;

  const _BetTabsConsumer({required this.eventData, required this.leagueData});

  @override
  Widget build(BuildContext context) {
    return InnerShadowCard(
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1B1A19),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _TabsSection(),
            const _MarketGroupSection(),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _DrawersSection(
                eventData: eventData,
                leagueData: leagueData,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabsSection extends ConsumerWidget {
  const _TabsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(
      betDetailMobileV2Provider.select((state) => state.currentFilter),
    );
    final availableTabs = ref.watch(
      betDetailMobileV2Provider.select((state) => state.availableTabs),
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              scrollbars: false,
              dragDevices: _horizontalDragDevices,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: availableTabs.map((tab) {
                  final isSelected = currentFilter == tab.filter;
                  return _TabItem(
                    tab: tab,
                    isSelected: isSelected,
                    onTap: () {
                      ref
                          .read(betDetailMobileV2Provider.notifier)
                          .changeFilter(tab.filter);
                    },
                  );
                }).toList(),
              ),
            ),
          ),
          Container(
            height: 0.5,
            color: const Color(0xFF2A2926),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final BetTabData tab;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: SoundTap.wrap(onTap),
          borderRadius: BorderRadius.circular(1000),
          child: Stack(
            children: [
              if (isSelected)
                Positioned(
                  bottom: 0,
                  left: -10,
                  right: -10,
                  child: ImageHelper.load(
                    path: AppIcons.sportStatusSelected,
                    fit: BoxFit.fill,
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                child: Center(
                  child: Text(
                    tab.label,
                    style: AppTextStyles.textStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? AppColors.yellow300
                          : AppColorStyles.contentTertiary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MarketGroupSection extends ConsumerWidget {
  const _MarketGroupSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(
      betDetailMobileV2Provider.select((s) => s.groupFilterSignature),
    );
    final selectedKey = ref.watch(
      betDetailMobileV2Provider.select((s) => s.marketGroupKey),
    );
    final groups = ref.read(betDetailMobileV2Provider).availableGroups;

    if (groups.length <= 2) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          scrollbars: false,
          dragDevices: _horizontalDragDevices,
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final g in groups)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _MarketGroupChip(
                    label: g.label,
                    isSelected: selectedKey == g.key,
                    onTap: () => ref
                        .read(betDetailMobileV2Provider.notifier)
                        .changeMarketGroup(g.key),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MarketGroupChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _MarketGroupChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: SoundTap.wrap(onTap),
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF252423),
            borderRadius: BorderRadius.circular(1000),
            border: Border.all(
              color: isSelected ? AppColors.yellow300 : Colors.transparent,
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.textStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 20 / 14,
              color: isSelected
                  ? AppColors.yellow300
                  : AppColorStyles.contentTertiary,
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawersSection extends ConsumerWidget {
  final LeagueEventData? eventData;
  final LeagueData? leagueData;

  const _DrawersSection({this.eventData, this.leagueData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drawers = ref.watch(
      betDetailMobileV2Provider.select((state) => state.filteredDrawers),
    );
    final oddsStyle = ref.watch(oddsStyleProvider);

    if (drawers.isEmpty) {
      final isBusy = ref.watch(
        betDetailMobileV2Provider.select((s) => s.isEmptyMarketsBusy),
      );
      if (isBusy) {
        return Container(
          padding: const EdgeInsets.all(24),
          alignment: Alignment.center,
          child: const CircularProgressIndicator(
            color: AppColorStyles.contentPrimary,
          ),
        );
      }
      final emptyText = ref.watch(
        betDetailMobileV2Provider.select((s) => s.emptyMarketsText),
      );
      return Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: Text(
          emptyText,
          style: AppTextStyles.textStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0x80FFFCDB),
          ),
        ),
      );
    }

    return Column(
      children: drawers.asMap().entries.map((entry) {
        final index = entry.key;
        final drawer = entry.value;

        return MarketDrawerV2MobileWidget(
          drawer: drawer,
          oddsStyle: oddsStyle,
          onToggle: () {
            ref.read(betDetailMobileV2Provider.notifier).toggleDrawer(index);
          },
          eventData: eventData,
          leagueData: leagueData,
        );
      }).toList(),
    );
  }
}
