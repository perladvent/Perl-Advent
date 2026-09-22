#!/bin/bash
#
# Single-article preview for the 2026 re-skin.
#
# Renders ONE .pod into out/2026/ as door 1 (2026-12-01.html), using the inc/
# fork of WWW::AdventCalendar (so the year-local templates and self-hosted fonts
# take effect). The article is staged into a throwaway 2026/.preview/ dir and
# 2026/articles/ is never touched. Images referenced by the article are copied
# into share/static just for the render and removed afterwards, leaving the tree
# clean.
#
# Usage:
#   ./script/preview-article.sh 2026/incoming/foo.pod
#
# Then serve it (or use `make preview`, which serves for you):
#   http_this out --port 8026 --autoindex
#   open http://127.0.0.1:8026/2026/2026-12-01.html

set -euo pipefail
cd "$(dirname "$0")/.."

YEAR=2026
STATIC="$YEAR/share/static"
PREVIEW_DIR="$YEAR/.preview"
PREVIEW_INI="$YEAR/.advent.preview.ini"
OUT="out/$YEAR"

usage() {
    echo "usage: $0 <path-to-article.pod>" >&2
}

# --- Validate: exactly one path, existing, ending in .pod ---------------------
if [[ $# -ne 1 ]]; then
    usage
    exit 1
fi
ARTICLE="$1"
if [[ ! -f "$ARTICLE" ]]; then
    echo "error: no such file: $ARTICLE" >&2
    usage
    exit 1
fi
if [[ "$ARTICLE" != *.pod ]]; then
    echo "error: not a .pod file: $ARTICLE" >&2
    usage
    exit 1
fi
ARTICLE_DIR="$(dirname "$ARTICLE")"

# --- Cleanup (removes only what we add), on exit whether we win or fail --------
COPIED=()
cleanup() {
    for f in "${COPIED[@]:-}"; do [[ -n "$f" && -e "$STATIC/$f" ]] && rm -f "$STATIC/$f"; done
    rm -rf "$PREVIEW_DIR"
    rm -f "$PREVIEW_INI"
}
trap cleanup EXIT

# --- Clean slate so a previous run never misleads -----------------------------
rm -rf "$OUT"
mkdir -p "$OUT"

# --- Stage the article as door 1 ----------------------------------------------
rm -rf "$PREVIEW_DIR"
mkdir -p "$PREVIEW_DIR"
cp "$ARTICLE" "$PREVIEW_DIR/$YEAR-12-01.pod"

# --- Stage referenced images into share/static --------------------------------
# Look for each referenced file beside the article and in a static/ subdir next
# to it (the fixture layout, e.g. 2026/uat-fixtures/static/). Remember exactly
# which files we add so cleanup removes only those (never a real asset). If a
# file already exists in share/static, leave it and use the real one.
while IFS= read -r base; do
    [[ -n "$base" ]] || continue
    src=""
    for cand in "$ARTICLE_DIR/$base" "$ARTICLE_DIR/static/$base"; do
        [[ -e "$cand" ]] && { src="$cand"; break; }
    done
    [[ -n "$src" ]] || continue
    if [[ -e "$STATIC/$base" ]]; then
        echo "note: $STATIC/$base already exists — leaving it, using the real one"
    else
        cp "$src" "$STATIC/$base"
        COPIED+=("$base")
    fi
done < <(grep -oE 'src="[^"]+"' "$ARTICLE" | sed -E 's/^src="//; s/"$//' | xargs -n1 basename 2>/dev/null | sort -u)

# --- Render 2026 with the inc/ fork on PERL5LIB -------------------------------
# advent.ini's article_dir wins over the --article-dir flag, so render from a
# temp ini that points article_dir at .preview (share_dir stays "share", so the
# year-local templates load). --today opens door 25 so door 1 is reachable.
sed 's|^article_dir.*|article_dir = .preview|' "$YEAR/advent.ini" > "$PREVIEW_INI"
FORK_LIB="$PWD/inc/WWW-AdventCalendar/lib"
(
    cd "$YEAR"
    PERL5LIB="$FORK_LIB${PERL5LIB:+:$PERL5LIB}" \
        advcal -c .advent.preview.ini -o "../$OUT" --today "$YEAR-12-25"
)
[[ -e "$YEAR/favicon.ico" ]] && cp "$YEAR/favicon.ico" "$OUT/" || true

PORT="${PREVIEW_PORT:-8026}"
echo
echo "Built $OUT/ from $ARTICLE."
echo "Open:  http://127.0.0.1:$PORT/$YEAR/$YEAR-12-01.html"
echo "Serve: http_this out --port $PORT --autoindex   (or: make preview ARTICLE=$ARTICLE)"
