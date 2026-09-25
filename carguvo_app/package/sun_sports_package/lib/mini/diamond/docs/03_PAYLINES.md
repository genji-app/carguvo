# 03 — Payline (20 dòng) & bộ chọn dòng

> Nguồn: `KimCuong_SlotMachineCmp.ts` (mảng `LINE`), `KimCuongLineSelectionView.ts`, `KimCuongGameView.setLines()`

## 1. Payline là gì?

Trong slot 3×3, **payline** là một đường đi qua 3 cột, mỗi cột lấy 1 trong 3 hàng (0=trên, 1=giữa, 2=dưới). Nếu 3 biểu tượng trên đường đó tạo tổ hợp trúng → dòng đó được thưởng. Kim Cương có **20 payline** (index 0..19).

## 2. Bảng 20 payline

Định nghĩa trong `KimCuong_SlotMachineCmp.LINE` — mỗi phần tử là `[hàng_cột0, hàng_cột1, hàng_cột2]`:

| Line ID | Đường (cột0, cột1, cột2) | Mô tả hình dạng |
|---|---|---|
| 0 | `[2,2,2]` | Ngang dưới |
| 1 | `[1,1,1]` | Ngang giữa |
| 2 | `[0,0,0]` | Ngang trên |
| 3 | `[2,0,2]` | Chữ V ngược (đáy-đỉnh-đáy) |
| 4 | `[0,2,0]` | Chữ V (đỉnh-đáy-đỉnh) |
| 5 | `[2,1,2]` | Võng nhẹ dưới |
| 6 | `[2,1,0]` | Chéo lên |
| 7 | `[0,1,2]` | Chéo xuống |
| 8 | `[1,0,1]` | Bướu lên giữa |
| 9 | `[1,2,1]` | Bướu xuống giữa |
| 10 | `[0,1,0]` | Vòm trên |
| 11 | `[2,2,1]` | Bậc dưới → giữa |
| 12 | `[1,1,0]` | Giữa → trên |
| 13 | `[1,1,2]` | Giữa → dưới |
| 14 | `[0,0,1]` | Trên → giữa |
| 15 | `[1,2,2]` | Giữa → dưới |
| 16 | `[0,1,1]` | Trên → giữa |
| 17 | `[2,1,1]` | Dưới → giữa |
| 18 | `[1,0,0]` | Giữa → trên |
| 19 | `[2,0,1]` | Zigzag |

> Mặc định `lineArr` khởi tạo = toàn bộ 20 dòng `[0..19]` → mặc định chơi **tất cả các dòng**.

## 3. Vẽ đường trúng — `drawLine(lineID, isClear)`

- Lấy `line = LINE[lineID]`, với mỗi cột lấy vị trí world của ô ở hàng tương ứng (`getLineWorldPosition()`).
- Thêm 1 điểm là **node số thứ tự dòng** (nhãn số bên rìa):
  - `lineID >= 10` → thêm vào **cuối** (đường đi từ trong ra nhãn bên phải).
  - `lineID < 10` → thêm vào **đầu** (nhãn bên trái).
- Vẽ bằng `LineSpriteComponent.draw(...)` với màu trắng `color(255,255,255,200)`, độ dày `3`.

### Các kiểu hiển thị đường
| Hàm | Khi nào dùng |
|---|---|
| `showLines(ids, timeShow, finishAfter, cb)` | Hiện lần lượt tất cả dòng trúng ngay sau khi dừng (giãn đều theo `timeShow`) |
| `showEachLines(ids, timePerLine)` | Lặp hiển thị từng dòng trúng (khi đứng yên, không auto) — hết vòng thì clear |
| `showLine(id)` | Hiện đúng 1 dòng (bấm vào nút số dòng) |
| `clearLine()` | Xoá hết đường đang vẽ |

Khi bấm vào **nút số dòng** (`line_buttons` trong `onLoad`): vẽ dòng đó 1 giây rồi tự clear.

## 4. Popup chọn dòng — `KimCuongLineSelectionView`

Mở bằng `btn_line` (chỉ khi máy dừng và không Auto).

### Toggle điều khiển nhanh
| Nút | Hành vi |
|---|---|
| **Tất cả** (`btn_tatca`) | Chọn hết 20 dòng |
| **Chẵn** (`btn_chan`) | Chọn các dòng index **lẻ** (`i % 2 !== 0`) — *xem lưu ý bên dưới* |
| **Lẻ** (`btn_le`) | Chọn các dòng index **chẵn** (`i % 2 === 0`) |
| **Huỷ** (`btn_huy`) | Bỏ chọn hết |
| **Tùy chọn** (`btn_custom`) | Tự bật khi lựa chọn không khớp preset nào |

> ⚠️ **Lưu ý ngược logic (đã verify trong source):** cách code hiện tại đảo nghĩa "chọn/bỏ chọn". Trong `getSelectedLines()`, một dòng được coi là **được chọn khi toggle KHÔNG check** (`if (!toggle.isChecked) ids.push(i)`). Do đó nhãn "Chẵn" thực chất lọc `i % 2 !== 0`. Khi port cần thống nhất lại quy ước để tránh nhầm.

### Đồng bộ trạng thái — `checkToggle()`
Tự động xác định đang ở preset nào dựa trên tập dòng đang chọn:
- `allSelected` → bật "Tất cả"
- `allEvenSelected` và đúng nửa số dòng → bật "Chẵn"
- `allOddSelected` và đúng nửa → bật "Lẻ"
- `noneSelected` → bật "Huỷ"
- không khớp gì → bật "Tùy chọn"

Cờ `isUpdatingToggles` chống đệ quy khi set toggle theo chương trình.

## 5. Cập nhật số dòng ra GameView — `setLines(lines)`

`GameView.setLines(lines)`:
- Lưu `lineArr = lines`.
- Cập nhật label: `line_num_text = lb_common_line_num.replace("{num}", lines.length)`.
- `lineArr` chính là mảng `ls` gửi lên server khi spin (xem `05_NETWORK_PROTOCOL.md`).

## 6. Vì sao payline quan trọng cho business
- **Số dòng = hệ số nhân tổng cược**: `tổng cược = bet × số dòng đang chọn`. Chọn nhiều dòng → cược lớn hơn, cơ hội trúng nhiều dòng hơn nhưng rủi ro/lượt cao hơn.
- Cho người chơi quyền tùy biến khẩu vị rủi ro (chơi ít dòng an toàn vs. all-in 20 dòng).
