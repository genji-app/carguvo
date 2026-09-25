# Minigame Feature

Feature này là khung Clean Architecture cho các mini game chạy bằng socket
riêng. Socket nằm ở `lib/core/services/websocket/minigame_websocket.dart` để
dùng chung hạ tầng reconnect/heartbeat của `BaseWebSocket`, nhưng protocol
được tách khỏi main/chat websocket.

## Socket Flow

```text
UI/provider
-> MinigameRepository.connect()
-> WebSocketManager.connectMinigame()
-> MinigameWebSocket.connectWithAuth()
-> websocket login command
-> minigame events stream
```

## Target Login Flow

Flow gốc cần follow khi nối minigame với login/main socket:

```text
User login form / auto login
        |
        v
LoginManager.requestLogin(...)
        |
        v
HTTP login success
        |
        v
SocketManager.setLoginData(SocketType.MAIN, info, signature)
        |
        |-- copy loginData sang SocketType.MINI cùng lúc
        v
SocketManager.sendLogin(SocketType.MAIN)
        |
        v
MAIN socket open -> gửi packet LogIn vào port "Simms"
        |
        v
MAIN login response success
        |
        v
emit CHECK_MINI_GAME_LOADED_AND_LOGIN
        |
        v
GameViewManager download/open mini node
        |
        v
SocketManager.sendLogin(SocketType.MINI)
        |
        v
MINI socket open -> gửi packet LogIn vào port "MiniGame"
        |
        v
MINI login response success
        |
        v
subscribe minigame + active node + start ping
```

Mapping sang code Flutter hiện tại:

```text
LoginManager.requestLogin(...)
  -> AuthRemoteDataSource.login / SbLogin.refreshToken()

SocketManager.setLoginData(SocketType.MAIN, info, signature)
  -> SbConfig.mainWsLoginInfo / SbConfig.mainWsLoginSignature

SocketType.MAIN
  -> WebSocketManager.main / SbMainWebSocket

SocketType.MINI
  -> WebSocketManager.minigame / MinigameWebSocket

SocketManager.sendLogin(SocketType.MAIN)
  -> SbMainWebSocket.onConnected() -> sendLogin(...)

CHECK_MINI_GAME_LOADED_AND_LOGIN
  -> TODO: feature event/provider trigger sau khi main login success

GameViewManager download/open mini node
  -> TODO: Minigame presentation/player layer

SocketManager.sendLogin(SocketType.MINI)
  -> MinigameWebSocket.connectWithAuth(...) -> onConnected() -> _sendLogin()
```

Implementation notes:

- MAIN login dùng port/zone `"Simms"`.
- MINI login phải dùng port/zone `"MiniGame"` khi protocol server yêu cầu.
- Khi WebSocket open, MINI login packet phải dùng đúng format:

```text
[
  MessageRequest.LogIn_Type,
  PortType.MINI,
  dataUserName,
  dataPwd,
  SocketManager.getLoginData(SocketType.MAIN)
]
```

- Nghĩa là port gửi server là `"MiniGame"`.
- `dataUserName` / `dataPwd` lấy từ `GameConfigManager.username/password`
  hoặc session được truyền vào feature.
- Login payload của MINI dùng lại payload MAIN:

```text
getLoginData(SocketType.MAIN)
```

- Login data của MINI phải được copy từ MAIN ngay sau HTTP login/loginAccessToken
  để tránh lệch `info/signature`.
- Chỉ gọi MINI login sau khi main login response success và mini node đã load.
- Sau MINI login success mới subscribe minigame, active node, và bật ping/session
  heartbeat.

## Required Login Data

- Minigame websocket URL
- Main access token (`SbHttpManager.userToken`)
- `wsToken` (`SbConfig.wsToken`)
- User id / customer login

The server protocol can be adapted inside `MinigameWebSocket` without changing
feature UI code.

## Protocol Commands

Web -> Cocos uses `messageType` strings:

```text
CONFIRM_BET
ALL_IN
GET_RANKING
GET_HISTORY
GET_SESSION_ANALYTIC
```

Cocos/socket -> Web uses numeric `cmd` values:

```text
1005 SUBSCRIBE_INFO
1000 BET
1003 SHOW_RESULT
1004 CALCULATE_RESULT_MONEY
1002 START_GAME
1007 SESSION_ANALYTIC
1008 UPDATE_BET_INFO
1009 GET_BET_HISTORY
1011 CHAT
```

`1010 BET_FREE` is reserved but intentionally inactive for now.
