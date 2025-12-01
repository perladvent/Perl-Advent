#!/usr/bin/env bash

set -eu -o pipefail

echo "             5         10        15        20        25"

for year in $(seq 2000 2010); do
    found=$(find "$year" | grep -e "/\d\d/index.html" -c)
    echo "$year $(printf "%0.s🎄" $(seq 1 "$found"))"
done

for year in $(seq 2011 2025); do
    found=$(find "$year/articles" | grep -c pod$)
    echo "$year $(printf "%0.s🎄" $(seq 1 "$found"))"
done
