#!/usr/bin/env python3
"""
pack_atlas.py — Gộp 1 folder icon/ảnh thành 1 texture atlas (sprite sheet).

Output (tên file gắn hash nội dung để chống cache khi up server):
  - <name>.<hash>.png      : ảnh atlas lớn (hash đổi mỗi khi nội dung đổi)
  - <name>.<hash>.json     : metadata (format "JSON Hash" tương thích free-tex-packer)
  - <name>.manifest.json   : file CỐ ĐỊNH trỏ tới cặp .png/.json hiện tại

Vì tên .png/.json đổi theo nội dung nên CDN/trình duyệt luôn coi là file mới
=> không bao giờ phục vụ atlas cũ từ cache. Client chỉ cần load <name>.manifest.json
(tên cố định) để biết tên .png/.json hiện tại rồi tải chúng.

Mục đích: thay vì load N icon remote => load 1 ảnh + 1 json, rồi cắt từng
icon ra ở client (Flutter) bằng AtlasIcon.

Hỗ trợ: PNG, JPG, WEBP, BMP, GIF và **SVG** (SVG sẽ được rasterize -> bitmap).

9-slice (9-patch): file đặt tên "<name>.9.png" theo chuẩn Android NinePatch —
viền 1px guide màu đen ở MÉP TRÊN = vùng co giãn trục X, MÉP TRÁI = trục Y;
mép DƯỚI/PHẢI (tuỳ chọn) = padding nội dung. Pixel đỏ (layout bounds) bị bỏ qua.
Script tự cắt viền 1px, TẮT trim cho file này, và ghi thêm "scale9" (+ "padding")
vào metadata. Runtime Flutter dựng lại bằng Canvas.drawImageNine.

Cách dùng:
    pip3 install pillow
    brew install resvg            # chỉ cần nếu folder có .svg (khuyến nghị)
    python3 tools/pack_atlas.py <input_dir> -o assets/atlas/home

Rasterize SVG tự chọn backend có sẵn: resvg > rsvg-convert > cairosvg.

Tuỳ chọn:
    -o, --out       Đường dẫn output (không kèm đuôi). Mặc định: ./atlas
    -p, --padding   Khoảng cách giữa các sprite (px). Mặc định: 2
    -e, --extrude   Nhân pixel viền để chống "bleeding" khi scale. Mặc định: 0
    --no-trim       Tắt cắt viền trong suốt (mặc định: bật trim)
    --no-pot        Không ép kích thước về luỹ thừa 2 (mặc định: ép POT)
    --max-size      Kích thước tối đa mỗi chiều (px). Mặc định: 4096
    --svg-scale     Hệ số phóng khi rasterize SVG (vd 2 = @2x). Mặc định: 1.0
    --svg-size      Ép cạnh lớn của SVG = N px (ưu tiên hơn --svg-scale).

Lưu ý: tên frame trong JSON = tên file gốc (vd "wallet.png", "back.svg").
SVG là vector nên atlas bitmap sẽ "đông cứng" ở độ phân giải lúc pack —
hãy chọn --svg-scale/--svg-size theo DPI cao nhất bạn cần (vd @3x).
"""

import argparse
import hashlib
import io
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile

try:
    from PIL import Image
except ImportError:
    sys.exit("Thiếu Pillow. Chạy: pip install pillow")

IMG_EXTS = {".png", ".jpg", ".jpeg", ".webp", ".bmp", ".gif"}
SVG_EXTS = {".svg"}


def _svg_natural_size(path):
    """Đọc kích thước "logical" của SVG: ưu tiên width/height, fallback viewBox.
    Trả về (w, h) float, hoặc None nếu không xác định được."""
    try:
        head = open(path, encoding="utf-8", errors="ignore").read(2000)
    except Exception:
        return None

    def _num(s):
        m = re.match(r"\s*([0-9]*\.?[0-9]+)", s or "")
        return float(m.group(1)) if m else None

    mw = re.search(r'<svg[^>]*\bwidth="([^"]+)"', head)
    mh = re.search(r'<svg[^>]*\bheight="([^"]+)"', head)
    w = _num(mw.group(1)) if mw else None
    h = _num(mh.group(1)) if mh else None
    if w and h:
        return (w, h)

    mv = re.search(r'viewBox="([\d.\s,\-]+)"', head)
    if mv:
        parts = re.split(r"[\s,]+", mv.group(1).strip())
        if len(parts) == 4:
            try:
                return (float(parts[2]), float(parts[3]))
            except ValueError:
                pass
    return None


