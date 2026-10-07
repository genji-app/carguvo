# KẾ HOẠCH CẢI THIỆN PACKAGE LOGIC — CHI TIẾT & TIẾN ĐỘ

> Ngày tạo: 16/09/2026. Phạm vi: `packages/` (32 package) ↔ `lib/` (app Flutter) ↔ `jaspr_web/lib/`.
> Nguồn: rà soát toàn bộ `pubspec.yaml`, barrel `lib/*.dart`, `lib/src/`, đếm usage `grep -rl "package:<pkg>/" lib`, `Makefile`, `PACKAGE_LOGIC_REVIEW_R8.md` (Round 8 DONE W1–W13).
> File này là KẾ HOẠCH + THEO DÕI TIẾN ĐỘ (ID việc G1… + trạng thái cập nhật tại chỗ). Chưa thực thi code.
>
> **Cập nhật 16/09/2026 (v2 — sau lần duyệt đối chiếu code):** (1) baseline sửa: Semaphore có **3 bản** (thêm copy trong `lib/.../asset_cache_controller.dart`), `copyWith` lệch **2 chiều** (không clear được + tự xoá error), bổ sung **dead code `game_url_resolver`**, số dòng game_orientation 55L, SDK/lints liệt kê đủ; (2) thêm mục **G1-0** (quyết dead code trước G1-1); (3) G2-1 đổi đích sang **game_taxonomy** (không nhét vào dart_kit); (4) G3 mở rộng sang bản copy trong `lib/`, nghiệm thu grep toàn repo; (5) G4-1 bắt buộc **audit call-site** trước sentinel; (6) mục tiêu phân mảnh sửa thành **8 → 5**; (7) G5 bổ sung sport_socket/paygate_domain/provider_game_manager/orientation_guard/flutter_slider_drawer/game_api_client.

---

## 0. Baseline & mục tiêu

### 0.1. Baseline (15–16/09/2026)

| Kiểm định | Trạng thái |
|---|---|
| Số package | **32** (`ls -1 packages \| wc -l`) |
| `publish_to: none` | 32/32 |
| `analysis_options.yaml` | 32/32 |
| Round 8 (W1–W13) | DONE (xoá 3 package chết, gỡ dep thừa, sink thay `print`, test-shared-flutter) |
| Package 0 test file | **7** (`adaptive_overlay`, `fullscreen_guard`, `game_launcher`, `game_orientation`, `game_downloader`, `floating_draggable_widget`, `flutter_slider_drawer`) |
| Package test mỏng (1–2 file) | `game_asset` (1), `game_url` (1), `paygate_domain` (1), `notification_domain` (1), `monitoring_domain` (2) |
| Nhóm `game_*` phân mảnh | 8 package; 5 cái nhỏ ~710 dòng (`game_url` 166L — trong đó `game_url_resolver.dart` là **dead code**, `game_asset` 148L, `game_launcher` 209L, `game_launcher_lifecycle` 132L, `game_orientation` 55L); 3 cái giữ lại lớn: `game_api_client` 3.849L, `game_downloader` 561L, `game_engine` 4.748L |
| Dead code | `game_url/lib/src/game_url_resolver.dart` (`GameUrlResolver`/`GameUrlResult`/`GameUrlFetcher`, `GameUrlReady/Native/Blocked/Unavailable`): **không ai dùng** — app đi đường `ProviderGameManager.gameUrlOf` → `LobbyGameUrl*`, chỉ re-export `GameUrlState/Status/FailureKind` từ package |
| Đảo tầng phụ thuộc | `transaction_domain → provider_game_manager`, `chat_protocol → auth_domain`, `betting_domain → app_format` (doc sai) |
| Trùng logic | `Semaphore` có **3 bản**: `dart_kit.Semaphore` (chuẩn, đã có `assert(max>0)`), `game_asset.AssetSemaphore` (không guard), bản copy thứ 3 trong app `lib/features/game/assets/dynamic_assets/cache/asset_cache_controller.dart:15` (đang được `game_asset_cache_provider.dart` dùng); `DateTime.now()` trực tiếp trong `game_asset` (:124, :138) và bản lib copy (:113, :188) |
| Chuẩn SDK/lints/clock trôi | SDK: `floating_draggable_widget` >=2.16.2, `flutter_slider_drawer`/`sport_socket`/`fullscreen_guard` >=3.0.0, `dart_kit`/`game_engine`/`orientation_guard`/`paygate_domain` >=3.5.0, `provider_game_manager` ^3.5.0, `casino_jackpot` ^3.5.0, `game_api_client` >=3.8.0 (còn lại ^3.9.2 hoặc ">=3.9.2 <4.0.0"); lints: `sport_socket` ^3.0.0, còn lại ^5.0.0; flutter_lints: `floating_draggable_widget` ^2.0.1, `fullscreen_guard` ^4.0.0, hỗn hợp ^5/^6, `flutter_slider_drawer` **không khai lints nào**; `game_api_client` là pure (dio) nhưng dùng `flutter_lints`; `clock` ^1.1.1 (chat_protocol, mini_game_countdown_core) vs ^1.1.2 (game_launcher_lifecycle) |
| `copyWith` lệch chuẩn | `GameUrlState.copyWith`: `url`/`nativeBundle` **không clear được null** (`?? this.x`) nhưng `error`/`failureKind` thì **LUÔN ghi đè** (mọi `copyWith` đều xoá error — cùng họ bug C5 `ParlayState`); `GameLauncherState.copyWith`: `activeGame` không clear được null, `errorMessage` luôn ghi đè. Call-site (app `game_url_provider.dart`, `game_launcher.dart`, `main_shell_layout.dart`) đang DỰA vào hành vi "tự xoá error" |
| CI | Không có, bù bằng `make test-packages` |

### 0.2. Mục tiêu

