# Texture Atlas cho UI icon (preload 1 ảnh thay vì N request)

Mục tiêu: gộp các icon liên quan của 1 màn hình vào **1 ảnh + 1 JSON**, preload
**một lần**, rồi cắt từng icon ra ở client → không còn N request remote.

## 1. Tạo atlas

```bash
pip install pillow
# Gộp folder icon -> assets/atlas/home.png + home.json
python tools/pack_atlas.py path/to/home_icons -o assets/atlas/home
```

### Icon SVG

SVG được hỗ trợ — script tự rasterize (vector → bitmap). Backend tự chọn theo
thứ tự ưu tiên: **resvg → rsvg-convert → cairosvg**. Khuyến nghị `resvg` (binary
độc lập, KHÔNG cần libcairo nên tránh lỗi `no library called cairo` trên macOS):

```bash
brew install resvg
python3 tools/pack_atlas.py home_icons -o assets/atlas/home --svg-scale 3
```

(Thay thế: `brew install librsvg` cho lệnh `rsvg-convert`; hoặc `pip install
cairosvg` + `brew install cairo` nếu muốn dùng cairosvg.)

- `--svg-scale 3`: render @3x cho nét trên màn mật độ cao. JSON sẽ ghi
  `"scale": 3` cho mỗi SVG; runtime tự chia `sourceSize/scale` để kích thước
  **logical** khớp SVG gốc → icon KHÔNG bị to gấp 3 lần khi vẽ không set
  width/height. (PNG/webp `scale=1`.)
- `--svg-size 96`: ép cạnh lớn = 96px (giữ tỉ lệ); scale được tính tự động theo
  kích thước tự nhiên của SVG.
- Trộn chung SVG + PNG trong cùng folder đều được; tên frame = tên file gốc
  (vd `back.svg`).

Tuỳ chọn hay dùng: `-p 2` (padding), `--no-trim`, `--max-size 2048`.
JSON xuất ra theo format **JSON Hash** (tương thích free-tex-packer), nên bạn cũng
có thể dùng thẳng free-tex-packer.com rồi export "JSON (Hash)".

Upload `home.png` + `home.json` lên CDN/server (đặt cạnh nhau cùng folder để
PNG tự resolve theo `meta.image`).

## 2. Khai báo nguồn atlas

```dart
import 'package:sun_sports/core/utils/sprite/atlas.dart';

const homeAtlas = AtlasSource.remote('https://cdn.example.com/atlas/home.json');
// PNG tự lấy theo meta.image; muốn ép thì: AtlasSource.remote(json, imageUrl: '...')
```

## 3. Preload khi vào Home (tải + decode đúng 1 lần)

```dart
@override
void initState() {
  super.initState();
  // warm cache; các AtlasIcon sau đó hiển thị tức thì
  WidgetsBinding.instance.addPostFrameCallback((_) {
    preloadAtlas(ref, homeAtlas);
  });
}
```

## 4. Dùng icon

```dart
AtlasIcon(
  source: homeAtlas,
  name: 'wallet.png',   // = tên file gốc trong atlas
  width: 24, height: 24,
  color: Theme.of(context).colorScheme.primary, // tint icon đơn sắc (bỏ nếu icon màu)
)
```

## Vì sao chỉ tải 1 lần?
`spriteAtlasProvider` là `FutureProvider.family` **không autoDispose** → atlas
(`ui.Image` đã decode) được giữ trong RAM theo URL; mọi `AtlasIcon` dùng chung,
không tải/decode lại. `ui.Image` được dispose tự động khi provider teardown.

## Lưu ý
- Atlas hợp cho **icon nhỏ, ít đổi**. Ảnh lớn/đổi liên tục vẫn nên `cached_network_image`.
- Giữ tổng kích thước atlas ≤ 2048px nếu cần hỗ trợ máy yếu (GL_MAX_TEXTURE_SIZE).
- Đổi icon ⇒ tạo atlas mới + đổi tên file (hoặc thêm `?v=` query) để bust cache.
