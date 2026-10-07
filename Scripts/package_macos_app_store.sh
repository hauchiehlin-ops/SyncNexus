#!/bin/zsh
# package_macos_app_store.sh
# macOS App Store 打包（建置、嵌入 profile、簽名、產出供 Transporter 上傳的 .pkg）
set -euo pipefail
export COPYFILE_DISABLE=1
cd "$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/.."

if [[ "${1:-}" == "--upload" ]]; then
  print -u2 "錯誤：macOS 套件不再由此腳本直接上傳。"
  print -u2 "請先執行不帶參數的打包指令，再使用 Apple Transporter 傳送產出的 .pkg。"
  exit 2
fi

APP_VERSION=$(tr -d ' \n' < VERSION)
BUILD_NUMBER=$(tr -d ' \n' < BUILD_NUMBER)
APP_BUNDLE_ID="${APP_BUNDLE_ID:-com.syncnexus.app}"
TEAM_ID="${TEAM_ID:-6UJ8GS752W}"

echo "========================================================"
echo "📦 macOS App Store 打包流程啟動"
echo "應用程式: $APP_BUNDLE_ID"
echo "版本號: $APP_VERSION (Build $BUILD_NUMBER)"
echo "Team ID: $TEAM_ID"
echo "========================================================"

# 1. 建置並簽署 App Store 應用程式
echo "==> [1/3] 建置 macOS App Store 應用程式..."
TEAM_ID="$TEAM_ID" APP_BUNDLE_ID="$APP_BUNDLE_ID" ./Scripts/build-app.sh --app-store

# 2. 打包生成 App Store 安裝套件 (.pkg)
PKG="build/SyncNexus-$APP_VERSION-b$BUILD_NUMBER.pkg"
echo "==> [2/3] 打包生成 App Store 提交包: $PKG"
rm -f "$PKG"

INSTALLER_IDENTITY=$(security find-identity -v -p basic | grep -E "3rd Party Mac Developer Installer|Mac Installer Distribution" | head -n 1 | sed -E 's/.*"([^"]+)".*/\1/' || true)

if [[ -n "$INSTALLER_IDENTITY" ]]; then
  echo "使用認證證書簽署: $INSTALLER_IDENTITY"
  productbuild --component build/SyncNexus.app /Applications --sign "$INSTALLER_IDENTITY" "$PKG"
  xattr -c "$PKG" 2>/dev/null || true
else
  print -u2 "錯誤：找不到 '3rd Party Mac Developer Installer' 或 'Mac Installer Distribution' 憑證"
  exit 1
fi

# 3. 本機完整性驗證；App Store Connect 的伺服器端驗證由 Transporter 執行。
echo "==> [3/3] 驗證 App、Provisioning Profile 與安裝套件簽章..."
[[ -f build/SyncNexus.app/Contents/embedded.provisionprofile ]] || {
  print -u2 "錯誤：App 缺少 embedded.provisionprofile"
  exit 1
}
codesign --verify --deep --strict build/SyncNexus.app
pkgutil --check-signature "$PKG"

echo "========================================================"
echo "✅ macOS App Store 套件已就緒: $PKG"
echo "下一步：開啟 Apple Transporter，將此 .pkg 拖入後按『傳送』。"
echo "本腳本不讀取 Apple ID 或 App 專用密碼，也不直接上傳。"
echo "========================================================"