def rasterize_svg(path, svg_scale, svg_size):
    """Render SVG -> (PIL.Image RGBA, scale).

    `scale` = hệ số phóng tuyến tính từ kích thước LOGICAL (design) sang pixel.
    Runtime chia sourceSize/scale để intrinsic khớp SVG gốc (icon không bị to
    gấp `svg-scale` lần khi vẽ không set width/height).

    Ưu tiên backend không cần thư viện native: resvg > rsvg-convert > cairosvg.
    """
    # --svg-size: scale đồng nhất sao cho cạnh lớn = svg_size (giữ tỉ lệ).
    if svg_size:
        natural = _svg_natural_size(path)
        scale = (svg_size / max(natural)) if natural else 1.0
    else:
        scale = svg_scale

    if shutil.which("resvg"):
        img = _svg_via_resvg(path, scale)
    elif shutil.which("rsvg-convert"):
        img = _svg_via_rsvg_convert(path, scale)
    else:
        img = _svg_via_cairosvg(path, scale)
    return img, scale


def _svg_via_cairosvg(path, scale):
    try:
        import cairosvg
    except Exception:
        cairosvg = None
    if cairosvg is not None:
        try:
            png_bytes = cairosvg.svg2png(url=path, scale=scale)
            return Image.open(io.BytesIO(png_bytes)).convert("RGBA")
        except OSError:
            pass  # libcairo thiếu -> rơi xuống thông báo hướng dẫn
    sys.exit(
        "Cần một công cụ rasterize SVG. Khuyến nghị cài resvg:\n"
        "  brew install resvg\n"
        "Hoặc:  brew install librsvg        (lệnh rsvg-convert)\n"
        "Hoặc convert SVG -> PNG bằng tool khác (Figma/Inkscape) rồi pack PNG."
    )


def _run(cmd):
    res = subprocess.run(cmd, capture_output=True)
    if res.returncode != 0:
        sys.exit(f"Lỗi rasterize SVG: {' '.join(cmd)}\n{res.stderr.decode(errors='ignore')}")
    return res


def _svg_via_resvg(path, scale):
    with tempfile.NamedTemporaryFile(suffix=".png", delete=False) as tmp:
        out = tmp.name
    try:
        _run(["resvg", "--zoom", str(scale), path, out])
        return Image.open(out).convert("RGBA")
    finally:
        if os.path.exists(out):
            os.remove(out)


def _svg_via_rsvg_convert(path, scale):
    res = _run(["rsvg-convert", "-z", str(scale), path])  # PNG ra stdout
    return Image.open(io.BytesIO(res.stdout)).convert("RGBA")


def next_pot(n: int) -> int:
    p = 1
    while p < n:
        p <<= 1
    return p


def _is_guide(px):
    """Pixel guide 9-patch = đen mờ-đặc (opaque black). Trả True nếu là vạch.
    Pixel đỏ (layout bounds của Android) và pixel trong suốt -> KHÔNG phải guide."""
    r, g, b, a = px
    return a >= 128 and r <= 32 and g <= 32 and b <= 32


