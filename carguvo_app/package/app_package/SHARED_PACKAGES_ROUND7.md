# BÁO CÁO: KIỂM ĐỊNH BUILD + LOGIC CÒN LẠI CÓ THỂ ĐÓNG VÀO PACKAGE DÙNG CHUNG (app Flutter + jaspr_web) — ROUND 7

> Ngày: 13/09/2026 (đợt 1–4). Bổ sung đợt 5: 14/09/2026. Rà toàn bộ `lib/`
> (1536 file Dart) ↔ `jaspr_web/lib/` (432 file) ↔ `packages/` (33 package).
> Bổ sung cho: `SHARED_PACKAGES.md`, `SHARED_PACKAGES_REMAINING.md`,
> `SHARED_PACKAGES_ROUND3.md`, `ROUND4.md`, `ROUND5.md`, `ROUND6.md`.

---

## TÓM TẮT (đọc 30 giây)

> ⚠️ Snapshot dưới đây ghi lại trạng thái ĐẦU Round 7 (13/09, trước khi thực
> thi). **Cập nhật đợt 5 (14/09): build đã XANH cả hai dự án — xem bảng
> "Đợt 5" + KẾT LUẬN.**

1. **(KHỞI ĐIỂM) Cả 2 dự án KHÔNG build được:**
   - App: `flutter build apk --debug` → **BUILD FAILED in 30s** (Dart compile error).
   - Web: `make build` (jaspr_web) → **FAIL** ở bước dart2js compile (29 lỗi unique).
   - Package chung: `make test-shared` → **FAIL** tại `mini_game_countdown_core`
     (test của chính package không compile); 23/24 package còn lại PASS (~948 test).
2. **Mọi lỗi dồn về đúng MỘT nguyên nhân: đợt delegate Round 6 (13/09) bị bỏ dở
   giữa chừng** — nửa call-site đã delegate sang package, nửa chưa — cộng thêm
   2 nợ cấu hình: thiếu dep `chat_protocol` ở app, và 4 file app import package
   `game_launcher` **chưa từng tồn tại**. Bản thân các package khoẻ mạnh
   (31/32 package `dart analyze` = 0 error).
3. Về logic dùng chung: sau 6 đợt, phần còn lại gộp được gồm
   **(A) 11 nợ gọi lại** từ Round 6, **(B) tầng parse REST** (Phase 5 cũ —
   15 file / 5323 dòng bên web, chưa hoist), và **(C) 7 ứng viên mới** tìm thấy
   đợt này — đáng chú ý nhất là bảng luật thành-công Paygate, luật đơn vị tiền
   khi đặt cược, và máy trạng thái phân trang 7 trạng thái.
4. **(Đợt 5) Phát hiện thêm 1 nợ lớn bị sót: package `sport_notice` port sai
   4 lớp guard** (MAX-MERGE, warming, slow-path diff, gap-clock) — 8 test app
   đỏ từ trước, và notice WEB CHẾT HẲN (không bao giờ có baseline). Đã viết
   lại mirror đúng bản gốc — xem "Đợt 5 (14/09/2026) — R7-4".

---

## TRẠNG THÁI TRIỂN KHAI (cập nhật 13/09/2026 — R7-0 + R7-1 + R7-2 ĐÃ THỰC THI)

Theo yêu cầu "xử lý đi": **Phase R7-0 (cứu build) + nợ gọi lại Nhóm A đã được
thực thi và verify**. Không package mới nào được tạo ngoài việc HOÀN THIỆN
`mini_game_countdown_core` (stub → controller thật) và PHỤC HỒI `game_launcher`
(bị xoá nhầm).

### Đợt 2 (cùng ngày) — R7-1 + R7-2 ĐÃ THỰC THI

| Mục | Trạng thái | Chi tiết thay đổi |
|---|---|---|
| A1 web `card_last_join_store` (R7-1) | ✅ XONG | `_parse` + phần parse session XOÁ — delegate `pgm.parseCardLastJoin` (provider_game_manager); `_asInt` chỉ giữ lại cho envelope `code`/`status` |
| C6 `dart_kit.MicrotaskBurstCoalescer` | ✅ XONG | Package +7 test; app `lib/core/utils/microtask_burst_coalescer.dart` → re-export; thêm dep `dart_kit` vào app pubspec |
| C6 (nối nợ Round 6) | ✅ XONG | App `debouncer`/`semaphore`/`request_lock_mixin` cũng chuyển re-export `dart_kit` (3 file, giữ nguyên API — trước đó dart_kit tồn tại nhưng KHÔNG ai dùng) |
| C5 `dart_kit.PaginatedMachine` | ✅ XONG | Package: `PaginatedStatus`/`PaginatedPage`/`PaginatedMachine` (7 trạng thái + RequestLock) +12 test; web `paginated_store.dart` → vỏ ChangeNotifier delegate, re-export giữ API; thêm dep `dart_kit` vào web pubspec |
| B12 web `match_summary_rest` | ✅ XONG | Xoá `parse` port tay (~108 dòng) — gọi `betting_domain.MatchSummaryParser.parse` |
| C2 `betting_domain.BettingRestRules` | ✅ XONG | Package mới (thousandUnitToVnd, parlayRouteSportId GSB-636, oddsStyleApiCode, parlaySendStyle 'de', isPlaceSuccess, freshOddsFromValues, parlayStakeForLeg, 3 bộ mã lỗi) +14 test; wire CẢ 2 BÊN: web `betting_rest`/`bet_selection.apiOddsStyle` + app `betting_repository._parlayRouteSportId`, `_getOddsStyleCode` ×2 provider |
| C4 `auth_domain.SbUserIdentity` | ✅ XONG | Package: 2 dạng numeric/named + balanceFromKUnits + toUserDataMap +7 test; wire CẢ 2 BÊN: app `SbUserService.parseUserInfo`/`parseBalance` + web `SbUserRest._fetch` |
| C7 `sport_events.FavoriteIds` | ✅ XONG | Package: parse `{"sportId":{"0":[..],"1":[..]}}` phòng thủ +8 test; wire CẢ 2 BÊN: app `FavoriteData.fromJson` + web `FavoritesRest.fetchFavoriteIds` |
| C3 cashout | ✅ (có sẵn) | Web `cashout_rest` đã delegate `betting_domain.CashoutQuote/Result` từ Round 3 — kiểm đếm lại, không cần làm thêm |

**Verify sau khi thực thi (đợt 2):**

| Kiểm định | Kết quả |
|---|---|
| `make test-shared` | ✅ **24/24 package pass** (~977 test; dart_kit 11→30, betting_domain 109→123, auth_domain 54→61, sport_events 20→28) |
| `flutter analyze lib test` (app) | ✅ **0 error** (1207 issues = warning/info) |
| `dart analyze` (jaspr_web) | ✅ **0 error** (45 issues = info) |
| `flutter build apk --debug` | ✅ **SUCCESS** — `✓ Built build/app/outputs/flutter-apk/app-debug.apk` |
| `make build-jaspr` | ✅ **SUCCESS** — `Completed building project to /build/jaspr` (staging, -O2) |
| Test nhóm liên quan app | ✅ 46 test pass (favorite/harness/league + notice/derived/event_live/socket_slice/live score). 🔴 3 test `match_notice_fast_path_test` fail — **đã A/B xác nhận fail có sẵn với bản gốc trước khi sửa** (do đợt sealed-class A11, không phải do đợt này) |

### Đợt 3 (cùng ngày) — R7-3: B1 + C1 ĐÃ THỰC THI

