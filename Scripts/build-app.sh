#!/bin/zsh
# Build SyncNexus.app (menu bar app) and optionally install it to ~/Applications.
#   Scripts/build-app.sh            build only  -> build/SyncNexus.app
#   Scripts/build-app.sh --install    build, copy to ~/Applications and launch
#   Scripts/build-app.sh --sandbox    build a locally signed sandboxed app
#   Scripts/build-app.sh --app-store  embed a Mac App Store profile and distribution-sign
set -euo pipefail
cd "${0:A:h}/.."
swift build -c release --product SyncNexusApp
APP=build/SyncNexus.app
rm -rf "$APP"; mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$(swift build -c release --show-bin-path)/SyncNexusApp" "$APP/Contents/MacOS/SyncNexus"
cp Scripts/Info.plist "$APP/Contents/Info.plist"
cp Resources/AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"
# Sign with the stable local identity or Apple Developer identity.
SANDBOX_ARGS=()
APP_STORE_BUILD=false
if [[ "${1:-}" == "--app-store" || "${2:-}" == "--app-store" ]]; then
  APP_STORE_BUILD=true
fi
if [[ "${1:-}" == "--sandbox" || "${2:-}" == "--sandbox" || "$APP_STORE_BUILD" == true ]]; then
  SANDBOX_ARGS=(--entitlements packaging/appstore/SyncNexus.entitlements)
fi

APP_SIGN_IDENTITY="${APP_SIGN_IDENTITY:-}"
if [[ "$APP_STORE_BUILD" == true ]]; then
  # Mac App Store/TestFlight requires a distribution provisioning profile inside
  # Contents. Merely signing with an Apple Distribution certificate is not enough.
  PROFILE="${APP_PROVISIONING_PROFILE:-}"
  if [[ -z "$PROFILE" ]]; then
    PROFILE_DIRS=(
      "$PWD"
      "$HOME/Library/Developer/Xcode/UserData/Provisioning Profiles"
      "$HOME/Library/MobileDevice/Provisioning Profiles"
    )
    for profile_dir in "${PROFILE_DIRS[@]}"; do
      for candidate in "$profile_dir"/*.(provisionprofile|mobileprovision)(N); do
        decoded=$(mktemp)
        if ! security cms -D -i "$candidate" > "$decoded" 2>/dev/null; then
          continue
        fi
        platform=$(/usr/libexec/PlistBuddy -c "Print :Platform:0" "$decoded" 2>/dev/null || true)
        application_id=$(/usr/libexec/PlistBuddy -c "Print :Entitlements:com.apple.application-identifier" "$decoded" 2>/dev/null || true)
        expires=$(plutil -extract ExpirationDate raw -o - "$decoded" 2>/dev/null || true)
        if [[ "$platform" == "OSX" && "$application_id" == "${TEAM_ID:-6UJ8GS752W}.com.syncnexus.app" && "$expires" > "$(date -u +%Y-%m-%dT%H:%M:%SZ)" ]]; then
          PROFILE="$candidate"
          break 2
        fi
      done
    done
  fi

  if [[ -z "$PROFILE" || ! -f "$PROFILE" ]]; then
    print -u2 "error: no valid Mac App Store provisioning profile found for com.syncnexus.app"
    print -u2 "Create/download it in Apple Developer Certificates, Identifiers & Profiles,"
    print -u2 "or set APP_PROVISIONING_PROFILE=/absolute/path/to/profile.provisionprofile."
    exit 1
  fi

  decoded=$(mktemp)
  if ! security cms -D -i "$PROFILE" > "$decoded" 2>/dev/null; then
    print -u2 "error: unable to decode provisioning profile '$PROFILE'"
    exit 1
  fi
  platform=$(/usr/libexec/PlistBuddy -c "Print :Platform:0" "$decoded" 2>/dev/null || true)
  application_id=$(/usr/libexec/PlistBuddy -c "Print :Entitlements:com.apple.application-identifier" "$decoded" 2>/dev/null || true)
  expires=$(plutil -extract ExpirationDate raw -o - "$decoded" 2>/dev/null || true)
  if [[ "$platform" != "OSX" ]]; then
    print -u2 "error: provisioning profile platform is '$platform', not 'OSX'"
    exit 1
  fi
  if [[ "$application_id" != "${TEAM_ID:-6UJ8GS752W}.com.syncnexus.app" ]]; then
    print -u2 "error: provisioning profile is for '$application_id', not '${TEAM_ID:-6UJ8GS752W}.com.syncnexus.app'"
    exit 1
  fi
  if [[ -z "$expires" || "$expires" < "$(date -u +%Y-%m-%dT%H:%M:%SZ)" ]]; then
    print -u2 "error: provisioning profile expired at '$expires'"
    exit 1
  fi
  cp "$PROFILE" "$APP/Contents/embedded.provisionprofile"
  echo "==> Embedded provisioning profile: $PROFILE"

  if [[ -z "$APP_SIGN_IDENTITY" ]]; then
    APP_SIGN_IDENTITY=$(security find-identity -v -p codesigning | grep -E 'Apple Distribution|3rd Party Mac Developer Application' | head -n 1 | sed -E 's/.*"([^"]+)".*/\1/' || true)
  fi
  if [[ -z "$APP_SIGN_IDENTITY" ]]; then
    print -u2 "error: no Apple Distribution application-signing identity found"
    exit 1
  fi