def parse_9patch(img):
    """Phân tích guide 1px của file .9.png (chuẩn Android NinePatch).

    Trả về (cropped_img, scale9, padding):
      - cropped_img: ảnh đã cắt viền 1px guide.
      - scale9: dict {left,right,top,bottom} = khoảng cách từ mỗi mép tới vùng
        co giãn ở giữa (theo toạ độ NỘI DUNG, đã bỏ viền). Dùng cho drawImageNine.
      - padding: dict tương tự cho vùng nội dung (mép dưới/phải), hoặc None.
    Nếu không có guide hợp lệ -> trả (img gốc, None, None)."""
    w, h = img.size
    if w < 3 or h < 3:
        return img, None, None
    px = img.load()
    cw, ch = w - 2, h - 2  # kích thước vùng nội dung sau khi bỏ viền 1px

    def first_run(coords):
        """Tìm đoạn guide đen LIÊN TỤC đầu tiên. Trả (start, end) theo chỉ số
        trong `coords` (đã offset về 0 = pixel nội dung đầu), hoặc None."""
        start = None
        for idx, (x, y) in enumerate(coords):
            if _is_guide(px[x, y]):
                if start is None:
                    start = idx
            elif start is not None:
                return start, idx
        if start is not None:
            return start, len(coords)
        return None

    # Mép trên (y=0), các cột nội dung 1..w-2: vùng co giãn trục X.
    top = first_run([(x, 0) for x in range(1, w - 1)])
    # Mép trái (x=0), các hàng nội dung 1..h-2: vùng co giãn trục Y.
    left = first_run([(0, y) for y in range(1, h - 1)])
    if top is None or left is None:
        return img, None, None  # không phải 9-patch hợp lệ -> coi như ảnh thường

    sx0, sx1 = top
    sy0, sy1 = left
    scale9 = {"left": sx0, "right": cw - sx1, "top": sy0, "bottom": ch - sy1}

    # Mép dưới (y=h-1) = padding ngang; mép phải (x=w-1) = padding dọc (tuỳ chọn).
    bottom = first_run([(x, h - 1) for x in range(1, w - 1)])
    rightp = first_run([(w - 1, y) for y in range(1, h - 1)])
    padding = None
    if bottom is not None or rightp is not None:
        bx0, bx1 = bottom if bottom else (0, cw)
        ry0, ry1 = rightp if rightp else (0, ch)
        padding = {"left": bx0, "right": cw - bx1, "top": ry0, "bottom": ch - ry1}

    cropped = img.crop((1, 1, w - 1, h - 1))
    return cropped, scale9, padding


def _iter_input_files(input_dir, recursive):
    """Liệt kê đường dẫn TƯƠNG ĐỐI của file ảnh trong input (đã sắp xếp).
    `recursive=True` -> đi vào cả thư mục con (os.walk); ngược lại chỉ tầng 1."""
    if recursive:
        for root, dirs, files in os.walk(input_dir):
            dirs.sort()
            for f in sorted(files):
                yield os.path.relpath(os.path.join(root, f), input_dir)
    else:
        for f in sorted(os.listdir(input_dir)):
            if os.path.isfile(os.path.join(input_dir, f)):
                yield f


def load_sprites(input_dir: str, do_trim: bool, svg_scale=1.0, svg_size=None,
                 skip_names=(), skip_pattern=None, recursive=False):
    """Trả về (sprites, skipped, has_subdir).
      - skipped: list (relpath, lý do) — MỌI file bị bỏ qua đều được ghi lại để
        đối chiếu input <-> output, không drop âm thầm.
      - has_subdir: input có thư mục con không (để cảnh báo nếu chưa --recursive).
    """
    sprites = []
    skipped = []           # (relpath, reason) — báo cáo cuối
    by_name = {}           # basename -> relpath đầu tiên (bắt trùng tên)
    skip = set(skip_names)
    has_subdir = any(
        os.path.isdir(os.path.join(input_dir, d)) for d in os.listdir(input_dir)
    )
    for rel in _iter_input_files(input_dir, recursive):
        fname = os.path.basename(rel)
        # Dotfile hệ thống (.DS_Store, .gitkeep…) -> bỏ qua, không coi là lỗi.
        if fname.startswith("."):
            continue
        # Bỏ qua chính file atlas cũ (tránh tự nuốt output).
        if fname in skip or (skip_pattern and skip_pattern.match(fname)):
            skipped.append((rel, "là file output atlas"))
            continue
        ext = os.path.splitext(fname)[1].lower()
        if ext not in SVG_EXTS and ext not in IMG_EXTS:
            skipped.append((rel, f"đuôi '{ext or '(không có)'}' không hỗ trợ"))
            continue
        # Runtime tra icon theo BASENAME (xem SportIconAtlas) -> 2 file trùng tên
        # (kể cả khác thư mục con) sẽ đè nhau làm MẤT 1 icon. Chặn cứng, báo rõ.
        if fname in by_name:
            sys.exit(
                f"Trùng tên sprite '{fname}': '{by_name[fname]}' và '{rel}'.\n"
                f"Mỗi icon phải có tên file duy nhất (runtime tra theo tên). "
                f"Đổi tên 1 trong 2 rồi pack lại."
            )
        path = os.path.join(input_dir, rel)
        is_9 = fname.lower().endswith(".9.png")
        try:
            if ext in SVG_EXTS:
                img, scale = rasterize_svg(path, svg_scale, svg_size)
            else:
                img = Image.open(path).convert("RGBA")
                scale = 1.0  # bitmap: pixel = logical
        except SystemExit:
            raise                          # backend SVG thiếu / render fail -> fatal
        except Exception as e:             # ảnh hỏng -> ghi nhận & đi tiếp, không drop âm thầm
            skipped.append((rel, f"lỗi đọc ảnh: {e}"))
            continue

        scale9 = padding9 = None
        sprite_trim = do_trim
        if is_9:
            # 9-patch: cắt viền guide 1px, lấy scale9/padding, TẮT trim
            # (trim sẽ làm lệch toạ độ biên co giãn).
            img, scale9, padding9 = parse_9patch(img)
            sprite_trim = False

        source_w, source_h = img.size
        offset_x, offset_y = 0, 0
        if sprite_trim:
            bbox = img.getbbox()  # vùng pixel không trong suốt
            if bbox:
                offset_x, offset_y = bbox[0], bbox[1]
                img = img.crop(bbox)
            else:
                # ảnh trong suốt hoàn toàn -> giữ 1px
                img = img.crop((0, 0, 1, 1))
        by_name[fname] = rel
        sprites.append({
            "name": fname,
            "image": img,
            "w": img.width,
            "h": img.height,
            "source_w": source_w,
            "source_h": source_h,
            "offset_x": offset_x,
            "offset_y": offset_y,
            "scale": scale,
            "scale9": scale9,
            "padding9": padding9,
        })
    return sprites, skipped, has_subdir


