#!/usr/bin/env bash
#
# Build release + upload source maps / debug symbols lên Sentry self-hosted.
#
# Yêu cầu ENV:
#   SENTRY_AUTH_TOKEN  Auth token (BÍ MẬT, không commit). Lấy từ devops/BE.
#
# org + url đã cấu hình trong pubspec.yaml (mục `sentry:`). Project được set
# tự động theo target bên dưới (web → ss-web, native → ss-mobile).
#
# Cách dùng:
#   SENTRY_AUTH_TOKEN=xxx ./scripts/sentry_release.sh web      [--dart-define=APP_ENV=prod ...]
#   SENTRY_AUTH_TOKEN=xxx ./scripts/sentry_release.sh android  [...]
#   SENTRY_AUTH_TOKEN=xxx ./scripts/sentry_release.sh ios      [...]
#
set -euo pipefail

TARGET="${1:-}"
shift || true
EXTRA_ARGS=("$@") # ví dụ: --dart-define=APP_ENV=prod

if [[ -z "${SENTRY_AUTH_TOKEN:-}" ]]; then
  echo "❌ Thiếu SENTRY_AUTH_TOKEN (export hoặc đặt trước lệnh)." >&2
  exit 1
fi

SYMBOLS_DIR="build/debug-info"

# Mỗi target chỉ upload đúng loại artifact của nó (tránh upload nhầm chéo
# project khi build/web hoặc build/debug-info cũ còn sót lại).
case "$TARGET" in
  web)
    export SENTRY_PROJECT="ss-web"
    echo "▶ Build web (release, có source maps)…"
    flutter build web --release --source-maps "${EXTRA_ARGS[@]}"
    UPLOAD_ARGS=(--sentry-define=upload_debug_symbols=false)
    ;;
  android)
    export SENTRY_PROJECT="ss-mobile"
    echo "▶ Build Android appbundle (release, obfuscate + split-debug-info)…"
    flutter build appbundle --release \
      --obfuscate --split-debug-info="$SYMBOLS_DIR" "${EXTRA_ARGS[@]}"
    UPLOAD_ARGS=(--sentry-define=upload_source_maps=false)
    ;;
  ios)
    export SENTRY_PROJECT="ss-mobile"
    echo "▶ Build iOS (release, obfuscate + split-debug-info)…"
    flutter build ipa --release \
      --obfuscate --split-debug-info="$SYMBOLS_DIR" "${EXTRA_ARGS[@]}"
    UPLOAD_ARGS=(--sentry-define=upload_source_maps=false)
    ;;
  *)
    echo "❌ Target không hợp lệ: '$TARGET' (cần: web | android | ios)" >&2
    exit 1
    ;;
esac

echo "▶ Upload symbol/source-map lên Sentry (project=$SENTRY_PROJECT)…"
dart run sentry_dart_plugin "${UPLOAD_ARGS[@]}"

echo "✅ Xong: $TARGET → project $SENTRY_PROJECT"
