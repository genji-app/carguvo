# Ping Logic

## Ping flow

File liên quan:

- `assets/bundles/base/scripts/network/SocketSend.ts`
- `assets/bundles/base/scripts/network/SocketManager.ts`
- `assets/bundles/base/scripts/network/SocketReceived.ts`
- `assets/bundles/base/base-common/GameDefine.ts`

### Tổng quan

Ping được dùng để giữ kết nối WebSocket sống và kiểm tra socket còn ở trạng thái logged in hay không.

Flow hiện tại:

1. Socket login thành công.
2. `SocketReceived` gọi `SocketManager.setPingTimeout(socketType)`.
3. `SocketManager` tạo timer theo `GAME_DEFINE.PING_INTERVAL_MS`.
4. Khi timer chạy, `SocketManager.funcSendPing()` gọi `SocketSend.sendPing()`.
5. `SocketSend` build gói ping rồi gửi qua `SocketManager.sendData()`.
6. Server trả về `MessageResponse.Ping_Response`.
7. `SocketReceived` nhận response, lấy `pingID`, rồi gọi lại `SocketManager.setPingTimeout(socketType, pingID)`.
8. Vòng ping tiếp tục lặp lại.

`GAME_DEFINE.PING_INTERVAL_MS` hiện đang là `2000`, nghĩa là mỗi vòng ping được schedule sau khoảng 2 giây.

### SocketReceived: bắt đầu ping sau login

Sau khi nhận `MessageResponse.LogIn_Response` thành công, `SocketReceived` set trạng thái login cho socket:

```ts
SocketManager.getInstance().setLoginState(socketType, isSucceed);
```

Nếu login thành công, ping timer được bật:

```ts
SocketManager.getInstance().setPingTimeout(socketType);
```

Luồng này có ở cả hai nhánh:

- `handleMessage()` cho các socket thường như `MAIN`, `AGENCY`, `HILO`, `DRAGON_TIGER`.
- `handleMessageMiniGame()` cho socket `MINI`.

### SocketManager: quản lý timer ping

`SocketManager.setPingTimeout(socketType, pingID = 0, timeOut = GAME_DEFINE.PING_INTERVAL_MS)` là nơi tạo timer ping.

Trước khi tạo timer mới, hàm luôn clear timer cũ:

```ts
this.clearTimeout(socketType, TIMEOUT_TYPE.PING);
```

Sau đó lưu timer vào `timeoutIds`:

```ts
this.timeoutIds[idTimeout] = setTimeout(() => {
    this.funcSendPing(socketType, pingID);
}, timeOut);
```

ID timer được tính bằng:

```ts
socketType + GAME_DEFINE.ID_PING_TIMEOUT
```

Vì `ID_PING_TIMEOUT = 0`, mỗi socket có một ping timeout riêng theo `socketType`.

### SocketManager: gửi ping khi timer chạy

Khi timer chạy, `funcSendPing(socketType, pingID)` kiểm tra socket còn logged in không:

```ts
if(!SocketManager.getInstance().checkLoginState(socketType)) {
    this.clearTimeout(socketType, TIMEOUT_TYPE.PING);
    return;
}
```

Nếu socket không còn `NETWORK_STATE.LOGGED_IN`, ping bị dừng và timer bị clear.

Nếu socket vẫn logged in, `SocketManager` gọi:

```ts
SocketSend.sendPing(socketType, pingID, 0);
```

### SocketSend: build packet ping

`SocketSend.sendPing(socketType, pingID = 0, time = 0)` tiếp tục kiểm tra login state:

```ts
if(!SocketManager.getInstance().checkLoginState(socketType)) {
    console.log("return");
    return;
}
```

Sau đó tăng `pingID` lên 1:

```ts
let pid = pingID + 1;
```

Hiện tại `time` luôn bị reset về `0`:

```ts
time = 0;
```

Packet ping được build theo format:

```ts
[
    MessageRequest.Ping_Type,
    SocketManager.getInstance().getPortTypeBySocketType(socketType),
    pid,
    time
]
```

Trong đó:

- `MessageRequest.Ping_Type = 7`
- `portType` được lấy theo socket:
  - `MAIN`, `AGENCY` -> `"Simms"`
  - `MINI` -> `"MiniGame"`
  - `HILO`, `DRAGON_TIGER` -> `"ShakeDisk"`
- `pid` là ping id mới.
- `time` hiện luôn là `0`.

Trước khi gửi, code stringify rồi parse thử packet để đảm bảo JSON hợp lệ. Nếu không lỗi và websocket tồn tại, packet được gửi bằng:

```ts
SocketManager.getInstance().sendData(socketType, data);
```

### SocketManager: sendData

`SocketManager.sendData(socketType, data)` là hàm gửi packet xuống websocket thật.

Với ping packet, log gửi đi bị bỏ qua:

```ts
if(data[0] != MessageRequest.Ping_Type){
    CommonUtils.log(...)
}
```

Nếu socket dùng msgpack, data sẽ được encode trước:

```ts
data = msgPack.encode(data);
```

Cuối cùng data được gửi qua `SocketGame.send()`:

```ts
SocketManager.getInstance().wsArr[socketType]?.send(data);
```

### SocketReceived: nhận Ping_Response

Khi server trả về ping response, message type là:

```ts
MessageResponse.Ping_Response
```

Trong `handleMessage()`:

```ts
let pingID = message[1];
SocketManager.getInstance().setPingTimeout(socketType, pingID);
return;
```

Trong `handleMessageMiniGame()`:

```ts
let pingID = message[1];
SocketManager.getInstance().setPingTimeout(socketType, pingID);
break;
```

