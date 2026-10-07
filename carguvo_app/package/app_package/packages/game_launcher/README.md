# game_launcher

Bọc `MethodChannel("<package>/launcher").invokeMethod("launchGame", ...)` để bàn giao từ Flutter sang native Cocos engine. Dart-only — native do app host (Cocos template) cung cấp. Xem chi tiết ở [`../README.md`](../README.md).

```dart
final result = await GameLauncher().launch(GameLaunchConfig(
  gamePath: gamePath,
  gameName: 'taixiu',
  credentials: GameCredentials(userToken: ..., refreshToken: ..., userName: ..., userPassword: ...),
));
```

`launch()` luôn trả `GameLaunchResult` (Success/Failure), không ném exception.