1. **P0 — Gỡ rủi ro logic thật:** layering, dup Semaphore (3 bản), `copyWith` lệch chuẩn (2 chiều: không clear được + tự xoá error).
2. **P0 — Giảm phân mảnh `game_*`:** 8 → 5 package, ranh giới PURE vs FLUTTER_ONLY rõ, xoá dead code `game_url_resolver`.
3. **P1 — Chuẩn hoá cơ khí:** SDK/lints/clock/strict-casts đồng đều, description đúng.
4. **P1 — Lấp test:** 7 package 0-test → có test tối thiểu; ưu tiên package dùng nhiều.
5. **P2 — Dọn khi rảnh:** version, barrel `show`, god-package, fallback/timezone, CI.

### 0.3. Quy ước thực thi

- **Một việc / một nhánh / một commit** — không trộn việc. Xong cả app + web mới merge.
- **Thứ tự mỗi việc:** (1) sửa package + test → (2) app nối import → (3) web nối import → (4) analyze + test 2 host → (5) commit + cập nhật bảng tiến độ tại chỗ.
- **Verify chuẩn:** `(cd packages/<pkg> && dart analyze && dart test)` (pure) / `flutter analyze && flutter test` (flutter); `flutter analyze lib`; `(cd jaspr_web && dart analyze lib)`; `make test-shared && make test-shared-flutter`.
- **Trạng thái:** `TODO` → `DOING` → `DONE` → `DEFER` (kèm lý do).

---

## 1. P0 — Gộp nhóm game_* phân mảnh (G1)

> Vấn đề: 8 package; 5 cái nhỏ ~710 dòng. game_orientation 55 dòng, game_asset 148 dòng, game_url 166 dòng. Tách ra không giảm coupling.

### G1-0. Xử lý dead code game_url_resolver (LÀM TRƯỚC G1-1)

- [x] **DONE (16/09/2026)** — Đã chọn (a) XOÁ: `game_url_resolver.dart` + group test `GameUrlResult`; barrel chỉ còn export state; sửa comment cũ nhắc resolver ở `jaspr_web/lib/services/config/app_facades.dart`. (b) không chọn.
- [x] **DONE (16/09/2026)** — Verify: grep `GameUrlResolver|GameUrlResult|GameUrlFetcher` trong lib + jaspr_web/lib + packages = 0 (các hit còn lại là `GameUrlResolver` web tự viết ở `jaspr_web/lib/services/casino/` — host code, khác class; và `SunGameUrlResult` của provider_game_manager); dart analyze + test game_url OK.
- **Nghiệm thu:** ✅ không còn taxonomy kết quả chết; game_url chỉ còn state.

### G1-1. Tạo game_foundation (pure, app + web)

- [x] **DONE (16/09/2026)** — Tạo packages/game_foundation/: pubspec (sdk >=3.9.2 <4.0.0; deps dart_kit + clock ^1.1.2 + provider_game_manager), analysis_options (lints/recommended + strict-casts), barrel export 3 file.
- [x] **DONE (16/09/2026)** — Move nguyên văn game_url_state.dart + game_asset_cache.dart (kèm fix G3) + game_launcher_lifecycle.dart sang lib/src/.
- [x] **DONE (16/09/2026)** — Di trú test 3 package cũ sang game_foundation/test/ (7 + 12 + 14 = **33/33 pass**).
- [x] **DONE (16/09/2026)** — App đổi import/re-export 4 chỗ (game_url_provider, asset_url_formatter, asset_storage, launcher/game_launcher) sang package:game_foundation/. Web **0 usage** — không khai dep game_foundation, chỉ gỡ 3 dep cũ khỏi jaspr_web/pubspec.yaml.
- [x] **DONE (16/09/2026)** — Xoá 3 thư mục cũ (git rm -rf) + gỡ khỏi pubspec app & web. Package còn lại: **31** (32 − 3 + game_taxonomy + game_foundation).
- **Nghiệm thu:** ✅ grep package:game_url|game_asset|game_launcher_lifecycle ở lib + jaspr_web/lib + packages = 0; make test-shared EXIT 0; flutter analyze lib 0 error; dart analyze web 0 error.

### G1-2. Gộp game_orientation vào orientation_guard — **DEFER (16/09/2026)**

> ⚠️ Lưu ý: `orientation_guard` hiện là package GENERIC (deps chỉ flutter/meta/web, description pub-style). Gộp `game_orientation` vào = thêm dep `provider_game_manager` (domain) vào package generic — đánh đổi ranh giới sạch để bớt 1 package 55 dòng, usage app chỉ 1 file. 2 lựa chọn: (a) **giữ nguyên game_orientation** (chi phí thấp, ranh giới sạch — khuyến nghị, chuyển trạng thái DEFER nếu chọn); (b) gộp như dưới nếu chấp nhận orientation_guard dính domain.
>
> **Chốt: chọn (a) — DEFER.** `game_orientation` giữ nguyên (55L, app=1); bảng phân loại G1-3 đã gắn nhãn FLUTTER_ONLY. Test matrix G5-3 làm trực tiếp trên `game_orientation` khi tới lượt.

- [ ] **TODO (nếu chọn gộp)** — Move game_orientation_resolver.dart sang orientation_guard/lib/src/resolvers/ (giữ nguyên class + extension). Thêm export + doc FLUTTER_ONLY. Thêm dep provider_game_manager cho orientation_guard.
- [ ] **TODO** — App đổi import (1 file). Xoá packages/game_orientation/ + gỡ khỏi pubspec app (web đã gỡ ở W10). Verify flutter analyze + test.
- **Nghiệm thu:** grep package:game_orientation/ = 0; matrix test pass (xem G5-3).

### G1-3. Giữ riêng + gắn nhãn FLUTTER_ONLY

- [x] **DONE (16/09/2026)** — Giữ riêng: game_launcher (MethodChannel), game_downloader (dart:io), game_engine (flutter_inappwebview), game_api_client (dio pure) — đúng ranh giới.
- [x] **DONE (16/09/2026)** — Sửa description gắn nhãn FLUTTER ONLY / FORK: game_launcher, game_engine, adaptive_overlay, fullscreen_guard, floating_draggable_widget (FORK), flutter_slider_drawer (FORK) — mẫu W10.
- [x] **DONE (16/09/2026)** — Bảng phân loại PURE (tầng 0 / PURE) vs FLUTTER ONLY vs FORK cho đủ 31 package + quy ước tầng (cấm dep ngược; tầng 0 không dep nhau) — đặt ở cuối `SHARED_PACKAGES.md` (mục "Phân loại package + quy ước tầng").

