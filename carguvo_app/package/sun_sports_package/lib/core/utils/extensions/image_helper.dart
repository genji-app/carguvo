import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart' as svg;
import 'package:http/http.dart' as http;
import 'package:sun_sports/core/utils/bundle_manager.dart';
import 'package:sun_sports/core/misc/semaphore.dart';
import 'package:sun_sports/core/utils/extensions/cached_manager.dart';
import 'package:sun_sports/core/utils/sprite/sprite_atlas.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';

class _BundleAssetGate extends StatelessWidget {
  const _BundleAssetGate({
    required this.builder,
    this.width,
    this.height,
    this.suppressWhenSuspended = false,
  });

  final Widget Function() builder;
  final double? width;
  final double? height;
  final bool suppressWhenSuspended;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: BundleManager.assetsGeneration,
      builder: (context, _, __) {
        if (suppressWhenSuspended && BundleManager.assetsSuspended) {
          return SizedBox(width: width, height: height);
        }
        return builder();
      },
    );
  }
}

class ImageHelper {
  static const int maxRetryAttempts = 3;

  static final Semaphore _downloadSemaphore = Semaphore(6);

  static const Duration _baseRetryDelay = Duration(milliseconds: 500);

  static const Duration _perAttemptTimeout = Duration(seconds: 10);

  static const int _minValidFileSize = 10;

  static Widget _defaultPlaceholder(double? width, double? height) {
    return SizedBox(
      width: width,
      height: height,
      child: const Center(child: SizedBox.shrink()),
    );
  }

  static Widget _defaultErrorWidget({
    double? width,
    double? height,
    double? borderRadius,
  }) {
    return Container(
      width: width,
      height: height ?? 144,
      decoration: BoxDecoration(
        borderRadius: borderRadius != null
            ? BorderRadius.circular(borderRadius)
            : null,
        color: AppColorStyles.backgroundPrimary,
      ),
      child: const Center(
        child: Icon(Icons.error, color: AppColorStyles.contentSecondary),
      ),
    );
  }

  static bool _isNetworkPath(String path) =>
      path.startsWith('http://') || path.startsWith('https://');

  static bool _isUnresolvedRemotePath(String path) =>
      path.isEmpty || path.startsWith('/');

  static String _normalizePath(String path) {
    String normalizedPath = path.trim();

    try {
      const int maxDecodeAttempts = 3;
      for (int i = 0; i < maxDecodeAttempts; i++) {
        if (normalizedPath.contains('%25') ||
            normalizedPath.contains('%3A')) {
          final decoded = Uri.decodeComponent(normalizedPath);
          if (decoded != normalizedPath) {
            normalizedPath = decoded;
          } else {
            break;
          }
        } else {
          break;
        }
      }
    } catch (_) {
    }

    return normalizedPath;
  }

  static Future<File?> _downloadFileWithRetry(String url) async {
    if (kIsWeb) return null;

    Object? lastError;
    for (int attempt = 1; attempt <= maxRetryAttempts; attempt++) {
      try {
        await _downloadSemaphore.acquire();
        final File file;
        try {
          file = await AssetsCacheManager.getSingleFileForUrlWithVersioning(url)
              .timeout(_perAttemptTimeout);
        } finally {
          _downloadSemaphore.release();
        }

        if (await file.exists()) {
          final size = await file.length();
          if (size >= _minValidFileSize) {
            return file;
          }
        }
        await AssetsCacheManager.clearCacheForUrl(url);
      } on TimeoutException catch (e) {
        lastError = e;
        try {
          await AssetsCacheManager.clearCacheForUrl(url);
        } catch (_) {
        }
      } catch (e) {
        lastError = e;
        try {
          await AssetsCacheManager.clearCacheForUrl(url);
        } catch (_) {
        }
      }

      if (attempt < maxRetryAttempts) {
        await Future<void>.delayed(_baseRetryDelay * attempt);
      }
    }

    try {
      await AssetsCacheManager.clearCacheForUrl(url);
    } catch (_) {
    }
    debugPrint(
      'ImageHelper: load failed after $maxRetryAttempts retries: $url '
      '(last error: $lastError)',
    );
    return null;
  }

  static Widget getSVG({
    required String path,
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.scaleDown,
  }) {
    return _BundleAssetGate(
      width: width,
      height: height,
      suppressWhenSuspended: true,
      builder: () => _getSvgUngated(
        path: path,
        width: width,
        height: height,
        color: color,
        fit: fit,
      ),
    );
  }

