#!/bin/sh
# exFAT volumes make macOS write AppleDouble "._*" files next to everything, including inside .git,
# where git then chokes on them (e.g. "non-monotonic index .git/objects/pack/._pack-*.idx"). Remove them.
gitdir=$(git rev-parse --git-dir 2>/dev/null) || exit 0
find "$gitdir" -name '._*' -type f -delete 2>/dev/null
exit 0
