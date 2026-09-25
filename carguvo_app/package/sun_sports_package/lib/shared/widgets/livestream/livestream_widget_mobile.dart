import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:sun_sports/shared/widgets/livestream/pip_manager.dart';
import 'package:sun_sports/shared/widgets/livestream/livestream_widget_container.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
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
  bool _showControls = false;
  Timer? _controlsTimer;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initWebView();
    PipManager().isVideoPlaying.addListener(_onPlayStateChanged);
  }

  void _onPlayStateChanged() {
    if (!mounted) return;
    final isPlaying = PipManager().isVideoPlaying.value;
    if (!isPlaying) {
    } else {
    }
  }

  @override
  void didUpdateWidget(LivestreamWidgetImpl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _initWebView();
    }
    if (PipManager().isPiPMode) {
      PipManager().closePiP();
    }
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    PipManager().isVideoPlaying.removeListener(_onPlayStateChanged);
    if (!PipManager().isPiPMode) {
      PipManager().releaseWebView();
      PipManager().hidePiP();
    }
    super.dispose();
  }

  void _initWebView() {
    if (widget.url.isEmpty) return;
    PipManager().initialize(
      context,
      onClose: _onPipClose,
      onPiPModeChanged: (_) {
        if (!mounted) return;
        try {
          setState(() {});
        } catch (_) {}
      },
    );
    PipManager().loadUrl(widget.url, context, eventId: widget.eventData?.eventId);
    if (mounted) setState(() {});
  }

  void _onPipClose() {
    if (!mounted) return;
    try {
      setState(() {});
    } catch (_) {}

  }

  void _showControlsWithAutoHide() {
  }

  void _hideControls() {
    _controlsTimer?.cancel();
    setState(() {
      _showControls = false;
    });
  }

  void _onPiPActivated(BuildContext context) {
    final pip = PipManager();
    pip.setOnVideoPage(true);
    pip.showPiP();
    pip.liftToOverlay(context);
    _hideControls();
    widget.onPiPActivated?.call();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final pip = PipManager();
    final controller = pip.webViewController;
    final isInitialized = controller != null;
    final isPiPMode = pip.isPiPMode;

    Widget? content;
    if (!isPiPMode && controller != null) {
      content = WebViewWidget(
        controller: controller,
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
          Factory<VerticalDragGestureRecognizer>(
            () => VerticalDragGestureRecognizer(),
          ),
          Factory<HorizontalDragGestureRecognizer>(
            () => HorizontalDragGestureRecognizer(),
          ),
          Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
        },
      );
    }

    return LivestreamWidgetContainer(
      url: widget.url,
      eventData: widget.eventData,
      sportId: widget.sportId,
      webViewContent: content,
      isInitialized: isInitialized,
      isLoading: !isInitialized,
      hasError: false,
      onPiPActivated: () => _onPiPActivated(context),
      notice: widget.notice,
    );
  }
}
