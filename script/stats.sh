#!/usr/bin/env bash

set -eu -o pipefail

echo "             5         10        15        20        25"

for year in $(seq 2000 2010); do
    found=$(find "$year" | grep -e "/\d\d/index.html" -c)
    echo "$year $(printf "%0.s🎄" $(seq 1 "$found"))"
done

for year in $(seq 2011 2026); do
    # articles/ appears with a year's first published article.
    found=0
    if [[ -d "$year/articles" ]]; then
        found=$(find "$year/articles" -name '*.pod' | wc -l)
    fi
    echo "$year $(printf "%0.s🎄" $(seq 1 "$found"))"
done