  static Widget _getSvgUngated({
    required String path,
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.scaleDown,
  }) {
    final normalizedPath = _normalizePath(path);

    if (_isUnresolvedRemotePath(normalizedPath)) {
      return _defaultPlaceholder(width, height);
    }

    if (!_isNetworkPath(normalizedPath)) {
      return _defaultPlaceholder(width, height);
    }

    if (kIsWeb) {
      return _CachedSvgNetworkWidget(
        key: ValueKey('svg_${normalizedPath}_${color?.hashCode ?? 0}'),
        url: normalizedPath,
        width: width,
        height: height,
        color: color,
        fit: fit,
      );
    }

    return svg.SvgPicture.network(
      normalizedPath,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
      width: width,
      height: height,
      fit: fit,
      placeholderBuilder: (context) => _defaultPlaceholder(width, height),
    );
  }

  static Future<void> precacheSvgPicture(String path) async {
    final normalizedPath = _normalizePath(path);
    try {
      final symbolId = _toSymbolId(_extractFilename(normalizedPath));
      final bundleSvgContent = BundleManager.instance.getSvgSymbol(symbolId);
      if (bundleSvgContent != null) {
        await svg.vg.loadPicture(svg.SvgStringLoader(bundleSvgContent), null);
        return;
      }
      if (_isNetworkPath(normalizedPath)) {
        await svg.vg.loadPicture(svg.SvgNetworkLoader(normalizedPath), null);
      }
    } catch (_) {
    }
  }

  static Future<void> precacheSVG(BuildContext context, String path) async {
    final normalizedPath = _normalizePath(path);
    if (!_isNetworkPath(normalizedPath)) return;
    try {
      final loader = svg.SvgNetworkLoader(normalizedPath);
      await svg.vg.loadPicture(loader, null);
    } catch (_) {
    }
  }

  static Future<void> precacheNetworkImage(
    BuildContext context,
    String imageUrl,
  ) async {
    if (kIsWeb) return;
    if (imageUrl.toLowerCase().endsWith('.svg')) return;

    final String normalizedPath = _normalizePath(imageUrl);
    if (_isUnresolvedRemotePath(normalizedPath)) return;

    String url = normalizedPath;
    if (!_isNetworkPath(url)) {
      final ResourceResult? resource = BundleManager.instance.lookupResource(
        BundleManager.toLookupKey(normalizedPath),
      );
      final String? resourceUrl = resource?.url;
      if (resourceUrl == null || !_isNetworkPath(resourceUrl)) return;
      url = resourceUrl;
    }

    try {
      await precacheImage(
        Image.network(url).image,
        context,
        onError: (Object error, StackTrace? stack) {},
      );
    } catch (_) {
    }
  }

  static Widget getNetworkImage({
    required String imageUrl,
    double? height,
    double? width,
    Widget? errorWidget,
    BoxFit? fit,
    Widget? placeholder,
    double? borderRadius,
    double? sizeLoading = 50,
    int maxRetries = maxRetryAttempts,
    int? cacheWidth,
    int? cacheHeight,
    FilterQuality filterQuality = FilterQuality.medium,
  }) {
    return _BundleAssetGate(
      width: width,
      height: height,
      suppressWhenSuspended: true,
      builder: () => _CachedNetworkImageWithRetry(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit ?? BoxFit.cover,
        borderRadius: borderRadius,
        placeholder: placeholder,
        errorWidget: errorWidget,
        memCacheWidth: cacheWidth,
        memCacheHeight: cacheHeight,
        maxHeightDiskCache: cacheHeight ?? 1200,
        maxWidthDiskCache: cacheWidth ?? 1200,
        filterQuality: filterQuality,
        maxRetries: maxRetries,
      ),
    );
  }

  static bool isSmallLogoCached({
    required String imageUrl,
    required double size,
  }) {
    if (imageUrl.isEmpty) return false;
    final cacheSize = (size * 2).toInt();
    final provider = ResizeImage.resizeIfNeeded(
      cacheSize,
      cacheSize,
      CachedNetworkImageProvider(
        imageUrl,
        cacheManager: AssetsCacheManager.getInstance(),
        maxWidth: cacheSize,
        maxHeight: cacheSize,
      ),
    );
    Object? key;
    provider
        .obtainKey(ImageConfiguration.empty)
        .then((k) => key = k, onError: (Object _) {});
    if (key == null) return false;
    return PaintingBinding.instance.imageCache.containsKey(key!);
  }

