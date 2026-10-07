#!/bin/bash
# tools/check_package_layers.sh — G6-6 (PACKAGE_LOGIC_IMPROVEMENT_PLAN.md)
#
# Guard 2 chiều cho ranh giới package (nguồn bảng phân loại:
# SHARED_PACKAGES.md — mục "Phân loại package + quy ước tầng"):
#   1. jaspr_web KHÔNG được import package FLUTTER ONLY / FORK (web thuần Dart).
#   2. package PURE KHÔNG được import `package:flutter/*` hay `dart:ui`.
#
# Exit 1 nếu vi phạm (dùng trong CI + pre-push).
set -u

cd "$(dirname "$0")/.." || exit 1
fail=0

# PURE (tầng 0 + tầng trên) — SHARED_PACKAGES.md 16/09/2026
PURE="dart_kit app_env app_format app_i18n game_taxonomy brand_config
notification_domain paygate_domain sport_events sport_notice auth_domain
betting_domain casino_jackpot chat_protocol game_api_client game_foundation
mini_game_countdown_core mini_game_protocol monitoring_domain
provider_game_manager sport_socket transaction_domain"

# FLUTTER ONLY + FORK — cấm với jaspr_web
FLUTTER_ONLY="adaptive_overlay fullscreen_guard game_downloader game_engine
game_launcher game_orientation orientation_guard
floating_draggable_widget flutter_slider_drawer"

# ── Guard 1: jaspr_web không import package Flutter ──
for p in $FLUTTER_ONLY; do
  hits=$(grep -rn "import ['\"]package:$p/" jaspr_web/lib 2>/dev/null || true)
  if [ -n "$hits" ]; then
    echo "❌ [G6-6] jaspr_web KHÔNG được import package Flutter-only '$p':"
    echo "$hits"
    fail=1
  fi
done

# ── Guard 2: package PURE không import flutter/dart:ui ──
for p in $PURE; do
  [ -d "packages/$p/lib" ] || continue
  hits=$(grep -rnE "^import ['\"](package:flutter/|dart:ui)" "packages/$p/lib" 2>/dev/null || true)
  if [ -n "$hits" ]; then
    echo "❌ [G6-6] package PURE '$p' KHÔNG được import flutter/dart:ui:"
    echo "$hits"
    fail=1
  fi
done

if [ "$fail" = "0" ]; then
  echo "✅ [G6-6] layer guard OK: ${FLUTTER_ONLY// /,} không bị web import; ${PURE// /,} không import flutter."
fi
exit $fail
