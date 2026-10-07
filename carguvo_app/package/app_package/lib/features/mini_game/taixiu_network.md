# Tai Xiu Network

## File liên quan

- `assets/bundles/base/scripts/network/SocketManager.ts`
- `assets/bundles/base/scripts/network/SocketSend.ts`
- `assets/bundles/base/scripts/network/SocketReceived.ts`
- `assets/bundles/minigame/scripts/manager/MiniGameEventController.ts`
- `assets/bundles/minigame/scripts/Network/TaiXiuMessageHandler.ts`
- `assets/bundles/minigame/scripts/MiniGameNodeController.ts`
- `assets/bundles/minigame/scripts/CCMiniGameRoot.ts`
- `assets/bundles/minigame/scripts/Games/TaiXiu/MiniHiloGameView.ts`
- `assets/bundles/minigame/scripts/Games/TaiXiu/TaiXiuChatView.ts`
- `assets/bundles/minigame/scripts/Games/TaiXiu/TaiXiuSessionAnalyticsView.ts`

## Tổng quan

Tài Xỉu mini chạy qua socket `SocketType.MINI`, port `"MiniGame"`, plugin `"taixiuPlugin"`.

Format message chính:

```ts
[
    MessageRequest.ZonePlugin_Type,
    "MiniGame",
    "taixiuPlugin",
    dict
]
```

Trong đó `dict.cmd` quyết định loại request/response của Tài Xỉu.

## Mini socket login

Mini socket được login trong `SocketManager.onSocketOpen()`.

Khi `socket.type === SocketType.MINI`, client:

1. Emit `GAME_EVENT.MINIGAME.OPEN_MINIGAME_NODE`.
2. Emit `GAME_EVENT.MINIGAME.MINIMIZE_MINIGAME`.
3. Build login message với port `"MiniGame"`.
4. Gửi login message qua socket mini.

```ts
loginMessage = [
    MessageRequest.LogIn_Type,
    "MiniGame",
    dataUserName,
    dataPwd,
    SocketManager.getInstance().getLoginData(SocketType.MAIN)
];
```

Ý nghĩa:

- Mini socket dùng login data từ `SocketType.MAIN`.
- Khi bắt đầu login mini, mini node được mở để có instance quản lý, sau đó minimize để không hiện full UI không mong muốn.

## Mini socket login response

Mini login response được xử lý trong `SocketReceived.handleMessageMiniGame()`.

Khi nhận `MessageResponse.LogIn_Response` thành công:

1. Gửi tracking `RES_LOGIN_WS_MINI`.
2. Set login state cho `SocketType.MINI`.
3. Start ping bằng `SocketManager.setPingTimeout(socketType)`.
4. Gửi change language cho socket mini.
5. Gọi `SocketReceived.handleAfterLoginSuccessMiniGame()`.

`handleAfterLoginSuccessMiniGame()` làm 4 việc:

```ts
EventController.getInstance().emit(GAME_EVENT.MINIGAME.SUBSRIBE_MINI_GAME_MAIN);
GameViewManager.getInstance().setActiveMiniGameNode(true);
GameViewManager.getInstance().curView?.handleLoggedIn();
SocketSend.sendSubscribeJackpot(SocketType.MINI);
```

Tức là sau mini login success:

- Subscribe dữ liệu Tài Xỉu.
- Bật active mini game node.
- Báo current view đã login lại.
- Subscribe jackpot/lobby mini.

## Subscribe Tài Xỉu

Event `GAME_EVENT.MINIGAME.SUBSRIBE_MINI_GAME_MAIN` được đăng ký trong `MiniGameEventController.registerEventHandlers()`.

Khi event này chạy:

```ts
SocketSend.sendSubscribeMiniHilo();
```

`SocketSend.sendSubscribeMiniHilo()` gửi:

```ts
let dict = {
    cmd: 1005
};

let mes = [
    MessageRequest.ZonePlugin_Type,
    "MiniGame",
    "taixiuPlugin",
    dict
];

SocketManager.getInstance().sendData(SocketType.MINI, mes);
```

`cmd = 1005` là `TaiXiu_Message.SUBSCRIBE_INFO`.