  static Widget getSmallLogo({
    required String imageUrl,
    required double size,
    Widget? errorWidget,
    Widget? placeholder,
    double? borderRadius,
    int maxRetries = maxRetryAttempts,
  }) {
    final cacheSize = (size * 2).toInt();

    return SizedBox(
      width: size,
      height: size,
      child: _BundleAssetGate(
        width: size,
        height: size,
        suppressWhenSuspended: true,
        builder: () => _CachedNetworkImageWithRetry(
          imageUrl: imageUrl,
          width: size,
          height: size,
          fit: BoxFit.contain,
          memCacheWidth: cacheSize,
          memCacheHeight: cacheSize,
          maxHeightDiskCache: cacheSize,
          maxWidthDiskCache: cacheSize,
          filterQuality: FilterQuality.low,
          placeholder: placeholder ?? const SizedBox.shrink(),
          errorWidget: errorWidget ??
              Icon(
                Icons.sports_soccer,
                size: size * 0.7,
                color: AppColorStyles.contentSecondary,
              ),
          borderRadius: borderRadius,
          maxRetries: maxRetries,
        ),
      ),
    );
  }

  static Widget getAvatar({
    required String imageUrl,
    double? height,
    double? width,
    Widget? errorWidget,
    BoxFit? fit,
    Widget? placeholder,
    int maxRetries = maxRetryAttempts,
  }) {
    final w = width ?? height ?? 60;
    final h = height ?? width ?? 60;
    final fallbackSize = w < h ? w : h;

    final defaultErr = errorWidget ??
        Container(
          width: w,
          height: h,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColorStyles.backgroundPrimary,
          ),
          child: Icon(
            Icons.person,
            size: fallbackSize * 0.6,
            color: AppColorStyles.contentSecondary,
          ),
        );

