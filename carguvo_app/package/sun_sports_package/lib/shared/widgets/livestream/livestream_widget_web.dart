import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/bet_detail/presentation/desktop/widgets/statistics_table_basketball.dart';
import 'package:sun_sports/features/bet_detail/presentation/desktop/widgets/statistics_table_tennis.dart';
import 'package:sun_sports/features/bet_detail/presentation/desktop/widgets/statistics_table_volleyball.dart';
import 'package:sun_sports/features/bet_detail/presentation/desktop/widgets/statistics_table_badminton.dart';
import 'package:sun_sports/features/bet_detail/presentation/mobile/widgets/mobile_statistics_table_widget.dart';
import 'package:sun_sports/shared/widgets/livestream/livestream_iframe_interaction.dart';
import 'package:sun_sports/shared/widgets/livestream/livestream_lifecycle.dart';
import 'package:sun_sports/shared/widgets/livestream/livestream_overlay_blocker.dart';
import 'package:sun_sports/shared/widgets/livestream/web_iframe_view.dart';
import 'package:sun_sports/shared/widgets/sport/match/match_notice_rive_animation.dart';

class LivestreamWidgetImpl extends StatefulWidget {
  final String url;
  final LeagueEventData? eventData;
  final int sportId;
  final VoidCallback? onPiPActivated;
  final MatchNoticeOverlayData? notice;

  const LivestreamWidgetImpl({
    super.key,
    required this.url,
    this.eventData,
    this.sportId = 1,
    this.onPiPActivated,
    this.notice,
  });

  @override
  State<LivestreamWidgetImpl> createState() => _LivestreamWidgetImplState();
}

