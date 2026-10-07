# Portal Native Bridge — jaspr_web chạy trong InAppWebView của app Flutter

> Doc thiết kế cho luồng: **app Flutter mở `jaspr_web` (portal) trong `flutter_inappwebview`
> → người chơi bấm game → portal detect mình đang chạy trong app → bắn event để Flutter
> ẩn webview và mở game bằng Cocos native**. Trên web mobile/desktop (browser thật)
> portal tự mở webview thứ 2 (iframe fullscreen / modal) như bình thường.

Phạm vi: **native app Android/iOS**. Flutter-web build không nằm trong luồng này
(trên web thì portal chính là website jaspr_web, không cần app).

Tài liệu liên quan:

- `lib/features/game/docs/README-flutter.md` — HostBridge SDK (`{type, data, source}` protocol)
- `packages/game_launcher/` — MethodChannel `launchGame` xuống native host (CocosFlutterActivity / AppDelegate)
- `packages/game_engine/lib/src/ih_runner/scripts/ih_runner_scripts.dart` — mẫu inject bridge `window.GameHost` sẵn có
- `jaspr_web/lib/services/web_device.dart` — detect mobile/desktop (AppDevice)

---

## 1. Kiến trúc tổng thể

```
┌─────────────────────────── App Flutter (native) ────────────────────────────┐
│                                                                             │
│  FlutterView: PortalHostPage (Stack)                                        │
│  ┌───────────────────────────────────────────────────────────────────────┐ │
│  │ InAppWebView ──► https://portal.s88.com/?client=native  (jaspr_web)    │ │
│  │   • initialUserScripts  → window.__S88_NATIVE__  (AT_DOCUMENT_START)   │ │
│  │   • initialSettings.userAgent  → "… S88NativeApp/1.0 (android)"       │ │
│  │   • addJavaScriptHandler('portalBridge', …)                            │ │
│  └───────────────────────────────────────────────────────────────────────┘ │
│         ▲ callHandler('portalBridge', {type: OPEN_GAME, …})                  │
│         ▼                                                                    │
│  PortalHostController:                                                       │
│    1) ẩn webview (Offstage — portal vẫn sống, không load lại)                │
│    2) game_downloader (nếu game chưa có local)                              │
│    3) GameLauncher.launch(GameLaunchConfig)                                  │
│       → MethodChannel <bundleId>/launcher → native show Cocos view           │
│    4) game EXIT → native trở về → show webview lại + push event xuống jaspr  │
└─────────────────────────────────────────────────────────────────────────────┘

Web (browser thật — không có signal nào):
  isRunningInFlutterApp == false
  → bấm game → render game trong "webview thứ 2" của chính SPA jaspr
    (iframe fullscreen / modal), hoặc route mới.
```

Điểm mấu chốt: **jaspr_web không thể tự biết** nó đang chạy trong app — Flutter phải
"gắn dấu" vào môi trường webview **trước khi JS của portal chạy**, và portal đọc dấu đó.

---

## 2. Multi-signal detection — `isRunningInFlutterApp`

Dùng **4 tín hiệu**, ưu tiên từ trên xuống. Đa tín hiệu để không break khi đổi
plugin/version webview và chống false-negative:

| # | Tín hiệu | Gắn phía Flutter | Độ tin cậy | Ghi chú |
|---|----------|-------------------|-----------|---------|
| 1 | `window.__S88_NATIVE__` (UserScript inject `AT_DOCUMENT_START`) | `initialUserScripts` | ⭐⭐⭐ cao nhất | Có sẵn **trước khi** JS portal chạy → đọc được ngay lần render đầu |
| 2 | `window.flutter_inappwebview` (plugin tự inject) | tự động của plugin | ⭐⭐⭐ | Chỉ tồn tại trong InAppWebView native |
| 3 | User-Agent chứa `S88NativeApp/<ver>` | `initialSettings.userAgent` | ⭐⭐ | Đọc được cả khi JS inject fail; có thể bị client đổi |
| 4 | URL param `?client=native` | URL load | ⭐ | Tín hiệu yếu (copy được URL), chỉ dùng dự phòng |