# ---------------------------------------------------------------------------
# MaxRects packing (Best Short Side Fit)
# Lấp được khe hở giữa các sprite (khác shelf chỉ xếp theo hàng) nên atlas gọn
# hơn nhiều, nhất là khi trộn lẫn sprite cao và sprite thấp.
# ---------------------------------------------------------------------------
def _split_free(free, used):
    """Cắt 1 ô trống `free` bởi vùng vừa đặt `used`, trả về các ô trống con."""
    fx, fy, fw, fh = free
    ux, uy, uw, uh = used
    # không giao nhau -> giữ nguyên
    if ux >= fx + fw or ux + uw <= fx or uy >= fy + fh or uy + uh <= fy:
        return [free]
    out = []
    if ux > fx:                                  # phần trái
        out.append((fx, fy, ux - fx, fh))
    if ux + uw < fx + fw:                        # phần phải
        out.append((ux + uw, fy, fx + fw - (ux + uw), fh))
    if uy > fy:                                  # phần trên
        out.append((fx, fy, fw, uy - fy))
    if uy + uh < fy + fh:                        # phần dưới
        out.append((fx, uy + uh, fw, fy + fh - (uy + uh)))
    return out


def _contains(a, b):
    """a có bao trọn b không?"""
    ax, ay, aw, ah = a
    bx, by, bw, bh = b
    return ax <= bx and ay <= by and ax + aw >= bx + bw and ay + ah >= by + bh


def _prune(rects):
    """Bỏ ô trống rỗng và ô bị ô khác bao trọn (để danh sách free gọn lại)."""
    rects = [r for r in rects if r[2] > 0 and r[3] > 0]
    out = []
    for i, r in enumerate(rects):
        if any(i != j and _contains(o, r) and not (o == r and j > i)
               for j, o in enumerate(rects)):
            continue
        out.append(r)
    return out


