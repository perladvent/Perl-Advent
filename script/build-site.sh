#!/bin/bash

# Usage ./script/build-site.sh
#
# To build just a single year
# ./script/build-site.sh --single-year 2023
#
# To build the entire month for the current year
# ./script/build-site.sh --single-year 2023 --today 2023-12-31

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

site=out
rm -rf $site
mkdir $site

perl mkarchives $site

for year in $(seq 2000 2010); do
    if [[ "${single_year:-}" && $single_year -ne $year ]]; then
        continue
    fi
    echo "copying $year"
    cp -R "$year" out/
done

for year in 1999 $(seq 2011 2023); do
    if [[ ${single_year:-} && $single_year -ne $year ]]; then
        continue
    fi
    mkdir "$site/$year"
    cd "$year"

    if [[ ${today:-} ]]; then
        advcal -c advent.ini -o "../$site/$year" --https --today "$today"
    else
        advcal -c advent.ini -o "../$site/$year" --https
    fi
    pwd
    if [[ `ls share/static/ | wc -l` -gt 0 ]]; then
        cp -R share/static/* "../$site/$year";
    fi
    if [[ -e "$year.css" ]]; then
        cp "$year.css" "../$site/$year"
    fi
    cd ..
done

cp ./*.html out/
cp RSS.xml out/
cp -R images out/
cp favicon.ico out/

Markdown.pl contact.mkdn >out/contact.html
Markdown.pl FAQ.mkdn >out/FAQ.html
Markdown.pl FAQ-submit.mkdn >out/FAQ-submit.html