    final defaultPh = placeholder ??
        Container(
          width: w,
          height: h,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColorStyles.backgroundPrimary,
          ),
        );

    return ClipOval(
      child: _BundleAssetGate(
        width: w,
        height: h,
        suppressWhenSuspended: true,
        builder: () => _CachedNetworkImageWithRetry(
          imageUrl: imageUrl,
          height: h,
          width: w,
          fit: fit ?? BoxFit.cover,
          maxHeightDiskCache: 600,
          maxWidthDiskCache: 600,
          filterQuality: FilterQuality.high,
          placeholder: defaultPh,
          errorWidget: defaultErr,
          maxRetries: maxRetries,
        ),
      ),
    );
  }

  static String _extractFilename(String path) {
    final noQuery = path.split('?').first.split('#').first;
    final slash = noQuery.lastIndexOf('/');
    final basename = slash == -1 ? noQuery : noQuery.substring(slash + 1);
    final dot = basename.lastIndexOf('.');
    return dot == -1 ? basename : basename.substring(0, dot);
  }

  static String _toSymbolId(String filename) {
    final sanitized = filename
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_-]'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    if (sanitized.isEmpty) return 'icon';
    if (RegExp(r'^[0-9]').hasMatch(sanitized)) return 'icon-$sanitized';
    return sanitized;
  }

  static Widget load({
    required String path,
    double? width,
    double? height,
    Color? color,
    BoxFit? fit,
    Widget? errorWidget,
    Widget? placeholder,
    double? borderRadius,
    int? cacheWidth,
    int? cacheHeight,
    int maxRetries = maxRetryAttempts,
    FilterQuality filterQuality = FilterQuality.medium,
    bool bypassSuspend = false,
  }) {
    return _BundleAssetGate(
      width: width,
      height: height,
      builder: () => _loadUngated(
        path: path,
        width: width,
        height: height,
        color: color,
        fit: fit,
        errorWidget: errorWidget,
        placeholder: placeholder,
        borderRadius: borderRadius,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
        maxRetries: maxRetries,
        filterQuality: filterQuality,
        bypassSuspend: bypassSuspend,
      ),
    );
  }

  static Widget _loadUngated({
    required String path,
    double? width,
    double? height,
    Color? color,
    BoxFit? fit,
    Widget? errorWidget,
    Widget? placeholder,
    double? borderRadius,
    int? cacheWidth,
    int? cacheHeight,
    int maxRetries = maxRetryAttempts,
    FilterQuality filterQuality = FilterQuality.medium,
    bool bypassSuspend = false,
  }) {
    filterQuality = _resolveFilterQuality(filterQuality);
    final normalizedPath = _normalizePath(path);
    
    if (_isUnresolvedRemotePath(normalizedPath)) {
      return placeholder ?? _defaultPlaceholder(width, height);
    }

    final isNetwork = _isNetworkPath(normalizedPath);
    final lowerPath = normalizedPath.toLowerCase();
    final isSvg = lowerPath.endsWith('.svg');
    final filename = _extractFilename(normalizedPath);
    final lookupFilename = BundleManager.toLookupKey(normalizedPath);

    if (!bypassSuspend && BundleManager.assetsSuspended) {
      final suspendCheck = BundleManager.instance.lookupResource(lookupFilename);
      final fromSuspendedBundle = suspendCheck != null &&
          BundleManager.isBundleSuspended(suspendCheck.bundleKey);
      if (fromSuspendedBundle || (suspendCheck == null && isNetwork)) {
        return SizedBox(width: width, height: height);
      }
    }

    if (isSvg) {
      final symbolId = _toSymbolId(filename);
      final bundleSvgContent = BundleManager.instance.getSvgSymbol(symbolId);
      if (bundleSvgContent != null) {
        return svg.SvgPicture.string(
          bundleSvgContent,
          width: width,
          height: height,
          colorFilter: color != null
              ? ColorFilter.mode(color, BlendMode.srcIn)
              : null,
          fit: fit ?? BoxFit.scaleDown,
          placeholderBuilder: (context) =>
              placeholder ?? _defaultPlaceholder(width, height),
        );
      }
    }

    if (!isSvg) {
      final resource = BundleManager.instance.lookupResource(lookupFilename);
      if (resource != null) {
        if (resource.type == 'atlas_frame' &&
            resource.atlasFrame != null &&
            resource.packFile != null) {
          final atlas =
              BundleManager.instance.getAtlasByPackFile(resource.packFile!);
          final frame = resource.atlasFrame!;
          if (atlas != null) {
            final atlasImageWidget = _AtlasImage(
              image: atlas.image,
              frame: frame,
              width: width,
              height: height,
              color: color,
              fit: fit ?? BoxFit.contain,
            );
            if (borderRadius != null && borderRadius > 0) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius),
                child: atlasImageWidget,
              );
            }
            return atlasImageWidget;
          }
        }

        if (resource.url != null && resource.url!.isNotEmpty) {
          return _buildResolvedNetworkImage(
            url: resource.url!,
            width: width,
            height: height,
            color: color,
            fit: fit,
            errorWidget: errorWidget,
            placeholder: placeholder,
            borderRadius: borderRadius,
            cacheWidth: cacheWidth,
            cacheHeight: cacheHeight,
            maxRetries: maxRetries,
            filterQuality: filterQuality,
          );
        }
      }
    }

    if (!isNetwork) {
      return placeholder ?? _defaultPlaceholder(width, height);
    }

    return _buildResolvedNetworkImage(
      url: normalizedPath,
      width: width,
      height: height,
      color: color,
      fit: fit,
      errorWidget: errorWidget,
      placeholder: placeholder,
      borderRadius: borderRadius,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
      maxRetries: maxRetries,
      filterQuality: filterQuality,
    );
  }

  static FilterQuality _resolveFilterQuality(FilterQuality? callerQuality) {
    if (callerQuality != null) return callerQuality;
    if (kIsWeb) {
      final view = WidgetsBinding.instance.platformDispatcher.views.first;
      final logicalWidth = view.physicalSize.width / view.devicePixelRatio;
      if (logicalWidth < 768) return FilterQuality.low;
    }
    return FilterQuality.medium;
  }

  static Widget _buildResolvedNetworkImage({
    required String url,
    double? width,
    double? height,
    Color? color,
    BoxFit? fit,
    Widget? errorWidget,
    Widget? placeholder,
    double? borderRadius,
    int? cacheWidth,
    int? cacheHeight,
    int maxRetries = maxRetryAttempts,
    FilterQuality filterQuality = FilterQuality.medium,
  }) {
    final lowerPath = url.toLowerCase();
    final isSvg = lowerPath.endsWith('.svg');
    final isGif = lowerPath.endsWith('.gif');

    if (isGif) {
      Widget gif = Image.network(
        url,
        width: width,
        height: height,
        fit: fit ?? BoxFit.contain,
        color: color,
        filterQuality: filterQuality,
        gaplessPlayback: true,
        loadingBuilder: (context, child, progress) => progress == null
            ? child
            : (placeholder ?? _defaultPlaceholder(width, height)),
        errorBuilder: (context, error, stack) =>
            errorWidget ?? _defaultPlaceholder(width, height),
      );
      if (borderRadius != null && borderRadius > 0) {
        gif = ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: gif,
        );
      }
      return gif;
    }

    if (kIsWeb) {
      if (isSvg) {
        return getSVG(
          path: url,
          width: width,
          height: height,
          color: color,
          fit: fit ?? BoxFit.scaleDown,
        );
      }
      return getNetworkImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: fit,
        errorWidget: errorWidget,
        placeholder: placeholder,
        borderRadius: borderRadius,
        maxRetries: maxRetries,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
        filterQuality: filterQuality,
      );
    }

    return _LazyLoadingImageWidget(
      key: ValueKey('lazy_${url}_${color?.hashCode ?? 0}'),
      url: url,
      isSvg: isSvg,
      width: width,
      height: height,
      color: color,
      fit: fit,
      errorWidget: errorWidget,
      placeholder: placeholder,
      borderRadius: borderRadius,
      maxRetries: maxRetries,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }
}

