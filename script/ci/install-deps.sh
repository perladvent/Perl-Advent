#!/bin/bash
#
# Install all dependencies for building the Perl Advent Calendar
# Used by CI workflows for reproducible builds
#
# Usage: ./script/ci/install-deps.sh
#

set -eu -o pipefail

echo "🐧 Installing vim for Text-VimColor..."
apt-get install -y vim

echo "📝 Installing vim-perl..."
cd inc/vim-perl
make install
cd ../..

echo "🍴 Installing Forked WWW-AdventCalendar..."
cd inc/WWW-AdventCalendar
dzil authordeps | xargs cpm install -g
dzil install
cd ../..

echo "🍴 Installing Forked Pod-Elemental-Transformer-SynHi..."
cd inc/Pod-Elemental-Transformer-SynHi
dzil authordeps | xargs cpm install -g
dzil install
cd ../..

echo "🍴 Installing Forked PPI-HTML..."
cd inc/PPI-HTML
perl -I. Makefile.PL
make install
cd ../..

echo "✅ All dependencies installed successfully!"