class _LivestreamWidgetImplState extends State<LivestreamWidgetImpl>
    with AutomaticKeepAliveClientMixin {
  html.IFrameElement? _iframe;
  bool _hasError = false;
  bool _isPiPMode = false;
  html.EventListener? _messageListener;

  String? _pausedSrc;

  static const String _blankSrc = 'about:blank';

  late final LivestreamIframeInteraction _interaction =
      LivestreamIframeInteraction(iframeProvider: () => _iframe);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if (widget.url.isEmpty) _hasError = true;

    _setupMessageListener();
    livestreamTabHiddenNotifier.addListener(_onTabHiddenChanged);
    livestreamOverlayBlockedNotifier.addListener(_onOverlayBlockedChanged);
    debugPrint(
      '[Livestream Web] initState: listener added. '
      'notifier.value=${livestreamTabHiddenNotifier.value} url=${widget.url}',
    );
  }

  @override
  void dispose() {
    debugPrint('[Livestream Web] dispose: removing listeners.');
    livestreamTabHiddenNotifier.removeListener(_onTabHiddenChanged);
    livestreamOverlayBlockedNotifier.removeListener(_onOverlayBlockedChanged);
    _removeMessageListener();
    _interaction.dispose();
    _iframe = null;
    super.dispose();
  }

  void _onIframeCreated(html.IFrameElement iframe) {
    _iframe = iframe;
    _interaction.applyDefault(iframe);
    iframe.onError.listen((_) {
      if (mounted) setState(() => _hasError = true);
    });
    if (livestreamTabHiddenNotifier.value) _pauseStream();
    _applyVisibility();
  }

  void _onTabHiddenChanged() {
    if (!mounted) return;
    final isHidden = livestreamTabHiddenNotifier.value;
    debugPrint(
      '[Livestream Web] tab hidden=$isHidden → '
      '${isHidden ? "stop" : "reload"} stream',
    );
    if (isHidden) {
      _pauseStream();
    } else {
      _resumeStream();
    }
  }

  void _pauseStream() {
    final iframe = _iframe;
    if (iframe == null) return;
    if (_pausedSrc != null) return;
    _pausedSrc = widget.url;
    iframe.src = _blankSrc;
    _interaction.deactivate();
  }

  void _resumeStream() {
    final iframe = _iframe;
    if (iframe == null) return;
    final pausedSrc = _pausedSrc;
    if (pausedSrc == null) return;
    iframe.src = pausedSrc;
    _pausedSrc = null;
  }

  void _onOverlayBlockedChanged() {
    if (!mounted) return;
    if (livestreamOverlayBlockedNotifier.value) _interaction.deactivate();
  }

  @override
  void didUpdateWidget(LivestreamWidgetImpl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _hasError = widget.url.isEmpty;
      _pausedSrc = null;
      _interaction.deactivate();
    }

    if (_isPiPMode) {
      setState(() => _isPiPMode = false);
      _applyVisibility();
    }
  }

  void _applyVisibility() {
    _iframe?.style.visibility = _isPiPMode ? 'hidden' : 'visible';
    if (_isPiPMode) _interaction.deactivate();
  }

  void _setupMessageListener() {
    _messageListener = (html.Event event) {
      if (event is html.MessageEvent) {
        debugPrint(
          '📨 Message from IFrame: ${event.data}, origin: ${event.origin}',
        );
        _handleMessageFromIFrame(event);
      }
    };
    html.window.addEventListener('message', _messageListener);
  }

  void _removeMessageListener() {
    if (_messageListener != null) {
      html.window.removeEventListener('message', _messageListener);
      _messageListener = null;
    }
  }

  void _handleMessageFromIFrame(html.MessageEvent event) {
    if (!mounted) return;

    try {
      final data = event.data;
      debugPrint('📨 Parsing message data: $data (type: ${data.runtimeType})');

      if (data is Map) {
        final type = data['type'] ?? data['event'] ?? '';
        final action = data['action'] ?? '';

        debugPrint('📨 Message type: $type, action: $action');

        if (type.toString().toLowerCase().contains('pip') ||
            type.toString().toLowerCase().contains('picture-in-picture') ||
            action.toString().toLowerCase().contains('pip')) {
          debugPrint('✅ PiP event detected from message!');
          _handlePiPActivated();
        }
      } else if (data is String) {
        final lowerData = data.toLowerCase();
        debugPrint('📨 Message string: $lowerData');
        if (lowerData.contains('pip') ||
            lowerData.contains('picture-in-picture') ||
            lowerData.contains('enterpictureinpicture')) {
          debugPrint('✅ PiP event detected from string message!');
          _handlePiPActivated();
        }
      }
    } catch (e) {
      debugPrint('❌ Error parsing message: $e');
    }
  }

  void _handlePiPActivated() {
    if (!mounted) return;

    debugPrint('🎬 _handlePiPActivated called - switching to scoreboard tab');

    setState(() {
      _isPiPMode = true;
    });
    _applyVisibility();

    if (widget.onPiPActivated != null) {
      debugPrint('✅ Calling onPiPActivated callback');
      widget.onPiPActivated!();
    } else {
      debugPrint('⚠️ onPiPActivated callback is null!');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.url.isEmpty) {
      return _buildPlaceholder(context);
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final videoPlayerHeight = screenWidth * 9 / 16;

    return SizedBox(
      width: double.infinity,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        color: const Color(0xFF000000),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.eventData != null) _buildStatisticsOverlay(),
            SizedBox(
              width: double.infinity,
              height: videoPlayerHeight,
              child: _buildVideoPlayerStack(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final videoPlayerHeight = screenWidth * 9 / 16;
    final totalHeight = widget.eventData != null
        ? 130.0 +
              videoPlayerHeight
        : videoPlayerHeight;

    return Container(
      width: double.infinity,
      height: totalHeight,
      decoration: const BoxDecoration(color: Color(0xFF000000)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.live_tv, color: Color(0xFF666666), size: 48),
            const SizedBox(height: 12),
            Text(
              'Không có link livestream',
              style: AppTextStyles.paragraphXSmall(
                color: const Color(0xFF888888),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsOverlay() {
    if (widget.eventData == null) return const SizedBox.shrink();

    const pulseAnimation = AlwaysStoppedAnimation<double>(1.0);

    return switch (widget.sportId) {
      2 => StatisticsTableBasketball(
        eventData: widget.eventData!,
        pulseAnimation: pulseAnimation,
        isDesktop: false,
      ),
      4 => StatisticsTableTennis(
        eventData: widget.eventData!,
        pulseAnimation: pulseAnimation,
        isDesktop: false,
      ),
      5 => StatisticsTableVolleyball(
        eventData: widget.eventData!,
        pulseAnimation: pulseAnimation,
        isDesktop: false,
      ),
      7 => StatisticsTableBadminton(
        eventData: widget.eventData!,
        pulseAnimation: pulseAnimation,
        isDesktop: false,
      ),
      _ => MobileStatisticsTableWidget(
        eventData: widget.eventData!,
        hideBottomBorderRadius: true,
        homeNotice: widget.notice?.homeNotice,
        awayNotice: widget.notice?.awayNotice,
        homeNoticeSeq: widget.notice?.homeNoticeSeq ?? 0,
        awayNoticeSeq: widget.notice?.awayNoticeSeq ?? 0,
        onHomeNoticeCompleted: widget.notice?.onHomeNoticeCompleted,
        onAwayNoticeCompleted: widget.notice?.onAwayNoticeCompleted,
      ),
    };
  }

  Widget _buildVideoPlayerStack() {
    if (_hasError) {
      return _buildErrorOverlay('Không thể tải livestream');
    }
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (event) => _interaction.onSlotPointerDown(event.position),
      onPointerMove: (event) => _interaction.onSlotPointerMove(event.position),
      onPointerUp: (_) => _interaction.onSlotPointerUp(),
      onPointerCancel: (_) => _interaction.onSlotPointerCancel(),
      child: ColoredBox(
        color: const Color(0xFF000000),
        child: WebIframeView(
          src: widget.url,
          allow: 'autoplay; encrypted-media; picture-in-picture; fullscreen',
          startPointerEventsNone: true,
          onElementCreated: _onIframeCreated,
        ),
      ),
    );
  }

  Widget _buildErrorOverlay(String message) => Container(
    color: const Color(0xFF000000),
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
