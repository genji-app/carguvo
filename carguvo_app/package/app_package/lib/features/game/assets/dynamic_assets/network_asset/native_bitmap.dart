part of 'network_asset.dart';

class _NativeBitmap extends StatefulWidget {
  final AssetCacheController controller;
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? color;
  final Widget? placeholder;
  final Widget? errorWidget;
  final int maxRetries;
  final int? cacheWidth;
  final int? cacheHeight;
  final bool fadeIn;

  const _NativeBitmap({
    required this.controller,
    required this.url,
    required this.maxRetries,
    required this.fadeIn,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.color,
    this.placeholder,
    this.errorWidget,
    this.cacheWidth,
    this.cacheHeight,
  });

  @override
  State<_NativeBitmap> createState() => _NativeBitmapState();
}

class _NativeBitmapState extends State<_NativeBitmap>
    with _NetworkRetryMixin, LoggerMixin {
  @override
  String get logTag => 'GameAssetCache';
  bool _useFallback = false;

  void _triggerRetry() {
    scheduleRetry(
      maxRetries: widget.maxRetries,
      onRetry: () async {
        try {
          await widget.controller.imageCacheManager.removeFile(widget.url);
          await CachedNetworkImage.evictFromCache(widget.url);
        } catch (_) {}
      },
      onMaxRetriesReached: () {
        if (mounted) {
          setState(() {
            _useFallback = true;
          });
          logInfo(
            'Max retries reached for CachedNetworkImage. Falling back to standard Image.network...',
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_useFallback) {
      return Image.network(
        widget.url,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        color: widget.color,
        cacheWidth: widget.cacheWidth,
        cacheHeight: widget.cacheHeight,
        errorBuilder: (context, error, stackTrace) {
          logError(
            'Fallback Image.network also failed for URL: ${widget.url}',
            error,
          );
          return _NetworkErrorWidget(
            errorWidget: widget.errorWidget,
            width: widget.width,
            height: widget.height,
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _NetworkPlaceholder(
            placeholder: widget.placeholder,
            width: widget.width,
            height: widget.height,
          );
        },
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || !widget.fadeIn) return child;
          return _NetworkFadeIn(child: child);
        },
      );
    }

    return CachedNetworkImage(
      cacheManager: widget.controller.imageCacheManager,
      key: ValueKey('${widget.url}-$retryCount'),
      imageUrl: widget.url,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      color: widget.color,
      maxWidthDiskCache: widget.cacheWidth,
      maxHeightDiskCache: widget.cacheHeight,
      placeholder: (context, url) => _NetworkPlaceholder(
        placeholder: widget.placeholder,
        width: widget.width,
        height: widget.height,
      ),
      errorWidget: (context, url, error) {
        logError('Native image load failed for URL: $url', error);
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _triggerRetry();
          }
        });

        return _NetworkPlaceholder(
          placeholder: widget.placeholder,
          width: widget.width,
          height: widget.height,
        );
      },
      fadeInDuration: widget.fadeIn
          ? const Duration(milliseconds: 250)
          : Duration.zero,
      fadeOutDuration: widget.fadeIn
          ? const Duration(milliseconds: 250)
          : Duration.zero,
    );
  }
}
