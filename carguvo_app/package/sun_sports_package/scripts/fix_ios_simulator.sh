#!/usr/bin/env bash
# fix_ios_simulator.sh
# Chẩn đoán + sửa lỗi:
#   "Unable to find a destination matching the provided destination specifier: { id:... }"
#   "iOS 26.x is not installed. Please download and install the platform from Xcode > Settings > Components."
#
# Cách dùng:
#   bash scripts/fix_ios_simulator.sh          # chỉ chẩn đoán (an toàn, không đổi gì)
#   bash scripts/fix_ios_simulator.sh --fix    # chẩn đoán + reset simulator + clean pods

set -uo pipefail

FIX=0
[[ "${1:-}" == "--fix" ]] && FIX=1

hr() { printf '\n\033[1;34m==> %s\033[0m\n' "$1"; }
ok() { printf '   \033[0;32m✔\033[0m %s\n' "$1"; }
bad() { printf '   \033[0;31mx\033[0m %s\n' "$1"; }
warn() { printf '   \033[0;33m!\033[0m %s\n' "$1"; }

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT" || exit 1
echo "Project: $PROJECT_ROOT"

# ---------------------------------------------------------------- 1. xcode-select
hr "1. Kiểm tra xcode-select"
DEV_DIR="$(xcode-select -p 2>/dev/null)"
echo "   xcode-select -p = $DEV_DIR"
if [[ "$DEV_DIR" == *"CommandLineTools"* || -z "$DEV_DIR" ]]; then
  bad "Đang trỏ vào CommandLineTools -> xcodebuild KHÔNG thấy simulator nào."
  echo "     Sửa: sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"
  if [[ $FIX -eq 1 ]]; then
    sudo xcode-select -s /Applications/Xcode.app/Contents/Developer && ok "Đã trỏ lại vào Xcode.app"
  fi
else
  ok "Trỏ đúng vào Xcode.app"
fi
xcodebuild -version 2>/dev/null || bad "xcodebuild không chạy được"

# ---------------------------------------------------------------- 2. SDK + runtime
hr "2. SDK iOS và simulator runtime đã cài"
echo "   --- SDKs ---"
xcodebuild -showsdks 2>/dev/null | grep -i "ios" || bad "KHÔNG có SDK iOS nào! -> Xcode > Settings > Components > cài platform iOS"
echo "   --- Runtimes ---"
RUNTIMES="$(xcrun simctl list runtimes 2>/dev/null | grep -i "iOS")"
if [[ -z "$RUNTIMES" ]]; then
  bad "KHÔNG có iOS simulator runtime nào được cài."
  echo "     Đây gần như chắc chắn là nguyên nhân lỗi của bạn."
  echo "     Sửa: mở Xcode > Settings (Cmd+,) > Components > tải 'iOS 26.x' (cả Simulator runtime)."
  echo "     Hoặc CLI:  xcodebuild -downloadPlatform iOS"
  if [[ $FIX -eq 1 ]]; then
    warn "Đang tải platform iOS (có thể mất 10-30 phút, vài GB)..."
    xcodebuild -downloadPlatform iOS
  fi
else
  echo "$RUNTIMES" | sed 's/^/   /'
  if echo "$RUNTIMES" | grep -qi "unavailable\|not available"; then
    bad "Có runtime ở trạng thái 'unavailable' -> cần cài lại từ Xcode > Settings > Components."
  else
    ok "Runtime iOS khả dụng"
  fi
fi

# ---------------------------------------------------------------- 3. simulator devices
hr "3. Danh sách simulator"
xcrun simctl list devices available 2>/dev/null | sed 's/^/   /'
echo
echo "   --- Thiết bị lỗi / không khả dụng ---"
UNAVAIL="$(xcrun simctl list devices 2>/dev/null | grep -i "unavailable" || true)"
if [[ -n "$UNAVAIL" ]]; then
  echo "$UNAVAIL" | sed 's/^/   /'
  bad "Có simulator hỏng. Flutter có thể vẫn đang gửi UDID cũ cho xcodebuild."
else
  ok "Không có simulator hỏng"
fi

# ---------------------------------------------------------------- 4. destination thật của scheme Runner
hr "4. Destination mà scheme Runner chấp nhận"
if [[ -d ios/Runner.xcworkspace ]]; then
  xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner -showdestinations 2>&1 \
    | sed -n '/Available destinations/,/Ineligible destinations/p' | sed 's/^/   /'
else
  bad "Không thấy ios/Runner.xcworkspace"
fi

# ---------------------------------------------------------------- 5. flutter devices
hr "5. flutter devices"
flutter devices 2>/dev/null | sed 's/^/   /'

# ---------------------------------------------------------------- 6. FIX
if [[ $FIX -eq 1 ]]; then
  hr "6. Dọn dẹp & reset"

  echo "   - Tắt Simulator.app + CoreSimulatorService"
  osascript -e 'quit app "Simulator"' 2>/dev/null
  xcrun simctl shutdown all 2>/dev/null
  killall -9 com.apple.CoreSimulator.CoreSimulatorService 2>/dev/null
  ok "Đã reset CoreSimulator"

  echo "   - Xoá simulator hỏng"
  xcrun simctl delete unavailable 2>/dev/null && ok "Đã xoá simulator unavailable"

  echo "   - Xoá DerivedData"
  rm -rf ~/Library/Developer/Xcode/DerivedData/* 2>/dev/null && ok "Đã xoá DerivedData"

  echo "   - flutter clean + pod install"
  flutter clean >/dev/null 2>&1
  rm -rf ios/Pods ios/Podfile.lock ios/.symlinks ios/Flutter/Flutter.framework ios/Flutter/Flutter.podspec
  flutter pub get
  ( cd ios && pod install --repo-update )
  ok "Đã cài lại Pods"

  hr "Xong. Giờ chạy lại:"
  echo "   flutter devices          # lấy UDID mới"
  echo "   flutter run -d <UDID>"
else
  hr "Chạy lại với --fix để tự động dọn dẹp"
  echo "   bash scripts/fix_ios_simulator.sh --fix"
fi
