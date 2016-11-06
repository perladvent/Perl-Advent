#!/pro/bin/perl

use 5.16.2;
use warnings;

use Data::Peek;
binmode STDERR, ":encoding(utf-8)";

use List::Util   qw( sum first );
use Text::CSV_XS qw( csv );

my $props = csv (in => "presents.csv", key => "present");
my @presents = keys %$props;

my %ship;

my @wlh = qw( name birth pc address wish spec );

my %count;
my %prod;
foreach my $wlfn (glob "wish-??.csv") {
    my ($cc) = uc ($wlfn) =~ m/-(\w+)/;
    my $aoa = csv (
	in      => $wlfn,
	bom     => 1,
	headers => \@wlh,
	filter  => { 1 => sub {
	    # Skip lacalized header
	    $_[0]->record_number == 1 and return 0;

	    # For shipping/logistics
	    $count{$_{wish}}{$cc}{$_{pc} =~ s/\s.*//r}++;

	    # For production
	    my $w = lc $_{wish};
	    my $p = $props->{$w} ? $w
		  : (first { $_ } grep m/\b $w \b/x => @presents) ||
		    (first {     $w =~ m/\b $_ \b/x }  @presents) || $w;
	    $prod{$p}{$w}{$_{spec}}++;

	    # Don't store
	    0;
	    }
	});
    }

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

    foreach my $cc (keys %{$count{$wish}}) {
	foreach my $postal (keys %{$count{$wish}{$cc}}) {
	    my $n = $count{$wish}{$cc}{$postal};
	    $ship{$cc}{$postal}{presents}{$wish} = {
		present => $p // "unknown",
		weight  => $weight,
		size    => $size,
		count   => $n,
		};
	    $ship{$cc}{$postal}{count}  += $n;
	    $ship{$cc}{$postal}{size}   += $n * $size;
	    $ship{$cc}{$postal}{weight} += $n * $weight;
	    }
	}
    }

DDumper { ship => \%ship, prod => \%prod };
