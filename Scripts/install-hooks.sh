#!/bin/zsh
# One-time per clone: turn on the version hooks in .githooks/
set -euo pipefail
cd "${0:A:h}/.."
git rev-parse --git-dir >/dev/null 2>&1 || { echo "這裡還不是 git 倉庫，請先 git init（或 clone）後再執行。" >&2; exit 1; }
git config core.hooksPath .githooks
chmod +x .githooks/* Scripts/bump-version.sh
echo "已啟用：commit 前自動提升 patch 版本、push 前檢查版本。目前版本：$(Scripts/bump-version.sh --show)"
