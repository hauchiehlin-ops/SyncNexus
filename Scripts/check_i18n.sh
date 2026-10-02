#!/bin/zsh
# check_i18n.sh
# 檢查雙平台 6 國語言覆蓋率與版本號一致性
set -euo pipefail
cd "${0:A:h}/.."

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
