#!/bin/bash
#
# Before a calendar opens, replace the atom.xml advcal just wrote for it with
# the static coming-soon.atom.xml.
#
# advcal's pre-season feed stamps the build time and a day countdown into its
# placeholder entry, so every push to main changes it and feed readers show it
# again. The static feed changes only when the year does.
#
# Usage: script/coming-soon-feed.sh YEAR OUTPUT_DIR
#   Run it right after advcal has written OUTPUT_DIR. It acts only when advcal
#   decided the calendar has not opened yet, so the two can never disagree about
#   the date; from the first door on, advcal's feed stands.

set -eu -o pipefail
cd "$(dirname "$0")/.."

if [[ $# -ne 2 || ! $1 =~ ^[0-9]{4}$ ]]; then
    echo "usage: $0 YEAR OUTPUT_DIR" >&2
    exit 2
fi
year="$1"
out="$2"

# advcal writes this summary only into its pre-season placeholder entry.
if ! grep -q 'The first door opens in' "$out/atom.xml"; then
    exit 0
fi

# Take the feed's id, title and author from the same advent.ini advcal read,
# so subscribers carry straight on to advcal's feed on December 1. The first
# calendar was in 2000, and there has been one every year since.
YEAR="$year" EDITION=$((year - 1999)) perl -Mstrict -wle '
    my %ini;
    open my $fh, "<", "$ENV{YEAR}/advent.ini" or die "$ENV{YEAR}/advent.ini: $!\n";
    while (<$fh>) { $ini{$1} //= $2 if /^(\w+)\s*=\s*(.*?)\s*$/ }
    my %value = (
        YEAR    => $ENV{YEAR},
        EDITION => $ENV{EDITION},
        URI     => $ini{uri},
        TITLE   => $ini{title},
        EDITOR  => $ini{editor},
    );
    for my $key (keys %value) {
        die "advent.ini has no \L$key\E\n" unless defined $value{$key};
        $value{$key} =~ s/&/&amp;/g;
        $value{$key} =~ s/</&lt;/g;
    }
    local $/;
    open my $in, "<", "coming-soon.atom.xml" or die "coming-soon.atom.xml: $!\n";
    my $xml = <$in>;
    $xml =~ s/@(\w+)@/$value{$1} \/\/ die "unknown placeholder \@$1\@\n"/ge;
    print $xml;
' >"$out/atom.xml.tmp"
mv "$out/atom.xml.tmp" "$out/atom.xml"
echo "wrote coming-soon feed to $out/atom.xml"
