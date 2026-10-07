#!/usr/bin/env python3
"""
pack_svg_sprite.py - Gom tat ca SVG trong raw_assets/<bundle>/svg thanh 1 SVG sprite
cho tung bundle, hash noi dung (chi data, khong meta), roi luu vao
assets/<bundle>/packs/<bundle>.<hash>.svg.

Cach dung:
  python3 tools/pack_svg_sprite.py
  python3 tools/pack_svg_sprite.py --raw-assets proj_resources/raw_assets --assets assets
  python3 tools/pack_svg_sprite.py --bundle diamond   # chi pack 1 bundle

Ghi chu:
  - Moi file SVG se tro thanh 1 <symbol> trong sprite.
  - id symbol mac dinh duoc tao tu ten file.
  - Cac id noi bo (gradient/clipPath/...) se duoc prefix theo ten icon
    de tranh xung dot giua nhieu SVG.
"""

from __future__ import annotations

import argparse
import base64
import copy
import hashlib
import io
import os
import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

from PIL import Image

SVG_NS = "http://www.w3.org/2000/svg"
XLINK_NS = "http://www.w3.org/1999/xlink"

ET.register_namespace("", SVG_NS)
ET.register_namespace("xlink", XLINK_NS)

ID_REF_ATTRS = {
    "href",
    f"{{{XLINK_NS}}}href",
    "clip-path",
    "mask",
    "filter",
    "fill",
    "stroke",
    "marker-start",
    "marker-mid",
    "marker-end",
}

# Presentation attrs KE THUA tu <svg> root goc. Phai copy sang <symbol>, neu
# khong nhung path thieu `fill` se inherit mac dinh (den) thay vi gia tri goc
# (vd fill="none") -> path chi-co-stroke bi to den che het noi dung.
INHERITED_PRESENTATION_ATTRS = (
    "fill",
    "stroke",
    "stroke-width",
    "stroke-linecap",
    "stroke-linejoin",
    "stroke-miterlimit",
    "stroke-dasharray",
    "stroke-dashoffset",
    "fill-rule",
    "clip-rule",
    "fill-opacity",
    "stroke-opacity",
    "color",
)

# Element ve vector "that": neu SVG chua bat ky tag nao trong day thi coi la
# vector (van pack vao sprite). Neu KHONG co tag nao trong day ma chi co
# <image> base64 -> do la anh raster deo vo SVG (Figma export) -> convert WebP.
_VECTOR_SHAPE_TAGS = {"path", "circle", "ellipse", "polygon", "polyline", "line", "text"}

# Bat phan base64 tu href dang 'data:image/<subtype>;base64,<data>'.
_DATA_URI_RE = re.compile(r"data:image/[^;,]+;base64,(.*)", re.DOTALL)


def hash_file_content(filepath: str | Path) -> str:
    """MD5 hash noi dung file (chi data, khong include meta nhu mtime)."""
    h = hashlib.md5()
    with open(filepath, "rb") as f:
        for chunk in iter(lambda: f.read(8192), b""):
            h.update(chunk)
    return h.hexdigest()


def local_name(tag: str) -> str:
    if "}" in tag:
        return tag.split("}", 1)[1]
    return tag


def sanitize_symbol_id(name: str) -> str:
    base = re.sub(r"[^A-Za-z0-9_-]+", "-", name.strip().lower())
    base = re.sub(r"-+", "-", base).strip("-")
    if not base:
        return "icon"
    if base[0].isdigit():
        return f"icon-{base}"
    return base


def parse_size(value: str | None) -> float | None:
    if not value:
        return None
    m = re.match(r"\s*([0-9]*\.?[0-9]+)", value)
    if not m:
        return None
    try:
        return float(m.group(1))
    except ValueError:
        return None


def resolve_viewbox(svg_root: ET.Element) -> str:
    vb = svg_root.get("viewBox")
    if vb:
        return vb.strip()

    width = parse_size(svg_root.get("width"))
    height = parse_size(svg_root.get("height"))
    if width and height:
        return f"0 0 {width:g} {height:g}"

    return "0 0 24 24"


def rewrite_id_refs(value: str, id_map: dict[str, str]) -> str:
    if not value:
        return value

    def _url_repl(match: re.Match[str]) -> str:
        old_id = match.group(1)
        return f"url(#{id_map.get(old_id, old_id)})"

    out = re.sub(r"url\(#([^)]+)\)", _url_repl, value)

    if out.startswith("#"):
        old = out[1:]
        return f"#{id_map.get(old, old)}"
    return out