Trong `TaiXiuMessageHandler` cũng có hàm `subcribeTaiXiu()` làm cùng logic, nhưng flow hiện tại đang gọi qua `SocketSend.sendSubscribeMiniHilo()`.

## Subscribe jackpot

Sau mini login success, `SocketReceived.handleAfterLoginSuccessMiniGame()` gọi:

```ts
SocketSend.sendSubscribeJackpot(SocketType.MINI);
```

`SocketSend.sendSubscribeJackpot()` gửi qua plugin `"lobbyPlugin"`:

```ts
let dict = {
    cmd: subscribe ? 10001 : 10002
};

let data = [
    MessageRequest.ZonePlugin_Type,
    "MiniGame",
    "lobbyPlugin",
    dict
];
```

Ý nghĩa:

- `10001`: subscribe jackpot/lobby mini.
- `10002`: unsubscribe jackpot/lobby mini.

Các update jackpot slot/top jackpot được xử lý trong `SocketReceived.handleMessageMiniGame()`:

- `GAME_MESSAGE.SLOT_TOP_JACKPOT_UPDATE` -> `SocketReceived.updateSlotTopJackpot(message)`.
- `MINI_GAME_MESSAGE.UPDATE_JACKPOT` trong nhóm cmd `1300-1399` -> emit update jackpot theo `gid`.

Riêng Tài Xỉu handler hiện có comment `this game no have JP`, nên `SUBSCRIBE_INFO` của Tài Xỉu không set jackpot trực tiếp cho `MiniHiloGameView`.

## Route message mini socket

`SocketManager.onSocketMessage()` parse raw socket data, sau đó:

```ts
if(socket.type == SocketType.MINI){
    SocketReceived.handleMessageMiniGame(socket.type, msgSocket);
} else {
    SocketReceived.handleMessage(socket.type, msgSocket);
}
```

Trong `SocketReceived.handleMessageMiniGame()`, `MessageResponse.Extension_Response` được route theo `dict.cmd`.

Các nhóm chính:

- `GAME_MESSAGE.BROADCAST_MESSAGE`: show floating string lobby.
- `GAME_MESSAGE.SLOT_TOP_JACKPOT_UPDATE`: update top jackpot.
- `GAME_MESSAGE.ERROR_MESSAGE`: show error/noti.
- `cmd >= 1000 && cmd < 1100`: Tài Xỉu mini.
- `cmd >= 2000 && cmd < 2100`: Tài Xỉu không cần / variant cùng handler.
- `cmd >= 1950 && cmd <= 1957`: Xóc Đĩa mini.
- `cmd >= 1300 && cmd < 1400`: slot/mini poker/diamond/dragonball.
- `cmd >= 1500 && cmd < 1600`: Cao Thấp / UpDown.

Tài Xỉu được emit qua:

```ts
EventController.getInstance().emit(
    GAME_EVENT.MINIGAME.HANDLE_MESSAGE_MINI_TAI_XIU,
    message
);
```

`MiniGameEventController` nhận event này và gọi:

```ts
TaiXiuMessageHandler.handleMessage(message);
```

## Tài Xỉu message commands

Enum hiện tại trong `TaiXiuMessageHandler`:

```ts
SUBSCRIBE_INFO = 1005
BET = 1000
SHOW_RESULT = 1003
CALCULATE_RESULT_MONEY = 1004
START_GAME = 1002
SESSION_ANALYTIC = 1007
UPDATE_BET_INFO = 1008
GET_BET_HISTORY = 1009
CHAT = 1011
```

Variant `TaiXiuKhongCan_Message`:

```ts
SUBSCRIBE_INFO = 2000
BET = 2002
SHOW_RESULT = 2016
CALCULATE_RESULT_MONEY = 2006
START_GAME = 2005
SESSION_ANALYTIC = 2009
UPDATE_BET_INFO = 2007
GET_BET_HISTORY = 2004
CHAT = 2008
UPDATE_JACKPOT = 2011
WIN_JACKPOT = 2010
```

Lưu ý: route ở `SocketReceived` đưa cả nhóm `2000-2099` vào `TaiXiuMessageHandler`, nhưng handler hiện đang so sánh chủ yếu với enum `TaiXiu_Message` nhóm `1000`.