| Mục | Trạng thái | Chi tiết thay đổi |
|---|---|---|
| B1 parser vé MyBets | ✅ XONG | Web `my_bets_rest` XOÁ toàn bộ parse tay + luật tiền (`_settlementOf` 5 bước, combinedOdds, parlayInfo money — ~150 dòng): `_fromCamel` → `BetSlip.fromJson` + `resolveComboWinning`, `_fromNumeric` → `BetSlipParser.parse`; map view qua `MyBetLeg.fromSlip/fromChild` (giữ fallback oddsName→cls CHỈ tab camel). 🔴 Package: sửa REGRESSION hoist — `BetSlipParser.parse` đọc nhầm `cashOutAbleAmount` khoá `'23'` (không tồn tại) thay vì `parlayInfo['0']` (bản gốc `bet_slip_parser.dart:30+88`) + camel `homeId/awayId` tolerant string (mirror `_idOf` của web, otherwise mất id → hỏng "Xem trận") + htScore/names tolerant. +14 test di trú `my_bets_parser_migration_test.dart` |
| C1 `paygate_domain` (TIỀN) | ✅ XONG | Package MỚI: `PaygateCommand` — bảng luật thành-công THEO TỪNG LỆNH (thiếu status OK với 8 lệnh / LỖI với giftcode+userCreateBankAccount; chargeCard thêm 1099 thành-công-mềm `isSoftProcessing` — không refresh số dư), `paygateStatusOf`, `PaygateResult` (+15 test). Wire CẢ 2 BÊN: web `paygate_rest` (PaygateResult re-export; `_result`/`_parseQr` nhận command; chargeCard/useGiftCode/OTP ×2/rút ×3/fetchConfig/getCryptoAddress — xoá `_status`) + app `deposit_repository_impl` ×7 site + `withdraw_repository_impl` ×3 site. Dep vào cả 2 pubspec |

**Verify sau khi thực thi (đợt 3):**

| Kiểm định | Kết quả |
|---|---|
| `make test-shared` | ✅ **25/25 package pass** (thêm `paygate_domain` 15 test; tổng ~1006 test) |
| `flutter analyze lib test` (app) | ✅ **0 error** (1206 issues — về đúng baseline) |
| `dart analyze` (jaspr_web) | ✅ **0 error** (45 issues = info) |
| `flutter build apk --debug` | ✅ **SUCCESS** |
| `make build-jaspr` | ✅ **SUCCESS** |

### Đợt 4 (cùng ngày) — R7-3: B10 + B5 + B6 + B11 ĐÃ THỰC THI

| Mục | Trạng thái | Chi tiết thay đổi |
|---|---|---|
| B10 outright parse | ✅ XONG | `betting_domain/src/outright_cards.dart`: `OutrightSelection`/`OutrightCard` + `parseOutrightCards` (3 tầng khoá số + flatten `outrightId = eventId*1000+lineIndex`, bỏ line rỗng, parse phòng thủ string/num) +5 test. Web `sport_outright_rest` xoá model + parse loop → `bd.parseOutrightCards`, re-export model giữ API cho UI. App `special_outright_model` giữ host (chờ delegate sau) |
| B5 search key-map | ✅ XONG | `sport_events/src/search_hits.dart`: `SearchLeagueHit`/`SearchEventHit`/`SearchHits.fromApi` (bảng key 0..11 — key 1 = leagueId, key 3 = eventId, cảnh báo đảo) + `parsePopularEventHits` (2 dạng envelope alternate/standard + sportId TỪ TRẬN + sort marketCount + take limit) +11 test. Wire CẢ 2 BÊN: web `search_rest` re-export + delegate; app `SearchResultItem`/`SearchLeagueItem` delegate (isLive mở rộng tolerant num/string) |
| B6 hot-stats luật | ✅ XONG | `betting_domain/src/hot_stats_rules.dart`: `HotStatsRules.bettingTrendLabel` (market 5 bám mainLine: mainLine 0 → |points| ≤ 0.5; khác 0 → 2 phía gần nhất; fallback market 1 đổi Home/Away; **market 3 cố ý bỏ qua**) + `totalUsers` (key "1") +7 test. Wire web `hot_stats_rest` (xoá `_bettingTrend` + `_Sel`). App `hot_match_repository_impl` đi qua model `BetStatisticsSimple` — delegate sau |
| B11 transaction payload | ✅ XONG | `transaction_domain/src/transaction_history_rest_rules.dart`: `TransactionHistoryApi` (4 command + assetName 'gold' — mirror api_endpoints:218-223), `transactionCountAndItemsOf` (3 hình dạng response, count thiếu → items.length), `transactionBusinessErrorOf` (paygate status 200/0 vs sa code) +9 test. Web `transaction_history_rest` xoá hằng + `_countAndItems` + body `_throwIfBusinessError` → delegate |

**Verify sau khi thực thi (đợt 4):**

| Kiểm định | Kết quả |
|---|---|
| `make test-shared` | ✅ **25/25 package pass** (~1037 test; sport_events +11, betting_domain +12, transaction_domain +9) |
| `flutter analyze lib test` (app) | ✅ **0 error** (1206 issues — baseline) |
| `dart analyze` (jaspr_web) | ✅ **0 error** (47 — +2 do analyze quét thêm thư mục build/jaspr) |
| `flutter build apk --debug` | ✅ **SUCCESS** |
| `make build-jaspr` | ✅ **SUCCESS** |

### Đợt 5 (14/09/2026) — R7-4: nợ notice (A12) + B3 + B8 + nợ test tiền ĐÃ THỰC THI

Tiếp "làm tiếp": xử lý nốt các mục còn lại + 1 nợ test đỏ mới phát hiện.

| Mục | Trạng thái | Chi tiết thay đổi |
|---|---|---|
| A12 `sport_notice` port SAI 4 lớp guard (mới phát hiện — 8 test app đỏ, KHÔNG phải 3 như ghi đợt 1) | ✅ XONG | Detector viết lại MIRROR đúng 2 bản gốc (app @83c2477a2, web @f08b83162): (1) **MAX-MERGE** fast path — EventLiveData partial (stats=0) không clobber snapshot (bản cũ gán thẳng → notice GIẢ); (2) **warming** chỉ add khi baseline-first `prev==null`, tiêu ở CẢ slow+fast (bản cũ add lại mỗi tick slow → warming không bao giờ hết, tick fast đầu bị nuốt mãi); (3) **slow path phải diff+trigger** trong `seedEvents` (bản cũ gán thẳng → goal qua nhịp convert-list không bắn, replay-guard đỏ); (4) **gap rules nhận đúng `clock` inject + `onSuspend`** (bản cũ dùng `DateTime.now` thật → fixture lệch, không xoá notice kẹt). Package: `MatchNoticeDetector(baselineOnUnknown:)` — web KHÔNG có slow path nên onEvent tự baseline (bản cũ web chết hẳn notice: prev==null → return mãi mãi) + `NoticeGapRules.suppressFor` (resume cooldown) + `_lastTickAt` null-init. App `MatchNoticeSuspendGuard`: nối `onSuspend` xuống gap rules + nhánh `resumed` đặt cooldown (bị bỏ sót). Web `match_notice_service`: `baselineOnUnknown: true` + khôi phục guard `homeScore/awayScore == null → return` (mirror bản gốc — bản cũ mặc null→0 clobber). Test package: viết lại `match_notice_detector_test.dart` (14 case: 5 fast-path + 2 slow + 1 baselineOnUnknown + 7 cũ) + `notice_gap_rules_test` +2. Verify: **15/15 test app notice** (fast_path 5 + replay 3 + suspend 7) + 14/14 package |
| B3 balance parse | ✅ XONG | `game_api_client.UserBalanceData.fromJson` mở rộng tolerant "500.000"/"500,000" (strip digits — 🔴 KHÔNG dùng `num.tryParse` cho string: "500.000" sẽ thành `500.0` double, sai 1000 lần). Web `balance_rest` XOÁ `_asInt` + `_parseBalance` → envelope `GameApiResponse.isSuccess` + `GameApiParsers.parseUserBalance` (web pubspec ĐÃ có dep). +1 test di trú (68/68) |
| B8 notification luật thuần | ✅ XONG | Package MỚI `notification_domain` (pure Dart, 0 dep): regex phân loại `(tỉ\|tỷ)\s*lệ\s*cược` / `(cập\s*nhật\|trận\s*đấu)` + 3 label hằng + `notificationRelativeTime` (+14 test). Model freezed GIỮ host (D6) — hoist không cần chờ chốt model. Wire CẢ 2 BÊN: app `notification_category.dart` + `notification_relative_time.dart` → wrapper 1 dòng; web `notification_rest` → enum vỏ map từ kind, label lấy hằng package. Dep vào cả 2 pubspec. Lệch category được HỢP NHẤT theo regex (regex ⊇ contains app — không mất phân loại nào của app, chỉ nhận thêm message kỳ dị "tỉ  lệ cược") |
| Nợ test tiền 1099 (mới phát hiện) | ✅ XONG | `money_flow_success_test` "thẻ cào 1099: không gọi ngay nhưng 30s sau VẪN kiểm tra lại" — **fail có sẵn từ a00750574** (A/B worktree xác nhận, trước đợt C1). Nguyên nhân: test đẩy user vào broadcast stream TRƯỚC tap, mà `userProvider` LAZY (notifier tạo trong tap) → miss → `state.isLoggedIn` false → nhịp trễ 30s tự return. Sửa TEST (đẩy lại user sau tap) — 5/5 pass. Code production không đổi |
| B9 avatar | ⏸ GIỮ HOÃN | View nhỏ; app có infra `SunApiResponse` riêng (nested-status) — cross-wiring không đáng (lý do không đổi) |

