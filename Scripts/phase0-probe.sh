#!/bin/zsh
# Phase 0 read-only probe: reports what this Mac actually exposes for each endpoint type.
# Changes nothing. Run:  Scripts/phase0-probe.sh [path-to-external-sync-folder]
set -u
echo "== macOS =="; sw_vers -productVersion

echo; echo "== Mounted external volumes (name | fs | UUID | writable) =="
for v in /Volumes/*(N); do
  [[ -L "$v" ]] && continue
  info=$(diskutil info -plist "$v" 2>/dev/null) || continue
  fs=$(print -r -- "$info" | plutil -extract FilesystemType raw -o - - 2>/dev/null)
  uuid=$(print -r -- "$info" | plutil -extract VolumeUUID raw -o - - 2>/dev/null)
  wr=$(print -r -- "$info" | plutil -extract WritableVolume raw -o - - 2>/dev/null)
  echo "$v | ${fs:-?} | ${uuid:-?} | writable=${wr:-?}"
done

echo; echo "== iCloud Drive folder =="
ICLOUD="$HOME/Library/Mobile Documents/com~apple~CloudDocs"
[[ -d "$ICLOUD" ]] && echo "found: $ICLOUD" || echo "not found (iCloud Drive off, or Full Disk Access missing for this terminal)"

echo; echo "== Google Drive for desktop =="
GD=( "$HOME"/Library/CloudStorage/GoogleDrive-*(N) )
(( ${#GD} )) && printf 'found: %s\n' "${GD[@]}" || echo "not found (Drive for desktop not installed / not signed in)"

echo; echo "== Placeholder (dataless) files, first 5 per cloud folder =="
for d in "$ICLOUD" "${GD[@]}"; do
  [[ -d "$d" ]] || continue
  echo "-- $d"
  find "$d" -maxdepth 3 -type f -flags +dataless 2>/dev/null | head -5
  find "$d" -maxdepth 3 -name '.*.icloud' 2>/dev/null | head -5
done

if [[ -n "${1:-}" && -d "$1" ]]; then
  echo; echo "== Endpoint folder: $1 =="
  df -h "$1" | tail -1
  echo "files: $(find "$1" -type f 2>/dev/null | wc -l | tr -d ' ')"
  echo "litter: $(find "$1" \( -name '._*' -o -name '.DS_Store' -o -name 'Thumbs.db' \) 2>/dev/null | wc -l | tr -d ' ')"
  echo "names unsafe for exFAT/Windows (first 10):"
  find "$1" -print 2>/dev/null | grep -E '[<>:"|?*\\]|[ .]$' | head -10
fi
