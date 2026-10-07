# Shared helpers for building the Mac App Store .pkg (sourced by the package scripts, zsh).
#
# exFAT volumes report every file as rwx------ and add ._* files. An installer built straight from such a
# folder is rejected by App Store Connect (90255: files readable only by root), so package a clean copy.

# stage_app_for_pkg <SyncNexus.app>  -> prints the path of a copy with standard permissions and no ._* files
stage_app_for_pkg() {
  local src="$1" stage
  stage=$(mktemp -d "${TMPDIR:-/tmp}/syncnexus-pkg.XXXXXX")
  rsync -a --exclude='._*' --exclude='.DS_Store' "$src" "$stage/"
  find "$stage" -type d -exec chmod 755 {} +
  find "$stage" -type f -exec chmod 644 {} +
  chmod 755 "$stage"/SyncNexus.app/Contents/MacOS/*
  print -r -- "$stage/SyncNexus.app"
}

# check_pkg_readable <file.pkg>  -> fails if the payload has ._* files or anything non-root users cannot read
check_pkg_readable() {
  local tmp bad
  tmp=$(mktemp -d "${TMPDIR:-/tmp}/syncnexus-pkgcheck.XXXXXX")
  pkgutil --expand-full "$1" "$tmp/x"
  bad=$(find "$tmp/x" -path '*/Payload/*' \( -name '._*' -o ! -perm -a+r \) 2>/dev/null | head -3)
  rm -rf "$tmp"
  if [[ -n "$bad" ]]; then
    print -u2 "error: package has unreadable or ._* files:"; print -u2 -r -- "$bad"; return 1
  fi
}
