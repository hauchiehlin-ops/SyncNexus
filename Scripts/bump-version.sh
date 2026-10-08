#!/bin/zsh
# Version bump for Sync-Nexus.
#   Scripts/bump-version.sh            patch  (0.1.0 -> 0.1.1)   <- what the commit hook does by default
#   Scripts/bump-version.sh minor      0.1.7 -> 0.2.0
#   Scripts/bump-version.sh major      0.4.2 -> 1.0.0
#   Scripts/bump-version.sh --show     print the current version
#   Scripts/bump-version.sh --sync     only copy VERSION/BUILD_NUMBER into Info.plist, the Homebrew cask and Android build.gradle.kts
# VERSION (x.y.z) is the marketing version; BUILD_NUMBER is an integer that goes up by one on EVERY bump
# (CFBundleVersion, the "bundle number"). Both files are the single source of truth.
set -euo pipefail
cd "$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/.."

CUR=$(tr -d ' \n' < VERSION)
BUILD=$(tr -d ' \n' < BUILD_NUMBER)
[[ $CUR =~ '^[0-9]+\.[0-9]+\.[0-9]+$' && $BUILD =~ '^[0-9]+$' ]] || { echo "VERSION / BUILD_NUMBER 格式不正確：$CUR / $BUILD" >&2; exit 1; }
IFS=. read -r MAJ MIN PAT <<< "$CUR"

KIND=${1:-patch}
case $KIND in
  --show) echo "$CUR (build $BUILD)"; exit 0 ;;
  --sync) NEW=$CUR; NEWBUILD=$BUILD ;;
  patch)  NEW="$MAJ.$MIN.$((PAT + 1))"; NEWBUILD=$((BUILD + 1)) ;;
  minor)  NEW="$MAJ.$((MIN + 1)).0";    NEWBUILD=$((BUILD + 1)) ;;
  major)  NEW="$((MAJ + 1)).0.0";        NEWBUILD=$((BUILD + 1)) ;;
  *) echo "用法：$0 [patch|minor|major|--show|--sync]" >&2; exit 2 ;;
esac

print -r -- "$NEW" > VERSION
print -r -- "$NEWBUILD" > BUILD_NUMBER
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $NEW" -c "Set :CFBundleVersion $NEWBUILD" Scripts/Info.plist
if [[ -f packaging/homebrew/syncnexus.rb ]]; then
  sed -i '' -E "s/^( *version )\".*\"/\1\"$NEW\"/" packaging/homebrew/syncnexus.rb
fi
ANDROID=Platforms/Android/app/build.gradle.kts
if [[ -f $ANDROID ]]; then
  sed -i '' -E "s/^( *versionCode = ).*/\1$NEWBUILD/; s/^( *versionName = ).*/\1\"$NEW\"/" $ANDROID
fi
[[ $KIND == --sync ]] && echo "已同步 $NEW (build $NEWBUILD)" || echo "$CUR (build $BUILD) → $NEW (build $NEWBUILD)"
