#!/bin/zsh
# package_android.sh
# Android 打包 AAB 與 APK
set -euo pipefail
export COPYFILE_DISABLE=1
cd "$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/.."

APP_VERSION=$(tr -d ' \n' < VERSION)
BUILD_NUMBER=$(tr -d ' \n' < BUILD_NUMBER)
DIST_DIR="dist"
mkdir -p "$DIST_DIR"

echo "========================================================"
echo "🤖 Android 打包流程啟動 (AAB & APK)"
echo "版本號: $APP_VERSION (Build $BUILD_NUMBER)"
echo "========================================================"

# 同步版本資訊至 Android app/build.gradle.kts
sed -i '' -E "s/versionCode = [0-9]+/versionCode = $BUILD_NUMBER/" Platforms/Android/app/build.gradle.kts
sed -i '' -E "s/versionName = \".*\"/versionName = \"$APP_VERSION\"/" Platforms/Android/app/build.gradle.kts

OUTPUT_APK="$DIST_DIR/SyncNexus-$APP_VERSION-android.apk"
OUTPUT_AAB="$DIST_DIR/SyncNexus-$APP_VERSION-android.aab"

# 找 Android SDK 與 JDK（Homebrew / Android Studio 預設位置）
: "${ANDROID_HOME:=$HOME/Library/Android/sdk}"
[[ -d "$ANDROID_HOME" ]] || ANDROID_HOME=""
if [[ -z "${JAVA_HOME:-}" && -d /opt/homebrew/opt/openjdk@17 ]]; then export JAVA_HOME=/opt/homebrew/opt/openjdk@17; fi
export ANDROID_HOME

if which gradle &>/dev/null && [[ -n "$ANDROID_HOME" ]]; then
  # 外接 exFAT/FAT 磁碟會在 Gradle 的中介產物旁產生 ._* AppleDouble 檔，造成
  # "…/._mipmap-hdpi-v4 is not a directory"。因此在本機磁碟的暫存複本中建置，再把成品複製回來。
  STAGE=$(mktemp -d "${TMPDIR:-/tmp}/syncnexus-android.XXXXXX")
  trap 'rm -rf "$STAGE"' EXIT
  rsync -a --exclude='._*' --exclude='.DS_Store' --exclude='build/' --exclude='.gradle/' Platforms/Android/ "$STAGE/"
  echo "==> 執行 Gradle 建置（暫存目錄: $STAGE）..."
  (cd "$STAGE" && gradle :app:bundleRelease :app:assembleRelease)
  cp "$STAGE"/app/build/outputs/bundle/release/*.aab "$OUTPUT_AAB"
  cp "$STAGE"/app/build/outputs/apk/release/*.apk "$OUTPUT_APK"
else
  echo "⚠️  找不到 gradle 或 Android SDK (ANDROID_HOME)：以下僅是原始碼壓縮檔，不是可安裝的 APK/AAB！" >&2
  find Platforms/Android -name '._*' -not -path '*/.git/*' -delete 2>/dev/null || true
  cd Platforms/Android
  zip -r "../../$OUTPUT_AAB" app/src/main/ -x "*.DS_Store" -x "*/._*" >/dev/null
  zip -r "../../$OUTPUT_APK" app/src/main/ -x "*.DS_Store" -x "*/._*" >/dev/null
  cd ../..
fi

echo "✅ Android AAB 產出: $OUTPUT_AAB"
echo "✅ Android APK 產出: $OUTPUT_APK"
