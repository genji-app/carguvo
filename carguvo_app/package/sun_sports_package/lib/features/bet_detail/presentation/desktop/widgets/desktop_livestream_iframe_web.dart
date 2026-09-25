import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/livestream/livestream_iframe_interaction.dart';
import 'package:sun_sports/shared/widgets/livestream/livestream_lifecycle.dart';
import 'package:sun_sports/shared/widgets/livestream/livestream_overlay_blocker.dart';
import 'package:sun_sports/shared/widgets/livestream/web_iframe_view.dart';

class DesktopLivestreamIframe extends StatefulWidget {
  final String url;

  final bool roundedTop;

  const DesktopLivestreamIframe({
    required this.url,
    this.roundedTop = true,
    super.key,
  });

  @override
  State<DesktopLivestreamIframe> createState() =>
      _DesktopLivestreamIframeState();
}

class _DesktopLivestreamIframeState extends State<DesktopLivestreamIframe>
    with AutomaticKeepAliveClientMixin {
  html.IFrameElement? _iframe;
  bool _hasError = false;

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

    livestreamTabHiddenNotifier.addListener(_onTabHiddenChanged);
    livestreamOverlayBlockedNotifier.addListener(_onOverlayBlockedChanged);

    debugPrint(
      '[Desktop Livestream] initState: '
      'tabHidden=${livestreamTabHiddenNotifier.value} url=${widget.url}',
    );
  }

  @override
  void didUpdateWidget(DesktopLivestreamIframe oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _hasError = widget.url.isEmpty;
      _pausedSrc = null;
      _interaction.deactivate();
    }
  }

  @override
  void dispose() {
    livestreamTabHiddenNotifier.removeListener(_onTabHiddenChanged);
    livestreamOverlayBlockedNotifier.removeListener(_onOverlayBlockedChanged);
    _interaction.dispose();
    _iframe = null;
    super.dispose();
  }

  void _onIframeCreated(html.IFrameElement iframe) {
    _iframe = iframe;
    _interaction.applyDefault(iframe);

    debugPrint('[LS-FLOW] 5. iframe created, src=${iframe.src}');

    iframe.onLoad.listen((_) {
      debugPrint('[LS-FLOW] 6. iframe onLoad OK (trang player đã tải)');
    });

    iframe.onError.listen((_) {
      debugPrint('[LS-FLOW] X. iframe onError → _hasError=true');
      if (mounted) setState(() => _hasError = true);
    });

    if (livestreamTabHiddenNotifier.value) {
      _pausedSrc = widget.url;
      iframe.src = _blankSrc;
    }
  }

  void _onTabHiddenChanged() {
    if (!mounted) return;
    final hidden = livestreamTabHiddenNotifier.value;
    debugPrint(
      '[Desktop Livestream] tab hidden=$hidden → '
      '${hidden ? "STOP stream" : "RESUME stream"}',
    );

    final iframe = _iframe;
    if (iframe == null) return;

    if (hidden) {
      if (_pausedSrc != null) return;
      _pausedSrc = widget.url;
      iframe.src = _blankSrc;
      _interaction.deactivate();
    } else {
      final pausedSrc = _pausedSrc;
      if (pausedSrc == null) return;
      iframe.src = pausedSrc;
      _pausedSrc = null;
    }
  }

  void _onOverlayBlockedChanged() {
    if (!mounted) return;
    if (livestreamOverlayBlockedNotifier.value) _interaction.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_hasError) {
      return _buildPlaceholder('Không thể tải livestream');
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (event) =>
            _interaction.onSlotPointerDown(event.position),
        onPointerMove: (event) =>
            _interaction.onSlotPointerMove(event.position),
        onPointerUp: (_) => _interaction.onSlotPointerUp(),
        onPointerCancel: (_) => _interaction.onSlotPointerCancel(),
        child: ColoredBox(
          color: const Color(0xFF1A1A1A),
          child: WebIframeView(
            src: widget.url,
            borderRadiusCss: widget.roundedTop ? '12px 12px 0 0' : '',
            startPointerEventsNone: true,
            onElementCreated: _onIframeCreated,
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(String message) => Container(
    constraints: const BoxConstraints(minHeight: 200),
    decoration: BoxDecoration(
      color: const Color(0xFF1A1A1A),
      borderRadius: widget.roundedTop
          ? const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            )
          : BorderRadius.zero,
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