> ⚠️ Không dùng tín hiệu nào làm cơ sở cho thao tác nhạy cảm (nạp/rút tiền, session).
> Với luồng nhạy cảm, `portalBridge` handler phải trả về **session thật** từ Flutter
> (xem §3.4) — browser thật gọi được handler cũng không có data.

Vì sao `AT_DOCUMENT_START` quan trọng: `webview_flutter` chỉ `runJavaScript` **sau**
khi trang load xong → portal render lần đầu đọc `false`. `flutter_inappwebview`
map sang WKUserScript (iOS) / tài khoản Android inject trước document → flag tồn tại
trước mọi script của trang, **không cần handshake async** cho lần detect đầu.

---

## 3. Phía Flutter (app host)

### 3.1. Hằng số + script inject

```dart
// lib/features/portal/portal_bridge_constants.dart
import 'package:flutter/foundation.dart';

/// Hằng số dùng chung 2 đầu của bridge portal ↔ app.
/// Phía jaspr_web phải giữ đúng các tên này (xem §4).
abstract final class PortalBridge {
  /// JS object inject AT_DOCUMENT_START — signal #1.
  static const String nativeFlagObject = '__S88_NATIVE__';

  /// Tên JavaScript handler đăng ký qua `addJavaScriptHandler` — signal #2.
  static const String handlerName = 'portalBridge';

  /// Token nhúng vào User-Agent — signal #3.
  static const String userAgentToken = 'S88NativeApp';

  /// Query param appended vào URL portal — signal #4.
  static const String urlClientParam = 'native';

  /// Script gắn flag native. Idempotent: inject lại không side-effect
  /// (cùng pattern guard như IHRunnerScripts trong game_engine).
  static String nativeFlagScript({required String appVersion}) => '''
    (function() {
      if (window.__S88_NATIVE__) return;
      window.__S88_NATIVE__ = {
        platform: '$platformName',
        appVersion: '$appVersion',
        bridge: '$handlerName',
      };
    })();
  ''';

  static String get platformName =>
      defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';
}
```

### 3.2. Widget `PortalHostPage` — nhúng portal + gắn 4 tín hiệu

```dart
// lib/features/portal/portal_host_page.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart;

import 'portal_bridge_constants.dart';
import 'portal_host_controller.dart';

class PortalHostPage extends StatefulWidget {
  const PortalHostPage({
    super.key,
    required this.portalUrl,
    required this.controller,
    this.appVersion = '1.0.0',
  });

  /// URL jaspr_web đã deploy (app_env / brand_config suy ra).
  final String portalUrl;
  final PortalHostController controller;
  final String appVersion;

  @override
  State<PortalHostPage> createState() => _PortalHostPageState();
}

class _PortalHostPageState extends State<PortalHostPage> {
  /// Giữ portal webview sống khi bị Offstage che đi — không load lại trang,
  /// không mất state (đăng nhập, tab đang mở) khi vào game rồi thoát ra.
  final _keepAlive = InAppWebViewKeepAlive();
  InAppWebViewController? _webController;

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Controller quyết định portal có hiện không (đang chơi Cocos thì ẩn).
    // Code hiển thị đầy đủ ở §3.5 (Stack + Offstage theo portalVisible).
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (_, __) => Stack(
        children: [
          Offstage(offstage: !widget.controller.portalVisible, child: _buildWebView()),
        ],
      ),
    );
  }

  InAppWebView _buildWebView() {
    final portalUri = Uri.parse(widget.portalUrl).replace(
      queryParameters: {
        ...Uri.parse(widget.portalUrl).queryParameters,
        // Signal #4 — dự phòng, phải explicit để không ghi đè param khác.
        'client': PortalBridge.urlClientParam,
      },
    );

    return InAppWebView(
      keepAlive: _keepAlive,
      initialUrlRequest: URLRequest(url: WebUri(portalUri.toString())),
      // Signal #1 — chạy TRƯỚC mọi script của trang.
      initialUserScripts: UnmodifiableListView([
        UserScript(
          source: PortalBridge.nativeFlagScript(appVersion: widget.appVersion),
          injectionTime: UserScriptInjectionTime.atDocumentStart,
          // Chỉ main frame: iframe game (nếu có) không được tự nhận là "native app".
          forMainFrameOnly: true,
        ),
      ]),
      initialSettings: InAppWebViewSettings(
        // Signal #3 — append token, không thay UA gốc (một số web chặn UA lạ).
        // UA gốc lấy async qua InAppWebViewController.getDefaultUserAgent()
        // rồi build settings ở initState — xem §3.5 lưu ý timing.
        userAgent: widget.controller.configuredUserAgent,
        javaScriptEnabled: true,
        mediaPlaybackRequiresUserGesture: false,
        transparentBackground: true,
        supportZoom: false,
        disableContextMenu: true,
      ),
      onWebViewCreated: (controller) {
        _webController = controller;
        // Signal #2 — handler 2 chiều (xem §3.3).
        controller.addJavaScriptHandler(
          handlerName: PortalBridge.handlerName,
          callback: widget.controller.onPortalMessage,
        );
        widget.controller.attach(controller);
      },
      onLoadStop: (_, __) {
        // Portals SPA có thể re-render trước khi handler sẵn sàng ở lần
        // đầu cài app — gửi thêm 1 cú "báo mình là native" cho chắc.
        widget.controller.notifyNativeReady();
      },
      onConsoleMessage: (_, message) {
        debugPrint('[portal] ${message.message}');
      },
    );
  }
}
```