class _CachedNetworkImageWithRetry extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final double? borderRadius;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final int maxHeightDiskCache;
  final int maxWidthDiskCache;
  final FilterQuality filterQuality;
  final int maxRetries;

  const _CachedNetworkImageWithRetry({
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.memCacheWidth,
    this.memCacheHeight,
    this.maxHeightDiskCache = 1200,
    this.maxWidthDiskCache = 1200,
    this.filterQuality = FilterQuality.high,
    this.maxRetries = ImageHelper.maxRetryAttempts,
  });

  @override
  State<_CachedNetworkImageWithRetry> createState() =>
      _CachedNetworkImageWithRetryState();
}

class _CachedNetworkImageWithRetryState
    extends State<_CachedNetworkImageWithRetry> {
  int _retryCount = 0;
  bool _scheduledRetry = false;
  bool _scheduledFailureCleanup = false;

  @override
  void didUpdateWidget(_CachedNetworkImageWithRetry oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _retryCount = 0;
      _scheduledRetry = false;
      _scheduledFailureCleanup = false;
    }
  }

  Future<void> _scheduleRetry() async {
    if (_scheduledRetry || !mounted) return;
    _scheduledRetry = true;

    try {
      await CachedNetworkImage.evictFromCache(widget.imageUrl);
      await AssetsCacheManager.clearCacheForUrl(widget.imageUrl);
    } catch (_) {
    }

    final delay = Duration(milliseconds: 500 * (_retryCount + 1));
    await Future<void>.delayed(delay);

    if (!mounted) return;
    setState(() {
      _retryCount++;
      _scheduledRetry = false;
    });
  }

  Future<void> _onPermanentFailure() async {
    if (_scheduledFailureCleanup) return;
    _scheduledFailureCleanup = true;
    try {
      await CachedNetworkImage.evictFromCache(widget.imageUrl);
      await AssetsCacheManager.clearCacheForUrl(widget.imageUrl);
    } catch (_) {
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = CachedNetworkImage(
      key: ValueKey('${widget.imageUrl}_$_retryCount'),
      imageUrl: widget.imageUrl,
      cacheManager: AssetsCacheManager.getInstance(),
      height: widget.height,
      width: widget.width,
      fit: widget.fit,
      memCacheWidth: widget.memCacheWidth,
      memCacheHeight: widget.memCacheHeight,
      filterQuality: widget.filterQuality,
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      placeholder: widget.placeholder != null
          ? (context, url) => widget.placeholder!
          : null,
      errorWidget: (context, url, error) {
        if (_retryCount < widget.maxRetries) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scheduleRetry();
          });
          return widget.placeholder ??
              ImageHelper._defaultPlaceholder(widget.width, widget.height);
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _onPermanentFailure();
        });
        return widget.errorWidget ??
            ImageHelper._defaultErrorWidget(
              width: widget.width,
              height: widget.height,
              borderRadius: widget.borderRadius,
            );
      },
    );

    if (widget.borderRadius != null && widget.borderRadius! > 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius!),
        child: image,
      );
    }
    return image;
  }
}

class _LazyLoadingImageWidget extends StatefulWidget {
  final String url;
  final bool isSvg;
  final double? width;
  final double? height;
  final Color? color;
  final BoxFit? fit;
  final Widget? errorWidget;
  final Widget? placeholder;
  final double? borderRadius;
  final int maxRetries;
  final int? cacheWidth;
  final int? cacheHeight;

  const _LazyLoadingImageWidget({
    required this.url,
    required this.isSvg,
    super.key,
    this.width,
    this.height,
    this.color,
    this.fit,
    this.errorWidget,
    this.placeholder,
    this.borderRadius,
    this.maxRetries = ImageHelper.maxRetryAttempts,
    this.cacheWidth,
    this.cacheHeight,
  });

