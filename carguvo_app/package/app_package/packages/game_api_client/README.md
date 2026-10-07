# 📦 Package: game_api_client 🕹️

A Pure Dart client for interacting with the Game API. This package provides a type-safe, robust implementation for managing game providers, game listings, and obtaining launch URLs with automatic token management.

---

## 🚀 Key Features

- **Pure Dart**: Zero dependencies on Flutter framework, making it suitable for Server-side Dart, Command line tools, or background Isolates.
- **VGV Style Architecture**: Follows the [Very Good Ventures](https://verygood.ventures/) standard for package structure and encapsulation.
- **Type-Safe Models**: Powered by `freezed` and `json_serializable` for immutable data structures and seamless JSON parsing.
- **Automatic Token Management**: Built-in interceptors for injecting authorization tokens and handling 401 token refresh cycles.
- **Business Error Detection**: Specialized `GameApiException` to distinguish between network failures and server-side business logic errors.

---

## 📦 Installation

Add the package path to your project's `pubspec.yaml`:

```yaml
dependencies:
  game_api_client:
    path: packages/game_api_client
```

---

## 📖 Usage Guide

### 1. Initialize the Client

The client requires a `Dio` instance and a `TokenProvider` callback.

```dart
final dio = GameApiClient.createDioClient(
  'https://api.your-domain.com/gameapi/public',
  onRefreshToken: () async {
    // Logic to refresh your session token
    return await authService.refreshToken();
  },
);

final client = GameApiClient(
  dio: dio,
  tokenProvider: () async => 'current-session-token',
);
```

### 2. Fetch Game Providers & Games

```dart
try {
  final providers = await client.getGames();
  for (final provider in providers) {
    print('Provider: ${provider.providerName}');
    for (final game in provider.gameList) {
      print(' - Game: ${game.gameName}');
    }
  }
} on GameApiException catch (e) {
  print('API Error [${e.errorCode}]: ${e.message}');
}
```

### 3. Get Game Launch URL

```dart
try {
  final url = await client.getGameUrl(
    GetGameUrlRequest(
      providerId: 'sunwin',
      productId: 'sunwin_SC',
      gameCode: 'SC',
      lang: 'vi',
      isMobileLogin: true,
    ),
  );
  print('Launch URL: $url');
} on GameApiUnauthorizedException {
  print('User session expired. Please re-login.');
} on GameApiException catch (e) {
  print('Failed to get launch URL: ${e.message}');
}
```

---

## 🛠️ Development & Testing

- **Generate Models**: Always run `dart run build_runner build --delete-conflicting-outputs` after model changes.
- **Analysis**: Maintain zero issues with `dart analyze`.
- **Formatting**: Run `dart format .` before committing.
- **Testing**: Run `dart test` to execute the unit test suite.

---
*Developed by Trippy*
