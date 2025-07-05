#!/bin/bash

# Usage ./script/build-site.sh
#
# To build just a single year
# ./script/build-site.sh --single-year 2025
#
# To build the entire month for the current year
# ./script/build-site.sh --single-year 2025 --today 2025-12-31
#
# Watch the filesystem:
# find 2025/articles | entr ./script/build-site.sh --single-year 2025 --today 2025-12-25

pwd
set -eu -o pipefail

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
    -s | --single-year)
        single_year="$2"
        shift
        shift
        ;;
    -t | --today)
        today="$2"
        shift
        shift
        ;;
    *)
        echo "Unknown option: $key"
        exit 1
        ;;
    esac
done

static_build=out
# rm -rf $static_build
# mkdir $static_build

perl mkarchives $static_build

for year in $(seq 2000 2010); do
    if [[ "${single_year:-}" && $single_year -ne $year ]]; then
        continue
    fi
    echo "copying $year"
    cp -R "$year" out/
done

for year in 1999 $(seq 2011 2025); do
    if [[ ${single_year:-} && $single_year -ne $year ]]; then
        continue
    fi
    target="$static_build/$year"
    mkdir -p "$target"
    cd "$year"

    asset_dir="share/static"
    mkdir -p "$asset_dir"
    mkdir -p "../$target/$asset_dir"

    if [[ $(ls "$asset_dir/" | wc -l) -gt 0 ]]; then
        cp -R "$asset_dir/"* "../$target/"
    fi

    if [[ ${today:-} ]]; then
        advcal -c advent.ini -o "../$target" --https --today "$today"
    else
        advcal -c advent.ini -o "../$target" --https
    fi

    if [[ -e "$year.css" ]]; then
        cp "$year.css" "../$static_build/$year"
    fi
    cd ..
done

for year in $(seq 2000 2025); do
    if test -d "out/$year"; then
        cp favicon.ico "out/$year/"
    fi
done

cp ./*.html out/
cp RSS.xml out/
cp -R images out/
cp favicon.ico out/

Markdown.pl contact.mkdn >out/contact.html
Markdown.pl FAQ.mkdn >out/FAQ.html
Markdown.pl FAQ-submit.mkdn >out/FAQ-submit.html