**Verify sau khi thực thi (đợt 5):**

| Kiểm định | Kết quả |
|---|---|
| `make test-shared` | ✅ **26/26 package pass** (~1.052 test; thêm `notification_domain` 14; `game_api_client` 67→68; `sport_notice` 14) |
| Test notice app | ✅ **15/15** (fast_path 5 + replay_guard 3 + suspend_guard 7 — trước đợt: **8 đỏ**) |
| Test tiền app | ✅ `money_flow_success_test` **5/5** (trước: 1 đỏ) |
| `flutter analyze lib test` (app) | ✅ **0 error** (1206 issues — baseline) |
| `dart analyze` (jaspr_web) | ✅ **0 error** (47 issues = info baseline) |
| `flutter build apk --debug` | ✅ **SUCCESS** |
| `make build` (jaspr_web) | ✅ **SUCCESS** |

**Nợ test PRE-EXISTING phát hiện khi quét (chưa làm — ngoài phạm vi shared-package):**
- 🔴 3 test `store_backed_seed_gate_test` (2) (4) + `store_backed_data_only_update_test` — `state.leagues` rỗng (`Bad state: No element` ở `widgetList.single`). **A/B xác nhận fail sẵn ở HEAD `f2c538c3c`** (trước mọi thay đổi đợt 5). Thuộc pipeline `events_v2`/store — đề xuất đợt riêng.

### Đợt 6 (14/09/2026) — R7-5: QUÉT FULL TEST SUITE — 32 test đỏ pre-existing → 0

Chạy `flutter test` FULL SUITE lần đầu trong các đợt R7 (các đợt trước chỉ chạy
nhóm liên quan) — phát hiện **32 test đỏ**, A/B worktree xác nhận **toàn bộ
fail sẵn** (ở HEAD `f2c538c3c`, và phần lớn cả ở `83c2477a2` trước Round 6) —
nợ cổ tích luỹ từ nhiều commit, không phải regression đợt 5. Đã xử lý **29/32**:

| Cụm | Số | Root cause | Fix |
|---|---|---|---|
| `store_backed_*` (seed_gate + data_only) | 3 | Fixture tạo `EventModelV2` thiếu `isLive: true` — gate `liveOnlyLeagues` (4fb1b0df8, fix ĐÚNG: live tab chỉ render event live, mirror web) lọc sạch fixture | Sửa FIXTURE (event live) — production đúng |
| `bet_detail_store_mode` + `goal_window` + `race_h7` | 13 | `betDetailMobileV2Provider` CỐ Ý autoDispose (decision đã ship — nhất quán eventsV2/parlay) nhưng test `container.read` 1-lần không giữ listener → notifier dispose ngay sau `pumpEventQueue` đầu → "Tried to use ... after dispose" | Test-infra: `container.listen(betDetailMobileV2Provider, …)` keep-alive trong helper `build()` ×3 file — production không đổi |
| `detail_store_backed_harness` (PARITY) | 6 | Lệch field `period` 2 đường: socket derive từ selectionId (luật tiền kèo rung — thiếu prefix `{period}-` → 607/620), REST-detail payload không gửi field 13 → 0 | **Prod**: `EventDetailResponseV2Adapter.toLeagueEventData` derive cùng luật qua `betting_domain.deriveSelectionPeriod` (1 nguồn luật 2 đường, mirror `StoreToV2Converter._derivePeriod`) — model deep-equal qua merge `_loadFullMarkets` |
| `sb_http_manager_test` | 6 | (a) `reset()` `_user.clear()` TRẦN → getters cast null (uid/balance) **crash thật sau reconnect nếu đọc trước getUserInfo**; (b) guard `getSbToken` DEAD CODE — `sportTokenUrl` luôn trả `'…?command=get-token'` (có suffix) nên `isEmpty` không bao giờ đúng; (c) test env thiếu path_provider (Hive) | **Prod**: `reset()` → `SbUserService.resetUserData` (khôi phục default như `resetForLogout`); `getSbToken` guard kiểm `sport_domain` trực tiếp. Test: status default 'Active' (khớp khai báo map), xoá `_userToken` tường minh (singleton carry-over), mock channel path_provider → temp dir |
| `market_odds_rules_test` | 3 | Declared delta Round D (07/07) STALE vs thay đổi có chủ ý đã ghi chú trong package: 145 (SB2 v6.0.41 đè nghĩa cũ → Corner OEU FT decimal-only, đo 2026-09-03), 138 (mirror 29/30), + nhóm v6.0.41 (68/81/82/98/147/1003/193/194/144/152/195/199/1005/1018/157), −1009/1010 (curl chấp nhận "ma") | Refresh 2 tập declared + comment trỏ nguồn chú thích inline package — guard delta hoạt động trở lại (lệch 1 id = đỏ) |
| `responsive_builder_test` | 1 | Sample width 1300 rơi TABLET sau khi `Breakpoints.desktop` đổi thành 1439 | Cập nhật sample theo breakpoint thật (950/1300→tablet, 1439 desktop, 1600 largeDesktop) |
| `home_screen_test` | 1 | Assert text placeholder 'Home (Mobile)/(Desktop)' — không còn tồn tại trong lib; width 1400 giờ là TABLET (breakpoint 1439) | Assert theo `byType` (HomeMobileScreen/HomeDesktopScreen); width desktop 1500 |
| `widget_test` (template) | 1 | Template Flutter "Counter" trỏ vào app THẬT — boot cần config/network, không unit-test được | `skip: true` + lý do (đợi harness boot-app riêng) |
| `sb_authentication_integration_test` | 5 | LIVE integration test (đúng doc ghi: cần mạng thật + token) — chết ở Hive/path_provider trong unit env | `skip` cả group + hướng dẫn chạy thủ công |

