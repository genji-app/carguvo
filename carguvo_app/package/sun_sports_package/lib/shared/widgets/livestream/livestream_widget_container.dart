import 'package:flutter/material.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/features/bet_detail/presentation/desktop/widgets/statistics_table_basketball.dart';
import 'package:sun_sports/features/bet_detail/presentation/desktop/widgets/statistics_table_tennis.dart';
import 'package:sun_sports/features/bet_detail/presentation/desktop/widgets/statistics_table_volleyball.dart';
import 'package:sun_sports/features/bet_detail/presentation/desktop/widgets/statistics_table_badminton.dart';
import 'package:sun_sports/features/bet_detail/presentation/mobile/widgets/mobile_statistics_table_widget.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/livestream/pip_manager.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/sport/match/match_notice_rive_animation.dart';

class LivestreamWidgetContainer extends StatelessWidget {
  final String url;

  final LeagueEventData? eventData;

  final int sportId;

  final Widget? webViewContent;

  final String placeholderMessage;

  final bool isInitialized;
  final bool isLoading;
  final bool hasError;
  final VoidCallback? onPiPActivated;
  final Widget Function(String)? buildErrorOverlay;

  final MatchNoticeOverlayData? notice;

  static const double statisticsOverlayHeight = 130.0;

  const LivestreamWidgetContainer({
    super.key,
    required this.url,
    this.eventData,
    this.sportId = 1,
    this.webViewContent,
    this.placeholderMessage = 'Không có link livestream',
    this.isInitialized = false,
    this.isLoading = false,
    this.hasError = false,
    this.onPiPActivated,
    this.buildErrorOverlay,
    this.notice,
  });

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return _buildPlaceholder(context, placeholderMessage);
    }

    final pip = PipManager();
    pip.setOverlayControlsBuilder(_buildPiPOverlayControls);

    final screenWidth = MediaQuery.sizeOf(context).width;
    final contentHeight = screenWidth * 9 / 16;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      ),
      clipBehavior: Clip.hardEdge,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        color: const Color(0xFF000000),
        clipBehavior: Clip.hardEdge,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (eventData != null) _buildStatisticsOverlay(),
            RepaintBoundary(
              child: SizedBox(
                height: contentHeight,
                child: _buildContentStack(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context, String message) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final contentHeight = screenWidth * 9 / 16;
    final totalHeight = eventData != null
        ? statisticsOverlayHeight + contentHeight
        : contentHeight;

    return Container(
      height: totalHeight,
      decoration: const BoxDecoration(
        color: Color(0xFF000000),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.live_tv, color: Color(0xFF666666), size: 48),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppTextStyles.paragraphXSmall(
                color: const Color(0xFF888888),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPiPOverlayControls(BuildContext context) {
    final pip = PipManager();
    return Container(
      color: AppColors.gray700,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: SoundTap.wrap(pip.requestFullscreen),
            child: ImageHelper.load(
              path: AppIcons.iconVideoFull,
              width: 32,
              height: 32,
            ),
          ),
          GestureDetector(
            onTap: SoundTap.wrap(() => pip.closePiP(userInitiated: true)),
            child: ImageHelper.load(
              path: AppIcons.iconClosePip,
              width: 32,
              height: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsOverlay() {
    if (eventData == null) return const SizedBox.shrink();

    const pulseAnimation = AlwaysStoppedAnimation<double>(1.0);

    return switch (sportId) {
      2 => StatisticsTableBasketball(
        eventData: eventData!,
        pulseAnimation: pulseAnimation,
        isDesktop: false,
      ),
      4 => StatisticsTableTennis(
        eventData: eventData!,
        pulseAnimation: pulseAnimation,
        isDesktop: false,
      ),
      5 => StatisticsTableVolleyball(
        eventData: eventData!,
        pulseAnimation: pulseAnimation,
        isDesktop: false,
      ),
      7 => StatisticsTableBadminton(
        eventData: eventData!,
        pulseAnimation: pulseAnimation,
        isDesktop: false,
      ),
      _ => MobileStatisticsTableWidget(
        eventData: eventData!,
        hideBottomBorderRadius: true,
        homeNotice: notice?.homeNotice,
        awayNotice: notice?.awayNotice,
        homeNoticeSeq: notice?.homeNoticeSeq ?? 0,
        awayNoticeSeq: notice?.awayNoticeSeq ?? 0,
        onHomeNoticeCompleted: notice?.onHomeNoticeCompleted,
        onAwayNoticeCompleted: notice?.onAwayNoticeCompleted,
      ),
    };
  }

  Widget _buildContentStack(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final containerWidth = constraints.maxWidth;
        final contentHeight = constraints.maxHeight;
        final pip = PipManager();
        final showEmbeddedPiP = pip.isPiPMode && !pip.isLiftedToOverlay;

        return Stack(
          children: [
            if (isInitialized && webViewContent != null)
              Positioned.fill(
                child: SizedBox(
                  width: containerWidth,
                  height: contentHeight,
                  child: webViewContent!,
                ),
              ),
            if (isLoading) _buildLoadingOverlay(),
            if (hasError && buildErrorOverlay != null)
              Positioned.fill(
                child: buildErrorOverlay!('Không thể tải livestream'),
              ),
            if (showEmbeddedPiP)
              Positioned(
                right: 12,
                bottom: 12,
                child: pip.buildEmbeddedPiP(
                  context,
                  containerWidth: containerWidth,
                ),
              ),
          ],
        );
      },
    );
  }

  static const Color _loadingColor = Color(0xFFFFD700);
  static const Color _loadingTextColor = Color(0xFFFFFCDB);

  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        color: const Color(0xFF000000),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: _loadingColor,
                strokeWidth: 2,
              ),
              const SizedBox(height: 12),
              Text(
                'Đang tải...',
                style: AppTextStyles.paragraphXSmall(color: _loadingTextColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
