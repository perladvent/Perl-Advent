#!/bin/bash

pwd
set -eu -o pipefail

site=out
rm -rf $site
mkdir $site

perl mkarchives $site

for year in 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010; do
    cp -R $year out/
done

for year in 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022; do
    mkdir "$site/$year"
    cd "$year"
    advcal -c advent.ini -o "../$site/$year"
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
