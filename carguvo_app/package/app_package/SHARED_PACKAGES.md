# Gộp code dùng chung cho app Flutter + jaspr_web

> Cập nhật: 08/09/2026. Tài liệu này tổng hợp đợt gộp hạ tầng dùng chung giữa
> `lib/` (app Flutter) và `jaspr_web/` (Dart web thuần, KHÔNG có Flutter SDK).

## Vì sao

Hai bản UI cùng sản phẩm nhưng chạy hai runtime khác nhau, nên trước đợt này
mọi thứ "chung về ý nghĩa" đều bị nhân bản bằng tay, và **đã lệch thật**:

| thứ bị nhân bản | bằng chứng lệch |
|---|---|
| `caxiloConfigUrl` | app trỏ jsDelivr, web trỏ raw.githubusercontent — cùng một file, hai nguồn, không ai chủ ý |
| model config casino | web port tay 724 dòng; chính tầng này từng đọc thiếu 3 khoá → **24 game live casino biến mất** |
| nhận diện phone/tablet/Safari theo User-Agent | **4 bản sao**, mỗi bản kèm comment "sửa một bên nhớ sửa bên kia" (đếm còn thiếu một) |
| `injectPreReleasePath` | 2 bản sao y hệt; lệch 1 ký tự là URL game vỡ ở một nền tảng, không ai biết |
| giải mã body config (JSON hoặc base64) | 3 bản sao |
| chuỗi hiển thị | web viết thẳng vào component kèm comment *"nguyên văn `I18n.xxx` bên app"* |
| `GameType` | 2 enum lệch tập member → map mất thông tin + 2 `switch` không phủ hết làm **cả loạt file test không compile nổi** |

Nguyên tắc đã theo: **gộp schema và cách lấy bytes, KHÔNG gộp cách sống với dữ
liệu đó** (state/vòng đời/UI của mỗi host giữ nguyên).

---

## Bản đồ package dùng chung

| package | nội dung | ai dùng |
|---|---|---|
| `packages/app_env` | `AppEnv` (env + URL config, compile-time) · `AppDevice` · `AppStorage` · `AppHttp` · `AppSession` | app, web, `provider_game_manager`, `game_engine` |
| `packages/app_i18n` | `I18n` — chuỗi hiển thị | app (re-export), web |
| `packages/brand_config` | mirror CDN, ứng viên URL, giải mã JSON/base64, model `BrandConfig` | app, web |
| `packages/caxilo_config` | schema + parse config casino (nay **pure Dart**) | app, web, `caxilo_repository` |
| `packages/provider_game_manager` | manager game provider + config lobby (nay **không có env riêng**; tách `lib/src/` thành 8 `part`) | app, web |

### `app_env` — 1 hằng số + 4 facade runtime

`AppEnv` là hằng compile-time (`String.fromEnvironment('APP_ENV')`), không cần
khởi tạo. 4 facade còn lại host **nạp một lần lúc boot**, rồi mọi package chung
đọc — thay cho việc mỗi package tự khai một "env" riêng:

| facade | trả lời | backing app Flutter | backing jaspr_web |
|---|---|---|---|
| `AppDevice` | browser/phone/tablet/iPad/Safari/Firefox, `platformId`, `versionId`, URL trang | `kIsWeb` + `dart:io` + `navigator` + `location` | `universal_web` |
| `AppStorage` | key-value **đồng bộ**, không bao giờ ném | `SharedPreferences` (warm ở `main`) | `localStorage` |
| `AppHttp` | `get`/`post` trả body thô | `LoggedHttp` | `package:http` + `AuthConfig.proxied` |
| `AppSession` | `accessToken`, `isLoggedIn`, `gold`, `language` | `SbApiClient.userToken` + `userProvider` (qua `bindGold`) | `AuthState.accessToken` / `.gold` |

Cả 4 **an toàn khi chưa configure** (mặc định vô hại, không ném) nên widget
test / unit test không phải khai gì. Mặc định `gold = 0` ⇒ cổng "đủ tiền" là
CHẶN, không cho qua oan.

**Nơi nạp**

