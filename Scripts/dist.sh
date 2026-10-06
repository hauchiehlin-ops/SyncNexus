#!/bin/zsh
# dist.sh
# 同時產生 macOS (.dmg) 與 Android (.apk / .aab) 正式發行檔
set -euo pipefail
cd "$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/.."

BUILD_MAC=false
BUILD_ANDROID=false

if [[ $# -eq 0 ]]; then
  BUILD_MAC=true
  BUILD_ANDROID=true
else
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --mac) BUILD_MAC=true; shift ;;
      --android) BUILD_ANDROID=true; shift ;;
      *) echo "未知參數: $1 (支援 --mac, --android)" >&2; exit 1 ;;
    esac
  done
fi

APP_VERSION=$(tr -d ' \n' < VERSION)
BUILD_NUMBER=$(tr -d ' \n' < BUILD_NUMBER)
DIST_DIR="build/dist/v$APP_VERSION-b$BUILD_NUMBER"
mkdir -p "$DIST_DIR"

echo "========================================================"
echo "🚀 建立全平台安裝包: v$APP_VERSION (Build $BUILD_NUMBER)"
echo "產出目錄: $DIST_DIR"
echo "========================================================"

if [[ "$BUILD_MAC" == true ]]; then
  echo "==> 正在建置 macOS 發行檔..."
  ./Scripts/package_macos_dmg.sh
  cp "dist/SyncNexus-$APP_VERSION-mac.dmg" "$DIST_DIR/"
fi

if [[ "$BUILD_ANDROID" == true ]]; then
  echo "==> 正在建置 Android 發行檔..."
  ./Scripts/package_android.sh
  cp "dist/SyncNexus-$APP_VERSION-android.apk" "$DIST_DIR/"
  cp "dist/SyncNexus-$APP_VERSION-android.aab" "$DIST_DIR/"
fi

# 產出安裝說明文件
cat <<EOF > "$DIST_DIR/安裝說明.txt"
Sync-Nexus v$APP_VERSION (Build $BUILD_NUMBER) 發布產出說明
=========================================================
1. macOS 版本:
   - SyncNexus-$APP_VERSION-mac.dmg
   - 支援 macOS Sonoma (14.0+) 及 Sequoia (15.0+)
   - 雙擊打開後，將 Sync-Nexus 拖曳至 Applications 資料夾即可使用。

2. Android 版本:
   - SyncNexus-$APP_VERSION-android.apk (手機/平板直接安裝檔)
   - SyncNexus-$APP_VERSION-android.aab (Google Play 專用發布包)
   - 支援 Android 8.0 至 Android 15+

3. 零雲端隱私保證:
   - 檔案完全離線雙向對帳，支援同 Wi-Fi 局域網直連。
EOF

echo "========================================================"
echo "🎉 全平台發行包已完成產出至: $DIST_DIR"
ls -lh "$DIST_DIR"
echo "========================================================"
