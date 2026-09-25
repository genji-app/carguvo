<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" style="height:64px;margin-right:32px"/>

# Giúp tôi tách

Dưới đây là **2 bản tài liệu tách riêng**: một cho team **Game (Cocos)**, một cho team **Flutter**. Bạn có thể lưu thành `README-game.md` và `README-flutter.md`.

***

## 1. README cho team Game (Cocos)

```markdown
# HostBridge SDK – Hướng dẫn cho team Game (Cocos)

Tài liệu này mô tả cách game Cocos giao tiếp với Host (ứng dụng Flutter / web) thông qua **HostBridge**.

Mục tiêu:

- Game chỉ cần biết **2 API**:
  - `HostBridge.sendToHost(eventName, payload)`
  - `HostBridge.onHostMessage(handler)`
- Không phụ thuộc cụ thể host là Flutter, web thuần hay framework khác.

---

## 1. Protocol – JSON event

Mọi event giữa game ↔ host đều dùng chung format:

```json
{
  "type": "EXIT_GAME",
  "data": { "gameId": "baccarat_1" },
  "source": "cocos-game"
}
```

- `type`: tên event (string, UPPER_SNAKE_CASE).
- `data`: object payload (luôn là object).
- `source`: ai gửi:
    - `"cocos-game"`: từ game.
    - `"flutter-host"`: từ app host.

---

## 2. Mini SDK – file `host_bridge.js`

Team game cần thêm file sau vào project (hoặc template build):

```js
// host_bridge.js
(function () {
  function sendToHost(eventName, payload) {
    var message = JSON.stringify({
      type: eventName,
      data: payload || {},
      source: 'cocos-game',
    });

    // 1) Flutter Web (game chạy trong iframe)
    if (window.parent && window.parent !== window) {
      window.parent.postMessage(message, '*'); // TODO: thay '*' bằng origin cụ thể nếu cần
    }

    // 2) Flutter Mobile (WebView / InAppWebView)
    if (window.flutterNotifyHost) {
      window.flutterNotifyHost(message);
    }

    // 3) Backward-compatible: host expose FlutterChannel (webview_flutter cũ)
    if (typeof FlutterChannel !== 'undefined' && FlutterChannel.postMessage) {
      // Nếu event là EXIT_GAME, giữ hành vi cũ: gửi 'backToApp'
      if (eventName === 'EXIT_GAME') {
        FlutterChannel.postMessage('backToApp');
      } else {
        FlutterChannel.postMessage(message);
      }
    }
  }

  function onHostMessage(handler) {
    window.onHostMessage = function (msg) {
      try {
        var data = typeof msg === 'string' ? JSON.parse(msg) : msg;
        handler && handler(data);
      } catch (e) {
        console.error('onHostMessage parse error', e);
      }
    };
  }

  // Expose API ra global
  window.HostBridge = {
    sendToHost: sendToHost,
    onHostMessage: onHostMessage,
  };
})();
```


### Cách include

- Nếu có `index.html` template:

```html
<script src="host_bridge.js"></script>
```

- Nếu dùng bundler/module: import `host_bridge.js` vào entry script.

---

## 3. Cách dùng trong game

### 3.1. Thoát game (EXIT_GAME)

Dùng khi người chơi bấm nút “Thoát / Back to App” trong UI:

```js
function onExitGameButtonClicked() {
  HostBridge.sendToHost('EXIT_GAME', {
    gameId: 'baccarat_1'
  });
}
```

Host sẽ đóng container game (WebView/iframe) và quay về app.

### 3.2. Kết thúc ván (ROUND_END)

```js
function onRoundEnd(result, winAmount) {
  HostBridge.sendToHost('ROUND_END', {
    result: result,      // "PLAYER" / "BANKER" / "TIE"
    winAmount: winAmount // số tiền thắng
  });
}
```


### 3.3. Đặt cược (BET_PLACED)

```js
function onBetPlaced(amount, gameCode) {
  HostBridge.sendToHost('BET_PLACED', {
    amount: amount,
    gameCode: gameCode
  });
}
```


### 3.4. Nhận event từ host (tuỳ chọn)

Nếu cần host gửi ngược thông tin (ví dụ balance, lệnh close):

```js
function setupHostListener() {
  HostBridge.onHostMessage(function (msg) {
    if (msg.type === 'SET_BALANCE') {
      updateBalanceInGame(msg.data.balance);
    }

    if (msg.type === 'FORCE_EXIT') {
      forceExitGame();
    }
  });
}
```


---

## 4. Backward compatibility với code cũ

Một số game cũ có thể đang dùng:

```js
if (typeof FlutterChannel !== 'undefined' && FlutterChannel.postMessage) {
  FlutterChannel.postMessage('backToApp');
}
```

Mini SDK đã xử lý `EXIT_GAME` → `'backToApp'` khi `FlutterChannel` tồn tại, nên:

- Game mới nên dùng **duy nhất**:
`HostBridge.sendToHost('EXIT_GAME', {...})`.
- Host sẽ hiểu đúng cả game cũ lẫn mới.

---
```

