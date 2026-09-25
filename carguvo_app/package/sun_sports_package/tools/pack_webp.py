from __future__ import annotations

import argparse
import hashlib
import io
import json
import os
import shutil
import sys
from pathlib import Path

from PIL import Image

# Gap giữa các sprite (1px để tránh bleeding khi render)
GAP = 1

# Các max_width thử
MAX_WIDTH_VALUES = [64, 128, 256, 512, 1024, 2048]


class MaxRectsPacker:
    """
    Thuật toán MaxRects (Best Short Side Fit) để tối ưu hóa không gian xếp hình.
    """
    def __init__(self, width: int, height: int, gap: int = 1):
        self.atlas_width = width
        self.atlas_height = height
        self.gap = gap
        # Danh sách các hình chữ nhật trống tự do (ban đầu là toàn bộ canvas)
        self.free_rectangles = [{"x": 0, "y": 0, "w": width, "h": height}]

    def insert(self, width: int, height: int) -> dict | None:
        # Thêm khoảng cách gap vào kích thước cần đặt (trừ khi ở sát biên, nhưng đơn giản hóa bằng cách cộng luôn)
        padded_w = width + self.gap
        padded_h = height + self.gap

        best_short_side_fit = float("inf")
        best_rect_idx = -1
        best_x, best_y = 0, 0

        # Tìm vùng trống vừa vặn nhất theo tiêu chí Best Short Side Fit (BSSF)
        for i, rect in enumerate(self.free_rectangles):
            if rect["w"] >= padded_w and rect["h"] >= padded_h:
                leftover_w = rect["w"] - padded_w
                leftover_h = rect["h"] - padded_h
                short_side_fit = min(leftover_w, leftover_h)

                if short_side_fit < best_short_side_fit:
                    best_short_side_fit = short_side_fit
                    best_rect_idx = i
                    best_x = rect["x"]
                    best_y = rect["y"]

        if best_rect_idx == -1:
            return None  # Không tìm thấy chỗ chứa

        # Khối hình chữ nhật đã được chọn đặt ảnh
        placed_rect = {"x": best_x, "y": best_y, "w": padded_w, "h": padded_h}

        # Chia tách các vùng trống còn lại dựa trên khối vừa đặt
        new_free_rects = []
        for i, rect in enumerate(self.free_rectangles):
            if self.is_overlapping(rect, placed_rect):
                new_free_rects.extend(self.split_rect(rect, placed_rect))
            else:
                new_free_rects.append(rect)

        self.free_rectangles = new_free_rects
        self.prune_free_rectangles()

        # Trả về tọa độ chính xác của sprite (không tính phần gap dư ở rìa phải/dưới)
        return {"x": best_x, "y": best_y, "w": width, "h": height}

    def is_overlapping(self, r1: dict, r2: dict) -> bool:
        return not (
            r1["x"] >= r2["x"] + r2["w"]
            or r1["x"] + r1["w"] <= r2["x"]
            or r1["y"] >= r2["y"] + r2["h"]
            or r1["y"] + r1["h"] <= r2["y"]
        )

    def split_rect(self, free_rect: dict, placed_rect: dict) -> list[dict]:
        sub_rects = []
        # Trục X
        if placed_rect["x"] < free_rect["x"] + free_rect["w"] and placed_rect["x"] + placed_rect["w"] > free_rect["x"]:
            # Thừa phía trên
            if placed_rect["y"] > free_rect["y"] and placed_rect["y"] < free_rect["y"] + free_rect["h"]:
                sub_rects.append({"x": free_rect["x"], "y": free_rect["y"], "w": free_rect["w"], "h": placed_rect["y"] - free_rect["y"]})
            # Thừa phía dưới
            if placed_rect["y"] + placed_rect["h"] < free_rect["y"] + free_rect["h"]:
                sub_rects.append({"x": free_rect["x"], "y": placed_rect["y"] + placed_rect["h"], "w": free_rect["w"], "h": (free_rect["y"] + free_rect["h"]) - (placed_rect["y"] + placed_rect["h"])})
        
        # Trục Y
        if placed_rect["y"] < free_rect["y"] + free_rect["h"] and placed_rect["y"] + placed_rect["h"] > free_rect["y"]:
            # Thừa bên trái
            if placed_rect["x"] > free_rect["x"] and placed_rect["x"] < free_rect["x"] + free_rect["w"]:
                sub_rects.append({"x": free_rect["x"], "y": free_rect["y"], "w": placed_rect["x"] - free_rect["x"], "h": free_rect["h"]})
            # Thừa bên phải
            if placed_rect["x"] + placed_rect["w"] < free_rect["x"] + free_rect["w"]:
                sub_rects.append({"x": placed_rect["x"] + placed_rect["w"], "y": free_rect["y"], "w": (free_rect["x"] + free_rect["w"]) - (placed_rect["x"] + placed_rect["w"]), "h": free_rect["h"]})
        
        return sub_rects

    def prune_free_rectangles(self):
        """ Loại bỏ các vùng trống bị bao trọn hoàn toàn bởi vùng trống khác. """
        i = 0
        while i < len(self.free_rectangles):
            j = i + 1
            while j < len(self.free_rectangles):
                if self.is_contained_in(self.free_rectangles[i], self.free_rectangles[j]):
                    self.free_rectangles.pop(i)
                    i -= 1
                    break
                if self.is_contained_in(self.free_rectangles[j], self.free_rectangles[i]):
                    self.free_rectangles.pop(j)
                    j -= 1
                j += 1
            i += 1

    def is_contained_in(self, r1: dict, r2: dict) -> bool:
        return (
            r1["x"] >= r2["x"]
            and r1["y"] >= r2["y"]
            and r1["x"] + r1["w"] <= r2["x"] + r2["w"]
            and r1["y"] + r1["h"] <= r2["y"] + r2["h"]
        )