**Verify sau khi thực thi (đợt 6):**

| Kiểm định | Kết quả |
|---|---|
| `flutter test` FULL SUITE | ✅ **+1275 ~7 skip · 0 FAIL** (trước đợt: +1249 −32; TEST_EXIT=0) |
| `flutter analyze lib test` | ✅ **0 error** (1206 issues — baseline) |
| `dart analyze` (jaspr_web) | ✅ **0 error** (47 — baseline) |
| `flutter build apk --debug` | ✅ **SUCCESS** |
| `make build` (jaspr_web) | ✅ **SUCCESS** |

> Còn lại sau đợt 6: chỉ B9 avatar (hoãn có lý do) + 7 skip có lý do (6 mới:
> 5 live-integration auth + widget template + 1 skip sẵn của sport_socket).

| Mục | Trạng thái | Chi tiết thay đổi |
|---|---|---|
| A8 game_launcher (phantom) | ✅ XONG | `git restore --source=14fb69d7d^ -- packages/game_launcher` (7 file: GameLauncher MethodChannel, GameLaunchConfig/Result/Failure, GameCredentials) + dep `game_launcher` trở lại `pubspec.yaml` (bị xoá sót từ 14fb69d7d) |
| A8 `game_launcher.dart` (app) | ✅ XONG | Phục hồi bản hoàn chỉnh 402 dòng (14fb69d7d^); thay khai báo enum+class in-file bằng import `game_launcher_lifecycle` (giữ Round 5) + re-export giữ API |
| A8 `game_orientation_resolver.dart` | ✅ XONG | Thêm `import game_orientation` (re-export-without-import) + dùng `DefaultGameOrientationResolver()` (abstract không instantiate được) |
| A8 `asset_storage.dart` | ✅ XONG | Thêm `import game_asset` (cùng lỗi re-export-without-import cho `AssetStorage`) |
| A7 card_last_join ambiguous | ✅ XONG | `game_last_join_provider.dart` + `game_last_join_test.dart`: `hide CardLastJoinSession, buildCardLastJoinSession` trên import `provider_game_manager`/`game.dart` — bản wrapper typed-model của app giữ nguyên |
| A9 chat_protocol dep | ✅ XONG | Thêm `chat_protocol: path: packages/chat_protocol` vào `pubspec.yaml` app |
| A10 live_consumers syntax | ✅ XONG | Xoá mảnh code mồ côi 608–628 (tail cũ của `_buildTableTennis`); bỏ import `live_match_period_resolver.dart` thừa |
| A11 freezed | ✅ XONG | `build_runner` sinh lại `match_notice_provider.freezed.dart`; `MatchNoticeEvent` đổi thành `sealed class` (đúng pattern `UnifiedTransaction`/`NotificationItem` của repo); thay `!e.isSoccer` (không tồn tại) bằng `e.sportId != 1` như bản cũ |
| A2 mini_game_countdown_core | ✅ XONG | Package: thay stub bằng `TaiXiuCountdownState` (class, field tên app: `taiXiuSec`/`taiXiuIsTai`/`taiXiuAwaitingResult`) + `TaiXiuCountdownController` (port logic từ bản web cũ — GSB-626/669, clock injectable qua `package:clock`) + `TaiXiuNanFlags` đầy đủ stream `onBowlOpened`; test viết lại 7 case (`fake_async`); dep `mini_game_protocol` + `clock`; xoá stub `tai_xiu_countdown.dart`. App: provider đã delegate đúng sẵn. Web: `parseTaiXiuMessage(raw.payload)`, nối `_bowlSub`, caller overlay/menu_panel/tx_game_view đổi tên prefix + `taiXiuAwaitingResult`, `start(_lobby.messages)` |
| A3 web match_notice_service | ✅ XONG | Thêm `dart:async`; khôi phục `bindBridge()` (idempotent, wrap `attach`) + `debugTrigger()` (ghi thẳng state qua `notice.noticeKey`); `bd_match_header` đổi `attach(_bridge)` → `bindBridge()` |
| A4 odds delegation 2 bên | ✅ XONG | App: `OddsChangeData` trở lại class thật (mirror `betting.OddsChangeRecord` + `oddsValues` + `getValueByStyleIndex` + `isIndicatorActive` qua `betting.isOddsIndicatorActive`); 6 file call-site thêm `hide OddsChangeDirection` (betting_enums): parlay_match_card, parlay_stake_section, bet_card_mobile(_v2), handicap_section, bet_card, socket_slice_coalescing_test. Web: `odds_display_service.styleValueOf` prefix `betting.OddsStyle` |
| A5 login_timing | ✅ XONG | `library;` về dòng 1 |
| A6 game_asset export | ✅ XONG | (gộp vào A8 — import interface) |
| (mới phát hiện) shell_desktop_sidebar | ✅ XONG | `c.categoryId` → `c.id` (`LobbyCategory` không có categoryId) |
| (mới phát hiện) store_to_v2_harness_test | ✅ XONG | `_FakeDataSource` implement thêm `getEventDates` (interface mới của `EventsV2RemoteDataSource`) |

**Verify sau khi thực thi:**

| Kiểm định | Kết quả |
|---|---|
| `flutter analyze lib test` (app) | ✅ **0 error** (1206 issues = warning/info có sẵn) |
| `dart analyze` (jaspr_web) | ✅ **0 error** (44 issues = warning/info) |
| `make test-shared` | ✅ **24/24 package pass** (`mini_game_countdown_core` +7 test mới) |
| `flutter build apk --debug` | ✅ **SUCCESS** — `✓ Built build/app/outputs/flutter-apk/app-debug.apk` (208MB, Gradle 719s) |
| `make build-jaspr` | ✅ **SUCCESS** — `Completed building project to /build/jaspr` (staging, -O2) |
| Test 2 file test đã sửa | ✅ **27/27 pass** (`game_last_join_test` + `socket_slice_coalescing_test`) |

> Ghi chú quy ước: mọi edit đều kèm comment `Round 7 (R7-0/Ax)` để trace được
> về báo cáo này.

---

## PHẦN I — KIỂM ĐỊNH BUILD

### 1.1. Kết quả từng kiểm định

| # | Kiểm định | Lệnh | Kết quả |
|---|---|---|---|
| 1 | pub get app | `flutter pub get` | ✅ OK |
| 2 | pub get web | `dart pub get` (jaspr_web) | ✅ OK — config cũ trước đó là một phần nguyên nhân làm báo lỗi phình to |
| 3 | analyze app | `flutter analyze lib test` | ❌ 1448 issues: **191 dòng error (~96 unique** — analyzer đếm mỗi lỗi 2 lần qua 2 context lib/test**)**, 0 warning, 1096 info |
| 4 | analyze web | `dart analyze` (jaspr_web) | ❌ 98 issues: **29 error unique** (58 dòng, mỗi lỗi 2 context), 0 warning, 40 info |
| 5 | build app | `flutter build apk --debug --no-pub` | ❌ **BUILD FAILED in 30s** (Gradle `assembleDebug` exit 1) |
| 6 | build web | `make build` (jaspr_web) | ❌ FAIL — dart2js compile error (Tailwind + jaspr builder chạy OK tới bước compile Dart) |
| 7 | test package chung | `make test-shared` | ❌ FAIL tại `packages/mini_game_countdown_core` (vòng lặp `|| exit 1` dừng ở package đầu tiên hỏng); **23 package còn lại PASS** |
| 8 | analyze từng package | `dart analyze` × 32 package | ✅ 31/32 = **0 error**; riêng `mini_game_countdown_core` = 2 error (file test cũ so với API package) |