> `build()` ở trên chỉ minh hoạ cấu trúc — bản thật dùng `AnimatedSwitcher`/`Stack`
> + `Offstage` theo `ValueListenable<bool> portalVisible` của controller (§3.3),
> phần code hiển thị nằm ở §3.5 để tránh trùng lặp.

### 3.3. `PortalHostController` — nhận event, mở Cocos, ẩn/hiện webview

Protocol message **trùng convention HostBridge** hiện có (`README-flutter.md`):
`{ "type": UPPER_SNAKE, "data": {}, "source": "jaspr-portal" }`.

Các event portal → app:

| `type` | `data` | Xử lý |
|---|---|---|
| `OPEN_GAME` | `gameId`, `gameCode`, `isLandscape`, tuỳ chọn `metadata` | ẩn webview → download (nếu cần) → `GameLauncher.launch` |
| `OPEN_URL` | `url`, `external?` | link ngoài: mở browser / load trong webview |
| `PORTAL_READY` | — | jaspr đã boot xong — dùng để push `NATIVE_READY` xuống |
| `LOG` | `level`, `message` | đẩy log portal về app (đi kèm Sentry) |

Event app → portal (qua `evaluateJavascript` gọi `window.onNativeMessage`):

| `type` | `data` | Ý nghĩa |
|---|---|---|
| `NATIVE_READY` | `platform`, `appVersion` | xác nhận signal #2 đã sẵn sàng (async) |
| `GAME_CLOSED` | `gameId`, `reason` | app đã đóng Cocos, portal hiện lại |
| `SESSION` | token/user… | đáp ứng `GET_SESSION` (xem dưới) |

```dart
// lib/features/portal/portal_host_controller.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../game/launcher/game_launcher.dart'; // facade app của game_launcher package
import 'portal_bridge_constants.dart';

class PortalHostController extends ChangeNotifier {
  PortalHostController({this.appVersion = '1.0.0'});

  final String appVersion;
  InAppWebViewController? _web;
  String configuredUserAgent = '';

  /// `false` khi đang chơi Cocos (webview bị Offstage).
  bool portalVisible = true;
  bool get isGameRunning => !portalVisible;

  /// Nhận mọi message từ jaspr (đã JSON string hoá theo protocol HostBridge).
  Object? onPortalMessage(List<dynamic> args) {
    final raw = args.isEmpty ? null : args.first;
    if (raw is! String) return null;
    final Map<String, dynamic> msg;
    try {
      msg = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
    switch (msg['type'] as String?) {
      case 'OPEN_GAME':
        _openGame(Map<String, dynamic>.from(msg['data'] as Map));
      case 'OPEN_URL':
        _openUrl(Map<String, dynamic>.from(msg['data'] as Map));
      case 'PORTAL_READY':
        notifyNativeReady();
      case 'GET_SESSION':
        // flutter_inappwebview: giá trị return của callback được resolve
        // về Promise phía JS — portal await được session thật.
        return jsonEncode({
          'type': 'SESSION',
          'data': _currentSession(), // đọc từ auth service của app
          'source': 'flutter-host',
        });
      case 'LOG':
        debugPrint('[portal-log] ${msg['data']}');
    }
    return null;
  }

  // … tiếp tục ở §3.3b
}
```