def hash_file_content(filepath: str | Path) -> str:
    h = hashlib.md5()
    with open(filepath, "rb") as f:
        for chunk in iter(lambda: f.read(8192), b""):
            h.update(chunk)
    return h.hexdigest()


def maxrects_pack_wrapper(
    images: list[dict], max_width: int, gap: int
) -> tuple[int, int, dict] | None:
    """
    Thử xếp toàn bộ ảnh vào một kích thước max_width cố định bằng MaxRects.
    Vì chưa biết chiều cao tối ưu, ta giả định chiều cao tối đa tạm thời là 4096.
    """
    packer = MaxRectsPacker(max_width, 4096, gap)
    frames = {}
    
    used_w = 0
    used_h = 0

    for img_data in images:
        w = img_data["width"]
        h = img_data["height"]

        if w > max_width:
            return None

        rect = packer.insert(w, h)
        if rect is None:
            return None  # Không đủ chỗ xếp (vượt quá chiều cao giả định hoặc bị phân mảnh)

        frames[img_data["name"]] = {
            "frame": {"x": rect["x"], "y": rect["y"], "w": w, "h": h},
            "rotated": False,
            "trimmed": False,
            "spriteSourceSize": {"x": 0, "y": 0, "w": w, "h": h},
            "sourceSize": {"w": w, "h": h},
        }

        used_w = max(used_w, rect["x"] + w)
        used_h = max(used_h, rect["y"] + h)

    return (used_w, used_h, frames)


def hash_input_files(input_dir: Path) -> str:
    """
    Tinh MD5 hash dua tren NOI DUNG + ten + relative path cua tat ca file
    input (sorted). Dam bao deterministic: cung raw assets -> cung hash,
    khong phu thuoc version Pillow/libwebp.
    """
    h = hashlib.md5()
    for f in sorted(input_dir.rglob("*")):
        if not f.is_file():
            continue
        if f.name in (".DS_Store",):
            continue
        rel = str(f.relative_to(input_dir))
        h.update(rel.encode("utf-8"))
        with open(f, "rb") as fh:
            for chunk in iter(lambda: fh.read(8192), b""):
                h.update(chunk)
    return h.hexdigest()