  @override
  State<_LazyLoadingImageWidget> createState() =>
      _LazyLoadingImageWidgetState();
}

class _LazyLoadingImageWidgetState extends State<_LazyLoadingImageWidget> {
  static final Map<String, Future<File?>> _verificationCache = {};
  static const int _maxVerificationCacheSize = 50;

  File? _cachedFile;
  String? _cachedSvgContent;
  Future<String>? _cachedSvgReadFuture;
  bool _hasError = false;
  bool _disposed = false;

  static void _cleanupVerificationCacheIfNeeded() {
    if (_verificationCache.length > _maxVerificationCacheSize) {
      final keysToRemove = _verificationCache.keys
          .take(_maxVerificationCacheSize ~/ 5)
          .toList();
      for (final key in keysToRemove) {
        _verificationCache.remove(key);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void didUpdateWidget(_LazyLoadingImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url || oldWidget.isSvg != widget.isSvg) {
      setState(() {
        _cachedFile = null;
        _cachedSvgContent = null;
        _cachedSvgReadFuture = null;
        _hasError = false;
      });
      _bootstrap();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> _bootstrap() async {
    await _loadCachedVersion();
    if (_disposed) return;
    if (widget.isSvg && _cachedSvgContent != null) return;
    await _verifyInBackgroundWithRetry();
  }

  Future<void> _loadCachedVersion() async {
    try {
      final normalizedUrl = widget.url.trim();
      final asset = AssetsCacheManager.getAssetForUrl(normalizedUrl);
      final cacheKey = asset != null
          ? AssetsCacheManager.getCacheKeyForIcon(asset)
          : normalizedUrl;

      if (widget.isSvg) {
        final cachedSvgString =
            AssetsCacheManager.getCachedSvgString(cacheKey);
        if (cachedSvgString != null && mounted) {
          setState(() {
            _cachedSvgContent = cachedSvgString;
          });
          return;
        }
      }

      final cachedFile =
          await AssetsCacheManager.getCachedFileForUrlWithVersioning(
        normalizedUrl,
      );

      if (cachedFile == null || !mounted) return;

      try {
        final size = await cachedFile.length();
        if (size < ImageHelper._minValidFileSize) {
          await AssetsCacheManager.clearCacheForUrl(normalizedUrl);
          return;
        }
      } catch (_) {
        return;
      }

      if (!mounted) return;
      setState(() {
        _cachedFile = cachedFile;
      });

      if (widget.isSvg) {
        try {
          final content = await cachedFile.readAsString();
          if (!mounted) return;
          AssetsCacheManager.cacheSvgString(cacheKey, content);
          setState(() {
            _cachedSvgContent = content;
          });
        } catch (_) {
        }
      }
    } catch (_) {
    }
  }

  Future<void> _verifyInBackgroundWithRetry() async {
    final normalizedUrl = widget.url.trim();

    final existing = _verificationCache[normalizedUrl];
    if (existing != null) {
      try {
        final file = await existing;
        if (!mounted) return;
        if (file != null) {
          await _onDownloadSuccess(file);
        } else if (_cachedFile == null) {
          setState(() {
            _hasError = true;
          });
        }
      } catch (_) {
        if (mounted && _cachedFile == null) {
          setState(() {
            _hasError = true;
          });
        }
      }
      return;
    }

    _cleanupVerificationCacheIfNeeded();

    final future = ImageHelper._downloadFileWithRetry(normalizedUrl);
    _verificationCache[normalizedUrl] = future;

    try {
      final file = await future;
      if (!mounted) return;
      if (file != null) {
        await _onDownloadSuccess(file);
      } else if (_cachedFile == null) {
        setState(() {
          _hasError = true;
        });
      }
    } catch (_) {
      if (mounted && _cachedFile == null) {
        setState(() {
          _hasError = true;
        });
      }
    } finally {
      _verificationCache.remove(normalizedUrl);
    }
  }

  Future<void> _onDownloadSuccess(File file) async {
    if (!mounted) return;
    final normalizedUrl = widget.url.trim();
    final asset = AssetsCacheManager.getAssetForUrl(normalizedUrl);
    final cacheKey = asset != null
        ? AssetsCacheManager.getCacheKeyForIcon(asset)
        : normalizedUrl;

    if (widget.isSvg) {
      try {
        final content = await file.readAsString();
        if (!mounted) return;
        AssetsCacheManager.cacheSvgString(cacheKey, content);
        setState(() {
          _cachedFile = file;
          _cachedSvgContent = content;
          _cachedSvgReadFuture = null;
          _hasError = false;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _cachedFile = file;
          _cachedSvgReadFuture = null;
          _hasError = false;
        });
      }
    } else {
      setState(() {
        _cachedFile = file;
        _hasError = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isSvg && _cachedSvgContent != null) {
      return svg.SvgPicture.string(
        _cachedSvgContent!,
        width: widget.width,
        height: widget.height,
        colorFilter: widget.color != null
            ? ColorFilter.mode(widget.color!, BlendMode.srcIn)
            : null,
        fit: widget.fit ?? BoxFit.scaleDown,
        placeholderBuilder: (context) =>
            widget.placeholder ??
            ImageHelper._defaultPlaceholder(widget.width, widget.height),
      );
    }

    if (_cachedFile != null) {
      if (widget.isSvg) {
        if (_cachedSvgContent != null) {
          return svg.SvgPicture.string(
            _cachedSvgContent!,
            width: widget.width,
            height: widget.height,
            colorFilter: widget.color != null
                ? ColorFilter.mode(widget.color!, BlendMode.srcIn)
                : null,
            fit: widget.fit ?? BoxFit.scaleDown,
            placeholderBuilder: (context) =>
                widget.placeholder ??
                ImageHelper._defaultPlaceholder(widget.width, widget.height),
          );
        }
        _cachedSvgReadFuture ??= _cachedFile!.readAsString();
        return FutureBuilder<String>(
          future: _cachedSvgReadFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return svg.SvgPicture.string(
                snapshot.data!,
                width: widget.width,
                height: widget.height,
                colorFilter: widget.color != null
                    ? ColorFilter.mode(widget.color!, BlendMode.srcIn)
                    : null,
                fit: widget.fit ?? BoxFit.scaleDown,
                placeholderBuilder: (context) =>
                    widget.placeholder ??
                    ImageHelper._defaultPlaceholder(
                      widget.width,
                      widget.height,
                    ),
              );
            }
            if (snapshot.hasError) {
              return widget.errorWidget ??
                  ImageHelper._defaultErrorWidget(
                    width: widget.width,
                    height: widget.height,
                    borderRadius: widget.borderRadius,
                  );
            }
            return widget.placeholder ??
                ImageHelper._defaultPlaceholder(widget.width, widget.height);
          },
        );
      }

      final image = Image.file(
        _cachedFile!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        cacheWidth: widget.cacheWidth,
        cacheHeight: widget.cacheHeight,
        filterQuality: FilterQuality.medium,
        errorBuilder: (context, error, stackTrace) =>
            widget.errorWidget ??
            ImageHelper._defaultErrorWidget(
              width: widget.width,
              height: widget.height,
              borderRadius: widget.borderRadius,
            ),
      );
      if (widget.borderRadius != null && widget.borderRadius! > 0) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius!),
          child: image,
        );
      }
      return image;
    }

    if (_hasError) {
      return widget.errorWidget ??
          ImageHelper._defaultErrorWidget(
            width: widget.width,
            height: widget.height,
            borderRadius: widget.borderRadius,
          );
    }

    return widget.placeholder ??
        ImageHelper._defaultPlaceholder(widget.width, widget.height);
  }
}

class _AtlasImage extends StatelessWidget {
  final ui.Image image;
  final AtlasFrame frame;
  final double? width;
  final double? height;
  final Color? color;
  final BoxFit fit;

