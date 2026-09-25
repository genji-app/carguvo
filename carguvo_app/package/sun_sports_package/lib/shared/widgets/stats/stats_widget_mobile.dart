import 'package:flutter/foundation.dart' show Factory;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sun_sports/core/services/config/sb_config.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/services/network/sb_http_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
  late WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  @override
  void didUpdateWidget(StatsWidgetImpl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.eventStatsId != widget.eventStatsId) {
      _initializeWebView();
    }
  }

  void _initializeWebView() {
    final statsUrl = _buildStatsUrl();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF1A1A1A))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _hasError = false;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _hasError = true;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(statsUrl));
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: widget.height,
        width: widget.width,
        color: const Color(0xFF1A1A1A),
        child: Stack(
          children: [
            Positioned.fill(
              child: WebViewWidget(
                controller: _controller,
                gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{
                  Factory<VerticalDragGestureRecognizer>(
                    VerticalDragGestureRecognizer.new,
                  ),
                  Factory<HorizontalDragGestureRecognizer>(
                    HorizontalDragGestureRecognizer.new,
                  ),
                  Factory<ScaleGestureRecognizer>(
                    ScaleGestureRecognizer.new,
                  ),
                },
              ),
            ),
            if (_isLoading)
              Container(
                color: const Color(0xFF1A1A1A),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Color(0xFFFFD700),
                        strokeWidth: 2,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Đang tải thống kê...',
                        style: AppTextStyles.paragraphXSmall(
                          color: const Color(0xFFFFFCDB),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_hasError) _buildPlaceholder('Không thể tải thống kê'),
          ],
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
