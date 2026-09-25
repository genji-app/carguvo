import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:sun_sports/core/services/config/sb_config.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/services/network/sb_http_manager.dart';
import 'package:sun_sports/shared/widgets/livestream/livestream_overlay_blocker.dart';
import 'package:sun_sports/shared/widgets/livestream/web_iframe_view.dart';

class StatsWidgetImpl extends StatefulWidget {
  final int eventStatsId;
  final int sportId;
  final double? height;
  final double? width;

  final bool ignoreOverlayBlock;

  const StatsWidgetImpl({
    super.key,
    required this.eventStatsId,
    required this.sportId,
    this.height,
    this.width,
    this.ignoreOverlayBlock = false,
  });

  @override
  State<StatsWidgetImpl> createState() => _StatsWidgetImplState();
}

class _StatsWidgetImplState extends State<StatsWidgetImpl> {
  html.IFrameElement? _iframe;

  @override
  void initState() {
    super.initState();
    livestreamOverlayBlockedNotifier.addListener(_applyPointerEvents);
  }

  @override
  void dispose() {
    livestreamOverlayBlockedNotifier.removeListener(_applyPointerEvents);
    _iframe = null;
    super.dispose();
  }

  void _onIframeCreated(html.IFrameElement iframe) {
    _iframe = iframe;
    _applyPointerEvents();
  }

  void _applyPointerEvents() {
    if (!mounted) return;
    final overlayBlocked = widget.ignoreOverlayBlock
        ? false
        : livestreamOverlayBlockedNotifier.value;
    _iframe?.style.pointerEvents = overlayBlocked ? 'none' : 'auto';
  }

  String _buildStatsUrl() {
    final http = SbHttpManager.instance;
    final urlStatistics = http.urlStatistics;
    final token = http.userTokenSb;
    final agentId = SbConfig.agentId;

    return '$urlStatistics/?token=$token&agentId=$agentId&lng=vi&sportId=${widget.sportId}&route=6&m=${widget.eventStatsId}';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.eventStatsId == 0) {
      return _buildPlaceholder('Không có dữ liệu thống kê');
    }

    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: ColoredBox(
        color: const Color(0xFF1A1A1A),
        child: WebIframeView(
          src: _buildStatsUrl(),
          allow: 'autoplay; encrypted-media',
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
          const Icon(Icons.bar_chart, color: Color(0xFF666666), size: 48),
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
