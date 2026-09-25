import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/utils/sprite/sprite_atlas.dart';
import 'package:sun_sports/core/utils/sprite/sprite_atlas_provider.dart';

class AtlasIcon extends ConsumerWidget {
  final AtlasSource source;
  final String name;
  final double? width;
  final double? height;

  final Color? color;

  final BoxFit fit;

  final Widget? placeholder;

  final Widget? errorWidget;

  final FilterQuality filterQuality;

  const AtlasIcon({
    super.key,
    required this.source,
    required this.name,
    this.width,
    this.height,
    this.color,
    this.fit = BoxFit.contain,
    this.placeholder,
    this.errorWidget,
    this.filterQuality = FilterQuality.medium,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(spriteAtlasProvider(source));

    return async.when(
      loading: () => _box(placeholder ?? const SizedBox.shrink()),
      error: (e, _) => _box(errorWidget ?? const SizedBox.shrink()),
      data: (atlas) {
        final frame = atlas.frame(name);
        if (frame == null) {
          assert(() {
            debugPrint('[AtlasIcon] không tìm thấy frame "$name". '
                'Có sẵn: ${atlas.names.take(10).join(", ")}...');
            return true;
          }());
          return _box(errorWidget ?? const SizedBox.shrink());
        }
        final Widget fitted = FittedBox(
          fit: fit,
          clipBehavior: Clip.hardEdge,
          child: CustomPaint(
            size: frame.sourceSize,
            painter: _AtlasIconPainter(
              image: atlas.image,
              frame: frame,
              color: color,
              filterQuality: filterQuality,
            ),
          ),
        );
        if (width != null || height != null) {
          return SizedBox(width: width, height: height, child: fitted);
        }
        return fitted;
      },
    );
  }

  Widget _box(Widget child) =>
      SizedBox(width: width, height: height, child: child);
}

class _AtlasIconPainter extends CustomPainter {
  final ui.Image image;
  final AtlasFrame frame;
  final Color? color;
  final FilterQuality filterQuality;

  _AtlasIconPainter({
    required this.image,
    required this.frame,
    required this.color,
    required this.filterQuality,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..filterQuality = filterQuality;
    if (color != null) {
      paint.colorFilter = ColorFilter.mode(color!, BlendMode.srcIn);
    }

    final src = frame.frame;
    final source = frame.sourceSize;
    final content = frame.contentSize;
    final scaleX = size.width / source.width;
    final scaleY = size.height / source.height;

    if (frame.rotated) {
      canvas.save();
      canvas.translate(
        frame.spriteOffset.dx * scaleX,
        frame.spriteOffset.dy * scaleY,
      );
      final contentW = content.height * scaleX;
      final contentH = content.width * scaleY;
      canvas.translate(0, contentH);
      canvas.rotate(-1.5707963267948966);
      canvas.drawImageRect(
          image, src, Rect.fromLTWH(0, 0, contentH, contentW), paint);
      canvas.restore();
    } else {
      final dst = Rect.fromLTWH(
        frame.spriteOffset.dx * scaleX,
        frame.spriteOffset.dy * scaleY,
        content.width * scaleX,
        content.height * scaleY,
      );
      canvas.drawImageRect(image, src, dst, paint);
    }
  }

  @override
  bool shouldRepaint(_AtlasIconPainter old) =>
      old.image != image ||
      old.frame != frame ||
      old.color != color ||
      old.filterQuality != filterQuality;
}
