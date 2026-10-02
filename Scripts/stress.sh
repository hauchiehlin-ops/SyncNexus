#!/bin/zsh
# Stress test on throw-away folders (never touches real data).
#   Scripts/stress.sh [files=30000] [bigMB=400] [workdir]
set -euo pipefail
cd "${0:A:h}/.."
N=${1:-30000}; BIG=${2:-400}; W=${3:-/private/tmp/syncnexus-stress}
swift build -c release --product syncnexus 2>&1 | tail -1
S=$(swift build -c release --show-bin-path)/syncnexus
rm -rf "$W"; mkdir -p "$W"/{A,B,C,D,home}; DB="$W/state.db"
export HOME="$W/home"      # the CLI keeps its Versions archive under HOME: never touch the real app data
t() { local label=$1; shift; local s=$(python3 -c 'import time;print(time.time())'); "$@" > "$W/last.log" 2>&1 || { cat "$W/last.log"; exit 1; }
      printf '%-42s %7.1fs   %s\n' "$label" "$(python3 -c "import time;print(time.time()-$s)")" "$(tail -1 "$W/last.log")"; }
echo "generating $N small files + 3 x ${BIG} MB..."
python3 - "$W/A" "$N" "$BIG" <<'PY'
import os, sys, random
root, n, big = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])
random.seed(1)
for i in range(n):
    d = os.path.join(root, f"dir{i//100:04d}")
    os.makedirs(d, exist_ok=True)
    with open(os.path.join(d, f"file{i:06d}.dat"), "wb") as f: f.write(os.urandom(random.randint(1000, 20000)))
os.makedirs(os.path.join(root, "big"), exist_ok=True)
for k in range(3):
    with open(os.path.join(root, "big", f"video{k}.bin"), "wb") as f:
        for _ in range(big): f.write(os.urandom(1 << 20))
PY
$S init --db "$DB" --endpoint "A=$W/A" --endpoint "B=$W/B" --endpoint "C=$W/C" --endpoint "D=$W/D,removable,portable" >/dev/null
sleep 3
/usr/bin/time -l "$S" sync --db "$DB" --yes > "$W/first.log" 2> "$W/first.time" || { tail -5 "$W/first.log"; exit 1; }
printf '%-42s %s\n' "first sync (4 endpoints)" "$(grep -E 'real|elapsed' "$W/first.time" | head -1) | $(grep 'maximum resident' "$W/first.time" | awk '{printf "%.0f MB RSS", $1/1048576}') | $(tail -1 "$W/first.log")"
t "no-op sync (all cached)" $S sync --db "$DB"
python3 - "$W/B" "$N" <<'PY'
import os, sys
for i in range(0, min(10000, int(sys.argv[2])), 100):
    p = os.path.join(sys.argv[1], f"dir{i//100:04d}", f"file{i:06d}.dat")
    with open(p, "ab") as f: f.write(b"edit")
PY
sleep 3; t "100 files edited on B" $S sync --db "$DB"
echo "edited" >> "$W/B/dir0003/file000300.dat"; sleep 3
t "1 file edited, incremental (--paths)" $S sync --db "$DB" --paths dir0003/file000300.dat
echo "edited again" >> "$W/B/dir0003/file000300.dat"; sleep 3
t "1 file edited, full scan" $S sync --db "$DB"
mv "$W/C/big/video0.bin" "$W/C/big/renamed-video.bin"; sleep 3
t "rename ${BIG} MB file on C" $S sync --db "$DB"
mv "$W/C/dir0001" "$W/C/dir0001-renamed"; sleep 3
t "rename folder (100 files) on C" $S sync --db "$DB"
rm -rf "$W"/D/dir005* ; sleep 1
t "delete 1000 files on D (confirmed)" $S sync --db "$DB" --yes
t "no-op sync again" $S sync --db "$DB"
echo; echo "DB size: $(du -h "$DB" | cut -f1)   files per endpoint: $(find "$W/A" -type f | wc -l | tr -d ' ') / $(find "$W/B" -type f | wc -l | tr -d ' ') / $(find "$W/C" -type f | wc -l | tr -d ' ') / $(find "$W/D" -type f | wc -l | tr -d ' ')"
echo "consistency check (file list + checksums of A vs B,C,D):"
for e in B C D; do diff <(cd "$W/A" && find . -type f ! -name '.syncnexus*' ! -name '._*' | sort) <(cd "$W/$e" && find . -type f ! -name '.syncnexus*' ! -name '._*' | sort) > /dev/null && echo "  A == $e (names)" || echo "  A != $e (names) !!"; done