- app: `lib/main.dart` (`AppDevice` ngay sau `ensureInitialized`, rồi
  `await configureAppFacades()` — xem `lib/core/services/config/app_facades.dart`),
  + `AppSession.bindGold(...)` trong `lib/app.dart` (số dư nằm trong Riverpod
  nên phải chờ có `ref`).
- web: `jaspr_web/lib/main.client.dart` dòng đầu `_main()` +
  `jaspr_web/lib/services/config/app_facades.dart`.

**Resource CDN + segment path (16/09/2026)** — `AppEnv.rsBaseUrl` là gốc CDN tài
nguyên, và phép ghép segment path giờ là logic DÙNG CHUNG:
`AppEnv.resourcePathSegment` (`''` | `devN` | `pre`) + `AppEnv.withPathSegment`
(trim `/` cuối, idempotent — config đã khai `/dev1` thì không nối đôi). App gọi
2 hàm này trong `SbConfig.applyBrandConfig`; web gọi ngay trong `rsBaseUrl`.
Trước đó mỗi bên tự trim/nối một kiểu → lệch một ký tự là một nền tảng đọc sai
thư mục resource mà **không có lỗi nào nổi lên**. Cùng lý do đã gộp
`AppEnv.injectPreReleasePath` (08/09/2026 — bị nhân bản nguyên si ở
`CasinoLauncher._buildInHouseUrl` + `GameUrlResolver._resolveInHouse`).

⚠️ Còn 1 bất đối xứng CÓ CHỦ Ý: pre-release thì app nối `/pre` vào `rs_domain`,
web thêm KHÔNG (asset rs của web pre vẫn ở gốc prod). `/pre` của web chỉ áp cho
URL game in-house qua `injectPreReleasePath`. Muốn đổi thì sửa 1 chỗ
(`rsBaseUrl`) vì phép ghép đã ở package.

---

## Đã làm, theo từng việc

### 1. `caxilo_config` thành pure Dart → web dùng chung, xoá bản port tay

- Bỏ `flutter` khỏi `dependencies` (thực tế `lib/` chưa từng import
  `package:flutter`; mấy chỗ khớp chữ "flutter" chỉ là string literal
  `'flutter-web'`). `flutter_test` → `test`, `flutter_lints` → `lints`.
- Thêm entry `caxilo_models.dart` (chỉ model, không client/preset) để web không
  kéo 84K preset vào bundle JS.
- `jaspr_web/lib/services/casino/caxilo_config.dart`: **724 → 165 dòng**, giờ là
  adapter: re-export model chung + 4 `typedef` giữ tên cũ
  (`InHouseGameConfig`, `InHouseVisibility`, `ExternalGameConfig`,
  `FilterConfig`) + phần bù web-only (`orderIndex` memo qua `Expando`,
  `visibilityOf`, `isEmpty`, `resolveApiGameCode`, `whitelistedProviderIds`,
  `kEmptyCaxiloConfig`, `orientationsFromJson`).
- Đổi hành vi có chủ ý: `fromJson` của package **nghiêm** hơn bản port (thiếu
  khoá `required` là ném) — cùng hành vi app Flutter đang có, và web vẫn an toàn
  vì `CaxiloStore._load` hợp nhất `{...preset, ...remote}` trước khi parse.

### 2. `app_env` + `injectPreReleasePath`

- Hai file `AppEnv` song song (71 + 166 dòng) → 1 package; hai file cũ chỉ còn
  re-export. Phần chỉ web có tách thành `WebEnv.caxiloPresetUrl`.
- **Chốt nguồn `caxiloConfigUrl`**: raw GitHub là chính, jsDelivr là fallback
  (theo bản web). App đổi theo, không rủi ro vì `CacheBustingHttpClient` tự dịch
  jsDelivr ↔ raw khi primary non-200.
- `injectPreReleasePath` hết nhân bản.
- KHÔNG gộp breakpoints: app desktop 1439 vs web 1280, lệch có chủ ý.

### 3. `brand_config` — chỉ tầng fetch + fallback + model

