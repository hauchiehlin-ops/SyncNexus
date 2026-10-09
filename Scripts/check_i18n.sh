#!/bin/zsh
# check_i18n.sh
# 檢查雙平台 6 國語言覆蓋率與版本號一致性
set -euo pipefail
cd "$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/.."

echo "==> [i18n & Version Check] 檢查版本一致性..."
APP_VERSION=$(tr -d ' \n' < VERSION)
BUILD_NUMBER=$(tr -d ' \n' < BUILD_NUMBER)
PLIST_VER=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" Scripts/Info.plist 2>/dev/null || echo "$APP_VERSION")
PLIST_BUILD=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" Scripts/Info.plist 2>/dev/null || echo "$BUILD_NUMBER")

if [[ "$APP_VERSION" != "$PLIST_VER" || "$BUILD_NUMBER" != "$PLIST_BUILD" ]]; then
  echo "⚠️ 版本號不同步，自動執行同步更新..."
  ./Scripts/bump-version.sh --sync
fi

echo "✅ 核心版本確認: $APP_VERSION (Build $BUILD_NUMBER)"

echo "==> [i18n Check] 檢查 Android 多國語系 (6 國語言)..."
REQUIRED_ANDROID_LANGS=("values" "values-zh-rTW" "values-zh-rCN" "values-ja" "values-th" "values-ko")
for lang in "${REQUIRED_ANDROID_LANGS[@]}"; do
  STR_FILE="Platforms/Android/app/src/main/res/$lang/strings.xml"
  if [[ ! -f "$STR_FILE" ]]; then
    echo "❌ 缺少 Android 語系檔: $STR_FILE" >&2
    exit 1
  fi
done
echo "✅ Android 6 國語言完整覆蓋！"

echo "==> [i18n Check] 檢查說明文件與隱私權政策 (6 國語言)..."
DOC_LANGS=("en" "zh-Hant" "zh-Hans" "ja" "th" "ko")
for l in "${DOC_LANGS[@]}"; do
  [[ -f "packaging/appstore/manual/MANUAL_$l.md" ]] || { echo "❌ 缺少 macOS 手冊: $l" >&2; exit 1; }
  [[ -f "packaging/appstore/privacy/PRIVACY_POLICY_$l.md" ]] || { echo "❌ 缺少 macOS 隱私權政策: $l" >&2; exit 1; }
  [[ -f "packaging/googleplay/manual/MANUAL_$l.md" ]] || { echo "❌ 缺少 Android 手冊: $l" >&2; exit 1; }
  [[ -f "packaging/googleplay/privacy/PRIVACY_POLICY_$l.md" ]] || { echo "❌ 缺少 Android 隱私權政策: $l" >&2; exit 1; }
done
echo "✅ 雙平台獨立文件 6 國語言完整齊備！"

echo "==> [i18n Check] 檢查各平台 docs/ 手冊與隱私權政策 (Apple / Android / Windows × 6 國語言)..."
for p in apple android windows; do
  for l in "${DOC_LANGS[@]}"; do
    [[ -f "docs/manual/$p/MANUAL_${p}_$l.md" ]] || { echo "❌ 缺少 $p 手冊 (docs/manual/$p): $l" >&2; exit 1; }
    [[ -f "docs/privacy/$p/PRIVACY_${p}_$l.md" ]] || { echo "❌ 缺少 $p 隱私權政策 (docs/privacy/$p): $l" >&2; exit 1; }
  done
done
echo "✅ docs/ 三平台手冊與隱私權政策 6 國語言完整齊備！"

echo "==> [i18n Check] 檢查 docs/MANUAL.md 與 docs/PRIVACY_POLICY.md 索引連結..."
for idx in docs/MANUAL.md docs/PRIVACY_POLICY.md; do
  # 每個平台區塊的 6 個連結必須指向 6 個不同的檔案
  for p in apple android windows; do
    n=$(grep -o "/$p/[A-Za-z_]*_$p""_[A-Za-z-]*\.md" "$idx" | sort -u | wc -l | tr -d ' ')
    [[ "$n" == "6" ]] || { echo "❌ $idx 的 $p 區塊只有 $n 個不同語系連結 (應為 6)" >&2; exit 1; }
  done
done
echo "✅ 索引連結皆指向各自語系！"

echo "==> [i18n Check] 檢查 Apple 手冊截圖 (每個語系各一套 UI 截圖)..."
SHOTS=(01_overview 02_diff_preview 02_diff_preview_toast 03_folders_endpoints 03_folders_offline_marker 04_activity 04_conflicts 05_versions 06_verification 07_settings)
for l in "${DOC_LANGS[@]}"; do
  for s in "${SHOTS[@]}"; do
    [[ -f "docs/manual/assets/$l/$s.png" ]] || { echo "❌ 缺少截圖 docs/manual/assets/$l/$s.png" >&2; exit 1; }
    [[ -f "Resources/ManualAssets/$l/$s.png" ]] || { echo "❌ 缺少 App 內截圖 Resources/ManualAssets/$l/$s.png" >&2; exit 1; }
  done
  # 手冊必須引用自己語系的截圖（07_settings_permissions 為系統設定畫面，所有語系共用）
  bad=$(grep -o '(\.\./assets/[^)]*\.png)' "docs/manual/apple/MANUAL_apple_$l.md" | grep -v "assets/$l/" | grep -v "07_settings_permissions" || true)
  [[ -z "$bad" ]] || { echo "❌ MANUAL_apple_$l.md 引用了其他語系的截圖: $bad" >&2; exit 1; }
done
echo "✅ 6 語系截圖齊備，且手冊皆引用對應語系！"
