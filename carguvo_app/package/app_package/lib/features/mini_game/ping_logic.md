# WebSocket Ping Logic

Ghi chú này tóm tắt logic ping/pong hiện tại của các WebSocket trong app để
đối chiếu khi port minigame.

## BaseWebSocket

`BaseWebSocket` là lớp nền cho `SbWebSocket`, `SbMainWebSocket`,
`SbChatWebSocket`, và `MinigameWebSocket` cũ.

Sau khi `WebSocketChannel.ready` thành công, base gọi `_startHeartbeat()`:

```text
connected
-> start heartbeat timer
-> every 30s send "PING"
```

Nếu nhận message đúng string:

```text
PONG
```

thì base nuốt message và không chuyển xuống subclass.

Base không có pong timeout. Không nhận `PONG` sẽ không tự reconnect. Reconnect
chỉ chạy khi socket báo `onError` hoặc `onDone`.

Reconnect mặc định:

```text
onError/onDone
-> self-redial
-> max 5 attempts
-> backoff 2s, 4s, 8s, 16s, 32s
```

## Sportbook WebSocket

Class: `SbWebSocket`

Sportbook không có ping custom riêng. Nó dùng heartbeat của `BaseWebSocket`:

```text
send "PING" every 30s
ignore "PONG"
```

Các message odds/score/balance được xử lý ở `onMessage()` sau khi base đã lọc
`PONG`.

Reconnect dùng base self-redial.

## Main WebSocket

Class: `SbMainWebSocket`

Main có ping/pong custom riêng, ngoài heartbeat string của base.

Sau khi login success hoặc nhận user info, main gọi `_startPing()` và gửi ngay:

```text
[7, "Simms", pingId, 0]
```

Pong được nhận theo 1 trong 2 format:

```text
{"pong": pingId}
[6, pingId]
```

Khi nhận pong, main schedule ping tiếp sau 5 giây:

```text
send ping
-> wait pong
-> receive pong
-> wait 5s
-> send next ping
```

Nếu không nhận pong, main không schedule ping tiếp. Hiện không có pong timeout
riêng để reconnect.

Lưu ý: Main WS đang bị comment/tạm tắt trong login flow hiện tại, nên logic này
có thể không chạy runtime.

## Chat WebSocket

Class: `SbChatWebSocket`

Chat có ping custom riêng:

```text
[7, chatZone, pingId, 0]
```

Sau khi chat login success, chat gửi ping định kỳ mỗi 5 giây:

```text
login success
-> start timer
-> every 5s send [7, chatZone, pingId, 0]
```

Chat có parse pong theo 2 format:

```text
[6, pingId]
{"pong": pingId}
```

Nhưng code ghi rõ chat server không reply pong ổn định, nên pong chỉ dùng cho
diagnostics, không dùng làm liveness signal.

Chat tự heal bằng các cơ chế khác:

```text
socket disconnected/error
connected nhưng login quá 12s chưa xong
proactive refresh wsToken trước khi expire
network restored event
recover/re-auth flow
```

Chat override recovery: khi rớt socket, nó không self-redial URL cũ như base mà
gọi `recover()` để refresh token và rebuild URL.

## Minigame Port Notes

Minigame hiện follow logic từ `ping_logic_flow.md`, gần với Main WS nhưng dùng
interval 2 giây theo JS `GAME_DEFINE.PING_INTERVAL_MS`.

Sau khi nhận `loginResponse`, ping manager không gửi ngay. Nó schedule ping đầu
tiên sau 2 giây:

```text
login success
-> wait 2s
-> send [7, "MiniGame", lastPingId + 1, 0]
-> receive [6, pingId]
-> wait 2s
-> send next ping
```

Minigame ping packet dùng port `"MiniGame"`:

```text
[7, "MiniGame", pingId, 0]
```

Login packet cũng dùng `"MiniGame"`:

```text
[1, "MiniGame", username, password, {info, signature}]
```

Nếu sau khi gửi ping mà không nhận `Ping_Response` trong 5 giây, Flutter dừng
ping loop và gọi reconnect cho socket minigame. Đây là phần mở rộng nhẹ so với
JS để tránh treo im khi server không trả pong.
