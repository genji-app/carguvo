part of 'network_asset.dart';

class _SvgNetworkWidget extends StatefulWidget {
  final AssetCacheController controller;
  final String url;
  final double? width;
  final double? height;
  final Color? color;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final int maxRetries;

  const _SvgNetworkWidget({
    required this.controller,
    required this.url,
    required this.maxRetries,
    this.width,
    this.height,
    this.color,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  State<_SvgNetworkWidget> createState() => _SvgNetworkWidgetState();
}

class _SvgNetworkWidgetState extends State<_SvgNetworkWidget>
    with _NetworkRetryMixin, LoggerMixin {
  @override
  String get logTag => 'GameAssetCache';
  static final Map<String, String> _svgCache = {};

  static final Map<String, Future<String>> _inFlight = {};

  String? _svgString;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadSvg();
  }

  @override
  void didUpdateWidget(covariant _SvgNetworkWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      resetRetry();
      _loadSvg();
    }
  }

  void _loadSvg() async {
    if (!mounted) return;
    final cacheKey = widget.url.trim();

    if (_svgCache.containsKey(cacheKey)) {
      setState(() {
        _svgString = _svgCache[cacheKey];
        _isLoading = false;
        _hasError = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final storedSvg = await widget.controller.assetStorage.read(cacheKey);
      if (storedSvg != null && storedSvg.isNotEmpty) {
        _svgCache[cacheKey] = storedSvg;
        if (mounted) {
          setState(() {
            _svgString = storedSvg;
            _isLoading = false;
          });
        }
        return;
      }
    } catch (_) {
    }

    _fetchWithRetryAndDedup(cacheKey);
  }

  void _fetchWithRetryAndDedup(String cacheKey) {
    if (retryTimer?.isActive ?? false) return;

    Future<String> fetchFuture;

    if (_inFlight.containsKey(cacheKey)) {
      fetchFuture = _inFlight[cacheKey]!;
    } else {
      fetchFuture = _executeHttpFetch(cacheKey);
      _inFlight[cacheKey] = fetchFuture;
    }

    fetchFuture
        .then((body) {
          _inFlight.remove(cacheKey);
          _svgCache[cacheKey] = body;
          if (mounted) {
            setState(() {
              _svgString = body;
              _isLoading = false;
            });
          }
          widget.controller.assetStorage.write(cacheKey, body);
        })
        .catchError((Object error, StackTrace stackTrace) {
          _inFlight.remove(cacheKey);
          logError('SVG fetch failed for URL: $cacheKey', error, stackTrace);
          if (mounted) {
            _handleFailure(cacheKey);
          }
        });
  }

  Future<String> _executeHttpFetch(String cacheKey) async {
    await widget.controller.requestSemaphore.acquire();
    try {
      final response = await http
          .get(Uri.parse(cacheKey))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return response.body;
      } else {
        throw Exception('SVG request returned code ${response.statusCode}');
      }
    } finally {
      widget.controller.requestSemaphore.release();
    }
  }

  void _handleFailure(String cacheKey) {
    scheduleRetry(
      maxRetries: widget.maxRetries,
      onRetry: () => _fetchWithRetryAndDedup(cacheKey),
      onMaxRetriesReached: () {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasError = true;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _NetworkPlaceholder(
        placeholder: widget.placeholder,
        width: widget.width,
        height: widget.height,
      );
    }

    if (_hasError || _svgString == null) {
      return _NetworkErrorWidget(
        errorWidget: widget.errorWidget,
        width: widget.width,
        height: widget.height,
      );
    }

    return _NetworkFadeIn(
      child: svg.SvgPicture.string(
        _svgString!,
        width: widget.width,
        height: widget.height,
        colorFilter: widget.color != null
            ? ColorFilter.mode(widget.color!, BlendMode.srcIn)
            : null,
        fit: widget.fit,
        placeholderBuilder: (context) => _NetworkPlaceholder(
          placeholder: widget.placeholder,
          width: widget.width,
          height: widget.height,
        ),
      ),
    );
  }
}
