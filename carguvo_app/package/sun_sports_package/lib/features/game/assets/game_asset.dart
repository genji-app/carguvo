import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';

import 'package:sun_sports/features/game/assets/game_asset_cache_provider.dart';
import 'package:sun_sports/features/game/assets/dynamic_assets/dynamic_assets.dart';

class GameAssetScope extends ConsumerWidget {
  const GameAssetScope({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(gameAssetCacheControllerProvider);
    return AssetCacheScope(controller: controller, child: child);
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    const double borderRadius = 8.0;
    if (kIsWeb) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      );
    }

    return Shimmer(
      duration: const Duration(milliseconds: 1500),
      color: const Color(0xFF3D3D3D),
      colorOpacity: 0.3,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class GameAssetImage extends StatelessWidget {
  const GameAssetImage({
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.cacheWidth,
    this.cacheHeight,
    this.errorWidget,
    this.placeholder,
    this.fadeIn =
        !kIsWeb,
    super.key,
  });

  final String imagePath;

  final double? width;

  final double? height;

  final BoxFit fit;

  final int? cacheWidth;

  final int? cacheHeight;

  final Widget? errorWidget;

  final Widget? placeholder;

  final bool fadeIn;

  @override
  Widget build(BuildContext context) {
    return ImageHelper.load(
      path: imagePath,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
      placeholder: placeholder ?? _Placeholder(width: width, height: height),
      errorWidget: errorWidget,
    );
  }
}
