import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:sun_sports/core/utils/sprite/sprite_atlas.dart';

@immutable
class AtlasSource {
  final String? jsonUrl;

  final String? imageUrl;

  final String? jsonAsset;
  final String? imageAsset;

  const AtlasSource.remote(this.jsonUrl, {this.imageUrl})
      : jsonAsset = null,
        imageAsset = null;

  const AtlasSource.asset(this.jsonAsset, {this.imageAsset})
      : jsonUrl = null,
        imageUrl = null;

  bool get isRemote => jsonUrl != null;

  @override
  bool operator ==(Object other) =>
      other is AtlasSource &&
      other.jsonUrl == jsonUrl &&
      other.imageUrl == imageUrl &&
      other.jsonAsset == jsonAsset &&
      other.imageAsset == imageAsset;

  @override
  int get hashCode => Object.hash(jsonUrl, imageUrl, jsonAsset, imageAsset);
}

Future<Uint8List> _httpFetch(String url) async {
  final res = await http.get(Uri.parse(url));
  if (res.statusCode != 200) {
    throw Exception('Atlas tải lỗi ($url): HTTP ${res.statusCode}');
  }
  return res.bodyBytes;
}

final spriteAtlasProvider =
    FutureProvider.family<SpriteAtlas, AtlasSource>((ref, source) async {
  final SpriteAtlas atlas;
  if (source.isRemote) {
    atlas = await SpriteAtlas.loadRemote(
      jsonUrl: source.jsonUrl!,
      imageUrl: source.imageUrl,
      fetch: _httpFetch,
    );
  } else {
    atlas = await SpriteAtlas.loadAsset(
      jsonAsset: source.jsonAsset!,
      imageAsset: source.imageAsset,
    );
  }
  ref.onDispose(atlas.dispose);
  return atlas;
});

Future<void> preloadAtlas(WidgetRef ref, AtlasSource source) {
  return ref.read(spriteAtlasProvider(source).future);
}
