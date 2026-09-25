# Tính năng: Luồng chơi & Trạng thái (Game Flow)

**Nguồn:** `TrenDuoiGameView.ts` — `reqStartGame`, `reqStartNewTurn`,
`reqStopGame`, `spin`, `resetAll`, `res*`, `onGameOver`.

---

## 1. Mục đích

Điều phối toàn bộ vòng đời một ván Trên Dưới: từ chờ chơi → quay lá → đoán
Trên/Dưới nhiều lượt → thắng (rút tiền) hoặc thua (reset).

---

## 2. Biến trạng thái cốt lõi

| Biến | Kiểu | Ý nghĩa |
|------|------|---------|
| `bet` | number | Mức cược hiện chọn (mặc định 1.000) |
| `mSessionID` | number | Id phiên đang chơi |
| `mUpDownValue` | number | Lựa chọn: **1 = Trên**, **-1 = Dưới** |
| `mIsPlaying` | bool | Đang trong ván (đã bấm Play) |
| `mIsGameOver` | bool | Ván đã thua/kết thúc |
| `mIsWinJackpot` | bool | Lượt vừa rồi trúng jackpot |
| `mVecResult` | any[] | Mảng **mã lá** đã lật trong ván (để đếm số lần lật) |
| `mNumOfA` | number | Số lá A đã ra (đếm ô AAA, tối đa 3) |
| `mTimeToCountDown` / `mTimeEndCountDown` | number | Đồng hồ (xem `06`) |

---

## 3. Các nút & hành động

| Nút | Hàm | Gửi message |
|-----|-----|-------------|
| Play (`btn_spin`) | `reqStartGame()` | `START_GAME` (1501) |
| Trên (`btn_up`) | set `mUpDownValue=1` → `reqStartNewTurn()` | `START_ROUND` (1502) |
| Dưới (`btn_down`) | set `mUpDownValue=-1` → `reqStartNewTurn()` | `START_ROUND` (1502) |
| Rút tiền / Lượt mới (`btn_luotmoi`) | `reqStopGame()` | `STOP_GAME` (1503) |
| Chip cược (`btn_chips[]`) | chọn mức cược (xem `07`) | — |
| Xếp hạng / Lịch sử / Trợ giúp / Đóng | mở popup / đóng | — |

`btn_up`/`btn_down` có hiệu ứng phóng to nhẹ khi bấm (tween scale ×1.1 trong
0.1s rồi về).

---

## 4. State machine (đầy đủ)

```
                    show() → TrenDuoiMessageHandler.subcribe()  (gửi INFO_GAME)
                                      │
                                      ▼
   ┌──────────────────────────────────────────────────────────┐
   │ IDLE  (resetAll)                                          │
   │  - status = "Nhấn Play để bắt đầu"                        │
   │  - btn_spin hiện; btn_up/down/luotmoi tắt(xám)            │
   │  - timer = 02:00 (chưa chạy), slot machine reset, A = 0   │
   └───────────────┬──────────────────────────────────────────┘
        bấm Play → reqStartGame(): mIsPlaying=true, status="",
                   spin(), gửi START_GAME
                                      │
                       resStartGame(iid=lá, crd=credit, up, down, sid)
                       → delay 0.5s → onUpdateResult(lá): hiện lá, bật
                         nút up/down theo luật, hiện up/down/credit
                                      ▼
   ┌──────────────────────────────────────────────────────────┐
   │ PLAYING                                                   │
   │  - high = up (thưởng Trên), low = down (thưởng Dưới)      │
   │  - mid = credit (tiền đang giữ → nút Rút tiền)            │
   │  - timer chạy (xem 06)                                    │
   └──────┬───────────────────────────────┬───────────────────┘
   bấm Trên/Dưới                       bấm Rút tiền (chỉ khi đã lật >1 lá)
   → spin(), gửi START_ROUND           → gửi STOP_GAME
          │                                     │
   resStartNewRound(iF, iJ, J, ng,...)   resStopGame(credit)
   → mIsGameOver=iF; delay0.5 →          → hiện "+credit", sfx thắng,
     onUpdateResult(lá, J)                 status="Thắng {money} sau {n} lần",
          │                                 disable nút, sau 3s → subcribe() (reset)
   ┌──────┴───────────┐
   │ iF=false (THẮNG) │ iF=true (THUA) → onGameOver():
   │ → tiếp tục PLAYING│   status="Bạn đã thua!", disable nút,
   │   bật lại up/down │   sau 3s → subcribe() (reset)
   │   theo luật lá    │
   └──────────────────┘

  Song song bất kỳ lúc nào: UPDATE_JAR → updateJackpot (xem 08)
```

---

## 5. Hàm `spin()` — khoá UI khi đang quay

Khi gửi START_GAME hoặc START_ROUND, gọi `spin()`:
- Tắt `btn_luotmoi`, `btn_down`, `btn_up` (interactable=false, nút Rút tiền chuyển
  **xám/grayscale**).
- Ẩn `btn_spin`.
- `stopTimer()` (dừng đồng hồ).
- Slot machine quay (`trenduoi_SlotMachineCmp.spin()`) + phát sfx quay loop.

→ Người chơi **không bấm được gì** cho tới khi nhận kết quả (res*) và
`onUpdateResult()` bật lại nút.

---

## 6. `resetAll()` — về trạng thái IDLE

- `mVecResult=[]`, timer = "02:00", status = hint "Nhấn Play để bắt đầu".
- `mid = bet`, `mIsGameOver=false`, `mIsPlaying=false`.
- Ẩn high/low price, clear label.
- Highlight đúng chip đang chọn, hiện `btn_spin`, disable up/down/luotmoi.
- Reset slot machine, `mNumOfA=0`, ẩn result panel, dừng timer.

`resetAll()` được gọi: lúc `start()` (khởi tạo), trong `resInfoGame` (đầu mỗi
lần subscribe), và khi START_GAME trả lỗi (`mgs`).

---

## 7. Thắng / thua / rút tiền

- **Thua** (`onGameOver`, do `iF=true`): ẩn result panel, status "Bạn đã thua!",
  disable hết nút, **sau 3 giây tự `subcribe()`** (lấy info game mới = reset),
  refresh tiền (`SocketSend.sendRefreshMoney(MAIN)`).
- **Rút tiền** (`resStopGame(credit)`): hiện `lbl_result_amount = "+{credit}"` với
  animation trượt + mờ dần, phát `win_sfx`, status = "Thắng {money} sau {count}
  lần lật" (`count = mVecResult.length`), disable nút, **sau 3 giây `subcribe()`**,
  refresh tiền.
- Mọi nhánh kết thúc đều **gọi lại `subcribe()` sau 3s** để quay về IDLE với dữ
  liệu mới nhất (số dư, hũ).

---

## 8. Gợi ý áp dụng Flutter

- Dựng `TrenDuoiPhase { idle, playing, finished }` + `busy` (tương ứng `spin()`
  khoá UI).
- `mVecResult.length` → đếm số lá đã lật; dùng cho: bật Rút tiền (`>1`), text
  "sau {n} lần".
- `mUpDownValue` map sang `udr` khi gửi: **Trên=1, Dưới=-1**.
- Sau thua/rút: hẹn 3 giây rồi `subscribe()` lại (đừng reset tức thì — để người
  chơi đọc kết quả).
- Đồng bộ với UI Flutter đã có: `phase==idle` → HintBar + nút Start tròn;
  `phase==playing` → CardHistory + 2 cửa + nút Rút tiền.
