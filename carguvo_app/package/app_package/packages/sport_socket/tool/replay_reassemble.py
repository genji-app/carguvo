#!/usr/bin/env python3
"""P2.8 replay-capture: lắp chunk RCAP|frameId|chunkIdx|<chunk> thành jsonl.

iOS print truncate ~1000 ký tự/dòng nên capture phải chunk <720/dòng
(xem _replayCapture trong payload_router.dart — patch tạm khi capture).
Script này gom chunk theo frameId, ghép theo chunkIdx, validate JSON,
ghi mỗi frame 1 dòng ra fixture.

Usage:
    python3 tool/replay_reassemble.py /tmp/replay_raw.log \
        test/fixtures/socket_frames_real.jsonl
"""
import json
import re
import sys

if len(sys.argv) != 3:
    sys.exit(__doc__)

src, dst = sys.argv[1], sys.argv[2]

frames: dict[int, dict[int, str]] = {}
order: list[int] = []
pattern = re.compile(r"RCAP\|(\d+)\|(\d+)\|(.*)$")

with open(src, encoding="utf-8", errors="replace") as f:
    for line in f:
        m = pattern.search(line.rstrip("\n"))
        if not m:
            continue
        fid, idx, chunk = int(m.group(1)), int(m.group(2)), m.group(3)
        if fid not in frames:
            frames[fid] = {}
            order.append(fid)
        frames[fid][idx] = chunk

ok = bad = 0
with open(dst, "w", encoding="utf-8") as out:
    for fid in order:
        parts = frames[fid]
        s = "".join(parts[i] for i in sorted(parts))
        try:
            json.loads(s)
        except ValueError:
            bad += 1  # chunk rớt giữa chừng (app kill sớm) — bỏ frame đó
            continue
        out.write(s + "\n")
        ok += 1

print(f"frames OK: {ok} | bỏ (chunk rớt/JSON hỏng): {bad}")
if ok == 0:
    sys.exit("KHÔNG frame nào hợp lệ — kiểm patch _replayCapture đã chạy chưa")
