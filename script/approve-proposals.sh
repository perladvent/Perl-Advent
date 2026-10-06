#!/usr/bin/env bash
#
# Pick pending article proposals with fzf and approve them via
# script/approve-article-proposal.pl.
#
# Pending = open issues labelled "Article" and "$YEAR", without
# "Proposal Accepted". Tab marks several, Enter approves after a y/N prompt.
#
# Usage:
#   script/approve-proposals.sh
# Override the calendar year with the YEAR env var (default 2026).

set -euo pipefail

YEAR="${YEAR:-2026}"
export YEAR

for cmd in gh fzf; do
    command -v "$cmd" >/dev/null || { echo "error: $cmd not found on PATH" >&2; exit 1; }
done

pending=$(gh issue list --state open --limit 200 \
    --label Article --label "$YEAR" \
    --search '-label:"Proposal Accepted"' \
    --json number,author,createdAt,title \
    --jq '.[] | "\(.number)\t\(.createdAt[:10])\t@\(.author.login)\t\(.title)"')

if [[ -z "$pending" ]]; then
    echo "No pending $YEAR proposals."
    exit 0
fi

selected=$(fzf --multi --delimiter='\t' --with-nth=1.. \
    --header="Pending $YEAR proposals — Tab to mark, Enter to approve, Esc to quit" \
    --preview='gh issue view {1}' --preview-window='right,60%,wrap' \
    <<<"$pending") || exit 0

echo "Will approve:"
echo "$selected" | awk -F'\t' '{ printf "  #%s  %s\n", $1, $4 }'
read -r -p "Proceed? [y/N] " answer
[[ "$answer" == [yY]* ]] || { echo "Aborted."; exit 0; }

cd "$(dirname "$0")/.."
while IFS=$'\t' read -r number _; do
    echo "Approving #$number..."
    perl script/approve-article-proposal.pl "$number"
done <<<"$selected"