def clone_svg_children_with_prefixed_ids(svg_root: ET.Element, prefix: str) -> list[ET.Element]:
    id_map: dict[str, str] = {}

    # Tao map id cu -> id moi
    for node in svg_root.iter():
        old_id = node.get("id")
        if old_id:
            id_map[old_id] = f"{prefix}-{old_id}"

    children: list[ET.Element] = []
    for child in list(svg_root):
        cloned = copy.deepcopy(child)
        for node in cloned.iter():
            old_id = node.get("id")
            if old_id and old_id in id_map:
                node.set("id", id_map[old_id])

            for attr_name, attr_value in list(node.attrib.items()):
                if attr_name in ID_REF_ATTRS:
                    node.set(attr_name, rewrite_id_refs(attr_value, id_map))
                    continue

                if attr_name == "style":
                    node.set("style", rewrite_id_refs(attr_value, id_map))
                    continue

                # Mot so attr co the chua tham chieu id dang '#id'
                if attr_value and "#" in attr_value:
                    node.set(attr_name, rewrite_id_refs(attr_value, id_map))

        children.append(cloned)
    return children


def flatten_pattern_image_fills(root: ET.Element) -> bool:
    """
    Phang hoa idiom raster-fill cua Figma:
        <rect ... fill="url(#pat)"/>
        <pattern id="pat" patternContentUnits="objectBoundingBox" ...>
            <use xlink:href="#img" transform="scale(...)"/>
        </pattern>
        <image id="img" ... xlink:href="data:image/png;base64,..."/>

    vector_graphics (engine cua flutter_svg) KHONG scale pattern
    objectBoundingBox theo bounding box -> anh render ~1x1 don vi (bé tí).
    Thay moi element to bang pattern nay bang <image> ve truc tiep tai dung
    vi tri/kich thuoc cua no, roi xoa pattern + image nguon (khoi nhan doi
    base64). Tra ve True neu co rewrite.
    """
    xhref = f"{{{XLINK_NS}}}href"

    # Index pattern objectBoundingBox va image theo id.
    obb_patterns: dict[str, ET.Element] = {}
    images: dict[str, ET.Element] = {}
    for el in root.iter():
        ln = local_name(el.tag)
        if ln == "pattern" and el.get("patternContentUnits") == "objectBoundingBox":
            pid = el.get("id")
            if pid:
                obb_patterns[pid] = el
        elif ln == "image":
            iid = el.get("id")
            if iid:
                images[iid] = el

    if not obb_patterns:
        return False

    # pattern id -> (data href cua image nguon, element image nguon).
    pat_data: dict[str, tuple[str, ET.Element]] = {}
    for pid, pat in obb_patterns.items():
        use = next((c for c in pat.iter() if local_name(c.tag) == "use"), None)
        if use is None:
            continue
        ref = (use.get("href") or use.get(xhref) or "").lstrip("#")
        img = images.get(ref)
        if img is None:
            continue
        data = img.get("href") or img.get(xhref)
        if data:
            pat_data[pid] = (data, img)

    if not pat_data:
        return False

    # Map con -> cha de thay the / xoa (ElementTree khong co parent pointer).
    parent_of = {child: parent for parent in root.iter() for child in parent}

    changed = False
    to_remove: list[ET.Element] = []
    for parent in list(root.iter()):
        for child in list(parent):
            fill = (child.get("fill") or "").strip()
            m = re.match(r"url\(#([^)]+)\)", fill)
            if not m or m.group(1) not in pat_data:
                continue
            data, _ = pat_data[m.group(1)]
            # <image> ke thua x/y/width/height cua element goc (thuong la <rect>).
            attrs = {"preserveAspectRatio": "none", xhref: data}
            for geo in ("x", "y", "width", "height"):
                v = child.get(geo)
                if v is not None:
                    attrs[geo] = v
            img_el = ET.Element(f"{{{SVG_NS}}}image", attrs)
            index = list(parent).index(child)
            parent.remove(child)
            parent.insert(index, img_el)
            changed = True

    if not changed:
        return False

    # Xoa pattern + image nguon da inline (khoi phinh base64 gap doi).
    for pid, (_, img) in pat_data.items():
        to_remove.append(obb_patterns[pid])
        to_remove.append(img)
    for el in to_remove:
        parent = parent_of.get(el)
        if parent is not None and el in list(parent):
            parent.remove(el)

    return changed


