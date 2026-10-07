import 'dart:async';

abstract class AssetReloader {
  Future<bool> reload({void Function(double progress)? onProgress});

  Future<bool> retry({void Function(double progress)? onProgress});
}
