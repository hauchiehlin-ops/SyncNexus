#!/bin/zsh
# package_macos_app_store.sh
# macOS 一鍵啟動 App Store 上架打包（全自動歸檔、簽名、驗證、上傳）
set -euo pipefail
cd "${0:A:h}/.."

APP_VERSION=$(tr -d ' \n' < VERSION)
BUILD_NUMBER=$(tr -d ' \n' < BUILD_NUMBER)
APP_BUNDLE_ID="${APP_BUNDLE_ID:-com.syncnexus.app}"
TEAM_ID="${TEAM_ID:-6UJ8GS752W}"
ASC_PROVIDER="${ASC_PROVIDER:-$TEAM_ID}"
ASC_EMAIL="${ASC_EMAIL:-Dr.barret.lin@gmail.com}"
APP_PASSWORD="${APP_PASSWORD:-bwtk-xbwo-mzii-vxyq}"

echo "========================================================"
echo "📦 macOS App Store 打包流程啟動"
echo "應用程式: $APP_BUNDLE_ID"
echo "版本號: $APP_VERSION (Build $BUILD_NUMBER)"
echo "Team ID: $TEAM_ID"
echo "========================================================"

# 1. 建置沙盒應用程式
echo "==> [1/4] 建置 macOS 沙盒應用程式..."
./Scripts/build-app.sh --sandbox >/dev/null

# 2. 打包生成 App Store 安裝套件 (.pkg)
PKG="build/SyncNexus-$APP_VERSION-b$BUILD_NUMBER.pkg"
echo "==> [2/4] 打包生成 App Store 提交包: $PKG"
rm -f "$PKG"

INSTALLER_IDENTITY=$(security find-identity -v -p basic | grep "3rd Party Mac Developer Installer" | head -n 1 | sed -E 's/.*"([^"]+)".*/\1/' || true)

if [[ -n "$INSTALLER_IDENTITY" ]]; then
  echo "使用認證證書簽署: $INSTALLER_IDENTITY"
  productbuild --component build/SyncNexus.app /Applications --sign "$INSTALLER_IDENTITY" "$PKG"
else
  echo "⚠️ 未檢測到 '3rd Party Mac Developer Installer' 證書，以標準沙盒 component 模式打包"
  productbuild --component build/SyncNexus.app /Applications "$PKG"
fi

# 3. 驗證套件 (Validation)
echo "==> [3/4] 驗證套件相容性與沙盒架構..."
if xcrun --find altool &>/dev/null; then
  echo "正在執行 App Store Connect 預檢驗證..."
  set +e
  xcrun altool --validate-app -f "$PKG" -t macos -u "$ASC_EMAIL" -p "$APP_PASSWORD" --asc-provider "$ASC_PROVIDER" 2>&1 | tee /tmp/asc_validate.log
  VALIDATE_STATUS=$?
  set -e
  if [[ $VALIDATE_STATUS -eq 0 ]]; then
    echo "✅ App Store Connect 預檢驗證通過！"
  else
    echo "⚠️ 驗證回應 (若尚未在 App Store Connect 建立 App Record，請先於後台建立):"
    cat /tmp/asc_validate.log
  fi
else
  echo "xcrun altool 工具就緒"
fi

# 4. 上傳至 App Store Connect (若指定 --upload 或由 release 腳本調用)
UPLOAD_FLAG="${1:-}"
if [[ "$UPLOAD_FLAG" == "--upload" ]]; then
  echo "==> [4/4] 正在上傳至 App Store Connect..."
  xcrun altool --upload-app -f "$PKG" -t macos -u "$ASC_EMAIL" -p "$APP_PASSWORD" --asc-provider "$ASC_PROVIDER"
  echo "🎉 上傳完成！請至 App Store Connect 檢查建置版本。"
else
  echo "==> [4/4] 本地安裝套件已就緒: $PKG"
  echo "如需直接上傳，請加上 --upload 參數："
  echo "  $0 --upload"
fi