def svg_is_raster_image(root: ET.Element) -> bool:
    """
    True neu SVG thuc chat chi la 1 anh raster (base64 <image>) chu khong phai
    vector: co it nhat 1 <image> voi href 'data:image...' VA khong co bat ky
    element ve vector nao (path/circle/ellipse/polygon/polyline/line/text).

    Cac SVG kieu nay thuong do Figma export anh bitmap ra dang
    <rect fill="url(#pattern -> <image> base64)"> -> flutter_svg render <image>
    nhung khong on dinh giua cac web renderer (skwasm/canvaskit) -> nen tach ra
    thanh WebP thuong.
    """
    has_data_image = False
    for el in root.iter():
        ln = local_name(el.tag)
        if ln in _VECTOR_SHAPE_TAGS:
            return False
        if ln == "image":
            href = el.get("href") or el.get(f"{{{XLINK_NS}}}href") or ""
            if href.strip().lower().startswith("data:image"):
                has_data_image = True
    return has_data_image


def extract_embedded_raster(root: ET.Element) -> bytes | None:
    """
    Tra ve bytes cua anh data-URI LON NHAT nhung trong SVG (thuong chi co 1),
    hoac None neu khong trich duoc.
    """
    best: bytes | None = None
    best_size = -1
    for el in root.iter():
        if local_name(el.tag) != "image":
            continue
        href = el.get("href") or el.get(f"{{{XLINK_NS}}}href") or ""
        m = _DATA_URI_RE.match(href.strip())
        if not m:
            continue
        try:
            raw = base64.b64decode(m.group(1), validate=False)
        except (ValueError, TypeError):
            continue
        if len(raw) > best_size:
            best_size = len(raw)
            best = raw
    return best


def convert_raster_svgs_to_webp(bundle_raw: Path) -> int:
    """
    Duyet <bundle_raw>/svg/*.svg. File nao thuc chat la anh raster (base64
    <image>, khong phai vector) thi:
      - Trich anh nhung, convert sang WebP -> <bundle_raw>/packs/<stem>.webp
        (anh truc tiep trong packs/ -> pack_webp gop vao atlas <bundle>).
      - XOA file .svg loi do -> khong pack vao sprite tong nua.

    Tra ve so file da convert. Phai chay TRUOC pack_webp (de atlas gom duoc anh
    moi) va TRUOC build_sprite (de sprite chi con vector).
    """
    svg_dir = bundle_raw / "svg"
    if not svg_dir.is_dir():
        return 0

    packs_dir = bundle_raw / "packs"
    converted = 0

    for svg_path in sorted(svg_dir.glob("*.svg")):
        try:
            root = ET.parse(svg_path).getroot()
        except ET.ParseError:
            continue
        if not svg_is_raster_image(root):
            continue

        raw = extract_embedded_raster(root)
        if raw is None:
            print(f"  ! {svg_path.name}: la anh raster nhung khong trich duoc <image> base64 -> giu nguyen")
            continue

        out_webp = packs_dir / f"{svg_path.stem}.webp"
        try:
            with Image.open(io.BytesIO(raw)) as img:
                if img.mode not in ("RGB", "RGBA"):
                    img = img.convert("RGBA")
                packs_dir.mkdir(parents=True, exist_ok=True)
                img.save(out_webp, "WEBP", quality=90, lossless=False)
        except Exception as exc:  # noqa: BLE001 - convert loi thi giu .svg lai
            print(f"  ! {svg_path.name}: convert WebP that bai ({exc}) -> giu nguyen .svg")
            continue

        svg_path.unlink(missing_ok=True)
        converted += 1
        print(f"  ~ raster SVG -> WebP: svg/{svg_path.name} -> packs/{out_webp.name} (da xoa .svg)")

    return converted


