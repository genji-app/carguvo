#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Load biến môi trường từ file .env ở root repo (nếu có).

Giữ nhẹ, không cần pip `python-dotenv`:
- parse dòng KEY=VALUE, bỏ comment sau #, strip quote.
- KHÔNG ghi đè biến đã có sẵn trong os.environ (ENV thật > .env file).
- Im lặng khi thiếu file (CI chỉ set ENV, không có .env vẫn chạy).
"""
from __future__ import annotations
import os
from pathlib import Path


def load_dotenv(dotenv_path: str | Path | None = None) -> str | None:
    if dotenv_path is None:
        dotenv_path = Path(__file__).resolve().parent.parent / ".env"
    p = Path(dotenv_path)
    if not p.is_file():
        return None
    for raw in p.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, val = line.split("=", 1)
        key = key.strip()
        val = val.strip()
        # bỏ comment cuối dòng chưa nằm trong quote:  KEY=val # comment
        if len(val) >= 2 and val[0] == val[-1] and val[0] in ("'", '"'):
            val = val[1:-1]
        else:
            val = val.split(" #", 1)[0].strip()
        if key and key not in os.environ:
            os.environ[key] = val
    return str(p)
