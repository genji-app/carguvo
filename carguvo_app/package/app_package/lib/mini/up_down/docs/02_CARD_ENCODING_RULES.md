# Tính năng: Mã hoá lá bài & Luật Trên/Dưới

**Nguồn:** `TrenDuoiGameView.ts` (`onUpdateResult`, `onGameOver`),
`TrenDuoiResultItem.ts` (`show`), `TrenDuoi_SlotMachineItemView.ts`.

---

## 1. Mã hoá lá bài (card code)

Server gửi **mã lá là số nguyên `0–51`** (field `iid` trong message — xem `00`,
`03`).

```
suit = floor(code % 4) + 1     // 1..4
rank = floor(code / 4) + 1      // 1..13
```

**Chất (suit):** (theo `TrenDuoiResultItem`)

| suit | Tên VN | Sprite gốc | Màu |
|------|--------|------------|-----|
| 1 | Bích (spade) | `ct_bich` | đen |
| 2 | Tép (club)  | `ct_tep`  | đen |
| 3 | Rô (diamond)| `ct_ro`   | đỏ |
| 4 | Cơ (heart)  | `ct_co`   | đỏ |

**Hạng (rank) & tên hiển thị:**

| rank | code | Tên |
|------|------|-----|
| 1 | 0–3   | **A** |
| 2..10 | 4..39 | "2".."10" |
| 11 | 40–43 | **J** |
| 12 | 44–47 | **Q** |
| 13 | 48–51 | **K** |

> Edge gốc: `if (rank == 15) rank = 2;` (phòng mã ngoài 0–51). Trong
> `onUpdateResult` còn `if (N == 1) N = 14;` — xem mục 2.

---

## 2. Giá trị so sánh Trên/Dưới (rất quan trọng)

Để so cao/thấp, **A là lá CAO NHẤT (giá trị 14)**, không phải 1:

```ts
// onUpdateResult(result):
let N = Math.floor(result / 4) + 1;   // rank 1..13
if (N == 1)  N = 14;                  // A → 14 (cao nhất)
if (N == 15) N = 2;                   // edge
let mCurrentResult = N;               // giá trị dùng để xét Trên/Dưới
```

Thang giá trị: **2 (thấp nhất) < 3 < … < 10 < J(11) < Q(12) < K(13) < A(14)**.

---

## 3. Luật bật/tắt nút Trên/Dưới

Sau khi lật lá (`onUpdateResult`, khi **chưa** game over):

```ts
btn_up.interactable   = (mCurrentResult != 14);  // không cho TRÊN nếu lá là A (14, max)
btn_down.interactable = (mCurrentResult != 2);   // không cho DƯỚI nếu lá là 2 (min)
btn_luotmoi.interactable = (mVecResult.length > 1); // chỉ Rút tiền sau khi đã thắng ≥1 lượt
```

→ Map sang UI 2 cửa `available/not_available`:
- Cửa **Trên** `available` khi lá hiện tại **≠ A**.
- Cửa **Dưới** `available` khi lá hiện tại **≠ 2**.
- Nút **Rút tiền** bật khi đã lật **> 1 lá**.

---

## 4. Đếm Át (AAA) & liên hệ jackpot

```ts
if (mCurrentResult == 14 && mNumOfA < mVecAAA.length) { // mỗi lá A
    mNumOfA++;
    updateNumA();   // bật ô A kế tiếp + hiệu ứng pop scale 1.2→1.0
}
```

- `mVecAAA` = 3 ô (theo thiết kế) → tối đa đếm 3 lá A.
- `updateNumA()`: ô thứ `index < mNumOfA` thì `interactable=true` + tween pop.
- Cụm AAA bên trái màn hình chính là **bộ đếm số lá A** đã ra trong ván (gợi ý
  điều kiện/độ hiếm cho jackpot).

---

## 5. Thắng / thua được quyết ở đâu

- **Server quyết**, client chỉ phản ứng theo cờ `iF` (isGameOver):
  - `resStartNewRound(..., isGameOver=iF, ...)` → `mIsGameOver = iF`.
  - Trong `onUpdateResult`: nếu `mIsGameOver` → `onGameOver()` (THUA). Ngược lại →
    tiếp tục, bật lại nút theo luật mục 3.
- Client **không tự so lá** để kết luận thắng/thua — chỉ dùng `mCurrentResult` để
  bật/tắt nút (luật mục 3) và đếm A.

---

## 6. Tiền thưởng & credit

- `up` / `down` (message) = **tiền thưởng dự kiến** nếu đoán Trên/Dưới đúng → hiển
  thị ở 2 cửa (label high/low).
- `crd` (credit) = **tiền đang giữ** (cộng dồn qua các lượt thắng) → hiển thị ở
  giữa (nút Rút tiền). Khi `STOP_GAME` trả `credit`, đó là số tiền nhận về.

---

## 7. Gợi ý áp dụng Flutter

- Viết helper thuần:
  ```dart
  ({int rank, int suit, int compareValue, String label, _Suit suit}) decodeCard(int code) {
    final suit = code % 4 + 1;       // 1 bích,2 tép,3 rô,4 cơ
    var rank = code ~/ 4 + 1;        // 1..13
    final compare = (rank == 1) ? 14 : rank;  // A = 14
    // label: 1/14→'A', 11→'J', 12→'Q', 13→'K', còn lại rank.toString()
  }
  ```
- `canBetUp = compareValue != 14`, `canBetDown = compareValue != 2` → truyền vào
  `_BetBar(available: ...)`.
- `canCashout = history.length > 1`.
- Đếm A: `numOfA = min(3, history.where((c) => decode(c).compare == 14).length)`
  → cụm AAA.
- Map suit → asset chất hiện có: bích→`up_down_spades.svg`, tép→`up_down_clubs.svg`,
  rô→`up_down_diamond.svg`, cơ→`up_down_heart.svg`.
