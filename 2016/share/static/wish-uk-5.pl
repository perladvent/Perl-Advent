#!/pro/bin/perl

use 5.16.2;
use warnings;

use Data::Peek;
binmode STDERR, ":encoding(utf-8)";

use List::Util   qw( sum first );
use Text::CSV_XS qw( csv );

my $props = csv (in => "presents.csv", key => "present");
my @presents = keys %$props;

my %count;
my $aoa = csv (in => "wish-uk.csv", headers => "auto", filter => {
    1 => sub {
	my $w = lc $_{Wish};
	my $p = $props->{$w} ? $w
	      : (first { $_ } grep m/\b $w \b/x => @presents) ||
	        (first {     $w =~ m/\b $_ \b/x }  @presents) || $w;
	$count{$p}{$w}{$_{Specs}}++;
	0;
	},
    });

DDumper \%count;
