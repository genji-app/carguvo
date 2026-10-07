import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

@immutable
class AtlasFrame {
  final Rect frame;

  final Size sourceSize;

  final Size contentSize;

  final Offset spriteOffset;

  final bool rotated;

  const AtlasFrame({
    required this.frame,
    required this.sourceSize,
    required this.contentSize,
    required this.spriteOffset,
    required this.rotated,
  });

  factory AtlasFrame.fromJson(Map<String, dynamic> json) {
    final f = json['frame'] as Map<String, dynamic>;
    final src = json['sourceSize'] as Map<String, dynamic>?;
    final sss = json['spriteSourceSize'] as Map<String, dynamic>?;
    final rotated = json['rotated'] as bool? ?? false;
    final scale = (json['scale'] as num?)?.toDouble() ?? 1.0;
    final s = scale == 0 ? 1.0 : scale;

    final fw = (f['w'] as num).toDouble();
    final fh = (f['h'] as num).toDouble();
    final rect = Rect.fromLTWH(
      (f['x'] as num).toDouble(),
      (f['y'] as num).toDouble(),
      rotated ? fh : fw,
      rotated ? fw : fh,
    );

    final contentSize = Size(fw / s, fh / s);

    return AtlasFrame(
      frame: rect,
      sourceSize: src == null
          ? contentSize
          : Size(
              (src['w'] as num).toDouble() / s,
              (src['h'] as num).toDouble() / s,
            ),
      contentSize: contentSize,
      spriteOffset: sss == null
          ? Offset.zero
          : Offset(
              (sss['x'] as num).toDouble() / s,
              (sss['y'] as num).toDouble() / s,
            ),
      rotated: rotated,
    );
  }
}

void paintAtlasFrame(
  Canvas canvas,
  ui.Image image,
  AtlasFrame frame,
  Rect dst, {
  Paint? paint,
}) {
  final source = frame.sourceSize;
  if (source.width <= 0 || source.height <= 0) return;
  final p = paint ?? (Paint()..filterQuality = FilterQuality.medium);
  final scaleX = dst.width / source.width;
  final scaleY = dst.height / source.height;
  final content = frame.contentSize;

  canvas.save();
  canvas.translate(
    dst.left + frame.spriteOffset.dx * scaleX,
    dst.top + frame.spriteOffset.dy * scaleY,
  );
  if (frame.rotated) {
    final contentW = content.height * scaleX;
    final contentH = content.width * scaleY;
    canvas.translate(0, contentH);
    canvas.rotate(-math.pi / 2);
    canvas.drawImageRect(
      image,
      frame.frame,
      Rect.fromLTWH(0, 0, contentH, contentW),
      p,
    );
  } else {
    canvas.drawImageRect(
      image,
      frame.frame,
      Rect.fromLTWH(0, 0, content.width * scaleX, content.height * scaleY),
      p,
    );
  }
  canvas.restore();
}

class SpriteAtlas {
  final ui.Image image;
  final Map<String, AtlasFrame> frames;

  const SpriteAtlas({required this.image, required this.frames});

  AtlasFrame? frame(String name) => frames[name];

  bool contains(String name) => frames.containsKey(name);

  Iterable<String> get names => frames.keys;

  void dispose() => image.dispose();

  static Map<String, AtlasFrame> _parseFrames(Map<String, dynamic> json) {
    final framesJson = json['frames'] as Map<String, dynamic>;
    return framesJson.map(
      (name, value) =>
          MapEntry(name, AtlasFrame.fromJson(value as Map<String, dynamic>)),
    );
  }

  static Map<String, AtlasFrame> parseFrames(Map<String, dynamic> json) {
    return _parseFrames(json);
  }

  static Future<ui.Image> decodeImage(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  static Future<SpriteAtlas> loadRemote({
    required String jsonUrl,
    String? imageUrl,
    required Future<Uint8List> Function(String url) fetch,
    bool bustCache = true,
  }) async {
    final jsonFetchUrl = bustCache
        ? _appendQuery(
            jsonUrl,
            '_',
            DateTime.now().millisecondsSinceEpoch.toString(),
          )
        : jsonUrl;
    final jsonBytes = await fetch(jsonFetchUrl);
    final jsonMap = jsonDecode(utf8.decode(jsonBytes)) as Map<String, dynamic>;
    final frames = _parseFrames(jsonMap);

    var resolvedImageUrl = imageUrl ?? _resolveImageUrl(jsonUrl, jsonMap);
    if (bustCache) {
      final meta = jsonMap['meta'] as Map<String, dynamic>?;
      final token =
          (meta?['version']?.toString().trim().isNotEmpty ?? false)
              ? meta!['version'].toString().trim()
              : _hashBytes(jsonBytes);
      resolvedImageUrl = _appendQuery(resolvedImageUrl, 'v', token);
    }
    final pngBytes = await fetch(resolvedImageUrl);
    final image = await decodeImage(pngBytes);

    return SpriteAtlas(image: image, frames: frames);
  }

  static String _appendQuery(String url, String key, String value) {
    final u = Uri.parse(url);
    final qp = Map<String, String>.from(u.queryParameters)..[key] = value;
    return u.replace(queryParameters: qp).toString();
  }

  static String _hashBytes(Uint8List bytes) {
    var hash = 0x811c9dc5;
    for (final b in bytes) {
      hash ^= b;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return hash.toRadixString(16);
  }

  static Future<SpriteAtlas> loadAsset({
    required String jsonAsset,
    String? imageAsset,
  }) async {
    final jsonStr = await rootBundle.loadString(jsonAsset);
    final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;
    final frames = _parseFrames(jsonMap);

    final imgAsset = imageAsset ?? _resolveAssetImage(jsonAsset, jsonMap);
    final data = await rootBundle.load(imgAsset);
    final image = await decodeImage(data.buffer.asUint8List());

    return SpriteAtlas(image: image, frames: frames);
  }

  static String _resolveImageUrl(String jsonUrl, Map<String, dynamic> jsonMap) {
    final meta = jsonMap['meta'] as Map<String, dynamic>?;
    final imageName = (meta?['image'] as String?) ?? 'atlas.png';
    return Uri.parse(jsonUrl).resolve(imageName).toString();
  }

  static String _resolveAssetImage(String jsonAsset, Map<String, dynamic> map) {
    final meta = map['meta'] as Map<String, dynamic>?;
    final imageName = (meta?['image'] as String?) ?? 'atlas.png';
    final idx = jsonAsset.lastIndexOf('/');
    final dir = idx == -1 ? '' : jsonAsset.substring(0, idx + 1);
    return '$dir$imageName';
  }
}
