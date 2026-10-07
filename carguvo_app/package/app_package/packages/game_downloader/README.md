# game_downloader

Check version → download `.zip` → unzip ra `<documents>/games/{gameName}`. Thuần Dart, không native. Xem chi tiết triển khai ở [`../README.md`](../README.md).

```dart
final downloader = GameDownloader();
await for (final p in downloader.prepareGame('taixiu')) {
  if (p.phase == DownloadPhase.done) print('Ready: ${p.gamePath}');
}
```

Cấu hình server qua `GameDownloader(config: GameDownloaderConfig(apiBaseUrl: ...))`.
