#!/bin/bash
#
# UAT preview for the 2026 re-skin.
#
# Renders ONLY 2026 into out/2026/ using the fixture articles in
# 2026/uat-fixtures/ (real past articles, renamed to 2026 dates) so you can
# click through a populated calendar — feature banners, code panels, lists,
# links, dark mode, visited-door ticks, the lot.
#
# It uses the inc/ fork of WWW::AdventCalendar (so the year-local templates and
# self-hosted fonts take effect) and points --article-dir at the fixtures, so
# 2026/articles/ is never touched. Fixture images are copied into share/static
# just for the render and removed afterwards, leaving the tree clean.
#
# Usage:
#   ./script/uat-preview.sh                 # simulate 2026-12-05
#   ./script/uat-preview.sh 2026-12-25      # simulate a later day (more doors)
#
# Then serve it (the sandbox can't bind a port, but your shell can):
#   cd out && python3 -m http.server 8026
#   open http://localhost:8026/2026/

set -eu -o pipefail
cd "$(dirname "$0")/.."

YEAR=2026
TODAY="${1:-$YEAR-12-05}"
FIXTURES="$YEAR/uat-fixtures"
STATIC="$YEAR/share/static"
OUT="out/$YEAR"

if [[ ! -d "$FIXTURES" ]]; then
    echo "No fixtures at $FIXTURES — nothing to preview." >&2
    exit 1
fi

# Copy fixture images into share/static for the render, and remember exactly
# which files we added so cleanup removes only those (never a real asset).
COPIED=()
cleanup() {
    for f in "${COPIED[@]:-}"; do [[ -n "$f" && -e "$STATIC/$f" ]] && rm -f "$STATIC/$f"; done
}
trap cleanup EXIT

if [[ -d "$FIXTURES/static" ]]; then
    for src in "$FIXTURES/static/"*; do
        [[ -e "$src" ]] || continue
        base="$(basename "$src")"
        if [[ -e "$STATIC/$base" ]]; then
            echo "note: $STATIC/$base already exists — leaving it, using the real one"
        else
            cp "$src" "$STATIC/$base"
            COPIED+=("$base")
        fi
    done
fi

# Render 2026 with the inc/ fork on PERL5LIB. advent.ini's article_dir wins over
# the --article-dir flag, so render from a temp ini that points article_dir at
# the fixtures (share_dir stays "share", so the year-local templates load).
mkdir -p "$OUT"
FORK_LIB="$PWD/inc/WWW-AdventCalendar/lib"
UAT_INI="$YEAR/.advent.uat.ini"
sed 's|^article_dir.*|article_dir = uat-fixtures|' "$YEAR/advent.ini" > "$UAT_INI"
COPIED+=()  # ensure array is defined even if no images copied
cleanup_ini() { rm -f "$UAT_INI"; }
trap 'cleanup; cleanup_ini' EXIT
(
    cd "$YEAR"
    PERL5LIB="$FORK_LIB${PERL5LIB:+:$PERL5LIB}" \
        advcal -c .advent.uat.ini -o "../$OUT" --today "$TODAY"
)
[[ -e favicon.ico ]] && cp favicon.ico "$OUT/" || true

echo
echo "Built $OUT/ (simulated today = $TODAY)."
echo "Serve it with:"
echo "    cd out && python3 -m http.server 8026"
echo "then open http://localhost:8026/$YEAR/"
