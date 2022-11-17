#!/pro/bin/perl

use 5.16.2;
use warnings;

use Data::Peek;
binmode STDERR, ":encoding(utf-8)";

use Text::CSV_XS qw( csv );

my %count;
my $aoa = csv (in => "wish-uk.csv", headers => "auto", filter => {
    1 => sub { $count{$_{Wish}}{$_{"Postal Code"} =~ s/\s.*//r}++; 0; }});

DDumper \%count;