§3.3b — phần còn lại của `PortalHostController`:

```dart
  Future<void> _openGame(Map<String, dynamic> data) async {
    if (isGameRunning) return; // chống double-tap
    portalVisible = false;
    notifyListeners();

    // 1) Ngừng media của portal (livestream/âm thanh nền nếu có).
    await _web?.evaluateJavascript(
      source: "document.querySelectorAll('video,audio')"
          ".forEach(el => { el.pause(); });",
    );

    // 2) Luồng launch Cocos sẵn có của app (game_downloader + game_launcher):
    //    giải nén zip nếu chưa có local, build GameLaunchConfig
    //    (gamePath/gameId/xxtea/credentials) rồi MethodChannel
    //    `<bundleId>/launcher` → native host show Cocos view.
    final result = await openCocosGame(
      gameCode: data['gameCode'] as String,
      isLandscape: data['isLandscape'] as bool? ?? true,
    );

    if (result is GameLaunchFailure) {
      portalVisible = true;
      notifyListeners();
      sendToPortal('GAME_CLOSED', {
        'gameId': data['gameId'],
        'reason': 'LAUNCH_FAILED:${result.code}',
      });
    }
  }

  Future<void> _openUrl(Map<String, dynamic> data) async {
    if (data['external'] == true) {
      // url_launcher mở ngoài (khuyến mãi, tải app, …)
    } else {
      await _web?.loadUrl(
        urlRequest: URLRequest(url: WebUri(data['url'] as String)),
      );
    }
  }

  /// Gửi event app → portal. Jaspr đăng ký nhận qua `window.onNativeMessage`
  /// (cùng cơ chế `onHostMessage` trong host_bridge.js của README-flutter.md).
  Future<void> sendToPortal(String type, Map<String, dynamic> data) async {
    final message = jsonEncode({
      'type': type,
      'data': data,
      'source': 'flutter-host',
    });
    await _web?.evaluateJavascript(
      source: "window.onNativeMessage && window.onNativeMessage($message);",
    );
  }

  /// Native trở về sau khi Cocos exit → hiện webview + báo portal.
  void onGameClosed({String? gameId, String reason = 'USER_EXIT'}) {
    portalVisible = true;
    notifyListeners();
    sendToPortal('GAME_CLOSED', {'gameId': gameId, 'reason': reason});
  }

  Future<void> notifyNativeReady() =>
      sendToPortal('NATIVE_READY', {'appVersion': appVersion});

  void attach(InAppWebViewController web) => _web = web;

  /// UA gốc (async) — gọi 1 lần lúc boot, xong mới build PortalHostPage,
  /// để `initialSettings.userAgent` có sẵn ngay từ lúc tạo webview.
  Future<void> initUserAgent() async {
    final defaultUA =
        await InAppWebViewController.getDefaultUserAgent() ?? '';
    configuredUserAgent =
        '$defaultUA ${PortalBridge.userAgentToken}/$appVersion';
  }

  Map<String, dynamic> _currentSession() => {/* từ auth service của app */};
}
```

### 3.4. Nhận exit từ Cocos native