  const _AtlasImage({
    required this.image,
    required this.frame,
    this.width,
    this.height,
    this.color,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    final Size src = frame.sourceSize;
    double? w = width;
    double? h = height;
    if (w != null && h == null && src.width > 0) {
      h = w * src.height / src.width;
    } else if (h != null && w == null && src.height > 0) {
      w = h * src.width / src.height;
    }

    final Widget fitted = FittedBox(
      fit: fit,
      clipBehavior: Clip.hardEdge,
      child: CustomPaint(
        size: src,
        painter: _AtlasPainter(image: image, frame: frame, color: color),
      ),
    );
    if (w != null || h != null) {
      return SizedBox(width: w, height: h, child: fitted);
    }
    return fitted;
  }
}

class _AtlasPainter extends CustomPainter {
  final ui.Image image;
  final AtlasFrame frame;
  final Color? color;

  _AtlasPainter({
    required this.image,
    required this.frame,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..filterQuality = FilterQuality.medium;
    if (color != null) {
      paint.colorFilter = ColorFilter.mode(color!, BlendMode.srcIn);
    }

    paintAtlasFrame(canvas, image, frame, Offset.zero & size, paint: paint);
  }

  @override
  bool shouldRepaint(_AtlasPainter old) =>
      old.image != image || old.frame != frame || old.color != color;
}

class _CachedSvgNetworkWidget extends StatefulWidget {
  final String url;
  final double? width;
  final double? height;
  final Color? color;
  final BoxFit fit;