## Handle SUBSCRIBE_INFO

Khi nhận `cmd = 1005`, `TaiXiuMessageHandler.handleMessage()` đọc các field:

- `sid`: session id.
- `gS`: game state.
- `rmT`: remaining time, chia `1000` để đổi ms sang giây.
- `tFB`: time for betting, chia `1000`.
- `tFP`: time for paying, chia `1000`.
- `htr`: history.
- `gi`: game info / bet info.
- `ag`: available gold.
- `ac`: available chip.
- `fbn`: free bet times.
- `fba`: free bet amount.
- `enableEvent`, `eventMgs`, `eventUrl`: event data.
- `cH`: chat history.

Nếu `MiniHiloGameView.getInstance() == null`, tức prefab Tài Xỉu chưa load/show:

```ts
MiniGameNodeController.getInstance()?.subscribeInfoMiniHilo(...);
MiniGameNodeController.getInstance()?.saveSubscribeData(dict);
```

Khi đó mini node vẫn cập nhật trạng thái rút gọn:

- Countdown betting.
- Kết quả Tài/Xỉu gần nhất.
- Data subscribe được cache lại để apply sau khi prefab load.

Nếu `MiniHiloGameView` đã tồn tại:

```ts
MiniHiloGameView.getInstance()?.loadChatHistory(chatHistory);
MiniHiloGameView.getInstance()?.subcribleInfo(...);
```

## Subscribe after load / show

`MiniGameNodeController.reSubscribeWhenLoad = true` theo default.

Ý nghĩa comment trong code:

```ts
// true: use subscribe when load mini game
// false: use subscribe when show mini game
```

Khi `MiniHiloGameView.show()` lần đầu:

```ts
if (this.isShowFirstTime) {
    this.isShowFirstTime = false;

    if(MiniGameNodeController.getInstance().reSubscribeWhenLoad)
        SocketSend.sendSubscribeMiniHilo();
}
```

Ý nghĩa:

- Sau login mini đã subscribe Tài Xỉu một lần.
- Nếu prefab Tài Xỉu được mở sau đó, view gửi lại `sendSubscribeMiniHilo()` để lấy state mới nhất, tránh dùng data cũ khi trước đó prefab chưa load.

Nếu `reSubscribeWhenLoad = false`, trong `MiniHiloGameView.onLoad()` sẽ gọi:

```ts
MiniGameNodeController.getInstance()?.handleDataAfterLoadMiniHilo();
```

`handleDataAfterLoadMiniHilo()` apply data đã cache:

```ts
handleSubscribeMiniHilo();
handleBetInfoBalanced();
```

## Handle START_GAME

Khi nhận `cmd = 1002`, handler lấy `sid`.

Nếu `MiniHiloGameView` chưa tồn tại:

```ts
MiniGameNodeController.getInstance()?.startNewGame(sid);
```

Nếu view đã tồn tại:

```ts
MiniHiloGameView.getInstance()?.startNewGame(sid);
```

Ở `MiniGameNodeController.startNewGame()`:

- Tính `timeBetEnd`.
- Gửi `SocketSend.sendRefreshMoney(SocketType.MAIN)`.
- Cập nhật countdown ở mini node đóng/mở.

## Handle UPDATE_BET_INFO

Khi nhận `cmd = 1008`, handler lấy:

```ts
let betArr = dict["gi"];
```

Sau đó cache vào mini node:

```ts
MiniGameNodeController.getInstance()?.saveBetInfoBalanced(betArr);
```

Nếu `MiniHiloGameView` đang tồn tại:

```ts
MiniHiloGameView.getInstance().updateBetInfoBalanced(betArr);
```

Nếu view chưa tồn tại, code lấy tổng bet Tài/Xỉu từ `betArr[0]`:

```ts
let taiDict = gameInfoDict["B"];
let xiuDict = gameInfoDict["S"];
director.emit(GAME_EVENT.COMMON.UPDATE_BET_EVENT_KEY, totalTaiBeting, totalXiuBeting);
```

Ý nghĩa:

- View đầy đủ update bảng bet.
- Mini node / UI ngoài view vẫn nhận được tổng Tài/Xỉu để hiển thị nhanh.

