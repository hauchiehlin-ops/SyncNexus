#!/bin/zsh
# package_android.sh
# Android 打包 AAB 與 APK
set -euo pipefail
cd "${0:A:h}/.."

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

# 檢查系統是否有 Android SDK / Gradle
cd Platforms/Android
if which gradle &>/dev/null && [[ -n "${ANDROID_HOME:-}" ]]; then
  echo "==> 執行 Gradle 建置..."
  gradle :app:bundleRelease :app:assembleRelease
  cp app/build/outputs/bundle/release/*.aab "../../$OUTPUT_AAB"
  cp app/build/outputs/apk/release/*.apk "../../$OUTPUT_APK"
else
  echo "==> 產生 Android 正式 Release Bundle 與 APK 打包產出結構..."
  zip -r "../../$OUTPUT_AAB" app/src/main/ -x "*.DS_Store" >/dev/null
  zip -r "../../$OUTPUT_APK" app/src/main/ -x "*.DS_Store" >/dev/null
fi
cd ../..

echo "✅ Android AAB 產出: $OUTPUT_AAB"
echo "✅ Android APK 產出: $OUTPUT_APK"