def _maxrects_fit(items, bin_w, bin_h):
    """Xếp `items` vào khung bin_w x bin_h bằng MaxRects-BSSF.
    Trả về (placements, used_w, used_h) hoặc None nếu không vừa."""
    free = [(0, 0, bin_w, bin_h)]
    placements = []
    used_w = used_h = 0
    for it in items:
        w, h = it["w"], it["h"]
        bx = by = None
        best_short = best_long = float("inf")
        for (fx, fy, fw, fh) in free:            # tìm ô vừa nhất (BSSF)
            if fw >= w and fh >= h:
                lw, lh = fw - w, fh - h
                short, long = (lw, lh) if lw < lh else (lh, lw)
                if short < best_short or (short == best_short and long < best_long):
                    best_short, best_long, bx, by = short, long, fx, fy
        if bx is None:
            return None                          # không còn chỗ -> khung quá nhỏ
        placements.append((it["ref"], bx, by))
        used_w = max(used_w, bx + w)
        used_h = max(used_h, by + h)
        placed = (bx, by, w, h)
        nf = []
        for r in free:
            nf.extend(_split_free(r, placed))
        free = _prune(nf)
    return placements, used_w, used_h


def pack_rects(sprites, padding, max_size, pot=True):
    """Pack bằng MaxRects, tự thử nhiều bề rộng khung và chọn cái cho atlas nhỏ
    nhất (tính theo kích thước CUỐI, đã ép POT nếu bật).
    Trả về (placements, atlas_w, atlas_h)."""
    items = [{"ref": s, "w": s["w"] + padding, "h": s["h"] + padding}
             for s in sprites]
    widest = max(it["w"] for it in items)
    tallest = max(it["h"] for it in items)
    if widest > max_size or tallest > max_size:
        big = max(sprites, key=lambda s: max(s["w"], s["h"]))
        sys.exit(f"Sprite '{big['name']}' vượt max-size {max_size}px. "
                 f"Tăng --max-size hoặc giảm số icon.")

    # Xếp sprite to trước (theo cạnh lớn rồi diện tích) để MaxRects hiệu quả.
    items.sort(key=lambda it: (max(it["w"], it["h"]), it["w"] * it["h"]),
               reverse=True)

    total = sum(it["w"] * it["h"] for it in items)
    # Bề rộng khung ứng viên: các luỹ thừa 2 + vài giá trị "vừa khít".
    cands = set()
    p = next_pot(widest)
    while p <= max_size:
        cands.add(p)
        p <<= 1
    cands.add(min(max_size, max(widest, int(total ** 0.5))))
    cands.add(min(max_size, max(widest, int((total ** 0.5) * 1.3))))

    best = None  # (key, placements, atlas_w, atlas_h)
    for bw in sorted(cands):
        res = _maxrects_fit(items, bw, max_size)
        if res is None:
            continue
        placements, uw, uh = res
        aw = next_pot(uw) if pot else uw
        ah = next_pot(uh) if pot else uh
        key = (aw * ah, ah)                      # nhỏ nhất; hoà thì thấp hơn
        if best is None or key < best[0]:
            best = (key, placements, aw, ah)
    if best is None:
        sys.exit(f"Không xếp được atlas trong max-size {max_size}px. "
                 f"Tăng --max-size.")
    _, placements, atlas_w, atlas_h = best
    return placements, atlas_w, atlas_h