Native host hiện có (`CocosFlutterActivity` / `AppDelegate`) đã có luồng exit
game → Flutter (`cocos_game_controller.dart`). Ghim thêm 1 hook: khi nhận exit,
gọi `controller.onGameClosed(gameId: …)` — webview hiện lại **nguyên trạng**
(vì `InAppWebViewKeepAlive` giữ webview sống, chỉ bị `Offstage` che).

### 3.5. Lưu ý wiring

- **`initUserAgent()` phải chạy trước khi build `PortalHostPage`** (UA là
  `initialSettings` — không đổi được sau khi tạo webview nếu không reload).
- **`Offstage` + platform view**: nếu trên thiết bị test thấy webview bị vẽ lại
  khi hiện lại (hiếm, Android hybrid composition), đổi sang che bằng widget
  opaque đặt trên Stack thay vì Offstage, hoặc `Visibility(visible: …,
  maintainState: true, maintainSize: true)`.
- **Back button / gesture**: bọc `PopScope` — khi `isGameRunning` chặn pop của
  portal (đang ẩn), forward về native để exit game.

---

## 4. Phía jaspr_web (portal)

### 4.1. `native_host_bridge.dart` — detect + gọi app

Đặt tại `jaspr_web/lib/services/native_host_bridge.dart`. jaspr_web chạy
client-side (`main.client.dart`) nên dùng được `dart:html` / `dart:js`.
Các hằng số phải **khớp §3.1** (`__S88_NATIVE__`, `portalBridge`, `S88NativeApp`, `native`).

```dart
// jaspr_web/lib/services/native_host_bridge.dart
import 'dart:convert';
import 'dart:html' as html;
import 'dart:js' as js;

/// Cờ native của plugin flutter_inappwebview (tự inject, chỉ có trên native).
final _inappBridge = js.context['flutter_inappwebview'];

/// True nếu portal đang chạy trong InAppWebView của app Flutter.
///
/// Multi-signal (xem §2): đọc đồng bộ được ngay lần render đầu vì UserScript
/// inject AT_DOCUMENT_START chạy trước mọi script của trang — không cần
/// handshake để render đúng nhánh UI.
bool get isRunningInFlutterApp =>
    // #1 JS object inject tại document-start (mạnh nhất)
    js.context['__S88_NATIVE__'] != null ||
    // #2 plugin object (chỉ tồn tại trong InAppWebView native)
    _inappBridge != null ||
    // #3 UA token
    html.window.navigator.userAgent.contains('S88NativeApp') ||
    // #4 URL param (yếu, dự phòng)
    Uri.base.queryParameters['client'] == 'native';

/// Metadata native (null nếu chạy browser). Dùng để hiện badge "đang chạy app",
/// version-debug, tuỳ chọn UI theo platform.
Map<String, dynamic>? get nativeInfo {
  final raw = js.context['__S88_NATIVE__'];
  if (raw is js.JsObject) {
    return {
      'platform': raw['platform'] as String?,
      'appVersion': raw['appVersion'] as String?,
    };
  }
  return null;
}

/// Gửi event lên app: `flutter_inappwebview.callHandler('portalBridge', msg)`.
Future<Object?> _callHandler(String message) async {
  final bridge = js.context['flutter_inappwebview'];
  if (bridge == null) return null;
  return bridge.callMethod('callHandler', ['portalBridge', message]);
}

/// API chính dùng ở nơi click game.
Future<void> sendToApp(String type, Map<String, dynamic> data) =>
    _callHandler(jsonEncode({
      'type': type,
      'data': data,
      'source': 'jaspr-portal',
    }));

/// Xin session từ app (GET_SESSION handler trả Promise → await được).
Future<Map<String, dynamic>?> requestSession() async {
  final raw = await _callHandler(jsonEncode({
    'type': 'GET_SESSION',
    'data': {},
    'source': 'jaspr-portal',
  }));
  if (raw is String) {
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded['data'] as Map<String, dynamic>?;
  }
  return null;
}

/// Đăng ký nhận event từ app (NATIVE_READY / GAME_CLOSED / …).
void onAppMessage(void Function(Map<String, dynamic>) handler) {
  js.context['onNativeMessage'] = (dynamic msg) {
    final decoded = (msg is String) ? jsonDecode(msg) : msg;
    handler(decoded as Map<String, dynamic>);
  };
}
```

