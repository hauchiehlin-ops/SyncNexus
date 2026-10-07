#!/bin/zsh
# Package SyncNexus.app into an App Store submission package (.pkg).
# Usage:
#   Scripts/package-appstore.sh                     (dry run packaging using local sign)
#   Scripts/package-appstore.sh "3rd Party Mac Developer Installer: Your Name (TEAMID)"
set -euo pipefail
export COPYFILE_DISABLE=1
cd "$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/.."

echo "==> Building Mac App Store App..."
Scripts/build-app.sh --app-store

VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" build/SyncNexus.app/Contents/Info.plist)
PKG="build/SyncNexus-$VERSION.pkg"
INSTALLER_SIGNER="${1:-}"

echo "==> Creating installer package for Mac App Store: $PKG"
if [[ -n "$INSTALLER_SIGNER" ]]; then
  productbuild --component build/SyncNexus.app /Applications --sign "$INSTALLER_SIGNER" "$PKG"
else
  productbuild --component build/SyncNexus.app /Applications "$PKG"
  echo "Notice: Unsigned package created for local inspection. To sign for App Store upload, provide your installer certificate identity."
fi

echo "==> Package created: $PKG"
echo "Next step: open Apple Transporter, add \"$PKG\", and click Deliver."
echo "This script does not accept Apple Account credentials or upload directly."
