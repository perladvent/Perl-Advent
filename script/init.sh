#!/bin/bash

set -eux -o pipefail

cpm install -g --cpanfile cpanfile

if [ -n "${PLENV_SHELL:-}" ]; then
    plenv rehash
fi

git submodule init
git submodule update

cd inc/WWW-AdventCalendar &&
    dzil authordeps | xargs cpm install -g &&
    dzil install && cd -

cd inc/Pod-Elemental-Transformer-SynHi &&
    dzil authordeps | xargs cpm install -g &&
    dzil install && cd -

cd inc/PPI-HTML &&
    perl -I. Makefile.PL &&
    make install && cd -

if [ -n "${PLENV_SHELL:-}" ]; then
    plenv rehash
fi