def pack_webp_to_atlas(
    input_dir: Path,
    output_dir: Path,
    output_name: str,
) -> tuple[str, str] | None:
    image_files = sorted(
        [f for f in os.listdir(input_dir) if f.lower().endswith((".webp", ".png"))]
    )
    if not image_files:
        return None

    # Tinh hash tu INPUT raw assets truoc (khong phu thuoc Pillow/libwebp version)
    file_hash = hash_input_files(input_dir)
    short_hash = file_hash[:8]

    images = []
    for f in image_files:
        img_path = os.path.join(input_dir, f)
        with Image.open(img_path) as img:
            # Nếu là PNG, convert sang WebP ngay trong bộ nhớ
            if f.lower().endswith(".png"):
                webp_buf = io.BytesIO()
                img.save(webp_buf, "WEBP", quality=90, lossless=False)
                webp_buf.seek(0)
                converted = Image.open(webp_buf)
                converted.load()  # force decode
                images.append(
                    {
                        "name": os.path.splitext(f)[0],
                        "image": converted,
                        "width": converted.width,
                        "height": converted.height,
                    }
                )
            else:
                images.append(
                    {
                        "name": os.path.splitext(f)[0],
                        "image": img.copy(),
                        "width": img.width,
                        "height": img.height,
                    }
                )

    # MaxRects hoạt động cực tốt khi xếp các ảnh có AREA (diện tích) lớn trước
    images.sort(key=lambda x: x["width"] * x["height"], reverse=True)

    max_sprite_dim = max(max(img["width"], img["height"]) for img in images)
    min_start = max(64, max_sprite_dim)

    best_result = None
    best_area = float("inf")
    best_mw = 0

    for mw in MAX_WIDTH_VALUES:
        if mw < min_start:
            continue

        # Thay thế bằng hàm mã hóa MaxRects mới
        result = maxrects_pack_wrapper(images, mw, GAP)
        if result is None:
            continue

        used_w, used_h, frames = result
        atlas_w = used_w
        atlas_h = used_h
        area = atlas_w * atlas_h

        # Ưu tiên diện tích Pow2 nhỏ nhất
        if area < best_area:
            best_area = area
            best_result = (atlas_w, atlas_h, frames)
            best_mw = mw

    if best_result is None:
        print(f"  (khong the xep {len(images)} sprite, sprite qua lon hoac can width/height > 2048)")
        return None

    atlas_width, atlas_height, frames_data = best_result

    # Tạo canvas atlas
    atlas_image = Image.new("RGBA", (atlas_width, atlas_height), (0, 0, 0, 0))

    for img_data in images:
        name = img_data["name"]
        box = frames_data[name]["frame"]
        atlas_image.paste(img_data["image"], (box["x"], box["y"]))
        img_data["image"].close()

    # Lưu tạm thời để định danh hash
    temp_webp = output_dir / "temp.webp"
    temp_json = output_dir / "temp.json"
    output_dir.mkdir(parents=True, exist_ok=True)

    atlas_image.save(temp_webp, "WEBP", quality=90, lossless=False)

    meta_data = {
        "frames": frames_data,
        "meta": {
            "app": "Python MaxRects Atlas Packer",
            "version": "2.0",
            "image": temp_webp.name,
            "format": "RGBA8888",
            "size": {"w": atlas_width, "h": atlas_height},
            "scale": "1",
        },
    }

    with open(temp_json, "w", encoding="utf-8") as f:
        json.dump(meta_data, f, indent=4, ensure_ascii=False)

    # Dung short_hash da tinh tu INPUT raw assets (khong phu thuoc Pillow/libwebp version)
    final_webp = output_dir / f"{output_name}.{short_hash}.webp"
    final_json = output_dir / f"{output_name}.{short_hash}.json"

    # Xoa cac ban hash cu cung output_name de output nhat quan 1 cap/file.
    for old in output_dir.glob(f"{output_name}.*.webp"):
        if old != final_webp:
            old.unlink(missing_ok=True)
    for old in output_dir.glob(f"{output_name}.*.json"):
        if old != final_json:
            old.unlink(missing_ok=True)

    # Cap nhat ten image trong meta cho khop voi file webp final.
    meta_data["meta"]["image"] = final_webp.name

    if temp_webp.exists():
        temp_webp.rename(final_webp)
    if temp_json.exists():
        temp_json.rename(final_json)

    print(
        f"  => {final_webp.name} ({atlas_width}x{atlas_height}, "
        f"Chon MaxWidth={best_mw}, {len(images)} sprites)"
    )
    print(f"  => {final_json.name}")

    return (final_webp.name, final_json.name)


def _save_webp_with_content_hash(src_file: Path, out_dir: Path) -> Path | None:
    """
    - Nếu src là .webp: copy bytes sang output.
    - Nếu src là .png: convert sang .webp lossless.
    - Hash theo NỘI DUNG FILE GOC (raw asset), khong phai output WebP bytes,
      de dam bao deterministic giua cac may (khong phu thuoc Pillow/libwebp version).
    """
    ext = src_file.suffix.lower()
    if ext not in {".webp", ".png"}:
        return None

    out_dir.mkdir(parents=True, exist_ok=True)

    stem = src_file.stem
    tmp_out = out_dir / f"{stem}.tmp.webp"

    # Xóa temp cũ nếu có
    if tmp_out.exists():
        tmp_out.unlink()

    if ext == ".webp":
        tmp_out.write_bytes(src_file.read_bytes())
    else:
        with Image.open(src_file) as img:
            img.save(tmp_out, "WEBP", quality=90, lossless=False)

    # Hash tu RAW ASSET goc (khong phu thuoc Pillow/libwebp version)
    short_hash = hash_file_content(src_file)[:8]
    final_out = out_dir / f"{stem}.{short_hash}.webp"

    # Dọn các bản hash cũ cùng stem để output luôn nhất quán 1 file/stem.
    for old_file in out_dir.glob(f"{stem}.*.webp"):
        if old_file != final_out and old_file != tmp_out:
            old_file.unlink(missing_ok=True)

    tmp_out.replace(final_out)
    return final_out


