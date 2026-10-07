#!/usr/bin/env bash
#
# Purge jsDelivr cache cho toàn bộ config sau khi sửa & push lên GitHub.
#
# Vì sao cần: app đọc config qua jsDelivr (CDN ổn định, tránh lỗi 400 ngẫu
# nhiên của raw.githubusercontent.com). jsDelivr cache file theo branch khá lâu
# (có thể tới ~12h), nên sau khi bạn sửa file config trên GitHub, bản mới KHÔNG
# tự lên ngay. Chạy script này để ép jsDelivr kéo bản mới (mất vài giây).
#
# Dùng:
#   ./scripts/purge_jsdelivr.sh
#
# Lưu ý: phải purge ĐÚNG từng URL đang dùng trong app. Nếu thêm/đổi file config
# trong code (SbConfig / AppEnv), nhớ cập nhật danh sách URLS bên dưới cho khớp.

set -euo pipefail

URLS=(
  # auth config (sappv363) — SbConfig.authConfigUrl
  "https://purge.jsdelivr.net/gh/dev-itto/configs@main/sun/config/sappv363.json"
  # main config — SbConfig.mainConfigUrl
  "https://purge.jsdelivr.net/gh/jamesgreenmango/configs@master/creator_s_prod.json"
  # sportbook config — SbConfig.sbConfigUrl
  "https://purge.jsdelivr.net/gh/Vulcan-dev-25/configs@main/sb_config.json"
  # brand config (prod / staging) — AppEnv.brandConfigUrl
  "https://purge.jsdelivr.net/gh/Vulcan-dev-25/configs@main/s88.json"
  "https://purge.jsdelivr.net/gh/Vulcan-dev-25/configs@main/s88_staging.json"
)

fail=0
for u in "${URLS[@]}"; do
  echo "→ purging: $u"
  if curl -fsS "$u" >/dev/null; then
    echo "  ✓ done"
  else
    echo "  ✗ failed"
    fail=1
  fi
done

if [[ "$fail" -eq 0 ]]; then
  echo "Hoàn tất — jsDelivr sẽ phục vụ bản config mới trong vài giây."
else
  echo "Có URL purge thất bại (xem ✗ ở trên). Thử lại sau ít phút."
  exit 1
fi