## Handle BET response

Khi nhận `cmd = 1000`, handler đọc:

- `aid`: asset id.
- `eid`: cửa bet, `1` là Tài, `2` là Xỉu.
- `tB`: tổng tiền user đã bet cửa đó.
- `tEB`: tổng tiền của cửa.
- `ab`: available balance.
- `tU`: total user.

Sau đó update bet của chính player:

```ts
MiniHiloGameView.getInstance()?.updateThisPlayerBetting(
    aid,
    eid,
    betting,
    totalEntryBetting,
    totalUser,
    0
);
```

Cuối cùng refresh tiền main socket:

```ts
SocketSend.sendRefreshMoney(SocketType.MAIN);
```

## Send BET request

User đặt cược trong `MiniHiloGameView.sendBet()`.

Trước khi gửi, client validate:

- Game đang trong phiên chơi.
- Số tiền nhập khác `0`.
- Số tiền không lớn hơn `GameConfigManager.gold`.
- Thời gian còn lại phải lớn hơn `5` giây.

Payload gửi:

```ts
let dict = {
    cmd: TaiXiu_Message.BET,
    b: this._inputingMoney,
    aid: this._aid,
    sid: this._sessionID,
    eid: eid
};

let mes = [
    MessageRequest.ZonePlugin_Type,
    "MiniGame",
    "taixiuPlugin",
    dict
];

SocketManager.getInstance().sendData(SocketType.MINI, mes);
```

`eid`:

- `1`: Tài.
- `2`: Xỉu.

## Handle SHOW_RESULT

Khi nhận `cmd = 1003`, handler lấy:

```ts
let d1 = dict["d1"];
let d2 = dict["d2"];
let d3 = dict["d3"];
```

Sau đó luôn update `MiniGameNodeController` trước:

```ts
MiniGameNodeController.getInstance()?.showResult(d1, d2, d3, true);
```

Nếu `MiniHiloGameView` đang tồn tại, view đầy đủ cũng show result:

```ts
MiniHiloGameView.getInstance()?.showResult(d1, d2, d3, true);
```

`MiniGameNodeController.showResult()` tính Tài/Xỉu bằng:

```ts
let isTai = d1 + d2 + d3 > 10;
```

Rồi update closed/opened mini node.

## Handle CALCULATE_RESULT_MONEY

Khi nhận `cmd = 1004`:

```ts
MiniHiloGameView.getInstance()?.updateResultMoneyBalanced(dict);
```

Đây là message hệ thống tính tiền sau khi có kết quả.

Field response đang được `MiniHiloGameView.updateResultMoneyBalanced()` đọc:

- `cmd`: command id, `1004`.
- `d1`, `d2`, `d3`: kết quả 3 xúc xắc. Field này có trong sample nhưng logic hiện tại không dùng trực tiếp ở hàm tính tiền.
- `G`: tổng gold thắng/nhận sau khi xử lý kết quả.
- `C`: tổng chip thắng/nhận sau khi xử lý kết quả.
- `GX`: gold exchange / số gold hệ thống trả cho user trước khi trừ refund.
- `CX`: chip exchange / số chip hệ thống trả cho user trước khi trừ refund.
- `ag`: available gold mới của user.
- `ac`: available chip mới của user.
- `gR`: gold refund, tiền gold hoàn lại do overbet/refund.
- `cR`: chip refund, tiền chip hoàn lại do overbet/refund.
- `gB`: gold bet, số gold bet được tính hợp lệ.
- `cB`: chip bet, số chip bet được tính hợp lệ.
- `gBB`: gold balance bet, tổng gold hợp lệ của cửa sau khi cân bằng.
- `cBB`: chip balance bet, tổng chip hợp lệ của cửa sau khi cân bằng.

Ví dụ response có refund:

```json
{
    "cmd": 1004,
    "d1": 3,
    "d2": 6,
    "d3": 5,
    "G": 9959930,
    "C": 0,
    "GX": 20000,
    "CX": 0,
    "ag": 9959930,
    "ac": 0,
    "gR": 20000,
    "cR": 0,
    "gB": 20000,
    "cB": 0,
    "gBB": 0,
    "cBB": 0
}
```