  const _CachedSvgNetworkWidget({
    required this.url,
    super.key,
    this.width,
    this.height,
    this.color,
    this.fit = BoxFit.scaleDown,
  });

  @override
  State<_CachedSvgNetworkWidget> createState() =>
      _CachedSvgNetworkWidgetState();
}

class _CachedSvgNetworkWidgetState extends State<_CachedSvgNetworkWidget> {
  static final Map<String, String> _svgStringCache = {};
  static final Map<String, Future<String>> _svgFutureCache = {};
  static const int _maxCacheSize = 100;

  String? _cachedSvgString;
  Future<String>? _svgStringFuture;

  @override
  void initState() {
    super.initState();
    _loadSvg();
  }

  @override
  void didUpdateWidget(_CachedSvgNetworkWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _cachedSvgString = null;
      _svgStringFuture = null;
      _loadSvg();
    }
  }

  static void _cleanupCacheIfNeeded() {
    if (_svgStringCache.length > _maxCacheSize) {
      final keysToRemove =
          _svgStringCache.keys.take(_maxCacheSize ~/ 5).toList();
      for (final key in keysToRemove) {
        _svgStringCache.remove(key);
      }
    }
  }

  static Future<String> _fetchSvgWithRetry(String url) async {
    Object? lastError;
    for (int attempt = 1; attempt <= ImageHelper.maxRetryAttempts; attempt++) {
      try {
        final response = await http
            .get(Uri.parse(url))
            .timeout(ImageHelper._perAttemptTimeout);
        if (response.statusCode == 200 &&
            response.body.length >= ImageHelper._minValidFileSize) {
          return response.body;
        }
        lastError = Exception(
          'HTTP ${response.statusCode}, body length ${response.body.length}',
        );
      } on TimeoutException catch (e) {
        lastError = e;
      } catch (e) {
        lastError = e;
      }

      if (attempt < ImageHelper.maxRetryAttempts) {
        await Future<void>.delayed(Duration(milliseconds: 500 * attempt));
      }
    }
    throw Exception(
      'Failed to load SVG after ${ImageHelper.maxRetryAttempts} retries: '
      '$lastError',
    );
  }

  void _loadSvg() {
    final normalizedUrl = ImageHelper._normalizePath(widget.url);
    final cacheKey = normalizedUrl;

    final cached = _svgStringCache[cacheKey];
    if (cached != null) {
      _cachedSvgString = cached;
      if (mounted) setState(() {});
      return;
    }

    _svgStringFuture = _svgFutureCache.putIfAbsent(cacheKey, () async {
      try {
        final svgString = await _fetchSvgWithRetry(normalizedUrl);
        _svgStringCache[cacheKey] = svgString;
        _cleanupCacheIfNeeded();
        _svgFutureCache.remove(cacheKey);
        return svgString;
      } catch (e) {
        _svgFutureCache.remove(cacheKey);
        rethrow;
      }
    });

    _svgStringFuture!.then((svgString) {
      if (!mounted) return;
      setState(() {
        _cachedSvgString = svgString;
      });
    }).catchError((Object _) {
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_cachedSvgString != null) {
      return svg.SvgPicture.string(
        _cachedSvgString!,
        colorFilter: widget.color != null
            ? ColorFilter.mode(widget.color!, BlendMode.srcIn)
            : null,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        placeholderBuilder: (context) =>
            ImageHelper._defaultPlaceholder(widget.width, widget.height),
      );
    }

    if (_svgStringFuture == null) {
      return ImageHelper._defaultPlaceholder(widget.width, widget.height);
    }

    return FutureBuilder<String>(
      future: _svgStringFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return svg.SvgPicture.string(
            snapshot.data!,
            colorFilter: widget.color != null
                ? ColorFilter.mode(widget.color!, BlendMode.srcIn)
                : null,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            placeholderBuilder: (context) =>
                ImageHelper._defaultPlaceholder(widget.width, widget.height),
          );
        }
        if (snapshot.hasError) {
          return SizedBox(
            width: widget.width,
            height: widget.height,
            child: const Center(child: Icon(Icons.error)),
          );
        }
        return ImageHelper._defaultPlaceholder(widget.width, widget.height);
      },
    );
  }
}