- `githubMirrorUrl`, `isGithubConfigUrl`, `configCandidates`,
  `preReleaseVariantUrl`, `decodeConfigBody` (JSON **hoặc** base64, xoá
  whitespace), `fetchFirstOkConfig` (host tiêm hàm tải), model `BrandConfig`
  (đọc khoan dung: kiểu sai → `null` thay vì ném giữa lúc apply).
- Nối vào: `SbConfigLoader` xoá 3 bản sao, `SbConfig.applyBrandConfig` đọc qua
  model, `AuthConfig` của web dùng `decodeConfigBody` + `fetchFirstOkConfig`.
- **Dừng ở đó**: `CaxiloConfigSyncNotifier` (Riverpod + connectivity +
  lifecycle) và `CaxiloStore`/`CasinoCatalog` giữ riêng.
- `BrandConfig.rsDomain` — **có** trong cả 2 config (verify 16/09/2026):
  `s88_staging.json` → `https://common-s88.sandboxg1.win/`, `s88.json` →
  `https://rs.static607zgn.com/` (ghi chú cũ trong `brand_config_model.dart` nói
  khoá không tồn tại là SAI). Getter trả **chuỗi thô**, KHÔNG biết sub-env staging
  (`/devN`) lẫn `/pre` — phép ghép do host áp qua `AppEnv.withPathSegment` +
  `AppEnv.resourcePathSegment` (xem mục `app_env` trên). Web KHÔNG đọc getter này.

### 4. `AppDevice` — gộp 4 bản nhận diện UA

Host nạp dữ kiện thô (`platform`, `userAgent`, `maxTouchPoints`, `pageUrl`,
`pageBaseUrl`); phân loại nằm một chỗ. Đã nối: `web_browser_detect` (app),
`PlatformUtils`, `SbConfig.platformId`/`versionId`, `web_device.dart` (web),
2 file trong `game_engine`, và `provider_game_manager`.

Đổi hành vi có chủ ý: web `isWebIOSBrowser` giờ bắt được iPadOS 13+ giả dạng
Safari desktop (`Macintosh` + `maxTouchPoints > 1`); bản cũ cố ý bỏ sót để
"khớp điểm mù bên app" — nay cả hai cùng đi qua `AppDevice`.

### 5. `provider_game_manager` — xoá `ProviderGameEnv` (18 member)

| env cũ | nay |
|---|---|
| `isBrowser`, `isMobile` | `AppDevice` |
| `homeUrl`, `pageBaseUrl` | `AppDevice.pageUrl` / `.pageBaseUrl` |
| `httpGet`, `httpPost` | `AppHttp` |
| `storageGet`, `storageSet` | `AppStorage` |
| `isLoggedIn`, `accessToken` | `AppSession` |
| `gold` | `AppSession.gold` |
| `language` | `AppSession.language` (lưu `AppStorage`, khoá `app.language`, mặc định `vi`) |
| `excludedGameIds` | khoá `excludedGameIds` của `lobbyGameConfig.json` |
| `lastGamePlayed`, `setLastGamePlayed` | `recentGameRefs` / `pushRecentGameRef` (`AppStorage`, **max 10**; Sun: `gameId`, NCC: `providerId_productId_gameCode`) |
| `showLoginPopup`, `showLoading`, `hideLoading`, `showMessage`, `openNewTab`, 3 × `msg*` | các nhánh của `ProviderGamePlayDecision` + `I18n` của `app_i18n` |

Thêm:

- `applyLobbyConfig(raw)` là entry point duy nhất cho lobby config — manager
  KHÔNG còn tự tải URL (`DynamicRsmanifest` là thứ riêng của app Cocos). Host
  đọc file từ bundle: `BundleManager.getTextData` (app) /
  `MiniGameAssets.getTextData` (web) → `LobbyGameConfigLoader`.
- Cache danh sách game: `sendGetGameList` lưu **raw body** lượt thành công gần
  nhất vào `AppStorage`; `init()` khôi phục ngay lúc khởi tạo để UI vẽ trước khi
  `/games` về. Body lỗi/`status != 0` không bao giờ được cache.