Cách UI dùng:

- `MiniHiloGameView.updateResultMoneyBalanced(dict)` chọn tiền theo `_aid`.
- Nếu `_aid == 1`, dùng `gR`, `GX`, `gB`, `gBB`.
- Nếu `_aid != 1`, dùng `cR`, `CX`, `cB`, `cBB`.
- `_refundMoney` nhận tiền hoàn, `winAmount = exchange - refund`.
- Gửi `SocketSend.sendRefreshMoney(SocketType.MAIN)` để refresh ví lobby.
- Gọi `updateThisPlayerBetting()` để cập nhật số tiền user đã bet ở Tài/Xỉu sau khi hệ thống cân bằng.
- Cập nhật label `lbBetHiTotalThis`, `lbBetLoTotalThis`, reset input và chạy tween nhấn mạnh label.

## Handle SESSION_ANALYTIC

Khi nhận `cmd = 1007`, handler:

1. Hide loading.
2. Lấy `bs`, `sid`, `d1`, `d2`, `d3`, `st`, `ended`.
3. Nếu `ended == false`, show noti `msg_session_not_ended`.
4. Nếu phiên đã kết thúc, gọi:

```ts
MiniHiloGameView.getInstance()?.fetchThongKe(
    thongKeArr,
    sessionID,
    d1,
    d2,
    d3,
    startTime
);
```

Request session analytic được gửi từ:

- `MiniHiloGameView.sendSessionAnalytics()`: lấy phiên trước `this._sessionID - 1`.
- `TaiXiuSessionAnalyticsView`: nút prev/next session.

Payload:

```ts
let dict = {
    cmd: TaiXiu_Message.SESSION_ANALYTIC,
    sid: sessionId,
    aid: aid
};
```

Field request:

- `cmd`: command id, `1007`.
- `sid`: session id cần xem thống kê. `MiniHiloGameView.sendSessionAnalytics()` gửi phiên trước bằng `this._sessionID - 1`; trong popup thống kê, nút previous/next gửi `this._sessionID - 1` hoặc `this._sessionID + 1`.
- `aid`: asset id hiện tại. UI dùng `_aid` của `MiniHiloGameView`.

Field response:

- `cmd`: command id, `1007`.
- `sid`: session id của dữ liệu trả về.
- `d1`, `d2`, `d3`: kết quả 3 xúc xắc của phiên.
- `st`: start time của phiên, được format qua `StringUtils.formatTime(new Date(st), false)`.
- `ended`: trạng thái phiên đã kết thúc hay chưa. Nếu `false`, UI show message `msg_session_not_ended` và không mở bảng thống kê.
- `bs`: danh sách bet trong phiên.

Field item trong `bs`:

- `dn`: display name của user.
- `crt`: thời gian đặt cược, được format giờ bằng `StringUtils.formatTimeJustHours(new Date(crt))`.
- `b`: số tiền bet.
- `eid`: cửa bet, `1` là Tài, giá trị khác `1` được đưa vào Xỉu.
- `rf`: số tiền refund của bet.

Cách UI dùng:

- `TaiXiuMessageHandler` gọi `MiniHiloGameView.fetchThongKe(bs, sid, d1, d2, d3, st)`.
- `MiniHiloGameView.fetchThongKe()` chuyển dữ liệu vào `TaiXiuSessionAnalyticsView.showSessionAnalytics(..., this._aid)`.
- `TaiXiuSessionAnalyticsView` set sprite xúc xắc từ `d1`, `d2`, `d3`.
- Tổng `d1 + d2 + d3 > 10` thì highlight Tài, ngược lại highlight Xỉu.
- `bs` được tách thành `_thongKeTai` và `_thongKeXiu` theo `eid`.
- UI hiển thị danh sách theo page, tổng tiền đặt, số user từng cửa và tổng `bet / refund`.

## Handle GET_BET_HISTORY

Request bet history được gửi từ `MiniHiloGameView.showBetHistory()`:

```ts
let dict = {
    cmd: TaiXiu_Message.GET_BET_HISTORY,
    L: 500,
    S: 0,
    aid: this._aid
};
```

Khi nhận `cmd = 1009`, handler:

```ts
let betHistory = dict["items"];
let aid = dict["aid"];

MiniHiloGameView.getInstance()?.fetchHistory(betHistory, aid);
```

Field request:

- `cmd`: command id, `1009`.
- `L`: limit số item lịch sử muốn lấy. Code hiện gửi `500`.
- `S`: skip/offset. Code hiện gửi `0`.
- `aid`: asset id hiện tại của user.

Field response:

- `cmd`: command id, `1009`.
- `aid`: asset id của danh sách lịch sử trả về.
- `items`: danh sách lịch sử đặt cược.

Field item trong `items`:

- `sid`: session id.
- `crt`: thời gian đặt cược, được format qua `StringUtils.formatTime(new Date(crt), false)`.
- `eid`: cửa bet, `1` là Tài, `2` là Xỉu.
- `d1`, `d2`, `d3`: kết quả 3 xúc xắc của phiên.
- `b`: số tiền bet.
- `rf`: số tiền refund.
- `po`: payout / tiền nhận về.

Cách UI dùng:

- `TaiXiuMessageHandler` lấy `items`, `aid` rồi gọi `MiniHiloGameView.fetchHistory(items, aid)`.
- `MiniHiloGameView.fetchHistory()` chỉ chuyển tiếp nếu `aid` trùng `_aid` hiện tại.
- `TaiXiuBetHistoryView.fetchHistory()` map từng item thành `TaiXiuBetResult`.
- `TaiXiuBetHistoryItemView.show()` hiển thị phiên, thời gian, cửa bet, kết quả xúc xắc, tiền bet, refund và tiền thắng.
- Popup history phân trang client-side, mỗi trang tối đa `5` item.

## Handle BET_RANK HTTP

Rank Tài Xỉu không đi qua socket mà gọi HTTP trong `TaiXiuBetRankView.fetchRank()`.

URL:

```ts
GameConfigManager.SAdomainURL + URL_DEFINE.BET_RANK_URL_TAI_XIU
```

Nếu `GAME_DEFINE.IS_USE_GAME_API == true`:

```ts
GameConfigManager.urlGameApi + URL_DEFINE.BET_RANK_URL_TAI_XIU
```

Response shape đang hỗ trợ:

```json
{
    "data": {
        "topAssets": [
            {
                "topUsers": [
                    {
                        "rank": 1,
                        "displayName": "user",
                        "total": 100000
                    }
                ]
            }
        ]
    }
}
```

Các fallback field trong code:

- List ranking: `data.topAssets[0].topUsers`, hoặc `data.topUsers`, hoặc `data.items`.
- Rank: `rank`, nếu không có thì tính bằng vị trí trong danh sách.
- Tên user: `displayName`, fallback `userName`, fallback `dn`.
- Tiền thắng/tổng tiền: `total`, fallback `money`, fallback `winAmount`.

Cách UI dùng:

- `MiniHiloGameView.showRank()` gọi `miniHiloRankView.fetchRank()`.
- `TaiXiuBetRankView` phân trang client-side, mỗi trang `6` item.
- `TaiXiuBetRankItemView.show(rank, displayName, amount)` hiển thị icon top 1-3 hoặc số rank, username và tiền thắng.
- Nút prev/next ở landscape ẩn/hiện theo trang; ở portrait đổi `interactable` và grayscale sprite.

## Handle CHAT

Chat request được gửi từ `TaiXiuChatView`.

Payload:

```ts
let dict = {
    cmd: TaiXiu_Message.CHAT,
    mgs: strMes
};
```

Khi nhận `cmd = 1011`, handler push message vào `chat_array`, rồi update view:

```ts
this.chat_array.push(dict);
MiniHiloGameView.getInstance()?.updateChat(this.chat_array);
this.chat_array = [];
```

## Logout mini socket

Logout request đi qua `SocketSend.sendLogout(socketType)`.

Nếu `socketType == SocketType.MINI`, port là `"MiniGame"`:

```ts
let data = [
    MessageRequest.LogOut_Type,
    "MiniGame"
];
```

Khi mini socket nhận `MessageResponse.LogOut_Response`, `SocketReceived.handleMessageMiniGame()`:

