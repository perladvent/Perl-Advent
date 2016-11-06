#!/pro/bin/perl

use 5.16.2;
use warnings;

use Data::Peek;
binmode STDERR, ":encoding(utf-8)";

use List::Util   qw( sum first );
use Text::CSV_XS qw( csv );

my $props = csv (in => "presents.csv", key => "present");

my %count;
my $aoa = csv (in => "wish-uk.csv", headers => "auto", filter => {
    1 => sub {
	$count{$_{Wish}}{$_{"Postal Code"} =~ s/\s.*//r}++;
	0;
	}
    });

my @presents = keys %$props;
my %ship;

foreach my $wish (keys %count) {
    my $w = lc $wish;
    my ($weight, $size, $p);
    if ($p = $props->{$w}) {
	($weight, $size) = ($p->{weight}, $p->{size});
	$p = $w;
	}
    elsif ($p = first { $_ } grep m/\b $w \b/x => @presents or
           $p = first {     $w =~ m/\b $_ \b/x }  @presents) {
	($weight, $size) = ($props->{$p}{weight}, $props->{$p}->{size});
	}
    else {
	($weight, $size) = (1, 1);
	}

    foreach my $postal (keys %{$count{$wish}}) {
	my $n = $count{$wish}{$postal};
	$ship{$postal}{presents}{$wish} = {
	    present => $p // "unknown",
	    weight  => $weight,
	    size    => $size,
	    count   => $n,
	    };
	$ship{$postal}{count}  += $n;
	$ship{$postal}{size}   += $n * $size;
	$ship{$postal}{weight} += $n * $weight;
	}
    }

DDumper \%ship;
