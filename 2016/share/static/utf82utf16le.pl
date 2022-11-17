#!/pro/bin/perl

use 5.18.2;
use warnings;

sub usage { die "$0: utf8.csv utf16le.csv\n"; }

use Encode qw( from_to );

my ($ff, $tf) = @ARGV;

open my $fh, "<", $ff or usage;

local $/;
$_ = <> =~ s/\r\n/\n/gr;
from_to $_, "utf-8", "utf-16le";
s/\A/\xff\xfe/;

close $fh;
open  $fh, ">", $tf or usage;
print $fh $_;
close $fh;