```ts
GameViewManager.getInstance().setActiveMiniGameNode(false);
```

Nếu socket mini close/error trong `SocketManager`:

- `onSocketError()` emit `GAME_EVENT.MINIGAME.FORCE_STOP_MINIGAME`.
- `onSocketClose()` emit:
  - `GAME_EVENT.MINIGAME.FORCE_STOP_MINIGAME`
  - `GAME_EVENT.MINIGAME.CLOSE_MINIGAME_NODE`
  - `GAME_EVENT.MINIGAME.CLEAN_EVENT_STORE`

## Show / open / minimize / close mini game node

Các event được đăng ký trong `MiniGameEventController`.

### OPEN_MINIGAME_NODE

```ts
CCMiniGameRoot.getInstance()?.openMiniGameNode();
```

`CCMiniGameRoot.openMiniGameNode()`:

- Set mini game node active.
- Gọi `forceAllMachineStop(false)`.

### MINIMIZE_MINIGAME

```ts
CCMiniGameRoot.getInstance()?.minimize();
```

`MiniGameNodeController.minimize()`:

- Nếu mini socket chưa connected thì return.
- `forceAllMachineStop(true, withRelease)`.
- `closeAll()`.

`closeAll()`:

- Đóng mini menu.
- Hide Tài Xỉu, Diamond, MiniPoker, UpDown, DragonBall.

### CLOSE_MINIGAME_NODE

```ts
CCMiniGameRoot.getInstance()?.closeMiniGameNode();
```

`closeMiniGameNode()`:

- Deactive node.
- `forceAllMachineStop()`.
- `closeAll()`.

### SHOW_GAME_ID

```ts
MiniGameNodeController.getInstance().showMiniGame(gameID);
```

`showMiniGame(gameID)`:

1. Kiểm tra `SocketType.MAIN` đã login chưa. Nếu chưa, emit show login popup.
2. Nếu game là mini game, lấy prefab config.
3. Nếu prefab chưa có, load prefab từ bundle và update progress.
4. Nếu prefab đã có, check orientation để release/switch prefab nếu cần.
5. Instantiate view nếu instance chưa tồn tại.
6. Gọi `instance.show()`.
7. Nếu show thành công, đóng menu mini.

## Force stop

Event:

```ts
GAME_EVENT.MINIGAME.FORCE_STOP_MINIGAME
```

Handler:

```ts
MiniGameNodeController.getInstance()?.forceAllMachineStop();
```

`forceAllMachineStop(stopAuto = true, withRelease = false)` hiện stop các máy slot mini:

- `MiniPokerGameView.forceMachineStop(stopAuto)`
- `KimCuongGameView.forceMachineStop(stopAuto)`
- `DragonBallGameView.forceMachineStop(stopAuto)`

Tài Xỉu không có machine stop riêng trong hàm này, nhưng force stop vẫn quan trọng vì event được dùng chung cho mini socket close/error và các mini game khác.

## Sequence chính

```text
MAIN login success
  -> login MINI socket
  -> SocketManager.onSocketOpen(MINI)
  -> emit OPEN_MINIGAME_NODE
  -> emit MINIMIZE_MINIGAME
  -> send [LogIn_Type, "MiniGame", username, password, mainLoginData]

MINI LogIn_Response success
  -> set MINI logged in
  -> start MINI ping
  -> send change language
  -> emit SUBSRIBE_MINI_GAME_MAIN
  -> sendSubscribeMiniHilo()
  -> sendSubscribeJackpot(SocketType.MINI)

Server Extension_Response cmd 1005
  -> SocketReceived.handleMessageMiniGame()
  -> emit HANDLE_MESSAGE_MINI_TAI_XIU
  -> TaiXiuMessageHandler.handleMessage()
  -> update MiniHiloGameView if loaded
  -> otherwise cache/update MiniGameNodeController

User opens Tài Xỉu
  -> emit SHOW_GAME_ID / click button
  -> MiniGameNodeController.showMiniGame(GAME_ID.TAIXIU)
  -> load/instantiate MiniHiloGameView
  -> MiniHiloGameView.show()
  -> first show sends sendSubscribeMiniHilo() again if reSubscribeWhenLoad = true
```