- `resolvePlay(gameId)` trả `sealed ProviderGamePlayDecision`: `Busy` /
  `NeedLogin` / `GameMaintaining` / `NotEnoughMoney(gold, required)` /
  `Unavailable(gameId, reason)` / `OpenInNewTab(url, game)` / `Play(url, game)`.
  Thứ tự 8 cổng giữ nguyên bản gốc. Host tự làm loading/toast/popup/mở tab.
- Danh sách gần đây: luôn đẩy lên đầu (đã có thì xoá chỗ cũ, không nhân bản),
  quá 10 thì cắt cuối; mỗi entry là **ref** của `LobbyGame` — game Sun lưu
  `gameId` dạng chuỗi, game NCC lưu `providerId_productId_gameCode` (KHÔNG lưu
  gameId của API `/games`: game khai trong `externalGames` của config không có
  gameId). `gameUrlOf` tự push khi mở được game (cả Sun lẫn NCC);
  `resolvePlay` tự push khi mở được game provider.
  ⚠️ Khác `CasinoRecentGamesStore` của web (max 5, khoá
  `providerId|productId|gameCode`, chỉ ô tìm kiếm Casino ghi).

### 6. `app_i18n`

- `lib/core/constants/i18n.dart` (387 dòng) → package chung; file cũ chỉ còn
  re-export nên call-site của app không đổi.
- Thêm 3 message cho game provider: `msgGameMaintain`, `msgNotEnoughMoney`,
  `msgRoomMaintained`.
- Đã đổi **19 chỗ** trong web sang `I18n.xxx` — đúng nhóm có bằng chứng ý định
  (comment trong file tự nhận là `I18n.<name>` và literal khớp byte-for-byte).
- KHÔNG để trong `app_env`: `app_env` là môi trường/nền tảng, còn đây là danh
  mục chữ UI (~390 dòng, sẽ phình khi thêm ngôn ngữ).

### 7. `GameType` — đồng bộ 2 enum

- `game_api_client.GameType` (số, từ API `/providers/games`) nay cùng tập
  member + cùng thứ tự với `caxilo_config.GameType` (tên chuỗi, từ config).
- 5 member chỉ có ở lobby (`none`, `sun`, `newGame`, `recent`, `provider`) mang
  **value âm sentinel** `-2…-6`, mỗi member một số riêng ⇒ `fromValue` vẫn đơn
  ánh; `isApiType` chặn việc gửi số sentinel lên API. Thêm `fromName` khoan
  dung (đối xứng với bản config: `'fish'`→`fishing`, `'cardgame'`→`card`).
- `caxilo_mapper` map **1-1 hai chiều** cho mọi member (trước đó 5 member kia bị
  dồn vào `unknown` → round-trip không về được).
- `game_type_parity_test.dart` canh: lệch tập member / lệch thứ tự / value
  trùng nhau / map mất thông tin đều đỏ ngay.

### 8. `BundleManager.getTextData` (app) & `MiniGameAssets.getTextData` (web)

Trước đó không có hàm nào trả **text** từ bundle (chỉ `File`/URL). Nay một lời
gọi lo trọn: native đọc disk cache (0 request), web `GET` một lượt theo URL
content-hash; `svg_symbol` trả markup trong RAM; lỗi → `null`, không ném.

---

## Sửa 2 lỗi CÓ SẴN chặn compile

Ở HEAD, `caxilo_config.GameType` đã có `none/sun/newGame/recent/provider` nhưng
2 `switch` chưa phủ hết ⇒ **lỗi biên dịch**, làm cả loạt file test không chạy
nổi:

- `lib/features/game/game_extensions.dart` (`GameTypeUI.displayName`)
- `packages/caxilo_repository/lib/src/games/caxilo_mapper.dart`

Vá xong thì số test **chạy được** tăng vọt (xem bảng dưới) — phần fail còn lại
là lỗi có sẵn, không đi qua code đợt này: seed store sport (`Bad state: No
element`) và `MissingPluginException(path_provider)` khi Hive init trong test.

---

## Kiểm chứng

