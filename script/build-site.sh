#!/bin/bash

pwd
set -eu -o pipefail

site=out
rm -rf $site
mkdir $site

perl mkarchives $site

for year in $(seq 2000 2010); do
    cp -R "$year" out/
done

for year in $(seq 2011 2023); do
    mkdir "$site/$year"
    cd "$year"
    advcal -c advent.ini -o "../$site/$year" --https
    pwd
    cp -R share/static/* "../$site/$year"
    cd ..
done

cp ./*.html out/
cp RSS.xml out/
cp -R images out/
cp favicon.ico out/

Markdown.pl contact.mkdn > out/contact.html
Markdown.pl FAQ.mkdn > out/FAQ.html
Markdown.pl FAQ-submit.mkdn > out/FAQ-submit.html