> ⚠️ Lưu ý đo đạc: `flutter analyze` chạy ở GỐC repo quét luôn cả `jaspr_web/`
> (context package khác + cấu hình pub cũ) nên báo 3264 issues/2452 error —
> phần lớn là ẢO. Số liệu đáng tin ở bảng trên là khi analyze TỪNG project riêng.

**Trạng thái package chung (test-shared, trừ package Flutter-bound):**

| Kết quả | Package (số test) |
|---|---|
| ✅ PASS (23) | `app_env` 47 · `app_format` 16 · `app_i18n` 3 · `auth_domain` 54 · `betting_domain` 109 · `brand_config` 32 · `casino_jackpot` 3 · `chat_protocol` 22 · `dart_kit` 11 · `game_api_client` 67 · `game_asset` 10 · `game_jackpot` 12 · `game_launcher_lifecycle` 12 · `game_url` 9 · `mini_game_protocol` 62 · `monitoring_domain` 24 · `provider_game_manager` 144 · `sport_events` 20 · `sport_live` 11 · `sport_notice` 14 · `sport_socket` 214 (1 skip) · `sport_vibrating_odds` 13 · `transaction_domain` 38 |
| ❌ FAIL (1) | `mini_game_countdown_core` — `test/countdown_test.dart` không compile: `TaiXiuCountdown(1, 12.5)` truyền `int` vào chỗ đòi `MiniGameCountdownState` |

> Tổng **~948 test pass** ở 23 package — tầng package tự thân khoẻ; lỗi nằm ở
> call-site app/web và đúng 1 package vừa tách.

### 1.2. Nguồn gốc lỗi — 8 cụm

Hai commit cuối `f8b9cf37` (17:08) và `c36e8318` (17:42) ngày 13/09 đã commit
code **không build được** — một số cụm gãy nằm sẵn ở HEAD, một số khác nằm trong
sửa-chưa-commit (đang `M`: `live_consumers.dart`, `odds_change_provider.dart`,
web `odds_display_service.dart`, web `login_timing.dart`).

**Cụm 1 — freezed chưa sinh (app, 1 file).**
`lib/features/sport/presentation/providers/match_notice_provider.dart` khai
`part 'match_notice_provider.freezed.dart'` nhưng file part **không tồn tại**
(duy nhất 1 part thiếu trong toàn bộ `lib/`) → `_$MatchNoticeEvent` không tìm
thấy, kéo theo `StateNotifier`/`state` báo lỗi dây chuyền trong file.
→ Chỉ cần `make gen` (build_runner).

**Cụm 2 — thiếu dep `chat_protocol` ở app.**
`lib/core/services/websocket/sb_chat_websocket.dart:21` import
`package:chat_protocol/chat_protocol.dart` — package tồn tại
(`packages/chat_protocol`, 22 test pass, web đã dùng) nhưng
**root `pubspec.yaml` chưa khai dep** → 6 lỗi (`ChatSessionMachine`,
`ChatSessionConfig`, `ChatSessionHooks`, `dispatchChatFrame`).

**Cụm 3 — package `game_launcher` PHANTOM (app, 4 file dính).**
`cocos_game_controller.dart:4` + `cocos_game_providers.dart:3` import
`package:game_launcher/game_launcher.dart` — **không tồn tại** (chỉ có
`game_launcher_lifecycle`). Symbol bị mất: `GameLauncher`, `GameLaunchConfig`,
`GameLaunchResult`, `GameLaunchFailure`, `GameCredentials`. Lỗi lan sang
`game_group_view`, `game_filter_view`, `game_player_notifier`
(`nativeGameLauncherProvider`, `isLauncherAvailable`).
→ Đây là một đợt tách **mở nhưng không xong**: hoặc hoàn thiện package
`game_launcher` (native launcher — taxonomy lỗi trùng với web
`casino_launcher`), hoặc revert 2 import về code trong app.

**Cụm 4 — `game_launcher.dart` (app) bị cắt gián đoạn.**
Dù re-export `GameLauncherState/Status` từ `game_launcher_lifecycle` (dòng
24–25), file vẫn báo undefined: `isLoggedInProvider`, `gameUrlProvider`,
`assetWipeProvider`, `GameLauncherState/Status`, mất hẳn `_openInNewTab`,
`_openWebViewPlayer`, `_isNativeMobile`; method thật là `launchGame` nhưng
call-site (`game_group_view.dart:54`) vẫn gọi `.launch`. File đang ở trạng thái
"nửa thân" — nhiều khả năng bị lược bớt khi dọn sang package `game_launcher`
chưa kịp tạo. → Khôi phục thân + import, đồng bộ tên method với call-site.

**Cụm 5 — `live_consumers.dart` HỎNG CÚ PHÁP (app, sửa chưa commit).**
Khối dòng ~608–860 vỡ cú pháp (`missing_const_final_var_or_type`,
`obsolete_colon_for_default_value` — dùng `:` thay `=` cho default value,
`unexpected_token`) trong lúc delegate `resolveLiveTimeDisplay` sang
`betting_domain`. ~20 lỗi syntax + lỗi dây chuyền trong file.

**Cụm 6 — delegate `OddsDirectionTracker` bán thành (app + web, sửa chưa commit).**
- App `odds_change_provider.dart`: xoá `OddsChangeData` + hằng, nhưng
  `parlay_live_odds_provider` (dòng 118/139) và `parlay_match_card` (793) vẫn
  đọc `OddsChangeData.oddsValues`; dòng 282 vẫn truyền named param `oddsValues`;
  file vẫn export `OddsChangeDirection` → **ambiguous import** với
  `betting_enums.dart` ở `parlay_match_card` (6 lỗi) + `parlay_stake_section` (2).
- Web `odds_display_service.dart`: switch dòng 233–241 dùng `OddsStyle`
  KHÔNG prefix trong khi import đã thành `as betting` → 5 lỗi.

**Cụm 7 — `mini_game_countdown_core` lệch API 3 lớp.**
Package đổi hình API (bản cũ `TaiXiuCountdown(int, double)` +
`TaiXiuCountdownState/Controller` + `TaiXiuNanFlags`; bản mới theo
`MiniGameCountdownState`) nhưng: (a) **test của chính package** vẫn xài API cũ
(2 error), (b) app `mini_game_countdown_provider.dart` + `mini_game_fab.dart` +
`mini_game_menu_panel.dart` (`taiXiuSec`/`taiXiuIsTai`/`taiXiuAwaitingResult`
kèm lỗi null-safety), (c) web `mini_game_countdown.dart` (5 lỗi tên cũ + 1 lỗi
`RawMessage` → `Map<String, dynamic>`), `tx_game_view.dart` (10 lỗi
`TaiXiuNanFlags`), `mini_game_overlay.dart` + `mini_game_menu_panel.dart`
(4 lỗi `MiniGameCountdownState/MiniGameCountdown`).
→ Chốt MỘT bộ tên API rồi sửa đồng loạt cả 3 lớp (package test, app, web).

**Cụm 8 — các nợ lẻ còn lại.**
- `game_asset`: interface `AssetStorage` không còn được export →
  `asset_storage.dart:10` `implements` class không tồn tại +
  `game_asset_cache_provider.dart:25` sai kiểu tham số.
- `game_last_join_provider.dart`: **ambiguous import** `CardLastJoinSession` /
  `buildCardLastJoinSession` — app vẫn giữ bản local
  `lib/features/game/last_join/card_last_join_session.dart` song song với
  package `provider_game_manager` (Round 6 — 3.1 nối app nhưng chưa xoá bản cũ);
  kèm lệch signature (named param `manager`).