| suite | kết quả |
|---|---|
| `app_env` | 33 pass |
| `app_i18n` | 3 pass |
| `brand_config` | 32 pass |
| `caxilo_config` | 68 pass |
| `provider_game_manager` | 33 pass |
| `caxilo_repository` | 173 pass |
| `game_api_client` | 67 pass |
| `flutter analyze lib` | 0 error |
| `dart analyze lib` (jaspr_web) | 0 error, 0 warning (21 info có sẵn) |

App test, đo bằng worktree ở HEAD để so:

| | HEAD | sau đợt gộp |
|---|---|---|
| `test/core` | 177 pass / 26 fail | **340 pass / 17 fail** |
| `test/features` + `providers` + `shared` | 554 pass / 49 fail | **806 pass / 19 fail** |

Ròng: `packages/` **+251 −61**, `lib/` + `jaspr_web/` **+75 −407**.

---

## Còn lại / khuyến nghị

1. **CHẶN THỬ NGHIỆM THỰC TẾ**: chạy `tools/upload_resources.py` cho bundle
   `dynamic` + deploy để CDN có `assets/dynamic/others/lobbyGameConfig.<hash>.json`.
   Trước đó cả hai `LobbyGameConfigLoader` chỉ log "chưa đọc được" và trả `false`.
2. **Web còn ~340 chuỗi** khớp byte-for-byte với hằng `app_i18n` nhưng KHÔNG có
   bằng chứng ý định. Cố ý chưa đổi: một số literal có thể là **giá trị wire**
   (khoá payment method, giá trị API) chỉ tình cờ trùng nhãn tiếng Việt — buộc
   nó vào `I18n` thì mai đổi nhãn là đổi luôn giá trị gửi lên server. Nên đổi
   thủ công theo từng màn.
3. `caxilo_repository.fromPackageGameType` còn `switch (packageType.value)` với
   10 case 1…20 — bảng số thứ hai, và nó nhận vào enum ĐÃ parse nên nhánh theo
   tên là đủ. Gọn lại được 1 dòng; chưa làm vì bạn chưa chốt.
4. `AppSession.language` đã có chỗ lưu nhưng **chưa có UI đổi ngôn ngữ**; khi
   thêm, `app_i18n` chuyển từ hằng sang tra bảng theo `AppSession.language` —
   call-site không phải sửa.
5. Chưa host nào gọi `ProviderGameManager.resolvePlay`. Khi nối UI: map quyết
   định → `I18n.msgGameMaintain` / `msgNotEnoughMoney` / `msgRoomMaintained`,
   mở tab bằng `new_tab_opener` (app) / cách của `CasinoLauncher` (web).

---

## Cập nhật Round 8 (15/09/2026) — xem `PACKAGE_LOGIC_REVIEW_R8.md`

- **XOÁ 3 package chết** (`game_jackpot`, `sport_live`, `sport_vibrating_odds`):
  không host nào import (app + web + package khác = 0 call-site). `game_jackpot`
  còn trùng tên class `JackpotTierState`/`JackpotDisplayState` với
  `casino_jackpot` (bản đang dùng thật). Lịch sử tạo/xoá giữ trong
  `SHARED_PACKAGES_ROUND5/6/7.md` (tài liệu lịch sử, KHÔNG sửa).
- **Auth uỷ quyền về package**: `lib/core/utils/auth_validator.dart` → re-export
  `auth_domain`; 3 entity app (`auth_entity.dart`, `auth_flow_result.dart`,
  `username_check_result.dart`) → re-export `auth_domain`; file
  `auth_entity.freezed.dart` của app đã XOÁ (freezed của package là bản duy nhất).
- **LoginTiming**: app delegate về `monitoring_domain` + bơm sink log/Sentry lúc
  boot (`AppFacades.configure`).

---

## Phân loại package + quy ước tầng (G1-3 / G2-3, 16/09/2026)

> Nguồn: `PACKAGE_LOGIC_IMPROVEMENT_PLAN.md` đợt 1–2. Cập nhật sau G1-1 (gộp
> `game_url` + `game_asset` + `game_launcher_lifecycle` → `game_foundation`) và
> G2-1 (tách `game_taxonomy`): **31 package**.