def process_direct_webp_png_folder(input_dir: Path, output_dir: Path) -> int:
    """Xử lý file .webp/.png trực tiếp trong một folder (không recurse)."""
    if not input_dir.is_dir():
        return 0

    processed = 0
    for src_file in sorted(input_dir.iterdir()):
        if not src_file.is_file():
            continue
        if src_file.suffix.lower() not in {".webp", ".png"}:
            continue
        result = _save_webp_with_content_hash(src_file, output_dir)
        if result is not None:
            print(f"  => {result.name}")
            processed += 1

    return processed


def pack_bundle(bundle_raw: Path, bundle_name: str, assets_dir: Path) -> int:
    """
    Pack tat ca anh trong <bundle_raw>/packs/ thanh atlas:
      - Sub-folder <packs>/<sub>  -> assets/<bundle>/packs/<bundle>_<sub>.<hash>.webp + .json
      - Anh truc tiep trong <packs>/ -> assets/<bundle>/packs/<bundle>.<hash>.webp + .json
    Tra ve so atlas da tao.
    """
    packs_dir = bundle_raw / "packs"
    if not packs_dir.is_dir():
        return 0

    out_dir = assets_dir / bundle_name / "packs"
    out_dir.mkdir(parents=True, exist_ok=True)

    count = 0

    # Sub-folders
    for sub in sorted([p for p in packs_dir.iterdir() if p.is_dir() and not p.name.startswith(".")]):
        output_name = f"{bundle_name}_{sub.name}"
        print(f"\n📦 Pack atlas: {bundle_name}/packs/{sub.name}/ -> {output_name}")
        result = pack_webp_to_atlas(sub, out_dir, output_name)
        if result is None:
            print("  (khong co file .webp/.png, bo qua)")
        else:
            count += 1

    # Direct images in packs/ (webp/png files, not in subfolders)
    direct_images = [
        p for p in packs_dir.iterdir()
        if p.is_file() and p.suffix.lower() in {".webp", ".png"} and not p.name.startswith(".")
    ]
    if direct_images:
        # Tao folder tam de pack cac anh truc tiep
        tmp_dir = packs_dir / ".direct_pack"
        tmp_dir.mkdir(parents=True, exist_ok=True)
        try:
            for p in direct_images:
                shutil.copy2(p, tmp_dir / p.name)
            output_name = bundle_name
            print(f"\n📦 Pack atlas: {bundle_name}/packs/ (anh truc tiep) -> {output_name}")
            result = pack_webp_to_atlas(tmp_dir, out_dir, output_name)
            if result is None:
                print("  (khong the pack anh truc tiep, bo qua)")
            else:
                count += 1
        finally:
            shutil.rmtree(tmp_dir, ignore_errors=True)

    return count


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Pack anh trong raw_assets/<bundle>/packs/ thanh texture atlas theo tung bundle"
    )
    parser.add_argument("--raw-assets", default="proj_resources/raw_assets", help="Thu muc raw_assets")
    parser.add_argument("--assets", default="assets", help="Thu muc assets output")
    parser.add_argument("--bundle", default=None, help="Chi pack 1 bundle cu the (ten folder)")
    args = parser.parse_args()

    raw_assets = Path(args.raw_assets)
    assets_dir = Path(args.assets)

    if not raw_assets.is_dir():
        sys.exit(f"Khong tim thay thu muc raw_assets: {raw_assets}")

    if args.bundle:
        bundles = [raw_assets / args.bundle]
    else:
        bundles = sorted([p for p in raw_assets.iterdir() if p.is_dir() and not p.name.startswith(".")])

    total = 0
    bundle_count = 0
    for bundle_raw in bundles:
        bundle_name = bundle_raw.name
        print(f"\n📦 Bundle: {bundle_name}")
        n = pack_bundle(bundle_raw, bundle_name, assets_dir)
        if n > 0:
            bundle_count += 1
            total += n

    print(f"\n✅ Da pack {total} atlas tu {bundle_count} bundle")


if __name__ == "__main__":
    main()
