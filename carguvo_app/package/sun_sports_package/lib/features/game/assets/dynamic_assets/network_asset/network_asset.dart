import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart' as svg;
import 'package:http/http.dart' as http;
import 'package:sun_sports/core/utils/extensions/log_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';

import '../cache/asset_cache_controller.dart';
import '../cache/asset_url_formatter.dart';

part 'native_bitmap.dart';
part 'network_asset_components.dart';
part 'network_retry_mixin.dart';
part 'svg_network_widget.dart';

class NetworkAsset extends StatefulWidget {
  final String path;
  final AssetCacheController? controller; 
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

  const NetworkAsset({
    required this.path,
    this.controller,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.color,
    this.placeholder,
    this.errorWidget,
    this.maxRetries = 3,
    this.cacheWidth,
    this.cacheHeight,
    this.fadeIn = true,
    super.key,
  });

  @override
  State<NetworkAsset> createState() => _NetworkAssetState();
}

class _NetworkAssetState extends State<NetworkAsset>
    with _NetworkRetryMixin, LoggerMixin {
  @override
  String get logTag => 'GameAssetCache';
  late bool _isNetwork;
  late bool _isSvg;

  Timer? _watchdogTimer;
  bool _isImageLoaded = false;

  AssetCacheController get _effectiveController {
    if (widget.controller != null) return widget.controller!;
    final scopeEl = context
        .getElementForInheritedWidgetOfExactType<AssetCacheScope>();
    final scope = scopeEl?.widget as AssetCacheScope?;
    if (scope == null) {
      throw FlutterError(
        'NetworkAsset requires an AssetCacheController.\n'
        'You must either pass a controller directly via the constructor '
        'or wrap the widget tree in an AssetCacheScope.',
      );
    }
    return scope.controller;
  }

  String get _bustedPath =>
      widget.path.toBustedUrl(_effectiveController.cacheVersion);

  @override
  void initState() {
    super.initState();
    _computeImageMeta();
    _effectiveController.init();
    _startWatchdog();
  }

  @override
  void didUpdateWidget(covariant NetworkAsset oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      resetRetry();
      _computeImageMeta();
      _startWatchdog();
    }
  }

  @override
  void dispose() {
    _watchdogTimer?.cancel();
    super.dispose();
  }

  void _startWatchdog() {
    _watchdogTimer?.cancel();
    _isImageLoaded = false;
    if (kIsWeb && _isNetwork && !_isSvg) {
      _watchdogTimer = Timer(const Duration(seconds: 10), () {
        if (mounted && !_isImageLoaded && retryCount < widget.maxRetries) {
          logInfo('Web image load hung for 10s (pending). Retrying...');
          _triggerImageRetry();
        }
      });
    }
  }

  void _computeImageMeta() {
    final path = widget.path.trim();
    _isNetwork = path.startsWith('http://') || path.startsWith('https://');
    _isSvg = path.toLowerCase().endsWith('.svg');
  }

  void _triggerImageRetry() {
    scheduleRetry(
      maxRetries: widget.maxRetries,
      onRetry: () {
        if (kIsWeb && _isNetwork && !_isSvg) {
          NetworkImage(_bustedPath).evict();
        }
        _startWatchdog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = _effectiveController;
    Widget imageWidget;

    if (_isSvg) {
      if (_isNetwork) {
        imageWidget = _SvgNetworkWidget(
          controller: controller,
          url: _bustedPath,
          width: widget.width,
          height: widget.height,
          color: widget.color,
          fit: widget.fit,
          placeholder: widget.placeholder,
          errorWidget: widget.errorWidget,
          maxRetries: widget.maxRetries,
        );
      } else {
        imageWidget = svg.SvgPicture.asset(
          widget.path,
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
        );
      }
    }
    else if (kIsWeb && _isNetwork) {
      imageWidget = Image.network(
        _bustedPath,
        key: ValueKey('$_bustedPath-$retryCount'),
        width: widget.width,
        height: widget.height,
        cacheWidth: widget.cacheWidth,
        cacheHeight: widget.cacheHeight,
        fit: widget.fit,
        color: widget.color,
        errorBuilder: (context, error, stackTrace) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _triggerImageRetry();
            }
          });
          if (retryCount < widget.maxRetries) {
            return _NetworkPlaceholder(
              placeholder: widget.placeholder,
              width: widget.width,
              height: widget.height,
            );
          }
          return _NetworkErrorWidget(
            errorWidget: widget.errorWidget,
            width: widget.width,
            height: widget.height,
          );
        },
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (frame != null) {
            _isImageLoaded = true;
            _watchdogTimer?.cancel();
          }

          if (wasSynchronouslyLoaded || !widget.fadeIn) return child;
          return _NetworkFadeIn(child: child);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _NetworkPlaceholder(
            placeholder: widget.placeholder,
            width: widget.width,
            height: widget.height,
          );
        },
      );
    }
    else if (_isNetwork) {
      imageWidget = _NativeBitmap(
        controller: controller,
        url: _bustedPath,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        color: widget.color,
        placeholder: widget.placeholder,
        errorWidget: widget.errorWidget,
        maxRetries: widget.maxRetries,
        cacheWidth: widget.cacheWidth,
        cacheHeight: widget.cacheHeight,
        fadeIn: widget.fadeIn,
      );
    }
    else {
      imageWidget = Image.asset(
        widget.path,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        color: widget.color,
        cacheWidth: widget.cacheWidth,
        cacheHeight: widget.cacheHeight,
        errorBuilder: (context, error, stackTrace) => _NetworkErrorWidget(
          errorWidget: widget.errorWidget,
          width: widget.width,
          height: widget.height,
        ),
      );
    }

    return imageWidget;
  }
}