---

## 2. P0 — Cắt đảo tầng phụ thuộc (G2)

### G2-1. Cắt transaction_domain → provider_game_manager

- [x] **DONE (16/09/2026)** — Đã tạo `packages/game_taxonomy/` (pubspec 0-dep, lints, analysis_options, barrel) + move nguyên văn ActivityGroup + classifyActivityGroup (un-part).
- [x] **DONE (16/09/2026)** — provider_game_manager re-export lại (`export ... show ActivityGroup, ActivityGroupClassifier` — đặt TRƯỚC các `part` vì quy tắc Dart); transaction_enums.dart đổi nguồn export; transaction_parse.dart:9 đổi import; gỡ dep provider_game_manager khỏi pubspec, thêm game_taxonomy. Test mới: 9 case classify (priority deposit→cancel→withdraw→promotion→sport→casino, rỗng, hoa/thường).
- [x] **DONE (16/09/2026)** — Verify: dart test 3 package (144 + 47 + 9 pass); grep import/export provider_game_manager trong packages/transaction_domain/lib = 0 (chỉ còn doc comment history).
- **Nghiệm thu:** ✅ transaction_domain không chạm provider_game_manager; host cũ không đổi import (re-export giữ API); test parse + classify pass.

### G2-2. Cắt chat_protocol → auth_domain

- [x] **DONE (16/09/2026)** — Move ChatWsCommand + 4 payload builders + unwrapChatContent + backoff + proactive delay sang `chat_protocol/lib/src/chat_wire.dart` (pure, clock). **Giữ lại auth_domain: `kTokenErrorPatterns` + `isTokenErrorMessage`** (host dùng; chat_protocol không dùng). `chatProactiveRefreshDelay` mặc định đổi `DateTime.now()` → `clock.now()`.
- [x] **DONE (16/09/2026)** — auth_domain re-export 8 symbol đã chuyển (barrel, có ghi chú "đổi import sang chat_protocol"); auth_domain/pubspec thêm dep chat_protocol (trên → dưới); chat_protocol/pubspec GỠ dep auth_domain; machine/dispatcher đổi import nội bộ sang `chat_wire.dart`.
- [x] **DONE (16/09/2026)** — Host đổi import: app `sb_chat_websocket.dart` (gỡ import auth_domain wire — symbols từ import chat_protocol có sẵn); web `chat_service.dart` (auth_domain giữ đúng `show isTokenErrorMessage`, wire symbols từ import chat_protocol có sẵn).
- [x] **DONE (16/09/2026)** — Test di trú + mở rộng: `auth_domain/test/chat_protocol_helpers_test.dart` → `chat_protocol/test/chat_wire_test.dart` (đổi nguồn + thêm group ChatWsCommand + test clock 40/40 pass); `chat_socket_protocol_test.dart` giữ lại phần token-pattern ở auth_domain (43/43 pass).
- [x] **DONE (16/09/2026)** — Verify: grep `auth_domain` trong packages/chat_protocol/lib = 0 (chỉ doc history); dart analyze 2 package sạch; flutter analyze lib 0 error; dart analyze web 0 error.
- **Nghiệm thu:** ✅ socket không phụ thuộc auth; không cycle (auth_domain → chat_protocol là chiều trên→dưới); token-error pattern vẫn 1 nguồn ở auth_domain.

### G2-3. Chốt tầng betting_domain → app_format + sửa doc

- [x] **DONE (16/09/2026)** — Sửa betting_domain description (đúng: Pure Dart + duy nhất dep app_format). Ghi quy ước tầng vào `SHARED_PACKAGES.md` mục "Phân loại package + quy ước tầng": tầng 0 = dart_kit/app_env/app_format/app_i18n/game_taxonomy/... (0 inter-dep); cấm `app_format` phụ thuộc ngược `betting_domain`.
- [x] **DONE (16/09/2026)** — Verify dart analyze + test betting_domain (make test-shared EXIT 0).
- **Nghiệm thu:** ✅ doc khớp thực tế; tầng chốt trong tài liệu.

---

## 3. P1 — Xoá trùng Semaphore + clock (G3)

> Phát hiện rà soát: `Semaphore` có **3 bản** (dart_kit chuẩn / game_asset package / copy trong app `lib/.../asset_cache_controller.dart`), không chỉ 2. dart_kit.Semaphore đã có `assert(_maxCount > 0)`; cả 2 bản AssetSemaphore đều KHÔNG guard release thừa.

- [x] **DONE (16/09/2026)** — Thay AssetSemaphore **bản package** bằng dart_kit Semaphore; xoá class riêng. game_asset thêm deps dart_kit + clock ^1.1.2.
- [x] **DONE (16/09/2026)** — Thay AssetSemaphore **bản copy trong app** `lib/features/game/assets/dynamic_assets/cache/asset_cache_controller.dart` (field `requestSemaphore` + provider). App GIỮ `AssetCacheController` Flutter riêng.
- [x] **DONE (16/09/2026)** — Phát hiện thêm lúc làm: bản **thứ 4** `_Semaphore` private trong `lib/core/utils/bundle_manager.dart` (có `dispose()` unblock waiter khi `BundleManager.reset`) → đã thêm `dispose({Object? error})` vào `dart_kit.Semaphore` + thay `_Semaphore` = `Semaphore` trong bundle_manager. Guard release thừa: `if (_current <= 0) { assert(false, ...); return; }` — debug/test ném AssertionError, release build no-op.
- [x] **DONE (16/09/2026)** — DateTime.now() → clock.now(): package (:124→clock, :138→clock) và lib copy (:113, :188); app pubspec thêm clock ^1.1.2.
- [x] **DONE (16/09/2026)** — Test: dart_kit +5 (maxCount 0, release thừa ×2, dispose ×2 — 35/35 pass); game_asset +4 periodic clear với `withClock(Clock.fixed(...))` (12/12 pass).
- **Nghiệm thu:** ✅ grep `^class .*Semaphore` toàn repo còn đúng 1 (dart_kit); grep DateTime.now() trong game cache (package + lib copy) = 0; make test-shared EXIT 0.