elif [[ -z "$APP_SIGN_IDENTITY" ]]; then
  APP_SIGN_IDENTITY=$(security find-identity -v -p codesigning | grep "Apple Distribution" | head -n 1 | sed -E 's/.*"([^"]+)".*/\1/' || true)
fi

if [[ -n "$APP_SIGN_IDENTITY" ]]; then
  echo "==> 使用 Apple Distribution 官方憑證簽署: $APP_SIGN_IDENTITY"
  codesign --force --deep --sign "$APP_SIGN_IDENTITY" "${SANDBOX_ARGS[@]}" --options runtime --identifier com.syncnexus.app "$APP"
else
  Scripts/setup-signing.sh >/dev/null
  KC=~/.syncnexus-signing/signing.keychain-db
  if [[ -f "$KC" && -z "${CI:-}" ]]; then
    security unlock-keychain -p "$(cat ~/.syncnexus-signing/keychain-password)" "$KC" 2>/dev/null || true
    HASH=$(security find-identity -p codesigning "$KC" 2>/dev/null | awk '/SyncNexus Local Signing/ {print $2; exit}' || true)
    if [[ -n "$HASH" ]]; then
      codesign --force --deep --sign "$HASH" "${SANDBOX_ARGS[@]}" --keychain "$KC" --identifier com.syncnexus.app "$APP"
    else
      codesign --force --deep --sign - "${SANDBOX_ARGS[@]}" --identifier com.syncnexus.app "$APP"
    fi
  else
    codesign --force --deep --sign - "${SANDBOX_ARGS[@]}" --identifier com.syncnexus.app "$APP"
  fi
fi
if [[ "$APP_STORE_BUILD" == true && ! -f "$APP/Contents/embedded.provisionprofile" ]]; then
  print -u2 "error: App Store build is missing Contents/embedded.provisionprofile"
  exit 1
fi
# App Store & TestFlight forbid com.apple.quarantine and non-standard extended attributes
xattr -cr "$APP" 2>/dev/null || true
codesign --verify --deep --strict "$APP"
codesign -dr - "$APP" 2>&1 | grep designated || true
echo "built $APP"
if [[ "${1:-}" == "--install" || "${2:-}" == "--install" ]]; then
  mkdir -p ~/Applications
  pkill -x SyncNexus 2>/dev/null || true; sleep 1
  rm -rf ~/Applications/SyncNexus.app; cp -R "$APP" ~/Applications/
  open ~/Applications/SyncNexus.app
  echo "installed ~/Applications/SyncNexus.app"
fi
