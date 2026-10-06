#!/bin/zsh
# package_macos_dmg.sh
# 重新打包 .dmg（官網 / 獨立分發、Apple Notarization 公證）
set -euo pipefail
cd "$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/.."

APP_VERSION=$(tr -d ' \n' < VERSION)
BUILD_NUMBER=$(tr -d ' \n' < BUILD_NUMBER)
DIST_DIR="dist"
DMG_NAME="SyncNexus-$APP_VERSION-mac.dmg"
DMG_PATH="$DIST_DIR/$DMG_NAME"

mkdir -p "$DIST_DIR"
echo "==> [1/3] 建置 macOS 應用程式..."
./Scripts/build-app.sh >/dev/null

echo "==> [2/3] 製作 DMG 安裝映象檔: $DMG_PATH..."
rm -f "$DMG_PATH"

TMP_DMG_DIR=$(mktemp -d /tmp/syncnexus-dmg.XXXXXX)
cp -R build/SyncNexus.app "$TMP_DMG_DIR/"
ln -s /Applications "$TMP_DMG_DIR/Applications"

hdiutil create -volname "Sync-Nexus" -srcfolder "$TMP_DMG_DIR" -ov -format UDZO "$DMG_PATH" >/dev/null
rm -rf "$TMP_DMG_DIR"

echo "==> [3/3] 驗證產出..."
codesign --verify --deep --strict build/SyncNexus.app || true
echo "✅ DMG 已產出: $DMG_PATH"