### Quy ước tầng (cấm đảo chiều)

- **Tầng 0** — pure Dart, 0 inter-dep: `dart_kit`, `app_env`, `app_format`,
  `app_i18n`, `game_taxonomy`, `brand_config`, `notification_domain`,
  `paygate_domain`, `sport_events`, `sport_notice`.
- Tầng cao hơn chỉ được dep tầng THẤP HƠN. Cấm dep ngược; cấm tầng 0 dep nhau
  (đặc biệt **cấm `app_format` phụ thuộc `betting_domain`** — chiều hiện tại
  là betting_domain → app_format, giữ nguyên).
- Luồng đã cắt (G2-1/G2-2): `transaction_domain` KHÔNG còn → `provider_game_manager`
  (qua `game_taxonomy`); `chat_protocol` KHÔNG còn → `auth_domain`
  (wire về `chat_wire.dart`; auth chỉ giữ token-error pattern, re-export tạm).

### Bảng phân loại

| Package | Loại | Host | Deps chính |
|---|---|---|---|
| `dart_kit` | PURE (tầng 0) | app + web | — |
| `app_env` | PURE (tầng 0) | app + web | — |
| `app_format` | PURE (tầng 0) | app + web | — |
| `app_i18n` | PURE (tầng 0) | app + web | — |
| `game_taxonomy` | PURE (tầng 0) | app + web | — |
| `brand_config` | PURE (tầng 0) | app + web | — |
| `notification_domain` | PURE (tầng 0) | app + web | — |
| `paygate_domain` | PURE (tầng 0) | app + web | — |
| `sport_events` | PURE (tầng 0) | app + web | — |
| `sport_notice` | PURE (tầng 0) | app + web | — |
| `auth_domain` | PURE | app + web | freezed_annotation, crypto, chat_protocol |
| `betting_domain` | PURE | app + web | app_format |
| `casino_jackpot` | PURE | app + web | game_api_client, meta |
| `chat_protocol` | PURE | app + web | clock |
| `game_api_client` | PURE | app + web | dio, freezed_annotation, json_annotation, meta |
| `game_foundation` | PURE | app | dart_kit, clock, provider_game_manager |
| `mini_game_countdown_core` | PURE | app + web | mini_game_protocol, clock |
| `mini_game_protocol` | PURE | app + web | freezed_annotation |
| `monitoring_domain` | PURE | app + web | sentry |
| `provider_game_manager` | PURE | app + web | app_env, game_taxonomy |
| `sport_socket` | PURE | app + web | web_socket_channel, protobuf |
| `transaction_domain` | PURE | app + web | game_taxonomy |
| `adaptive_overlay` | FLUTTER ONLY | app | flutter |
| `fullscreen_guard` | FLUTTER ONLY | app | flutter, meta, web |
| `game_downloader` | FLUTTER ONLY | app | flutter, dio, archive, hive |
| `game_engine` | FLUTTER ONLY | app | flutter, app_env, flutter_inappwebview |
| `game_launcher` | FLUTTER ONLY | app | flutter, package_info_plus |
| `game_orientation` | FLUTTER ONLY | app | flutter, provider_game_manager, orientation_guard |
| `orientation_guard` | FLUTTER ONLY | app | flutter, meta, web |
| `floating_draggable_widget` | FORK (FLUTTER ONLY) | app | flutter (SDK cũ >=2.16.2 — ngoại lệ G5) |
| `flutter_slider_drawer` | FORK (FLUTTER ONLY) | app | flutter |

- **PURE** = không import `package:flutter` — import được từ cả app lẫn
  `jaspr_web` (nơi nào không dùng thật thì host không khai dep, vd web không
  khai `game_foundation`).
- **FLUTTER ONLY** = có `sdk: flutter` — CHỈ app; description pubspec đã gắn
  nhãn. KHÔNG được import từ `jaspr_web` (guard CI G6-6).
- **FORK** = fork nội bộ của package pub.dev, giữ nguyên tên — đã khai
  `publish_to: none` chặn publish nhầm.
