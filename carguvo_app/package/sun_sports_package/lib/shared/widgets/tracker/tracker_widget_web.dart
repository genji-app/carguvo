import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:sun_sports/core/services/config/sb_config.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/services/network/sb_http_manager.dart';
import 'package:sun_sports/shared/widgets/livestream/livestream_overlay_blocker.dart';
import 'package:sun_sports/shared/widgets/livestream/web_iframe_view.dart';

class TrackerWidgetImpl extends StatefulWidget {
  final int eventStatsId;
  final int sportId;
  final double height;
  final double borderRadius;
  final bool hidden;
  final bool ignoreOverlayBlock;

  const TrackerWidgetImpl({
    super.key,
    required this.eventStatsId,
    required this.sportId,
    this.height = 200,
    this.borderRadius = 0,
    this.hidden = false,
    this.ignoreOverlayBlock = false,
  });

  @override
  State<TrackerWidgetImpl> createState() => _TrackerWidgetImplState();
}

class _TrackerWidgetImplState extends State<TrackerWidgetImpl> {
  html.IFrameElement? _iframe;

  @override
  void initState() {
    super.initState();
    livestreamOverlayBlockedNotifier.addListener(_applyPointerAndVisibility);
  }

  @override
  void didUpdateWidget(TrackerWidgetImpl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hidden != widget.hidden) {
      _applyPointerAndVisibility();
    }
  }

  @override
  void dispose() {
    livestreamOverlayBlockedNotifier.removeListener(_applyPointerAndVisibility);
    _iframe = null;
    super.dispose();
  }

  void _onIframeCreated(html.IFrameElement iframe) {
    _iframe = iframe;
    _applyPointerAndVisibility();
  }

  void _applyPointerAndVisibility() {
    if (!mounted) return;
    final iframe = _iframe;
    if (iframe == null) return;
    final overlayBlocked = widget.ignoreOverlayBlock
        ? false
        : livestreamOverlayBlockedNotifier.value;
    iframe.style.pointerEvents = overlayBlocked ? 'none' : 'auto';
    iframe.style.visibility = widget.hidden ? 'hidden' : 'visible';
  }

  String _buildTrackerUrl() {
    final http = SbHttpManager.instance;
    final urlStatistics = http.urlStatistics;
    final token = http.userTokenSb;
    final agentId = SbConfig.agentId;

    return '$urlStatistics/?token=$token&agentId=$agentId&lng=vi&sportId=${widget.sportId}&route=8&m=${widget.eventStatsId}';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.eventStatsId == 0) {
      return _buildPlaceholder('Không có dữ liệu tracker');
    }

    return SizedBox(
      height: widget.height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: WebIframeView(
          src: _buildTrackerUrl(),
          allow: 'autoplay; encrypted-media; fullscreen',
          borderRadiusCss:
              widget.borderRadius > 0 ? '${widget.borderRadius}px' : '',
          onElementCreated: _onIframeCreated,
        ),
      ),
    );
  }

  Widget _buildPlaceholder(String message) => Container(
    height: widget.height,
    decoration: BoxDecoration(
      color: const Color(0xFF1A1A1A),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.sports_soccer, color: Color(0xFF666666), size: 48),
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
