#!/bin/zsh
# Long-running confidence check on throw-away data: the randomized crash-injection fuzz at scale, then the stress test.
#   Scripts/soak.sh [fuzz-scale=10] [stress-files=30000]
set -euo pipefail
cd "${0:A:h}/.."
SCALE=${1:-10}; FILES=${2:-30000}
echo "== fuzz (FUZZ_SCALE=$SCALE)"
FUZZ_SCALE=$SCALE swift test --filter FuzzTests 2>&1 | grep -E "✔|✘|FUZZ FAILURES|seed [0-9]+ " | cut -c1-300
echo "== stress ($FILES files)"
Scripts/stress.sh "$FILES" 200 2>&1 | grep -E "first sync|no-op|incremental|full scan|rename|DB size|A ==|!!|rror"
rm -rf /private/tmp/syncnexus-stress