### 4.2. Dùng ở nơi bấm game

```dart
Future<void> onGameCardTap(GameItem game) async {
  if (isRunningInFlutterApp) {
    // App Flutter: ẩn portal, mở Cocos native.
    await sendToApp('OPEN_GAME', {
      'gameId': game.id,
      'gameCode': game.code,
      'isLandscape': game.isLandscape,
    });
    return;
  }
  // Browser thật: mở "webview thứ 2" — iframe fullscreen / modal trong SPA,
  // hoặc provider live game thì đi luồn PL runner của jaspr_web như hiện tại.
  openWebGameOverlay(game.launchUrl);
}
```

Khởi động: trong `main.client.dart` (sau `AppDevice.configure`) gọi
`sendToApp('PORTAL_READY', {})` và `onAppMessage(...)` để nhận `NATIVE_READY`
/ `GAME_CLOSED` (refresh số dư, trạng thái nút khi quay lại từ game).

Lưu ý SSR: các getter trên chạm `window` — chỉ gọi ở client component /
sau boot, không gọi trong render server.

---

## 5. Sequence đầy đủ một vòng chơi game

```
Người chơi          jaspr_web (InAppWebView)         Flutter app              Native Cocos
   │ tap game card        │                              │                        │
   │──────────────────►   │ isRunningInFlutterApp == true │                        │
   │                      │ callHandler('portalBridge',  │                        │
   │                      │   {OPEN_GAME, gameCode…}) ──► │                        │
   │                      │   (UI khoá nút, chờ)          │ Offstage webview       │
   │                      │                              │ pauseAllMedia           │
   │                      │                              │ game_downloader (nếu cần)│
   │                      │                              │ GameLauncher.launch ───►│ show Cocos
   │                      │                              │                        │ … chơi …
   │                      │                              │   exit event ◄─────────│ EXIT_GAME
   │                      │  GAME_CLOSED ◄─────────────  │ onGameClosed()         │
   │ ◄─────────────────   │ (unmute, refresh balance,    │ portalVisible = true   │
   │   thấy portal lại    │  enable nút)                 │                        │
```

---

## 6. Pitfalls đã gặp / dễ gặp trong repo này

1. **Timing inject** — luôn inject ở `AT_DOCUMENT_START` (map sang WKUserScript).
   Inject sau load (`onLoadStop`) sẽ khiến lần render đầu của jaspr đọc `false`.
2. **`forMainFrameOnly: true`** — portal mở game trong iframe thì iframe KHÔNG
   được nhận `__S88_NATIVE__`, nếu không game web trong iframe sẽ tưởng mình
   chạy native và gọi nhầm bridge.
3. **Double-tap / re-entry** — khoá bằng `if (isGameRunning) return;` ở
   controller; phía jaspr disable nút ngay khi gửi `OPEN_GAME`.
4. **Webview bị phá khi ẩn** — dùng `InAppWebViewKeepAlive`; nếu vẫn bị Android
   hybrid composition vẽ lại, che bằng widget opaque thay vì Offstage.
5. **Media portal vẫn phát khi vào game** — chủ động pause mọi `video/audio`
   trước khi launch (cocos có nhạc riêng).
6. **Session/cookie** — webview có cookie store riêng: đăng nhập phải xảy ra
   TRONG portal webview, hoặc app đẩy session qua `GET_SESSION` handler.
   Đừng nhét token vào URL (rò rỉ qua log/history).
7. **iOS WKWebView** — cần `contentBlockers` rỗng, kiểm tra ATS nếu portal
   là http nội bộ khi dev; camera/mic của game live cần thêm
   `onPermissionRequest`.
8. **Android surface** — đã có `CaxiloSurfaceCompositorPlugin`
   (`syncRenderSurface`) cho game IH runner: nếu webview portal và native view
   đánh nhau z-order trên Android, gọi sync surface sau khi show lại portal.
