import 'package:adaptive_overlay/adaptive_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/providers/main_content_provider.dart';
import 'package:sun_sports/core/services/maintenance/sb_maintenance_provider.dart';
import 'package:sun_sports/core/services/models/api_v2/sport_constants.dart';
import 'package:sun_sports/providers/auth_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/league_provider.dart';
import 'package:sun_sports/features/bet_detail/presentation/providers/bet_detail_mobile_v2_provider.dart';
import 'package:sun_sports/features/betting/betting.dart';
import 'package:sun_sports/features/profile_hub/profile_hub_providers.dart';
import 'package:sun_sports/features/sport/presentation/widgets/sport_hot_section.dart';
import 'package:sun_sports/features/sport/presentation/widgets/sport_live_chat.dart';
import 'package:sun_sports/shared/widgets/authenticated_widget.dart';
import 'package:sun_sports/shared/widgets/chat/chat_login_overlay.dart';
import 'package:sun_sports/shared/widgets/tracker/tracker_widget.dart';

class ShellDesktopRightSidebar extends ConsumerWidget {
  const ShellDesktopRightSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentType = ref.watch(mainContentProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final isBetDetail =
        contentType == MainContentType.betDetail && isAuthenticated;
    final isBadminton =
        ref.watch(currentSportIdProvider) == SportType.badminton.id;
    final hideHot =
        contentType == MainContentType.sport ||
        isBetDetail ||
        isBadminton ||
        ref.watch(sbMaintenanceProvider);

    return SizedBox(
      width: 320,
      child: Column(
        children: [
          if (isBetDetail)
            const Padding(
              padding: EdgeInsets.only(
                top: 16,
                left: 12,
                right: 12,
                bottom: 16,
              ),
              child: _BetDetailTrackerSection(),
            ),
          if (!hideHot)
            const Padding(
              padding: EdgeInsets.only(top: 16, left: 12, right: 12),
              child: SportHotSection(isRightSidebar: true),
            ),
          if (!hideHot) const SizedBox(height: 12),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 12, right: 12, bottom: 12, top: 0),
              child: AuthenticatedWidget(
                fallback: ChatLoginOverlay(),
                child: SportLiveChat(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BetDetailTrackerSection extends ConsumerStatefulWidget {
  const _BetDetailTrackerSection();

  @override
  ConsumerState<_BetDetailTrackerSection> createState() =>
      _BetDetailTrackerSectionState();
}

class _BetDetailTrackerSectionState
    extends ConsumerState<_BetDetailTrackerSection> {
  AdaptiveOverlayController? _profileController;
  bool _profileVisible = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = ref.read(profileHubControllerProvider);
    if (controller != _profileController) {
      _profileController?.removeListener(_onProfileChanged);
      _profileController = controller..addListener(_onProfileChanged);
      _profileVisible = controller.isVisible;
    }
  }

  void _onProfileChanged() {
    if (!mounted) return;
    final visible = _profileController?.isVisible ?? false;
    if (visible != _profileVisible) {
      setState(() => _profileVisible = visible);
    }
  }

  @override
  void dispose() {
    _profileController?.removeListener(_onProfileChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventStatsId = ref.watch(
      betDetailMobileV2Provider.select((s) => s.eventData?.eventStatsId ?? 0),
    );
    final isLive = ref.watch(
      betDetailMobileV2Provider.select((s) => s.eventData?.isLive ?? false),
    );
    final sportId = ref.watch(
      betDetailMobileV2Provider.select((s) => s.sportId),
    );
    final myBetVisible = ref.watch(myBetOverlayVisibleProvider);

    if (eventStatsId == 0 || !isLive) return const SizedBox.shrink();

    return TrackerWidget(
      key: ValueKey('sidebar-tracker-$eventStatsId'),
      eventStatsId: eventStatsId,
      sportId: sportId,
      height: 322,
      borderRadius: 12,
      hidden: _profileVisible || myBetVisible,
    );
  }
}
