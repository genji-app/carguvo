import 'package:flutter/material.dart';
import 'package:app_package/core/utils/styles/app_text_styles.dart';
import 'package:app_package/core/services/config/sb_config.dart';
import 'package:app_package/core/services/network/sb_http_manager.dart';
import 'package:app_package/shared/widgets/loading/s88_loading.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TrackerWidgetImpl extends StatefulWidget {
  final int eventStatsId;
  final int sportId;
  final double height;
  final double borderRadius;
  final bool hidden;

  final bool ignoreOverlayBlock;

  final double croppedTop;

  const TrackerWidgetImpl({
    super.key,
    required this.eventStatsId,
    required this.sportId,
    this.height = 400,
    this.borderRadius = 0,
    this.hidden = false,
    this.ignoreOverlayBlock = false,
    this.croppedTop = 0,
  });

  @override
  State<TrackerWidgetImpl> createState() => _TrackerWidgetImplState();
}

class _TrackerWidgetImplState extends State<TrackerWidgetImpl> {
  late WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  @override
  void didUpdateWidget(TrackerWidgetImpl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.eventStatsId != widget.eventStatsId) {
      _initializeWebView();
    }
  }

  void _initializeWebView() {
    final trackerUrl = _buildTrackerUrl();

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
      ..loadRequest(Uri.parse(trackerUrl));
  }

  String _buildTrackerUrl() {
    final http = SbHttpManager.instance;
    final urlStatistics = http.urlStatistics;
    final token = http.userTokenSb;
    final agentId = SbConfig.agentId;
    debugPrint('Tracker URL: $urlStatistics/?token=$token&agentId=$agentId&lng=vi&sportId=${widget.sportId}&route=8&m=${widget.eventStatsId}');
    return '$urlStatistics/?token=$token&agentId=$agentId&lng=vi&sportId=${widget.sportId}&route=8&m=${widget.eventStatsId}';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.eventStatsId == 0) {
      return _buildPlaceholder('Không có dữ liệu tracker');
    }

    return Offstage(
      offstage: widget.hidden,
      child: _buildTracker(),
    );
  }

  Widget _buildTracker() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: Container(
        height: widget.height,
        color: const Color(0xFF1A1A1A),
        child: Stack(
          children: [
            Positioned.fill(
              child: WebViewWidget(controller: _controller),
            ),
            if (_isLoading)
              Positioned(
                top: widget.croppedTop,
                left: 0,
                right: 0,
                bottom: 0,
                child: const S88Loading(
                  indicatorSize: 72,
                  backgroundColor: Color(0xFF1A1A1A),
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            if (_hasError)
              Positioned(
                top: widget.croppedTop,
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildPlaceholder('Không thể tải tracker'),
              ),
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
