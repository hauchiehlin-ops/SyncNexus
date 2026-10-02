#!/bin/zsh
# Build SyncNexus.app (menu bar app) and optionally install it to ~/Applications.
#   Scripts/build-app.sh            build only  -> build/SyncNexus.app
#   Scripts/build-app.sh --install  build, copy to ~/Applications and launch
set -euo pipefail
cd "${0:A:h}/.."
swift build -c release --product SyncNexusApp
APP=build/SyncNexus.app
rm -rf "$APP"; mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$(swift build -c release --show-bin-path)/SyncNexusApp" "$APP/Contents/MacOS/SyncNexus"
cp Scripts/Info.plist "$APP/Contents/Info.plist"
cp Resources/AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"
# Sign with the stable local identity or Apple Developer identity
SANDBOX_ARGS=()
if [[ "${1:-}" == "--sandbox" || "${2:-}" == "--sandbox" ]]; then
  SANDBOX_ARGS=(--entitlements packaging/appstore/SyncNexus.entitlements)
fi

Scripts/setup-signing.sh >/dev/null
APP_SIGN_IDENTITY="${APP_SIGN_IDENTITY:-}"
if [[ -z "$APP_SIGN_IDENTITY" ]]; then
  APP_SIGN_IDENTITY=$(security find-identity -v -p codesigning | grep "Apple Distribution" | head -n 1 | sed -E 's/.*"([^"]+)".*/\1/' || true)
fi

if [[ -n "$APP_SIGN_IDENTITY" ]]; then
  echo "==> 使用 Apple Distribution 官方憑證簽署: $APP_SIGN_IDENTITY"
  codesign --force --deep --sign "$APP_SIGN_IDENTITY" "${SANDBOX_ARGS[@]}" --options runtime --identifier com.syncnexus.app "$APP"
else
  KC=~/.syncnexus-signing/signing.keychain-db
  if [[ -f "$KC" ]]; then
    security unlock-keychain -p "$(cat ~/.syncnexus-signing/keychain-password)" "$KC"
    HASH=$(security find-identity -p codesigning "$KC" | awk '/SyncNexus Local Signing/ {print $2; exit}')
    codesign --force --deep --sign "$HASH" "${SANDBOX_ARGS[@]}" --keychain "$KC" --identifier com.syncnexus.app "$APP"
  else
    codesign --force --deep --sign - "${SANDBOX_ARGS[@]}" --identifier com.syncnexus.app "$APP"
  fi
fi
codesign -dr - "$APP" 2>&1 | grep designated || true
echo "built $APP"
if [[ "${1:-}" == "--install" || "${2:-}" == "--install" ]]; then
  mkdir -p ~/Applications
  pkill -x SyncNexus 2>/dev/null || true; sleep 1
  rm -rf ~/Applications/SyncNexus.app; cp -R "$APP" ~/Applications/
  open ~/Applications/SyncNexus.app
  echo "installed ~/Applications/SyncNexus.app"
fi