- Web `login_timing.dart`: `library;` đặt SAU import (dòng 12) — lỗi cơ học
  khi edit delegate `monitoring_domain.LoginTiming`.
- Web `match_notice_service.dart`: mất `import 'dart:async'`
  (`StreamSubscription` ×2) và mất method `bindBridge`/`debugTrigger` mà
  `sd_live_list.dart:102` + `odds_demo_page.dart:135` vẫn gọi.
- Web `bd_match_header.dart:143`: getter `_bridge` không tồn tại.

### 1.3. Thứ tự vá đề xuất để build lại xanh (không đổi kiến trúc)

1. `make gen` — sinh lại `match_notice_provider.freezed.dart`.
2. Thêm `chat_protocol` vào `pubspec.yaml` app + `flutter pub get`.
3. Cụm `game_launcher`: chốt (a) hoàn thiện package `game_launcher`, hoặc
   (b) revert import về code trong app; khôi phục thân `game_launcher.dart`;
   đồng bộ `.launch` ↔ `.launchGame`.
4. Sửa khối syntax `live_consumers.dart` 608–860.
5. Hoàn tất delegate odds: app `odds_change_provider` + call-site parlay
   (`oddsValues`, ambiguous `OddsChangeDirection`) + web `odds_display_service`
   (prefix `betting.`).
6. Cụm mini game countdown (package test + app 3 file + web 4 file).
7. Web lẻ: `login_timing.dart` (`library;` lên đầu), `match_notice_service.dart`
   (`dart:async` + `bindBridge`/`debugTrigger`), `bd_match_header.dart` (`_bridge`).
8. `game_asset`: export lại `AssetStorage`; xoá bản copy
   `lib/features/game/last_join/card_last_join_session.dart`.
9. Verify xanh: `make gen` → `flutter analyze lib test` (0 error) →
   `dart analyze` web (0 error) → `make test-shared` →
   `flutter build apk --debug` → `make build-jaspr`.

---

## PHẦN II — LOGIC CÒN LẠI CÓ THỂ ĐÓNG VÀO PACKAGE DÙNG CHUNG

Bản đồ tổng hợp sau 6 đợt:

| Nhóm | Số vị trí | Tính chất |
|---|---|---|
| A. Nợ gọi lại từ Round 6 (chưa nối/half-done) | 11 | 🔴 phần pure đã nằm trong package, chỉ còn nối call-site |
| B. Phase 5 của Round 6 — tầng parse REST | 13 | ⚪ web 5323 dòng ↔ app repository; cần chốt model |
| C. Ứng viên MỚI đợt này | 7 | 🟡 thuần Dart, có bản đối xứng 2 bên |
| D. KHÔNG nên đóng gói | — | cập nhật danh mục chốt từ các đợt trước |

---

## NHÓM A — NỢ GỌI LẠI TỪ ROUND 6 (🔴 làm TRƯỚC khi mở package mới)

Round 6 báo "XONG" nhưng thực tế mới nối MỘT bên, hoặc rename API chưa lan hết
call-site — chính là các cụm lỗi build ở Phần I. Liệt kê lại thành checklist
để không lẫn vào việc "thêm package mới":

| # | Vị trí | Việc còn thiếu |
|---|---|---|
| A1 | web `services/casino/card_last_join_store.dart` (`_parse` dòng 237–250) | Đang parse local (`sid/serverID→serverId`, `pwd/roomPassword→password`, `_asInt` phòng thủ) song song với `provider_game_manager.parseCardLastJoin` — file **không import package**. Nối + xoá bản parse (Round 6 3.1 chỉ nối app) |
| A2 | `mini_game_countdown_core` + 7 call-site (app 3, web 4) + test package | Chốt bộ tên API cuối (`MiniGameCountdownState`?), sửa đồng loạt — xem Cụm 7 |
| A3 | web `services/odds/match_notice_service.dart` | Hoàn tất delegate `sport_notice`: thêm `dart:async`, khôi phục `bindBridge`/`debugTrigger` cho 2 call-site |
| A4 | app `odds_change_provider.dart` + web `odds_display_service.dart` | Hoàn tất delegate `OddsDirectionTracker`: đổi hết call-site parlay khỏi `OddsChangeData.oddsValues`, gỡ export `OddsChangeDirection` chồng `betting_enums`, prefix `betting.OddsStyle` |
| A5 | web `services/monitoring/login_timing.dart` | Sửa vị trí `library;` (đã delegate `monitoring_domain`, edit gãy) |
| A6 | `game_asset` ↔ app `asset_storage.dart` | Export lại interface `AssetStorage` (Round 5 từng có; rename đã cắt export) |
| A7 | app `lib/features/game/last_join/card_last_join_session.dart` | Xoá bản copy (ambiguous với `provider_game_manager.CardLastJoinSession`) |
| A8 | `cocos_game_controller/cocos_game_providers/game_launcher.dart` | Chốt số phận package `game_launcher` (phantom) — Cụm 3/4 |
| A9 | root `pubspec.yaml` | Thêm dep `chat_protocol` (web đã có) |
| A10 | app `live_consumers.dart` | Sửa syntax khối 608–860 (delegate `resolveLiveTimeDisplay`) |
| A11 | app `match_notice_provider.dart` | `make gen` sinh freezed part |

---

## NHÓM B — TẦNG PARSE REST (⚪ Phase 5 của Round 6 — xác nhận CÒN NGUYÊN)

Web có 15 file `services/rest/` (**5323 dòng**) port tay từ tầng repository app.
Đây là lớp lớn nhất còn lại; chữ ký chung: **HTTP giữ host** (`AppHttp`/
`http` + `AuthConfig.proxied`), chỉ hoist PARSE + LUẬT thuần vào package
(tiền lệ `transaction_domain`, `betting_domain`). Bảng chi tiết:

| # | Web (`jaspr_web/lib/services/rest/`) | Dòng | App đối xứng | Ghi chú + đề xuất |
|---|---|---|---|---|
| B1 | `my_bets_rest.dart` (936) | `my_bet_repository/repositories/my_bet_repository_remote.dart` (373) | Parser vé `MyBetTicket`/`MyBetLeg` **2 dạng camelCase + khoá SỐ** — tiền. Hoist vào `betting_domain` (model thuần + `fromCamel/fromNumeric`); host giữ fetch + cache | Ưu tiên cao nhất nhóm |
| B2 | `betting_rest.dart` (484) | `sb_betting_service.dart` + `betting_repository.dart` | Body place/calculate-bet + 2 bẫy tiền: hạn mức đơn vị NGHÌN (×1000), xiên luôn decimal + `oddsStyle:'de'`, đơn gửi style đang hiển thị (612 "Incorrect winnings") → `betting_domain.BettingRestRules` (pure) | 🆕 nâng cấp từ "cần chốt" thành đề xuất cụ thể |
| B3 | `balance_rest.dart` (390) | wallet/ví app | Parse số dư + lịch sử biến động — kèm nhóm B1 | |
| B4 | `cashout_rest.dart` (179) | `sb_betting_service:249-278` + `MyBetRepositoryRemote:60-150` + `BetResellNotifier` | Luồng bán vé **hỏi giá 2 lần** + parse + phân loại lỗi → mở rộng `betting_domain` | |
| B5 | `search_rest.dart` (319) | `features/search/data/models/*` | Key-map SỐ (`1↔3` dễ đảo, ISO key `5`, epoch key `6`, sort `marketCount`) — Round 6 5.2. Hoist bảng key + `fromApi` vào package (đề cử `betting_domain` hay `sport_events`) | |
| B6 | `hot_stats_rest.dart` (208) | `hot_match_repository_impl.dart:180-258` | 2 endpoint song song, `page+size` BẮT BUỘC, `catchError` từng cái, cache theo `eventId` — parse thuần, gộp được | |
| B7 | `sport_lobby_rest.dart` (463) | `sb_http_manager` + endpoint model | Hot/popular/pin — luật top-league ĐÃ delegate (Round 6 2.5); còn lại mapping endpoint + seed store | gộp từng mảnh |
| B8 | `notification_rest.dart` (152) | `notification_item.dart` (freezed) | Nhỏ, gộp được khi model chuẩn hoá | |
| B9 | `avatar_rest.dart` (120) | user avatar reader | Nhỏ | |
| B10 | `sport_outright_rest.dart` (199) | outright reader | Kèm `OutrightKind` đã trong `betting_domain` | |
| B11 | `transaction_history_rest.dart` (340) | 4 data source + `sb_http_manager:774-915` | Header `Authorization` RAW không Bearer + `AuthConfig.proxied` — phần URL/query hoist được vào `transaction_domain` | |
| B12 | `match_summary_rest.dart` (281) | `SbHttpManager:965-979` + `MyBetRepositoryRemote:318-354` | `MatchSummaryParser` ĐÃ nằm trong `betting_domain` — web rest chỉ cần gọi lại; phần cache giữ host | rẻ nhất nhóm |
| B13 | `paygate_rest.dart` (950) | `features/profile/deposit/.../deposit_repository_impl.dart` + withdraw | **TIỀN.** Xem C1 — đáng lẽ là ứng viên package riêng | |
| — | `favorites_rest.dart` (188) | `favorite_provider:182-306` | Parse `{"sportId":{"0":[…],"1":[…]}}` — xem C7 | |
| — | `sb_user_rest.dart` (114) | `sb_user_service.dart:24-52` | Parse định danh sportbook — xem C4 | |

---

## NHÓM C — ỨNG VIÊN MỚI TÌM THẤY ĐỢT NÀY (🟡)

| # | Ứng viên | Bằng chứng 2 bên | Đề xuất package |
|---|---|---|---|
| C1 | **Bảng luật thành-công Paygate** (TIỀN) — mỗi lệnh một luật: `status==0` (giftcode `:325`, thiếu là LỖI) · `status!=null && !=0` (đa số — thiếu là OK) · `status ?? 1` (userCreateBankAccount `:714`) · `1099` = thành-công-mềm riêng `chargeCard` (`:210`) | web `paygate_rest.dart` (950 dòng, tự ghi "đã đối chiếu từng dòng") ↔ app `deposit_repository_impl` + withdraw | `paygate_domain` (hay mở rộng `transaction_domain`): model phiếu + `isSuccessFor(command, json)` + parse slip; HTTP giữ host. Lệch 1 luật = tiền user |
| C2 | **Luật đơn vị tiền khi đặt cược** — nghìn→VND, chọn `oddsStyle` gửi lên (de vs user style), làm tròn place-odds 2 số | web `betting_rest.dart` (484) ↔ app `sb_betting_service` + `betting_repository:93-110` | mở rộng `betting_domain` (`betting_rest_rules.dart`) — dùng chung 2 bên khi dựng body |
| C3 | **Cashout** — hỏi giá 2 lần, parse resell | web `cashout_rest.dart` (179) ↔ app 3 tầng | mở rộng `betting_domain` (luật) — endpoint giữ host |
| C4 | **SbUserIdentity parse** — legacy numeric `{"0":"username","1":"VND","2":"500.000","3":"Active"}` vs modern named; `cust_login`/`cust_id` (staging trả rỗng) | web `sb_user_rest.dart` (114) ↔ app `sb_user_service.dart:24-52` | mở rộng `auth_domain` (định danh vào body đặt cược — lệch là 607/632) |
| C5 | **Máy trạng thái phân trang 7 trạng thái** (`loading`/`refreshing`/`loadingMore`/… giữ-data-cũ) + khoá request | web `services/transaction/paginated_store.dart` (192, port `PaginatedNotifierMixin`+`PaginatedState`+`PaginatedStatus`+`RequestLock`) ↔ app `lib/core/pagination/` | Hoist state-machine thuần (không Riverpod) vào `dart_kit`/package mới; đồng thời web **đang tự viết lại lock** thay vì dùng `dart_kit.RequestLock` (Round 6 4.4) — nối lại |
| C6 | **`microtask_burst_coalescer`** — gộp burst stream broadcast thành 1 flush (pure Dart, 0 dep) | app dùng ở 3 provider (`event_live`, `odds_change`, `market_status`); web chưa có nhu cầu nhưng cùng họ `Debouncer`/`Semaphore` | đưa vào `dart_kit` (mở rộng Round 6 4.4) |
| C7 | **Favorites parse** — `{"sportId":{"0":[leagueIds],"1":[eventIds]}}`, chuỗi A++B | web `favorites_rest.dart` (188) ↔ app `favorite_provider:182-306` + `favorite_data.dart:16-44` | mở rộng `sport_events` (parse thuần) — nhỏ, không phải tiền |

---

## NHÓM D — KHÔNG NÊN ĐÓNG GÓI (giữ host — chốt lại, cập nhật từ các đợt trước)

| # | Thứ | Lý do |
|---|---|---|
| 1 | Pages/controllers mini game per-game (`pages/mini_game/**` 52 file, `services/mini_game/**` 34 file) ↔ `lib/mini/**` | Vỏ state/UI là host; LUẬT đã tách (`mini_game_protocol`, `mini_game_countdown_core`, `slot_prefs_rules`, sound registry) |
| 2 | `sentry_service.dart`, `web_log.dart`, `perf_hud.dart`, `js_heap*` (web-only monitoring) | Infra riêng web; phần chung (scrubber, LoginTiming) đã trong `monitoring_domain` |
| 3 | `orientation_lock`, `native_drag_block`, `pointer_coords`, `pull_to_refresh_block`, `iframe_inert`, `dom_input` | Quirk nền web riêng |
| 4 | `session_kick`, `sport_socket_bridge`, wiring subscribe/reconnect | Vòng đời phiên của host |
| 5 | Widget/UI/theme/scroll/responsive (`lib/shared/widgets`, `shared/responsive`, `shared/scroll`) | Host |
| 6 | Model freezed nặng (`UnifiedTransaction`, `NotificationItem`) | App freezed ↔ web model thuần — chờ chốt kiến trúc (thuộc nhóm B) |
| 7 | `mg_orientation` (web) vs `game_orientation` (Flutter-bound) | Cùng phép so `w>h`, khác nguồn đo |
| 8 | Game launcher state máy host (app StateNotifier/web CasinoLauncher) | Chỉ hoist taxonomy lỗi nếu làm A8 |

---

## THỨ TỰ LÀM ĐỀ XUẤT (checklist)

### Phase R7-0 — CỨU BUILD (không thêm package mới) 🔴 — ✅ ĐÃ XONG (đợt 1)
- [x] Làm đủ các mục Nhóm A liên quan build (A2–A11) theo thứ tự 1.3;
      chốt số phận `game_launcher` (A8)
- [x] Verify: `make gen` · `flutter analyze lib test` 0 error · `dart analyze` web 0 error
      · `make test-shared` 24/24 · `flutter build apk --debug` · `make build-jaspr`
- [x] Rút kinh nghiệm ghi vào quy ước: **delegate xong phải chạy analyze CẢ 2 bên
      + `make test-shared` trước khi commit** (Round 6 commit khi còn đỏ)

