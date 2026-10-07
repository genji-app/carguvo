#!/usr/bin/env python3
"""G6-2: sinh barrel betting_domain với `export ... show ...` tường minh.

Quét tên khai báo public top-level trong packages/betting_domain/lib/src/*.dart
(class/enum/mixin/extension/typedef/function/const/final), sinh file barrel
mới theo pattern sport_socket: `export 'src/x.dart' show A, B;`.

Dùng kèm vòng lặp prune: `dart analyze` báo `undefined_shown_name` cho mọi
tên KHÔNG phải export thật của file — nhét output analyze vào argv[1] là
script tự bỏ các tên đó khỏi show (analyzer = ground truth, khử cả trường
hợp member class nằm cột 0 do file không dart-format).
"""
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, 'packages', 'betting_domain', 'lib', 'src')
OUT = os.path.join(ROOT, 'packages', 'betting_domain', 'lib', 'betting_domain.dart')
JSON_OUT = '/tmp/bd_exports.json'

KEYWORDS = {
    'if', 'for', 'while', 'switch', 'return', 'catch', 'else', 'do', 'try',
    'new', 'throw', 'set', 'get', 'extends', 'with', 'implements', 'on',
    'as', 'in', 'is', 'void', 'await', 'yield', 'assert', 'late',
}

PATTERNS = [
    r'^(?:abstract\s+|sealed\s+|base\s+|final\s+|interface\s+)*class\s+([A-Za-z_]\w*)',
    r'^enum\s+([A-Za-z_]\w*)',
    r'^mixin\s+([A-Za-z_]\w*)',
    r'^extension\s+([A-Za-z_]\w*)\s+on\s',
    r'^extension type\s+(?:const\s+)?([A-Za-z_]\w*)',
    r'^typedef\s+([A-Za-z_]\w*)\s*=',
    r'^typedef\s+(?:[A-Za-z_][\w<>, ?]*\s+)?([a-z]\w*)\s*\(',
    r'^(?:const|final)\s+[A-Za-z_][\w<>, ?]*?\s+([A-Za-z_]\w*)\s*[=({]',
    r'^(?:[A-Za-z_][\w<>, ?]*\s+)?([a-z]\w*)\s*[<(]',
]

# ── Load extraction (hoặc prune từ output analyze) ──
if os.path.exists(JSON_OUT):
    with open(JSON_OUT) as fh:
        result = json.load(fh)
else:
    result = {fn: [] for fn in sorted(os.listdir(SRC)) if fn.endswith('.dart')}

if len(sys.argv) > 1:  # prune mode: argv[1] = file chứa output `dart analyze`
    flagged = re.findall(
        r"src/([\w.]+)' doesn't export a member with the shown name '(\w+)'",
        open(sys.argv[1], encoding='utf-8').read(),
    )
    for fn, name in flagged:
        if fn in result and name in result[fn]:
            result[fn].remove(name)
    print(f'pruned {len(flagged)} flagged name(s)')

if not os.path.exists(JSON_OUT) or len(sys.argv) > 1:
    pass  # result đã có; lần đầu tiên mới quét regex bên dưới

if not result or all(not v for v in result.values()):
    for fn in sorted(os.listdir(SRC)):
        if not fn.endswith('.dart'):
            continue
        names = set()
        with open(os.path.join(SRC, fn), encoding='utf-8') as fh:
            for line in fh:
                for p in PATTERNS:
                    m = re.match(p, line)
                    if m:
                        n = m.group(1)
                        if not n.startswith('_') and n not in KEYWORDS:
                            names.add(n)
                        break
        result[fn] = sorted(names)
    print('fresh regex scan done')

total = sum(len(v) for v in result.values())
print('files:', len(result), 'symbols:', total)

with open(JSON_OUT, 'w') as fh:
    json.dump(result, fh)

# ── Sinh barrel mới ──
lines = [
    '/// Domain đặt cược DÙNG CHUNG app Flutter + jaspr_web (tách 10/09/2026 —',
    '/// Phase 3 của PACKAGING_PLAN.md: mục 1.2–1.6, 2.1).',
    '///',
    '/// Mọi luật TIỀN/ĐẶT CƯỢC chung nằm ở đây — sửa 1 chỗ, cả 2 nền tảng nhận.',
    '///',
    '/// G6-2: barrel dùng `export ... show ...` TƯỜNG MINH (mẫu sport_socket) —',
    '/// API công khai liệt kê tên một một, khỏi lộ symbol nội bộ qua wildcard.',
    '/// Sinh từ khai báo public của từng file src (script tools/ trong ghi chú',
    '/// kế hoạch); thêm symbol mới phải THÊM VÀO show tương ứng.',
    'library;',
    '',
]


def wrap_export(fn, names):
    """`export 'src/f.dart' show a, b, ...;` — wrap 78 cột, thụt lề 4."""
    head = f"export 'src/{fn}' show"
    one_liner = head + ' ' + ', '.join(names) + ';'
    if len(one_liner) <= 78:
        return [one_liner]
    # Part tự mang dấu phẩy (trừ part cuối mang ';') — pack greedy theo cột.
    parts = [head] + [f'{n},' for n in names[:-1]] + [f'{names[-1]};']
    lines_out = []
    cur = ''
    for p in parts:
        tentative = f'{cur} {p}' if cur else p
        if cur and len(tentative) > 78:
            lines_out.append(cur)
            cur = f'    {p}'
        else:
            cur = tentative
    lines_out.append(cur)
    return lines_out


for fn in sorted(result):
    names = result[fn]
    if not names:
        print(f'⚠️  {fn}: 0 symbol — kiểm tra tay!')
        lines.append(f"export 'src/{fn}';")
        lines.append('')
        continue
    lines.extend(wrap_export(fn, names))
    lines.append('')

with open(OUT, 'w', encoding='utf-8') as fh:
    fh.write('\n'.join(lines) + '\n')
print('written:', OUT)
