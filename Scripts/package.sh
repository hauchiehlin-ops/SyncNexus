#!/bin/zsh
# Build the app and produce  build/SyncNexus-<version>.zip  plus the sha256 for the Homebrew cask.
set -euo pipefail
cd "${0:A:h}/.."
Scripts/build-app.sh >/dev/null
VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" build/SyncNexus.app/Contents/Info.plist)
ZIP="build/SyncNexus-$VERSION.zip"
rm -f "$ZIP"
ditto -c -k --keepParent build/SyncNexus.app "$ZIP"
SHA=$(shasum -a 256 "$ZIP" | awk '{print $1}')
echo "built   $ZIP"
echo "version $VERSION"
echo "sha256  $SHA"
echo
echo "Next: upload $ZIP to a GitHub release tagged v$VERSION, then put version/sha256 into packaging/homebrew/syncnexus.rb"