### Phase R7-1 — Nối nợ không chặn build (rẻ, xoá copy) — ✅ ĐÃ XONG (đợt 2)
- [x] A1 web `card_last_join_store` → `parseCardLastJoin` (+ test di trú sẵn
      trong `provider_game_manager/test/card_last_join_test.dart`)

### Phase R7-2 — Mở rộng tiền lệ có sẵn (không package mới) 🟡 — ✅ ĐÃ XONG (đợt 2)
- [x] C2 `betting_domain.betting_rest_rules.dart` (+14 test; wire app + web)
- [x] C3 cashout luật vào `betting_domain` — ✅ đã có từ Round 3 (CashoutQuote/Result), kiểm đếm lại
- [x] C4 `auth_domain.SbUserIdentity` (+7 test; wire app + web)
- [x] B12 web `match_summary_rest` gọi lại `MatchSummaryParser`
- [x] C5 `dart_kit`: `PaginatedMachine` (+12 test) + web `paginated_store` delegate; `RequestLock` nối qua máy luôn
- [x] C6 `dart_kit.MicrotaskBurstCoalescer` (+7 test; app 3 provider + re-export debouncer/semaphore/request_lock)
- [x] C7 `sport_events` favorites parse (+8 test; wire app + web)

### Phase R7-3 — Package mới (chỉ khi chốt model) ⚪ — HOÀN THÀNH TOÀN BỘ (đợt 3–5)
- [x] C1 `paygate_domain` (bảng luật thành-công theo lệnh + 1099 soft +
      `PaygateResult`) — TIỀN (+15 test; wire app deposit ×7 + withdraw ×3, web ×13)
- [x] B1: web `my_bets_rest` xoá parse tay + luật tiền, delegate
      `BetSlip.fromJson`/`BetSlipParser.parse` (+14 test di trú; sửa bug
      `cashOutAbleAmount` khoá '23' + tolerant ids trong package)
- [x] B5 search key-map → `sport_events` (+11 test; wire app + web, gồm cả luật popular)
- [x] B6 hot-stats → `betting_domain.HotStatsRules` (+7 test; wire web; app qua model — follow-up)
- [x] B10 outright parse → `betting_domain.parseOutrightCards` (+5 test; wire web, re-export model)
- [x] B11 transaction payload → `transaction_domain` (+9 test; wire web)
- [x] B3 balance — ✅ ĐỢT 5: `game_api_client.UserBalanceData` tolerant + web `balance_rest`
      delegate envelope/parse (parse thuần hoist xong; lifecycle startSync/polling vẫn host)
- [x] B8 notification — ✅ ĐỢT 5: package mới `notification_domain` (category +
      relative-time, +14 test; wire app + web). Model freezed vẫn giữ host (D6)
      — hoist luật thuần không cần chờ chốt model
- [ ] B9 avatar — HOÃN (đợt 5 đánh giá lại): view nhỏ; app đã có infra
      `SunApiResponse` (nested-status) — cross-wiring không đáng

### Phase R7-4 — Nợ phát sinh (14/09) 🔴 — ✅ ĐÃ XONG (đợt 5)
- [x] A12 `sport_notice` viết lại mirror bản gốc: MAX-MERGE + warming 2 đường +
      slow-path diff + gap-clock/onSuspend + `baselineOnUnknown` (web) — 8 test
      app đỏ → 15/15 xanh; notice web hết "chết hẳn" (không bao giờ có baseline)
- [x] Nợ test tiền: `money_flow_success_test` "thẻ cào 1099" — sửa test setup
      (user vào stream sau khi lazy notifier được tạo), 5/5 pass
- [x] 3 test `store_backed_*` (events_v2) — ✅ ĐỢT 6: fixture thiếu `isLive: true`
      (gate `liveOnlyLeagues` 4fb1b0df8 lọc sạch) — sửa fixture

### Phase R7-5 — FULL TEST SUITE (14/09) 🔴 — ✅ 32 đỏ → 0 (đợt 6)
- [x] Quét `flutter test` FULL SUITE lần đầu — 32 đỏ pre-existing (A/B worktree
      xác nhận, phần lớn cổ từ trước Round 6) → xử lý 29, skip có lý do 3 file:
- [x] **Prod fix**: `SbHttpManager.reset()` khôi phục default (getter crash sau
      reconnect) + `getSbToken` guard dead-code (kiểm `sport_domain` trực tiếp) +
      `EventDetailResponseV2` derive period mirror store (parity luồng tiền kèo rung)
- [x] Test-infra: keep-alive listener bet_detail ×13; fixture live ×3; delta
      market_odds refresh ×3; responsive/home byType+breakpoint thật; mock
      path_provider Hive
- [x] Skip có lý do: widget template (boot app thật) + auth live-integration ×5
- [ ] (không còn nợ đỏ — full suite +1275 ~7 skip · 0 fail)

**Verify mỗi phase** (quy ước các đợt trước):
1. `dart test packages/<pkg>/` — test di trú về `packages/<pkg>/test/`
2. `make test-shared` (phải 24/24)
3. `flutter analyze lib test` + `dart analyze` (jaspr_web) — 0 error cả hai
4. Test nhóm liên quan app (`test/…`) + test web
5. `flutter build apk --debug` + `make build-jaspr` — build xanh CẢ HAI trước khi commit

---

## KẾT LUẬN

- 🟢 **Trạng thái (cập nhật đợt 6, 14/09): XANH TOÀN DIỆN** — build CẢ HAI dự
  án SUCCESS, **full test suite +1275 ~7 skip · 0 fail** (trước đợt quét: 32 đỏ
  pre-existing), package dùng chung xanh 26/26 (~1.052 test).
- Sau 6 đợt, phần logic dùng chung còn lại THỰC SỰ chỉ còn: **B9 avatar (hoãn
  có lý do)** + các mục nhóm D (không đóng gói). Nhóm B (tầng parse REST 15
  file/5323 dòng web) đã hoist hết phần parse+luật thuần đáng hoist; lifecycle
  (startSync, polling, cache, retry) đúng quy ước giữ host.
- 7 skip đều có lý do ghi rõ: 5 live-integration auth (cần mạng thật + token,
  chạy thủ công khi cần), widget template (đợi harness boot-app), 1 skip sẵn
  của sport_socket.
- Danh mục "không đóng gói" giữ nguyên logic cũ, chỉ cập nhật.

> Báo cáo này CHỈ PHÂN TÍCH. Chưa sửa file code, chưa thêm dep, chưa chạy
> generator — mọi con số đo từ các lệnh đọc-đơn-thuần (`analyze`, `build`, `test`).

---

## PHỤ LỤC — SỐ LIỆU ĐO

| Chỉ số | Giá trị |
|---|---|
| File Dart app `lib/` | 1536 |
| File Dart web `jaspr_web/lib/` | 432 |
| Package nội bộ `packages/` | 33 (33 analyze 0 error — thêm `notification_domain` đợt 5) |
| Test package chung pass | ~1.052 / 26 package (đợt 5; khởi điểm ~948/23) |
| App error unique | 0 (đợt 5 — khởi điểm ~96) |
| Web error unique | 0 (đợt 5 — khởi điểm 29) |
| Test notice app | 15/15 (đợt 5 — trước đó 8 đỏ vì `sport_notice` port sai 4 lớp guard) |
| `services/rest/` web | 15 file / ~5.000 dòng (đợt 4-5 xoá thêm ~300 dòng parse tay: my_bets, balance, notification…) |
| Commit gây lỗi Round 6 | `f8b9cf37` 13/09 17:08 · `c36e8318` 13/09 17:42 |
| Commit chứa đợt 2–4 (user commit 14/09 10:55) | `f2c538c3c` |