***

## 2. README cho team Flutter

```markdown
# Game Host Bridge – Hướng dẫn cho team Flutter (App + Web)

Tài liệu này mô tả cách ứng dụng Flutter giao tiếp với game Cocos (build web) thông qua WebView (mobile) và iframe (web).

Game dùng mini SDK `HostBridge` (JS) như trong tài liệu riêng cho team game.

---

## 1. Protocol – GameHostEvent

Mọi message game ↔ host đều quy về `GameHostEvent`:

```dart
import 'dart:convert';

class GameHostEvent {
  final String type;
  final Map<String, dynamic> data;
  final String? source;
  final String? raw;

  GameHostEvent({
    required this.type,
    required this.data,
    this.source,
    this.raw,
  });

  factory GameHostEvent.fromJson(dynamic input) {
    if (input is String) {
      try {
        final map = jsonDecode(input) as Map<String, dynamic>;
        return GameHostEvent(
          type: map['type'] as String? ?? '',
          data: (map['data'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{},
          source: map['source'] as String?,
          raw: input,
        );
      } catch (_) {
        // non-JSON string (vd 'backToApp')
        return GameHostEvent(
          type: input,
          data: const {},
          source: null,
          raw: input,
        );
      }
    } else if (input is Map) {
      final map = input.cast<String, dynamic>();
      return GameHostEvent(
        type: map['type'] as String? ?? '',
        data: (map['data'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{},
        source: map['source'] as String?,
        raw: jsonEncode(map),
      );
    }
    return GameHostEvent(type: '', data: const {}, source: null, raw: null);
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'data': data,
        if (source != null) 'source': source,
      };

  String encode() => jsonEncode(toJson());
}
```

Các `type` chính giai đoạn 1:

- `EXIT_GAME`
- `ROUND_END`
- `BET_PLACED`
- `OPEN_DEPOSIT`
- `OPEN_HISTORY`
- `SESSION_EXPIRED`

---

## 2. Interface chung: GameHostBridge

```dart
import 'dart:async';
import 'game_host_event.dart';

abstract class GameHostBridge {
  /// Stream nhận toàn bộ event từ game
  Stream<GameHostEvent> get events;

  /// Gọi sau khi WebView/iframe load xong để inject JS / setup listener
  Future<void> bootstrap();

  /// Gửi event từ Host sang game
  Future<void> send(GameHostEvent event);

  void dispose();
}
```


---

## 3. Bridge cho từng platform

### 3.1. Mobile – webview_flutter

File: `webview_game_host_bridge.dart`

```dart
import 'dart:async';
import 'package:webview_flutter/webview_flutter.dart';

import 'game_host_bridge.dart';
import 'game_host_event.dart';

class WebViewGameHostBridge implements GameHostBridge {
  final WebViewController controller;
  final _controller = StreamController<GameHostEvent>.broadcast();

  WebViewGameHostBridge(this.controller) {
    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'FlutterChannel', // trùng phía JS
        onMessageReceived: (msg) {
          final ev = GameHostEvent.fromJson(msg.message);
          _controller.add(_normalizeEvent(ev));
        },
      );
  }

  GameHostEvent _normalizeEvent(GameHostEvent ev) {
    // Game cũ: FlutterChannel.postMessage('backToApp')
    if (ev.type == 'backToApp') {
      return GameHostEvent(
        type: 'EXIT_GAME',
        data: const {},
        source: ev.source ?? 'cocos-game',
        raw: ev.raw,
      );
    }
    return ev;
  }

  @override
  Stream<GameHostEvent> get events => _controller.stream;

  @override
  Future<void> bootstrap() async {
    await controller.runJavaScript(r'''
      // Bridge cho HostBridge.sendToHost(...)
      window.flutterNotifyHost = function(message) {
        if (window.FlutterChannel && FlutterChannel.postMessage) {
          FlutterChannel.postMessage(message);
        }
      };
    ''');
  }

  @override
  Future<void> send(GameHostEvent event) async {
    final msg = event.encode();
    await controller.runJavaScript('''
      if (window.onHostMessage) {
        window.onHostMessage($msg);
      }
    ''');
  }

  @override
  void dispose() {
    _controller.close();
  }
}
```

- Nhận:
    - `FlutterChannel.postMessage('backToApp')` → `EXIT_GAME`.
    - `FlutterChannel.postMessage(JSON)` → parse → `type` theo JSON.

---

### 3.2. Mobile – flutter_inappwebview

File: `inappwebview_game_host_bridge.dart`

```dart
import 'dart:async';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'game_host_bridge.dart';
import 'game_host_event.dart';

class InAppWebViewGameHostBridge implements GameHostBridge {
  final InAppWebViewController controller;
  final _controller = StreamController<GameHostEvent>.broadcast();

  InAppWebViewGameHostBridge(this.controller) {
    controller.addJavaScriptHandler(
      handlerName: 'gameBridge',
      callback: (args) {
        if (args.isEmpty) return null;
        final raw = args;
        final ev = GameHostEvent.fromJson(raw);
        _controller.add(_normalizeEvent(ev));
        return {'status': 'ok'};
      },
    );
  }

  GameHostEvent _normalizeEvent(GameHostEvent ev) {
    if (ev.type == 'backToApp') {
      return GameHostEvent(
        type: 'EXIT_GAME',
        data: const {},
        source: ev.source ?? 'cocos-game',
        raw: ev.raw,
      );
    }
    return ev;
  }

  @override
  Stream<GameHostEvent> get events => _controller.stream;

  @override
  Future<void> bootstrap() async {
    await controller.evaluateJavascript(source: r'''
      window.flutterNotifyHost = function(message) {
        if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
          window.flutter_inappwebview.callHandler('gameBridge', message);
        }
      };
    ''');
  }

  @override
  Future<void> send(GameHostEvent event) async {
    final msg = event.encode();
    await controller.evaluateJavascript(source: '''
      if (window.onHostMessage) {
        window.onHostMessage($msg);
      }
    ''');
  }

  @override
  void dispose() {
    _controller.close();
  }
}
```


---

### 3.3. Web – IframeGameHostBridge

File: `iframe_game_host_bridge.dart`

```dart
import 'dart:async';
import 'dart:html' as html;
import 'dart:ui' as ui;

import 'game_host_bridge.dart';
import 'game_host_event.dart';

class IframeGameHostBridge implements GameHostBridge {
  final html.IFrameElement iframe;
  final _controller = StreamController<GameHostEvent>.broadcast();
  late final StreamSubscription<html.MessageEvent> _sub;

  IframeGameHostBridge._(this.iframe) {
    _sub = html.window.onMessage.listen((event) {
      final ev = GameHostEvent.fromJson(event.data);
      if (ev.type.isNotEmpty) {
        _controller.add(ev);
      }
    });
  }

  static Future<IframeGameHostBridge> create({
    required Uri gameUri,
    required String viewType,
  }) async {
    final iframe = html.IFrameElement()
      ..src = gameUri.toString()
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%';

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      viewType,
      (int id) => iframe,
    );

    return IframeGameHostBridge._(iframe);
  }

  @override
  Stream<GameHostEvent> get events => _controller.stream;

  @override
  Future<void> bootstrap() async {
    // game dùng window.parent.postMessage(JSON) nên không cần inject thêm
  }

  @override
  Future<void> send(GameHostEvent event) async {
    iframe.contentWindow?.postMessage(event.encode(), '*');
  }

  @override
  void dispose() {
    _sub.cancel();
    _controller.close();
  }
}
```


---

## 4. Business logic – GameHostService

File: `game_host_service.dart`

```dart
import 'dart:async';

import 'game_host_bridge.dart';
import 'game_host_event.dart';

class GameHostService {
  final GameHostBridge bridge;
  late final StreamSubscription<GameHostEvent> _sub;

  final void Function()? onExitGame;

  GameHostService(
    this.bridge, {
    this.onExitGame,
  });

  Future<void> init() async {
    await bridge.bootstrap();
    _sub = bridge.events.listen(_onEvent);
  }

  void _onEvent(GameHostEvent event) {
    switch (event.type) {
      case 'EXIT_GAME':
        _handleExitGame(event);
        break;
      case 'ROUND_END':
        _handleRoundEnd(event);
        break;
      case 'BET_PLACED':
        _handleBetPlaced(event);
        break;
      case 'OPEN_DEPOSIT':
        _handleOpenDeposit(event);
        break;
      default:
        break;
    }
  }

  void _handleExitGame(GameHostEvent event) {
    if (onExitGame != null) {
      onExitGame!();
    }
  }

  void _handleRoundEnd(GameHostEvent event) {
    // TODO: update balance, show result, log analytic...
  }

  void _handleBetPlaced(GameHostEvent event) {
    // TODO: check limit, log...
  }

  void _handleOpenDeposit(GameHostEvent event) {
    // TODO: navigate đến màn nạp tiền
  }

  Future<void> sendToGame(String type, Map<String, dynamic> data) {
    final ev = GameHostEvent(
      type: type,
      data: data,
      source: 'flutter-host',
    );
    return bridge.send(ev);
  }

  void dispose() {
    _sub.cancel();
    bridge.dispose();
  }
}
```


---

## 5. Ví dụ tích hợp

### 5.1. Mobile – webview_flutter

```dart
class CocosGamePage extends StatefulWidget {
  final String gameUrl;
  const CocosGamePage({super.key, required this.gameUrl});

  @override
  State<CocosGamePage> createState() => _CocosGamePageState();
}

class _CocosGamePageState extends State<CocosGamePage> {
  late final WebViewController _webController;
  GameHostService? _service;

  @override
  void initState() {
    super.initState();

    _webController = WebViewController()
      ..loadRequest(Uri.parse(widget.gameUrl));

    final bridge = WebViewGameHostBridge(_webController);
    _service = GameHostService(
      bridge,
      onExitGame: () => Navigator.of(context).pop(),
    )..init();
  }

  @override
  void dispose() {
    _service?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebViewWidget(controller: _webController),
    );
  }
}
```


### 5.2. Web – iframe

```dart
class CocosGameWebPage extends StatefulWidget {
  final String gameUrl;
  const CocosGameWebPage({super.key, required this.gameUrl});

  @override
  State<CocosGameWebPage> createState() => _CocosGameWebPageState();
}

class _CocosGameWebPageState extends State<CocosGameWebPage> {
  GameHostService? _service;
  final _viewType = 'cocos-game-iframe';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final bridge = await IframeGameHostBridge.create(
      gameUri: Uri.parse(widget.gameUrl),
      viewType: _viewType,
    );

    _service = GameHostService(
      bridge,
      onExitGame: () => Navigator.of(context).pop(),
    );

    await _service!.init();
    setState(() {});
  }

  @override
  void dispose() {
    _service?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_service == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: HtmlElementView(viewType: _viewType),
    );
  }
}
```


---

Với hai README này, bạn có thể gửi riêng cho team Cocos và team Flutter để mỗi bên chỉ cần đọc phần liên quan.