9. **Debug** — Android: `chrome://inspect` inspect được webview portal;
   iOS: Safari → Develop. Đặt `PlatformInAppWebViewController.setDebugLoggingEnabled(true)`
   khi dev. Log 2 đầu qua event `LOG` để Sentry thấy lỗi phía portal.

---

## 7. Checklist nghiệm thu base

- [ ] Portal load trong app, `__S88_NATIVE__` đọc được ngay lần render đầu
      (verify bằng devtools console của webview).
- [ ] Bấm game: webview ẩn, Cocos mở, nhạc portal dừng.
- [ ] Exit game: portal hiện lại **không reload trang**, giữ nguyên tab/login.
- [ ] `GAME_CLOSED` về tới jaspr (nút enable lại, số dư refresh).
- [ ] Browser thật (Chrome mobile + desktop): `isRunningInFlutterApp == false`,
      mở web overlay đúng nhánh.
- [ ] Back button khi đang chơi: không pop portal, forward exit cho native.
- [ ] Double-tap card: không mở 2 game.
- [ ] Test cả Android thật + iOS thật (WKUserScript khác Chrome behaviour).

---

## 8. Ước lượng thời gian dựng base

Giả định: **1 dev rành codebase này**, tận dụng hạ tầng sẵn có
(`game_engine`, `game_launcher`, `game_downloader`, protocol HostBridge,
jaspr_web đã deploy). "Base" = luồng end-to-end: mở app → portal → bấm game
→ Cocos → exit → về portal, trên cả Android + iOS, chưa tính UX polish.

| # | Hạng mục | Ước lượng |
|---|----------|-----------|
| B1 | `PortalHostPage` + settings + keep-alive + lifecycle (§3.2) | 0.5–1 ngày |
| B2 | Inject 4 tín hiệu + verify `isRunningInFlutterApp` trên máy thật | 0.5 ngày |
| B3 | `PortalHostController`: handler 2 chiều, `GET_SESSION`, `GAME_CLOSED` (§3.3) | 1 ngày |
| B4 | jaspr_web: `native_host_bridge.dart` + wire vào chỗ click game + nhánh web fallback (§4) | 1–1.5 ngày |
| B5 | Ẩn/hiện webview + nối `openCocosGame` (downloader + launcher) + media pause + PopScope | 1–2 ngày |
| B6 | Luồng exit Cocos → show portal lại + event về jaspr (§3.4) | 0.5–1 ngày |
| B7 | Test chéo Android/iOS thật, sửa bug timing/Offstage/surface | 1–2 ngày |
| | **Tổng base end-to-end** | **≈ 5.5–9 dev-ngày** |

Quy đổi: một dev riêng → **1.5–2 tuần** cho base chạy demo được; **+1 tuần** nữa
cho base "chấp nhận ship" (log/Sentry 2 đầu, chống double-tap, xử lý lỗi
`LAUNCH_FAILED` có UI, session qua `GET_SESSION` ổn định).

Các biến số làm đội thời gian (cộng dồn):

| Biến số | Impact |
|---|---|
| Native host Cocos (`launchGame` channel) còn bug/không ổn định | +2–4 ngày |
| Cần chia sẻ login giữa app và portal (không login lại trong webview) | +1–2 ngày |
| Dev lần đầu với codebase (chưa rành game_engine/game_launcher) | ×1.5–2 |
| Portal cần hoạt động cả khi offline/đứng đầu (splash, retry) | +1–2 ngày |
| Cần 2 dev (1 Flutter, 1 Jaspr) song song thì rút còn ≈ 3–4 ngày calendar |

Lý do rẻ hơn "viết từ 0": ~60–70% hạ tầng đã có trong repo — phần thực sự
mới chỉ là **portal webview host + 4 tín hiệu + `native_host_bridge` của
jaspr** (≈ B1–B4, tổng 3–4 ngày).

Thứ tự đề xuất làm: B2 → B4 (proof-of-concept detect + event chạy được
trước tiên, rủi ro kỹ thuật lớn nhất nằm ở đây) → B1/B3 → B5/B6 → B7.





