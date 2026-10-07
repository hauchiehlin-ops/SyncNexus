#!/bin/zsh
# Build the app and produce  build/SyncNexus-<version>.zip  plus the sha256 for the Homebrew cask.
set -euo pipefail
export COPYFILE_DISABLE=1
cd "$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/.."
Scripts/build-app.sh >/dev/null
VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" build/SyncNexus.app/Contents/Info.plist)
ZIP="build/SyncNexus-$VERSION.zip"
rm -f "$ZIP"
# exFAT volumes show AppleDouble (._*) files as real files; zip a clean copy from the local disk instead.
STAGE=$(mktemp -d "${TMPDIR:-/tmp}/syncnexus-zip.XXXXXX")
trap 'rm -rf "$STAGE"' EXIT
rsync -a --exclude='._*' --exclude='.DS_Store' build/SyncNexus.app "$STAGE/"
ditto -c -k --norsrc --noextattr --keepParent "$STAGE/SyncNexus.app" "$ZIP"
SHA=$(shasum -a 256 "$ZIP" | awk '{print $1}')
echo "built   $ZIP"
echo "version $VERSION"
echo "sha256  $SHA"
echo
echo "Next: upload $ZIP to a GitHub release tagged v$VERSION, then put version/sha256 into packaging/homebrew/syncnexus.rb"