---

## 4. P1 — copyWith + GameLauncher (G4)

### G4-1. copyWith chuẩn 2 chiều (audit call-site BẮT BUỘC)

> ⚠️ Hiện trạng 2 hướng khác nhau — không làm sentinel đại trà được: (1) `activeGame`/`url`/`nativeBundle` đang **không clear được null** (`?? this.x`); (2) `error`/`errorMessage`/`failureKind` đang **LUÔN ghi đè** (mọi `copyWith` tự xoá error). Sentinel áp cho nhóm (2) sẽ ĐẢO hành vi: các call-site không truyền error sẽ giữ lại lỗi cũ thay vì xoá như hiện nay.

- [x] **DONE (16/09/2026)** — Bước 1: audit call-site — kết quả: `GameLauncherState.copyWith` KHÔNG có call-site nào trong app (app dựng state trực tiếp qua constructor); `GameUrlState.copyWith` chỉ có 7 call-site trong `game_url_provider.dart`. Call-site dựa vào tự-xoá error/failureKind: `:28` (đầu lượt loading) và `:43/:48` (success — nhưng error/failureKind đã null từ :28 nên an toàn).
- [x] **DONE (16/09/2026)** — Bước 2: sentinel `static const Object _unset` cho tất cả field nullable: GameUrlState (url/error/failureKind/nativeBundle) + GameLauncherState (activeGame/errorMessage); `status` giữ `??` merge (non-nullable, không clear được).
- [x] **DONE (16/09/2026)** — Bước 3: sửa call-site `game_url_provider.dart:28` — thêm `failureKind: null` tường minh (trước đây copyWith tự xoá failureKind; nếu không sửa thì success sẽ còn failureKind cũ).
- [x] **DONE (16/09/2026)** — Bước 4: test 2 chiều — game_url (copyWith() giữ nguyên TẤT CẢ kể cả error; truyền null clear được — 7/7 pass) + game_launcher_lifecycle (giữ nguyên/clear null — 14/14 pass).
- **Nghiệm thu:** ✅ hết bug "lỗi cũ còn" lẫn bug "lỗi bị nuốt"; app `flutter analyze lib` 0 error; không có call-site nào đổi hành vi ngoài ý muốn (audit bảng trên).

### G4-2. Cache channel của GameLauncher

- [x] **DONE (16/09/2026)** — GameLauncher._resolveChannel(): cache 1 nhánh duy nhất `_channel ??= MethodChannel(await resolveChannelName())` — trước đây nhánh không override tạo MethodChannel MỚI mỗi lần gọi (kèm await PackageInfo). Override vẫn hoạt động (resolveChannelName trả override).
- [x] **DONE (16/09/2026)** — Test game_launcher 12/12 pass (mock MethodChannel + PackageInfo 9.x) — trùng G5-4, đã làm cùng lúc.
- ℹ️ Phần "map catch(e) sang GameUrlFailureKind trong GameUrlResolver" đã GỎI khỏi việc này: resolver là dead code, số phận xử lý ở G1-0 (đã xoá).

---

## 5. P1 — Thống nhất SDK/lints/clock (G5-co khí, 1 PR)