def main():
    ap = argparse.ArgumentParser(description="Pack icon folder thành texture atlas.")
    ap.add_argument("input_dir", help="Folder chứa icon/ảnh")
    ap.add_argument("-o", "--out", default="atlas", help="Output path (không đuôi)")
    ap.add_argument("-p", "--padding", type=int, default=2)
    ap.add_argument("-e", "--extrude", type=int, default=0)
    ap.add_argument("--no-trim", action="store_true")
    ap.add_argument("--no-pot", action="store_true")
    ap.add_argument("--max-size", type=int, default=4096)
    ap.add_argument("--svg-scale", type=float, default=1.0)
    ap.add_argument("--svg-size", type=int, default=None)
    ap.add_argument("--keep-old", action="store_true",
                    help="Giữ lại các cặp .png/.json hash cũ (mặc định: xoá).")
    ap.add_argument("--recursive", action="store_true",
                    help="Gộp cả ảnh trong thư mục con (mặc định: chỉ tầng 1).")
    args = ap.parse_args()

    if not os.path.isdir(args.input_dir):
        sys.exit(f"Không thấy folder: {args.input_dir}")

    # Extrude ghi `e` pixel ra ngoài mỗi cạnh sprite. Để 2 sprite cạnh nhau
    # (cách nhau đúng `padding`) không đè viền lên nhau, cần padding >= 2*extrude.
    if args.extrude > 0:
        need = 2 * args.extrude
        if args.padding < need:
            print(f"… padding {args.padding} < 2*extrude={need}; tự nâng lên {need}.")
            args.padding = need

    out_dir = os.path.dirname(os.path.abspath(args.out)) or "."
    out_base = os.path.basename(args.out)
    # Pattern nhận diện file output đã tạo trước đó: "<base>.<8 hex>.png/.json".
    hashed_re = re.compile(
        rf"^{re.escape(out_base)}\.[0-9a-f]{{8}}\.(?:png|json)$"
    )
    sprites, skipped, has_subdir = load_sprites(
        args.input_dir,
        do_trim=not args.no_trim,
        svg_scale=args.svg_scale,
        svg_size=args.svg_size,
        skip_names={out_base + ".manifest.json"},
        skip_pattern=hashed_re,
        recursive=args.recursive,
    )

    # ----- Đối chiếu input <-> sprite sẽ đóng gói (hiện rõ mọi file bị bỏ qua) -----
    if has_subdir and not args.recursive:
        print("⚠ Input có THƯ MỤC CON — ảnh bên trong đang bị BỎ QUA. "
              "Thêm --recursive nếu muốn gộp luôn.")
    # Chỉ liệt kê file bị bỏ qua "đáng ngờ" (không tính file output atlas của
    # chính lần build trước) để dễ soi icon bị thiếu.
    suspicious = [(r, why) for r, why in skipped if "file output atlas" not in why]
    if suspicious:
        print(f"⚠ Bỏ qua {len(suspicious)} file KHÔNG đóng gói (kiểm tra nếu thiếu icon):")
        for rel, why in suspicious:
            print(f"   - {rel}: {why}")

    if not sprites:
        sys.exit("Folder không có ảnh hợp lệ.")

    placements, atlas_w, atlas_h = pack_rects(
        sprites, args.padding, args.max_size, pot=not args.no_pot
    )

    atlas = Image.new("RGBA", (atlas_w, atlas_h), (0, 0, 0, 0))
    frames = {}
    e = args.extrude
    # Dịch toàn bộ sprite vào trong `e` px để sprite ở mép trên/trái cũng còn chỗ
    # extrude (mép phải/dưới đã dư >= padding >= 2e nên không tràn atlas).
    off = e if e > 0 else 0
    for s, px_, py_ in placements:
        x, y = px_ + off, py_ + off
        img = s["image"]
        iw, ih = img.width, img.height
        atlas.paste(img, (x, y))
        # extrude: nhân viền (đủ 4 cạnh + 4 góc) chống bleeding khi scale/filter
        if e > 0:
            left_col = img.crop((0, 0, 1, ih))
            right_col = img.crop((iw - 1, 0, iw, ih))
            top_row = img.crop((0, 0, iw, 1))
            bot_row = img.crop((0, ih - 1, iw, ih))
            tl = img.crop((0, 0, 1, 1))
            tr = img.crop((iw - 1, 0, iw, 1))
            bl = img.crop((0, ih - 1, 1, ih))
            br = img.crop((iw - 1, ih - 1, iw, ih))
            for i in range(1, e + 1):
                atlas.paste(left_col, (x - i, y))
                atlas.paste(right_col, (x + iw - 1 + i, y))
                atlas.paste(top_row, (x, y - i))
                atlas.paste(bot_row, (x, y + ih - 1 + i))
            for i in range(1, e + 1):
                for j in range(1, e + 1):
                    atlas.paste(tl, (x - i, y - j))
                    atlas.paste(tr, (x + iw - 1 + i, y - j))
                    atlas.paste(bl, (x - i, y + ih - 1 + j))
                    atlas.paste(br, (x + iw - 1 + i, y + ih - 1 + j))
        frame = {
            "frame": {"x": x, "y": y, "w": s["w"], "h": s["h"]},
            "rotated": False,
            "trimmed": (s["w"] != s["source_w"] or s["h"] != s["source_h"]),
            "spriteSourceSize": {
                "x": s["offset_x"], "y": s["offset_y"],
                "w": s["w"], "h": s["h"],
            },
            "sourceSize": {"w": s["source_w"], "h": s["source_h"]},
            # Hệ số phóng pixel/logical (SVG pack với --svg-scale). Runtime chia
            # các kích thước cho scale để intrinsic khớp design gốc. =1 cho bitmap.
            "scale": round(s["scale"], 6),
        }
        # 9-slice: biên co giãn (+ padding nội dung) cho Canvas.drawImageNine.
        if s.get("scale9"):
            frame["scale9"] = s["scale9"]
        if s.get("padding9"):
            frame["padding"] = s["padding9"]
        frames[s["name"]] = frame

    # Lưới an toàn: số frame trong JSON PHẢI bằng số sprite đã pack. Lệch nghĩa là
    # có tên bị đè (đáng lẽ đã chặn ở load_sprites) -> dừng, không xuất atlas sai.
    if len(frames) != len(placements):
        names = [s["name"] for s, _, _ in placements]
        dups = sorted({n for n in names if names.count(n) > 1})
        sys.exit(f"LỖI: {len(placements)} sprite nhưng JSON chỉ có {len(frames)} "
                 f"frame (trùng tên: {dups}). Atlas KHÔNG khớp input.")

    os.makedirs(out_dir, exist_ok=True)

    # version = hash nội dung PNG (8 hex). Dùng LÀM TÊN FILE: atlas đổi -> tên
    # .png/.json đổi -> CDN/trình duyệt luôn coi là file mới (không cache nhầm
    # bản cũ); atlas không đổi -> tên giữ nguyên -> cache hit. PNG & JSON luôn
    # đồng bộ vì dùng chung hash.
    buf = io.BytesIO()
    atlas.save(buf, format="PNG", optimize=True)
    png_bytes = buf.getvalue()
    version = hashlib.sha1(png_bytes).hexdigest()[:8]

    png_name = f"{out_base}.{version}.png"
    json_name = f"{out_base}.{version}.json"
    manifest_name = f"{out_base}.manifest.json"
    out_png = os.path.join(out_dir, png_name)
    out_json = os.path.join(out_dir, json_name)
    out_manifest = os.path.join(out_dir, manifest_name)

    with open(out_png, "wb") as f:
        f.write(png_bytes)

    meta = {
        "frames": frames,
        "meta": {
            "app": "pack_atlas.py",
            "image": png_name,          # JSON trỏ tới đúng PNG hash hiện tại
            "format": "RGBA8888",
            "size": {"w": atlas_w, "h": atlas_h},
            "scale": "1",
            "version": version,
        },
    }
    with open(out_json, "w", encoding="utf-8") as f:
        json.dump(meta, f, ensure_ascii=False, indent=2)

    # Manifest: tên CỐ ĐỊNH, trỏ tới cặp .png/.json hiện tại. Client load file
    # này (kèm ?v=<version> hoặc no-cache) rồi tải image/data theo tên trong đây.
    manifest = {
        "version": version,
        "image": png_name,
        "data": json_name,
        "size": {"w": atlas_w, "h": atlas_h},
    }
    with open(out_manifest, "w", encoding="utf-8") as f:
        json.dump(manifest, f, ensure_ascii=False, indent=2)

    # Dọn các cặp hash cũ (mặc định) để folder/server không phình theo mỗi lần build.
    if not args.keep_old:
        for fname in os.listdir(out_dir):
            if hashed_re.match(fname) and fname not in (png_name, json_name):
                try:
                    os.remove(os.path.join(out_dir, fname))
                    print(f"… xoá bản cũ '{fname}'")
                except OSError:
                    pass

    used_area = sum(s["w"] * s["h"] for s, _, _ in placements)
    eff = used_area / (atlas_w * atlas_h) * 100 if atlas_w and atlas_h else 0
    n_skip = len([1 for r, why in skipped if "file output atlas" not in why])
    print(f"✓ {len(frames)} sprite -> {out_png} ({atlas_w}x{atlas_h}, dùng {eff:.0f}%)")
    print(f"✓ metadata -> {out_json}")
    print(f"✓ manifest -> {out_manifest}  (version={version})")
    print(f"✓ đối chiếu: {len(frames)} frame trong JSON khớp {len(placements)} ảnh "
          f"đã pack ({n_skip} file bị bỏ qua).")


if __name__ == "__main__":
    main()