Nghĩa là client không gửi ping tiếp ngay khi nhận response. Thay vào đó, nó schedule timer mới. Sau `PING_INTERVAL_MS`, timer mới gọi `funcSendPing()`, rồi `SocketSend.sendPing()` gửi packet tiếp theo với `pingID + 1`.

### Sequence ngắn

```text
Login success
  -> SocketReceived.setLoginState(LOGGED_IN)
  -> SocketReceived.setPingTimeout(socketType, 0)
  -> wait PING_INTERVAL_MS
  -> SocketManager.funcSendPing(socketType, 0)
  -> SocketSend.sendPing(socketType, 0, 0)
  -> send [Ping_Type, portType, 1, 0]
  -> server response [Ping_Response, 1]
  -> SocketReceived.setPingTimeout(socketType, 1)
  -> wait PING_INTERVAL_MS
  -> SocketSend.sendPing(socketType, 1, 0)
  -> send [Ping_Type, portType, 2, 0]
  -> ...
```

### Ghi chú

- Ping chỉ chạy khi socket đang `NETWORK_STATE.LOGGED_IN`.
- Mỗi socket có timer ping riêng.
- Khi socket mất login state, `funcSendPing()` sẽ clear ping timeout và dừng vòng ping.
- Ping send/receive đang được loại khỏi log thường để tránh spam console.
- Đoạn code cũ trong `SocketReceived.handleMessage()` từng có `setTimeout()` gọi `SocketSend.sendPing()` trực tiếp sau `Ping_Response`, nhưng hiện không chạy vì đã `return` ngay sau `setPingTimeout()`.

## Abstract logic cho Flutter

Khi port logic này sang Flutter, nên tách ping thành một service độc lập, ví dụ `SocketPingController` hoặc `PingService`. Service này không cần biết UI, chỉ cần biết socket nào đang login, cách gửi packet, và cách nhận `Ping_Response`.

### Thành phần nên có

- `SocketConnection`: wrapper quanh websocket, có `send()`, `close()`, `isConnected`.
- `SocketState`: trạng thái socket, tối thiểu có `loggedOut`, `connecting`, `loggedIn`, `closed`.
- `PingService`: quản lý `Timer`, `pingId`, interval, start/stop ping.
- `MessageDispatcher`: parse message từ server và route `Ping_Response` về `PingService`.

### State cần lưu

```dart
Timer? pingTimer;
int pingId = 0;
bool isLoggedIn = false;
Duration pingInterval = const Duration(seconds: 2);
```

Nếu app có nhiều socket, mỗi socket nên có một instance `PingService`, hoặc một map theo socket type:

```dart
final Map<SocketType, PingService> pingServices = {};
```

### Luồng start ping

Sau khi login websocket thành công:

```text
onLoginResponse(success = true)
  -> socketState = loggedIn
  -> pingService.start(lastPingId: 0)
```

`start()` không gửi ping ngay. Nó schedule một timer sau `pingInterval`, giống logic hiện tại:

```dart
void start({int lastPingId = 0}) {
  stop();
  pingId = lastPingId;

  pingTimer = Timer(pingInterval, () {
    sendPing();
  });
}
```

### Luồng send ping

Trước khi gửi ping, luôn kiểm tra socket còn login và connection còn mở:

```dart
void sendPing() {
  if (!socketState.isLoggedIn || !socket.isConnected) {
    stop();
    return;
  }

  final nextPingId = pingId + 1;
  final packet = [
    MessageRequest.ping,
    portType,
    nextPingId,
    0,
  ];

  socket.send(jsonEncode(packet));
}
```

Sau khi gửi, không tự tăng `pingId` vĩnh viễn nếu muốn bám đúng logic hiện tại. `pingId` nên được cập nhật từ server response. Nếu server response trả lại `nextPingId`, response sẽ là source-of-truth.

### Luồng nhận Ping_Response

Khi dispatcher nhận message từ websocket:

```dart
void onSocketMessage(dynamic rawMessage) {
  final message = jsonDecode(rawMessage as String);
  final type = message[0];

  if (type == MessageResponse.ping) {
    final responsePingId = message[1] as int;
    pingService.onPingResponse(responsePingId);
    return;
  }

  // handle message khác
}
```

Trong `PingService`, nhận response xong thì schedule vòng tiếp theo:

```dart
void onPingResponse(int responsePingId) {
  if (!socketState.isLoggedIn) {
    stop();
    return;
  }

  start(lastPingId: responsePingId);
}
```

Như vậy flow Flutter sẽ là:

```text
login success
  -> start timer
  -> timer fires
  -> send [Ping_Type, portType, pingId + 1, 0]
  -> wait server response
  -> receive [Ping_Response, pingId]
  -> reset timer
  -> repeat
```

### Stop ping

Ping phải dừng trong các trường hợp:

- User logout.
- Socket close.
- Socket error.
- Login state bị set về `loggedOut`.
- App quyết định reconnect socket.

Hàm stop chỉ cần cancel timer:

```dart
void stop() {
  pingTimer?.cancel();
  pingTimer = null;
}
```

### Gợi ý xử lý timeout response

Logic hiện tại chỉ schedule ping tiếp sau khi có `Ping_Response`. Khi sang Flutter, có thể thêm một response timeout nếu cần phát hiện mất kết nối nhanh hơn:

```text
send ping
  -> start response timeout, ví dụ 5 giây
  -> nếu nhận Ping_Response: cancel response timeout, schedule ping tiếp
  -> nếu timeout: stop ping, mark socket disconnected, trigger reconnect
```

Phần này là mở rộng so với code hiện tại, không bắt buộc nếu muốn giữ behavior giống TypeScript.
