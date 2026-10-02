#!/bin/zsh
# release.sh
# 一鍵式通用標準作業程序 (SOP):
# 1. 升版本號與 bundle 號 (patch / minor / major)
# 2. i18n 與版本一致性檢查
# 3. macOS App Store 打包（建置、簽名、驗證；最後由 Transporter 傳送）
# 4. Android 打包 AAB 與 APK
# 5. 建立 chore(release): commit 與 tag
set -euo pipefail
cd "${0:A:h}/.."

MODE="${1:-patch}"

echo "================================================================="
echo "🌟 Sync-Nexus 一鍵式全自動發行 (Release Pipeline) 啟動"
echo "執行模式: $MODE"
echo "================================================================="

case "$MODE" in
  bump)
    BUMP_TYPE="${2:-patch}"
    echo "==> 僅升級版本號 ($BUMP_TYPE)..."
    ./Scripts/bump-version.sh "$BUMP_TYPE"
    ./Scripts/check_i18n.sh
    exit 0
    ;;
  apple)
    echo "==> 僅發行 Apple App Store..."
    ./Scripts/check_i18n.sh
    ./Scripts/package_macos_app_store.sh
    exit 0
    ;;
  android)
    echo "==> 僅發行 Android (AAB & APK)..."
    ./Scripts/check_i18n.sh
    ./Scripts/package_android.sh
    exit 0
    ;;
  patch|minor|major)
    BUMP_TYPE="$MODE"
    ;;
  *)
    echo "用法:" >&2
    echo "  $0 [patch|minor|major]         (完整全自動流程：升版 -> i18n -> Apple -> Android -> Git Tag)" >&2
    echo "  $0 bump [patch|minor|major]   (只升版號與同步)" >&2
    echo "  $0 apple                      (只打包 Apple App Store)" >&2
    echo "  $0 android                    (只打包 Android)" >&2
    exit 1
    ;;
esac

# 步驟 1: 升版本號與 bundle 號
echo "-----------------------------------------------------------------"
echo "▶ 步驟 1/5: 升版本號與 bundle 號 ($BUMP_TYPE)..."
./Scripts/bump-version.sh "$BUMP_TYPE"
NEW_VER=$(tr -d ' \n' < VERSION)
NEW_BUILD=$(tr -d ' \n' < BUILD_NUMBER)

# 步驟 2: i18n 與版本一致性檢查
echo "-----------------------------------------------------------------"
echo "▶ 步驟 2/5: 執行 i18n 多國語系與版本一致性檢查..."
./Scripts/check_i18n.sh

# 步驟 3: macOS App Store 上架打包（全自動歸檔、簽名、驗證、產出 PKG）
echo "-----------------------------------------------------------------"
echo "▶ 步驟 3/5: macOS App Store 上架打包..."
./Scripts/package_macos_app_store.sh

# 步驟 4: Android 打包 AAB 與 APK + 生成跨平台 dist 安裝映像
echo "-----------------------------------------------------------------"
echo "▶ 步驟 4/5: Android 打包 AAB 與 APK (及 DMG)..."
./Scripts/dist.sh

# 步驟 5: 建立 chore(release): commit 與 git tag
echo "-----------------------------------------------------------------"
echo "▶ 步驟 5/5: 建立 Git commit 與 release tag..."
git add -A
COMMIT_MSG="chore(release): v$NEW_VER (build $NEW_BUILD)"
git commit -m "$COMMIT_MSG"
TAG_NAME="v$NEW_VER"
git tag -f -a "$TAG_NAME" -m "Release $TAG_NAME (Build $NEW_BUILD)"

echo "================================================================="
echo "🎉 全流程發布成功！"
echo "版本: $NEW_VER (Build $NEW_BUILD)"
echo "Git Commit: $COMMIT_MSG"
echo "Git Tag: $TAG_NAME"
echo ""
echo "接下來："
echo "  1. 使用 Apple Transporter 傳送 build/SyncNexus-$NEW_VER-b$NEW_BUILD.pkg"
echo "  2. 將 Android AAB 上傳至 Google Play Console（正式上架時）"
echo "  3. 推送 Git commit 與 tag："
echo "  git push && git push --tags"
echo "================================================================="
