# Changelog

## 0.0.2 (2026-08-20)

### 🚀 Enhancements & Architecture Alignment
- **Clean Architecture Error Pipeline**: Aligned with `lodic_rest` standards:
  - Removed `onResponse` rejection from `GameApiErrorInterceptor`, keeping Dio interceptors purely focused on HTTP/network errors (`onError`).
  - Business errors in `HTTP 200` responses are parsed via `GameApiResponse.fromJson` and thrown as clean, typed `GameApiException` directly via `dataOrThrow`.
  - Avoided redundant and wasteful retry attempts in `GameApiRetryInterceptor` on deterministic business errors.
- **Jackpot Realtime Support**:
  - Added `JackpotEntry` model and `GameApiClient.getJackpots()` for public jackpot endpoint `GET /jackpot/all`.
  - Integrated `_parseNum` currency policy parsing.

## 0.0.1 (2026-04-01)

### 📦 Initial Release

- Initial extraction of `game_api_client` from `lib/core` as a standalone Pure Dart package.
- Transitioned to Pure Dart (no depends on `sdk: flutter`) using `package:meta` and basic platform abstractions.
- Adopted VGV style architecture:
  - Internals hidden in `lib/src`.
  - Public interface exposed via `lib/game_api_client.dart`.
- Included models for:
  - `ProviderGames`: List of game providers and games.
  - `GetGameUrlRequest`: Game launch request data.
  - `GameUrlData`: Resulting game URL data.
  - `GameApiResponse`: Unified API response wrapper.
- Interceptors:
  - `GameApiErrorInterceptor`: Unified business error handling.
  - `GameApiTokenRefreshInterceptor`: Standard 401 token refresh mechanism.
- Analysis & Quality:
  - Enabled `flutter_lints` for coding standards.
  - Full support for `freezed` and `json_serializable` code generation.