def build_sprite(input_dir: Path) -> Path | None:
    """
    Gom cac SVG trong input_dir thanh 1 SVG sprite (tam thoi: <stem>.svg).
    Tra ve duong dan file tam (chua hash). Tra ve None neu khong co SVG.
    """
    if not input_dir.is_dir():
        return None

    svg_files = sorted([p for p in input_dir.rglob("*") if p.is_file() and p.suffix.lower() == ".svg"])
    if not svg_files:
        return None

    sprite_root = ET.Element(
        f"{{{SVG_NS}}}svg",
        {
            "xmlns": SVG_NS,
            "xmlns:xlink": XLINK_NS,
            "style": "display:none",
        },
    )

    used_ids: set[str] = set()
    packed_count = 0

    for svg_path in svg_files:
        symbol_id = sanitize_symbol_id(svg_path.stem)
        original_id = symbol_id
        idx = 2
        while symbol_id in used_ids:
            symbol_id = f"{original_id}-{idx}"
            idx += 1
        used_ids.add(symbol_id)

        try:
            root = ET.parse(svg_path).getroot()
        except ET.ParseError as exc:
            print(f"! Bo qua {svg_path.name}: SVG khong hop le ({exc})")
            continue

        # Phang hoa raster-fill dang pattern objectBoundingBox (Figma) -> <image>
        # truc tiep, neu khong anh se render bé tí trong flutter_svg.
        if flatten_pattern_image_fills(root):
            print(f"  ~ flatten pattern-image: {svg_path.name}")

        view_box = resolve_viewbox(root)
        symbol_attrs = {"id": symbol_id, "viewBox": view_box}
        # Giu lai presentation attrs cua root de symbol tu mo ta duoc default
        # ke thua (quan trong nhat: fill="none").
        for attr in INHERITED_PRESENTATION_ATTRS:
            value = root.get(attr)
            if value is not None:
                symbol_attrs[attr] = value
        symbol = ET.SubElement(sprite_root, f"{{{SVG_NS}}}symbol", symbol_attrs)
        symbol_children = clone_svg_children_with_prefixed_ids(root, symbol_id)
        for node in symbol_children:
            symbol.append(node)

        packed_count += 1

    if packed_count == 0:
        return None

    temp_file = input_dir.parent / f"{input_dir.name}.svg"
    temp_file.parent.mkdir(parents=True, exist_ok=True)
    ET.ElementTree(sprite_root).write(temp_file, encoding="utf-8", xml_declaration=True)

    print(f"  Da pack {packed_count} SVG vao: {temp_file.name}")
    return temp_file


def pack_bundle(bundle_raw: Path, bundle_name: str, assets_dir: Path) -> str | None:
    """
    Pack SVG cua 1 bundle:
      - input : <bundle_raw>/svg/
      - temp  : <bundle_raw>/svg.<name>.svg
      - hash  : <name>.<hash>.svg
      - output: <assets_dir>/<bundle_name>/packs/<name>.<hash>.svg
    Tra ve ten file final hoac None.
    """
    svg_dir = bundle_raw / "svg"
    if not svg_dir.is_dir():
        return None

    # Tach cac SVG that ra la anh raster (base64 <image>) thanh WebP trong
    # packs/ va xoa .svg loi TRUOC khi build sprite -> sprite chi con vector.
    convert_raster_svgs_to_webp(bundle_raw)

    temp_file = build_sprite(svg_dir)
    if temp_file is None:
        return None

    try:
        file_hash = hash_file_content(temp_file)
        short_hash = file_hash[:8]

        out_dir = assets_dir / bundle_name / "packs"
        out_dir.mkdir(parents=True, exist_ok=True)

        final_file = out_dir / f"{bundle_name}.{short_hash}.svg"

        # Xoa cac ban hash cu cung ten bundle (de output luon nhat quan 1 file/bundle)
        for old in out_dir.glob(f"{bundle_name}.*.svg"):
            if old != final_file:
                old.unlink(missing_ok=True)

        if final_file.exists():
            final_file.unlink(missing_ok=True)
        temp_file.rename(final_file)
        print(f"  => {final_file.relative_to(assets_dir)}")
        return final_file.name
    finally:
        if temp_file.exists():
            temp_file.unlink(missing_ok=True)


def main() -> None:
    parser = argparse.ArgumentParser(description="Pack SVG theo tung bundle thanh SVG sprite")
    parser.add_argument("--raw-assets", default="proj_resources/raw_assets", help="Thu muc raw_assets")
    parser.add_argument("--assets", default="proj_resources/assets", help="Thu muc assets output")
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
    for bundle_raw in bundles:
        bundle_name = bundle_raw.name
        print(f"\n📦 Bundle: {bundle_name}")
        result = pack_bundle(bundle_raw, bundle_name, assets_dir)
        if result:
            total += 1

    print(f"\n✅ Da pack SVG cho {total} bundle")


if __name__ == "__main__":
    main()