- [x] **DONE (16/09/2026)** — SDK về sdk: >=3.9.2 <4.0.0 cho tất cả (30/31; ngoại lệ duy nhất ghi lý do: floating_draggable_widget >=2.16.2 — fork upstream giữ SDK cũ, đã ghi ngay trong pubspec). Ngoại lệ flutter constraint: orientation_guard giữ `flutter: >=3.27.0`.
- [x] **DONE (16/09/2026)** — Lints: pure → lints ^5.0.0 (sport_socket đã nâng từ ^3.0.0; game_api_client đã đổi flutter_lints → lints vì pure/dio); flutter → flutter_lints ^6.0.0 thống nhất (adaptive_overlay, fullscreen_guard, game_downloader, game_engine, game_launcher, game_orientation, flutter_slider_drawer — slider_drawer đã THÊM lints, trước đây 0 khai). floating_draggable_widget giữ ^2.0.1 theo upstream.
- [x] **DONE (16/09/2026)** — clock về ^1.1.2 (chat_protocol, mini_game_countdown_core đã nâng). analysis_options pure đồng đều lints/recommended + strict-casts; `public_member_api_docs` giữ riêng cho 3 package Flutter public-API lớn (orientation_guard, game_engine, fullscreen_guard) — không ép toàn repo.
- [x] **DONE (16/09/2026)** — Verify: for p in packages/*/ (pub get + analyze): 24/31 package **0 issue**. Warning còn lại đều PRE-EXISTING, không phải của G5: floating_draggable_widget ×2 (upstream fork), provider_game_manager ×2 (test cũ), sport_socket ×16 (strict-inference test cũ + js_interop info). Không có error nào.
- **Nghiệm thu:** ✅ grep sdk:/lints: đúng 1 chuẩn mỗi nhóm (+2 ngoại lệ có lý do ghi trong pubspec); clock 1 version.

---

## 6. P1 — Lấp test 0-test (G5-test)

| ID | Package (usage) | Test tối thiểu | T.thái |
|---|---|---|---|
| G5-1 | adaptive_overlay (12 lib, app 10) | controller show/hide/close, trigger, visibility gate | **DONE** (14/14 — controller open/close/toggle + notify no-op; of/maybeOf/breakpointOf; desktop side overlay mở/đóng + onDismissed; mobile bottom sheet; trigger rebuild; gate mount/unmount) |
| G5-2 | fullscreen_guard (app 5) | request/satisfy/clear, auto re-gate | **DONE** (12/12 — fake strategy/platform UI: auto-satisfy, gate blocking/informational, satisfy fail, clear ±restore, re-gate khi mất fullscreen, widget gate proceed/cancel) |
| G5-3 | game_orientation (app 1) | matrix LobbyGame x Experience → Policy; SunOrientation → DeviceOrientation | **DONE** (2/2 — sửa lỗi compile phiên trước: tên constructor fake, thiếu import services; sửa expectation p3: largeTablet map vào bucket DESKTOP → default 4 hướng; +3 case default/expand-fail) |
| G5-4 | game_launcher (app 3) | resolveChannelName, launch success/failure/missing-plugin/invalid-path, logSink | **DONE** (12/12 — mock MethodChannel + PackageInfo 9.x) |
| G5-5 | game_downloader (app 3) | version compare, checksum, unzip happy/fail (mock dart:io qua interface) | **DONE** (26/26 — RemoteVersionSource 11 (URL pattern + ma trận lỗi HTTP qua MockClient); GameDownloader 15 (checkVersion ±sync, prepareGame happy/404/zip-rỗng/zip-hỏng/URL-scheme, deleteGame; dart:io thật trong temp dir + fake Dio adapter + store RAM). ⚠️ LƯU Ý: package KHÔNG có logic checksum (kế hoạch ghi dư) — đã test đủ phần tồn tại; **phát hiện + sửa 1 bug thật**: archive 4.x decode byte rác thành archive 0 entry KHÔNG ném → rename temp ném PathNotFoundException khó hiểu; đã thêm guard `archive.isEmpty → UnzipException` trong `_unzip`) |
| G5-6 | game_asset/foundation (app 2) | toBustedUrl matrix, semaphore ordering, periodic clear clock fake | **DONE** (12/12 — semaphore ordering chuyển về dart_kit 35/35; +4 test periodic clear) |
| G5-7 | fork draggable/slider | Giữ upstream — smoke test nếu fork có sửa (re-clamp FAB) | **DONE** (floating_draggable_widget 5/5 — smoke re-clamp: FAB clamp từ build đầu, re-clamp khi màn thu nhỏ 800→400, dx/dy âm, neo góc phải-dưới. flutter_slider_drawer: fork vendor KHÔNG có sửa riêng (grep không thấy marker fork) → giữ upstream, không test — lý do ghi tại đây) |
| G5-8 | package mỏng (game_url, paygate, notification, monitoring) | Mỗi package ≥3 case nhánh lỗi (game_url: test GameUrlState — nếu G1-0 xoá resolver thì chỉ còn state; paygate: ≥3 case parse/lỗi) | **DONE (verify)** — đã đủ từ baseline, chạy lại ĐẠT: game_foundation 33/33 (thay game_url), paygate 15, notification 14, monitoring 24 — mọi nhánh lỗi (thiếu status, status≠0, 1099 soft, chênh lệch âm, redact) đều có case |

- [x] **DONE (16/09/2026)** — Chạy make test-shared-flutter (8 package Flutter, EXIT 0) + make test-shared (22 package pure, EXIT 0) sau khi thêm.
- **Nghiệm thu:** ✅ 0 package 0-test (trừ flutter_slider_drawer — fork vendor không sửa, có lý do); make test-packages EXIT=0.

---

## 7. P2 — Chuẩn hoá nhỏ (G6, khi rảnh)

- [x] **DONE (16/09/2026)** — Version: thống nhất **0.1.0** cho 29/31 package nội bộ (trước đây 0.0.1/0.1.0/0.1.0+1/0.2.0/1.0.0/1.1.0/1.4.1); 2 fork giữ version upstream (floating_draggable_widget 2.3.0, flutter_slider_drawer 3.0.2 — track upstream). Điều kiện tiên quyết đã kiểm: KHÔNG pubspec nào ghim version constraint trên path-dep (grep = 0) ⇒ đổi version vô rủi ro resolve; 32/32 vẫn publish_to:none.
- [x] **DONE (16/09/2026)** — Barrel betting_domain: 31 file wildcard → `export 'src/x.dart' show A, B;` TƯỜNG MINH như sport_socket (**110 symbol** liệt kê tên), sinh bằng script `tools/gen_betting_barrel.py` (regex scan + vòng lặp prune theo `dart analyze` — analyzer là ground truth, khử false-positive từ file không dart-format như `market_labels.dart` có member class nằm cột 0). Library name thống nhất: **`library;` unnamed** (majority 24/30 + lint khuyến nghị) — đổi 4 barrel đặt tên (adaptive_overlay, fullscreen_guard, orientation_guard, game_api_client, bỏ luôn comment `ignore_for_file: unnecessary_library_name`); 2 fork giữ nguyên. Verify: dart analyze 0 issue + betting test 149 pass + app/web analyze 0 error (host không dùng symbol nào bị cắt).
- [ ] **DEFER (16/09/2026) — G6-3 (provider_game_manager god-package).** Chốt: **DEFER, cần session riêng có audit.** Lý do: `manager.dart` là 1 class `ProviderGameManager` duy nhất (1.213 dòng) giữ ~40 field mutable dùng chung chéo 3 mối quan tâm (lobby/search/url — `_productInfos`, `_environments`, `_providerOverrides`, `_sunGameDetails`, streams…); "tách facade khỏi LobbyStore/SearchStore/UrlResolver" thật sự = kéo state vào store object + rewiring gần như toàn bộ 1.213 dòng, rủi ro trên đúng luồng tiền lobby/URL game, trong khi test hiện chỉ phủ ở tầng facade. Không phải việc "khi rảnh" làm nửa vời được. Bản ghi khi làm: (a) audit call-site app + web từng method trước; (b) tách 1 store/lần (UrlResolver trước — phụ thuộc state ít nhất), giữ facade delegate để host không đổi import.
- [x] **AUDIT G6-3 LÀM SẴN (16/09/2026, chỉ đọc)** — dữ kiện cho session tách:
  - Call-site host: `gameUrlOf` **app=2 / web=2** (entry URL resolver duy nhất); `applyLobbyConfig` app=1/web=1; `getEnvironmentByGameBundle` web=1; **`getProductUrlFromGameCode`, `getProductUrl`, `getEnvironmentByGameId`, `getGameListByCategory`, `getGameListByProvider` = 0 call-site ở host** (chỉ dùng nội bộ / chết) — ứng viên xoá/`@visibleForTesting` trước khi tách để thu nhỏ bề mặt.
  - File kết quả đã sẵn: `manager_game_url.dart` (LobbyGameUrl Ready/Native/Blocked/Unavailable), `manager_lobby_game.dart`, `manager_search.dart` — tách = move LOGIC từ manager.dart vào store class cầm field, facade delegate.
  - Field cần cho UrlStore (đếm từ code): `_environments`, `_providerOverrides`, `_apiGameCodes`, `_sunGameDetails`, `_sunLoadStopDebounceMs`, `_mapProductByCodeFull`, `_mapProductByCode`, `_mapProductByGameId` — 8 field, tách được bằng 1 object `store` giữ refs; khớp hướng dẫn "UrlResolver trước".
  - Test bạt: `provider_game_manager_test.dart` (facade) + `real_config_test.dart` phủ URL — đủ làm regression sau mỗi bước tách.
- [x] **DONE (16/09/2026)** — parseSortTime: **inject clock** qua tham số `now` (`DateTime Function()? now`, mặc định `DateTime.now` — hành vi giữ nguyên, không đổi luật fallback "bây giờ + log cảnh báo" của bản gốc); test sort flaky hết: +5 case (inject, default, ưu tiên field, log, 2 bản ghi cùng clock bằng nhau). Chọn inject thay vì trả null/epoch vì mọi call-site (app 4, web 2) đều nhét thẳng vào `sortTime` non-nullable của model — trả null phải sửa model + 6 call-site, không tương xứng P2.
- [x] **DONE (16/09/2026)** — formatHistoryTime: chuẩn hoá **local 1 chỗ** — đầu vào `isUtc` quy về giờ máy (`toLocal()`) trước khi format; đầu vào local giữ nguyên (không đổi 2 host hiện tại, luôn nhận local từ `epochToLocal`). +3 case (local bất biến, UTC = toLocal, UTC khác giờ UTC trừ khi máy chạy UTC).
- [x] **DONE (16/09/2026)** — CI: tạo `.github/workflows/packages.yml` (job duy nhất 9 bước: analyze pure + analyze flutter + make test-shared + make test-shared-flutter + `flutter analyze lib` + web `dart analyze lib` + guard tầng) và `tools/check_package_layers.sh` — guard 2 chiều theo bảng phân loại SHARED_PACKAGES.md: (1) jaspr_web cấm import 9 package FLUTTER ONLY/FORK; (2) 22 package PURE cấm import `package:flutter/|dart:ui`. Guard đã test **thật cả 2 chiều**: pass EXIT 0 trên tree sạch; EXIT 1 + liệt kê vi phạm khi giả lập PURE import flutter.
- **Nghiệm thu:** make test-packages EXIT 0 (30/30 suite) sau toàn bộ G6; analyze 2 host 0 error.

---

## 8. Bảng tiến độ tổng (cập nhật tại chỗ)

| ID | Việc | Mức | T.thái | Commit |
|---|---|---|---|---|
| G1-0 | Xoá dead code game_url_resolver (quyết a/b) | P0 | **DONE** (a) | d6c9f0e05 |
| G1-1 | game_foundation, xoá 3 package nhỏ | P0 | **DONE** | d6c9f0e05 |
| G1-2 | game_orientation → orientation_guard (TRADE-OFF, có thể DEFER) | P0 | **DEFER** (chọn giữ nguyên) | — |
| G1-3 | Nhãn FLUTTER_ONLY + bảng phân loại | P0 | **DONE** | b48065501 |
| G2-1 | Cắt transaction_domain → provider_game_manager (đích: game_taxonomy 0-dep) | P0 | **DONE** | f836ae5ac + 7e66ba7be |
| G2-2 | Cắt chat_protocol → auth_domain | P0 | **DONE** | acfd0907b |
| G2-3 | Tầng betting_domain → app_format + doc | P0 | **DONE** | b48065501 |
| G3 | Semaphore chung (dedup 3+1 bản: dart_kit/game_asset/lib ×2/bundle_manager) + clock cache | P1 | **DONE** | 7ad5064d9 |
| G4-1 | copyWith sentinel 2 chiều + AUDIT call-site | P1 | **DONE** | d6c9f0e05 |
| G4-2 | Cache channel GameLauncher | P1 | **DONE** | f3f4441a7 |
| G5-co khí | SDK/lints/clock/analyzer | P1 | **DONE** (verify 24/31 package 0 issue, còn lại pre-existing) | b48065501 |
| G5-1..8 | Lấp test (TẤT CẢ DONE — +59 test mới đợt này) | P1 | **DONE** (G5-8 chỉ verify) | ac3709c5c |
| G6-1 | Version thống nhất 0.1.0 (29 pkg, fork giữ upstream) | P2 | **DONE** | b48065501 |
| G6-2 | Barrel betting_domain export show (110 symbol) + library; | P2 | **DONE** | a825d4583 |
| G6-3 | provider_game_manager tách store (1 class 1.213 dòng) | P2 | **DEFER** (cần session riêng + audit call-site) | — |
| G6-4 | parseSortTime inject clock | P2 | **DONE** (+5 test) | f836ae5ac |
| G6-5 | formatHistoryTime chuẩn hoá local | P2 | **DONE** (+3 test) | f836ae5ac |
| G6-6 | CI workflow + guard tầng 2 chiều (đã test thật) | P2 | **DONE** | fdf4c1c43 |

> ℹ️ **Commit thực tế (16/09/2026):** nhóm theo FILE final-state thành 11 commit — KHÔNG tái lập được 17 commit lịch sử vì các trạng thái trung gian đã trộn trong working tree. Identity repo-local: `rg <admin@Admin.local>` (khớp các commit gần nhất trên máy):
> `f836ae5ac` G2-1+G6-4/5 · `d6c9f0e05` G1-1+G1-0+G4-1 · `7ad5064d9` G3 · `acfd0907b` G2-2 · `f3f4441a7` G4-2 · `ac3709c5c` G5-1/2/3/5/7 · `b48065501` G1-3+G5-co khí+G6-1 · `a825d4583` G6-2 · `fdf4c1c43` G6-6 · `7e66ba7be` fixup G2-1 · commit cuối = tài liệu này.

**Thứ tự đề xuất (làm 4 việc trước):** G2-1 (cắt dep nặng, đích game_taxonomy) → G1-0 (xoá dead code resolver — NHANH, unblock G1-1) → G3 (Semaphore 3 bản + clock) → G4-1 + G5-4 (copyWith + AUDIT call-site trước, test launcher sau). Nhỏ, không đụng UI, gỡ đúng rủi ro logic thật.

> ⚠️ Ghi chú thứ tự: G3/G4-1 đụng đúng các file mà G1-1 sẽ move (game_asset_cache.dart, game_url_state.dart, game_launcher_lifecycle.dart) — thực thi theo thứ tự trên thì các fix được bê theo G1-1 một lần; nếu đổi ý chạy G1-1 trước thì G3/G4-1 phải làm trên game_foundation. G4-1 BẮT BUỘC bước audit call-site trước khi đổi copyWith (xem mục 4).

### ✅ Đợt 1 (16/09/2026) — G2-1 + G1-0 + G3 + G4-1 + G5-4/G5-6: ĐÃ LÀM, CHƯA COMMIT

> `git config user.email` chưa đặt trên máy này ⇒ chưa commit được; chia commit theo nhóm file dưới đây sau khi đặt email (`git config user.email "..."`).

- **Commit 1 — G2-1 (game_taxonomy):** `packages/game_taxonomy/**` (mới), `packages/provider_game_manager/` (barrel + pubspec + xoá src/activity_group.dart), `packages/transaction_domain/` (pubspec + transaction_enums + transaction_parse).
- **Commit 2 — G1-0 (xoá dead code):** `packages/game_url/` (xoá resolver, barrel, test), `jaspr_web/lib/services/config/app_facades.dart` (comment).
- **Commit 3 — G3 (Semaphore + clock):** `packages/dart_kit/` (semaphore + test), `packages/game_asset/` (pubspec + cache + test), `pubspec.yaml` (+clock), `lib/features/game/assets/` (asset_cache_controller + game_asset_cache_provider), `lib/core/utils/bundle_manager.dart`.
- **Commit 4 — G4-1 + G5-4/G5-6 (copyWith + test):** `packages/game_url/lib/src/game_url_state.dart` + test, `packages/game_launcher_lifecycle/` (state + test), `lib/features/game/url/game_url_provider.dart` (call-site), `packages/game_launcher/test/game_launcher_test.dart` (mới).

**Verify đợt 1 (tất cả ĐẠT):** `make test-shared` EXIT 0 (tất cả package pure); `make test-shared-flutter` EXIT 0 (game_engine 28, game_launcher 12, orientation_guard 37); `flutter analyze lib` 0 error; `jaspr_web dart analyze lib` 0 error; các nghiệm thu grep (G1-0/G2-1/G3) như ghi ở từng mục. Test mới cộng dồn: game_taxonomy +9, dart_kit +5, game_asset +4, game_url +2, game_launcher_lifecycle +2, game_launcher +12.

### ✅ Đợt 2 (16/09/2026) — G1-1 + G1-2(DEFER) + G1-3 + G2-2 + G2-3 + G4-2: ĐÃ LÀM

- **Commit 5 — G1-1 (game_foundation):** `packages/game_foundation/**` (mới), xoá `packages/game_url|game_asset|game_launcher_lifecycle`, `pubspec.yaml` + `jaspr_web/pubspec.yaml`, 4 file re-export app (`lib/features/game/url/game_url_provider.dart`, `lib/features/game/assets/dynamic_assets/cache/asset_url_formatter.dart` + `asset_storage.dart`, `lib/features/game/launcher/game_launcher.dart`).
- **Commit 6 — G2-2 (chat wire):** `packages/chat_protocol/` (chat_wire.dart mới, barrel, pubspec, machine, dispatcher, test/chat_wire_test.dart di trú + clock test), `packages/auth_domain/` (chat_socket_protocol cắt gọn, barrel re-export, pubspec, test giữ token-pattern), `lib/core/services/websocket/sb_chat_websocket.dart`, `jaspr_web/lib/services/chat/chat_service.dart`.
- **Commit 7 — G1-3 + G2-3 + G4-2 (nhãn + doc + cache channel):** 7 pubspec description (6 nhãn + betting_domain), `SHARED_PACKAGES.md` (bảng phân loại + quy ước tầng), `packages/game_launcher/lib/src/game_launcher.dart` (cache channel).

**Verify đợt 2 (tất cả ĐẠT):** `make test-shared` EXIT 0 (22 package pure, game_foundation 33/33); `make test-shared-flutter` EXIT 0 (game_engine 28, game_launcher 12, orientation_guard 37); `make test-packages` EXIT 0 (25 all-pass); `flutter analyze lib` 0 error; `jaspr_web dart analyze lib` 0 error. Còn lại: G5-co khí + G5-1/2/3/5/8 + G6.

### ✅ Đợt 3 (16/09/2026) — G5-co khí (verify) + G5-test lấp hết (G5-1/2/3/5/7/8): ĐÃ LÀM, CHƯA COMMIT

> Đợt này chốt nốt toàn bộ P1. Ghi chú: G5-co khí + file test game_orientation đã được làm DỞ ở phiên trước nhưng (a) chưa ghi tiến độ, (b) test game_orientation không biên dịch được (sai tên constructor fake, thiếu import `flutter/services`, expectation p3 sai luật) — phiên này sửa + chạy ĐẠT.

- **Commit 8 — G5-co khí (verify + khuyết thiếu):** toàn bộ `packages/*/pubspec.yaml` + `analysis_options.yaml` (SDK/lints/clock — đã có sẵn từ phiên trước), `packages/adaptive_overlay/pubspec.yaml` (thêm flutter_test), `packages/fullscreen_guard/pubspec.yaml` (GỠ `test:` thừa — package Flutter khai `test:` làm `make test-shared` nhặt nhầm chạy `dart test` → fail).
- **Commit 9 — G5-3 (sửa test game_orientation):** `packages/game_orientation/test/game_orientation_test.dart` (2/2 pass).
- **Commit 10 — G5-1 (adaptive_overlay):** `packages/adaptive_overlay/test/adaptive_overlay_test.dart` (mới, 14 test).
- **Commit 11 — G5-2 (fullscreen_guard):** `packages/fullscreen_guard/test/fullscreen_guard_controller_test.dart` + `test/fullscreen_guard_widget_test.dart` (mới, 12 test).
- **Commit 12 — G5-5 + bug fix (game_downloader):** `packages/game_downloader/test/remote_version_source_test.dart` + `test/game_downloader_test.dart` (mới, 26 test) + **`lib/src/game_downloader.dart` (guard `archive.isEmpty → UnzipException` — bug thật: archive 4.x decode byte rác thành 0 entry, không ném, làm rename temp nổ PathNotFoundException)**.
- **Commit 13 — G5-7 (fork smoke):** `packages/floating_draggable_widget/test/floating_draggable_widget_test.dart` (mới, 5 test — language version 2.16: không dùng `library;`).

**Verify đợt 3 (tất cả ĐẠT):**
- `make test-shared` EXIT 0 — 22 package pure (dart_kit 35, game_foundation 33, betting_domain 149, provider_game_manager 144, sport_socket 217, transaction_domain 47, auth_domain 43, chat_protocol 40, …).
- `make test-shared-flutter` EXIT 0 — 8 package: adaptive_overlay **14**, floating_draggable_widget **5**, fullscreen_guard **12**, game_downloader **26**, game_engine 28, game_launcher 12, game_orientation **2**, orientation_guard 37.
- `flutter analyze lib` 0 error; `jaspr_web dart analyze lib` 0 error.
- Verify loop G5 (pub get + analyze 31 package): 24/31 **0 issue**; warning còn lại pre-existing (floating_draggable_widget ×2 upstream, provider_game_manager ×2 test cũ, sport_socket ×16 cũ) — không warning/error mới nào từ đợt này.
- Test mới cộng dồn đợt 3: adaptive_overlay +14, fullscreen_guard +12, game_downloader +26, floating_draggable_widget +5 = **+57** (game_orientation +2 là sửa test hỏng của phiên trước).

**Còn lại:** chỉ còn nhóm P2 (G6-1..6).

### ✅ Đợt 4 (16/09/2026) — G6-1/2/4/5/6 DONE, G6-3 DEFER: ĐÃ LÀM, CHƯA COMMIT

> Chốt nốt nhóm P2. Sau đợt này KHÔNG còn việc TODO nào trong kế hoạch — chỉ còn G6-3 (DEFER, cần session riêng) và commit (máy chưa đặt `git user.email`).

- **Commit 14 — G6-4 + G6-5 (transaction_domain):** `packages/transaction_domain/lib/src/transaction_parse.dart` (inject `now` vào parseSortTime; formatHistoryTime normalize `isUtc` → local) + `test/transaction_parse_time_test.dart` (mới, 8 test — transaction_domain 55/55).
- **Commit 15 — G6-1 (version):** 20 file `packages/*/pubspec.yaml` đổi version → 0.1.0 (fullscreen_guard bỏ `+1`); tiền đề đã kiểm: 0 path-dep nào bị ghim version.
- **Commit 16 — G6-2 (barrel + library name):** `packages/betting_domain/lib/betting_domain.dart` (31 export show, 110 symbol) + `tools/gen_betting_barrel.py` (script sinh + prune theo analyzer); 4 barrel `library;` hoá (adaptive_overlay, fullscreen_guard, orientation_guard, game_api_client — bỏ ignore comment).
- **Commit 17 — G6-6 (CI + guard):** `.github/workflows/packages.yml` (mới) + `tools/check_package_layers.sh` (mới, guard 2 chiều — đã test âm với giả lập vi phạm).

**Verify đợt 4 (tất cả ĐẠT):**
- `make test-packages` EXIT 0 — 30/30 suite (sau khi đổi version + barrel).
- betting_domain: `dart analyze` 0 issue + 149 test pass; app `flutter analyze lib` 0 error; web `dart analyze lib` 0 error.
- Guard layer: EXIT 0 trên tree sạch; EXIT 1 khi giả lập vi phạm (adaptive_overlay giả làm PURE → liệt kê 12 file import flutter).
- transaction_domain 55/55 (gián tiếp: make test-shared); orientation_guard 37, fullscreen_guard 12, adaptive_overlay 14, game_api_client 68 — sau khi đổi library;.
- Test mới đợt 4: transaction_domain +8.

**Kết thúc kế hoạch:** P0 ✅ (G1*, G2*) · P1 ✅ (G3, G4, G5) · P2 ✅ (G6 trừ G6-3 DEFER). Chỉ còn: đặt `git user.email` rồi commit theo 17 commit đã chia; G6-3 làm session riêng khi có audit.

---

## 9. Phụ lục — Lệnh kiểm tái lập

```bash
ls -1 packages | sort; ls -1 packages | wc -l
for d in packages/*/; do echo "--- $(basename $d)"; find "$d/lib" -type f | sort; done
grep -H "path:" packages/*/pubspec.yaml
grep -H "sdk:" packages/*/pubspec.yaml
grep -H "lints:" packages/*/pubspec.yaml
for p in $(ls -1 packages); do echo -n "$p app=$(grep -rl "package:$p/" lib 2>/dev/null | wc -l)"; echo " web=$(grep -rl "package:$p/" jaspr_web/lib 2>/dev/null | wc -l)"; done
grep -rn "class.*Semaphore" packages/*/lib lib jaspr_web/lib --include="*.dart"   # nghiệm thu G3: chỉ còn dart_kit
grep -rn "GameUrlResolver\|GameUrlResult\|GameUrlFetcher" lib jaspr_web/lib packages --include="*.dart"   # nghiệm thu G1-0: = 0
grep -rn "DateTime.now()" packages/game_asset/lib packages/game_url/lib packages/game_launcher_lifecycle/lib lib/features/game/assets --include="*.dart"
for d in packages/*/; do echo "$(basename $d): $(find "$d/test" -name "*_test.dart" 2>/dev/null | wc -l) test files"; done
(cd packages/<pkg> && dart analyze && dart test)
(cd packages/<pkg> && flutter analyze && flutter test)
flutter analyze lib; (cd jaspr_web && dart analyze lib)
make test-shared && make test-shared-flutter
```



