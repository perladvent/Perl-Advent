#!/bin/bash
#
# Before a calendar opens, replace the atom.xml advcal just wrote for it with
# the static coming-soon.atom.xml.
#
# advcal's pre-season feed stamps the build time and a day countdown into its
# placeholder entry, so every push to main changes it and feed readers show it
# again. The static feed changes only when the year does.
#
# Usage: script/coming-soon-feed.sh YEAR OUTPUT_DIR [TODAY]
#   TODAY is YYYY-MM-DD and defaults to the current date, as with advcal.
#   From December 1 of YEAR on, it does nothing and advcal's feed stands.

set -eu -o pipefail
cd "$(dirname "$0")/.."

year="$1"
out="$2"
today="${3:-$(date +%F)}"

# advcal opens a calendar on December 1 of its year.
if [[ ! "$today" < "$year-12-01" ]]; then
    exit 0
fi

# The first calendar was in 2000, and there has been one every year since.
edition=$((year - 1999))

sed -e "s/@YEAR@/$year/g" -e "s/@EDITION@/$edition/g" \
    coming-soon.atom.xml >"$out/atom.xml"
echo "wrote coming-soon feed to $out/atom.xml"
