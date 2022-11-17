#! /usr/bin/env perl -l
### Copyright - 2005 William Ricker / N1VUX
### License - Same as Perl
### Purpose - Find Words that are time_t's or vice versa

use warnings;
use strict;
use English qw{-no-match-vars};

## ARGS
# defaults
our %Time_of;
our $Char;    ##Allow limited search because BILL'o'Clock is what I want
my $show_while_keeping = 1;

if ( $ARGV[0] =~ m{ --sort | -s }ixism ) {
    shift @ARGV;
    $show_while_keeping = 0;
}

our $IsUC;

while ( @ARGV and $ARGV[0] =~ m{ \A \w{4} \Z }xism ) {
    my $arg = shift @ARGV;
    $IsUC = 1;
    keep_it($arg);

    # OR @TBD - while @ARG ?
}
if ( keys %Time_of ) {    # did we loop?

    exit if $show_while_keeping;

    for my $word ( sort keys %Time_of ) {
        show($word) unless $show_while_keeping;
    }
    exit;
}

if( scalar @ARGV ){
    my $arg = shift @ARGV;
    $Char = $arg if defined $arg and $arg =~ m{ \A \w{1} \Z }xsmi;

    $IsUC = $Char =~ /[A-Z]/ ? 1 : 0;
}

sub bytes_to_nums {
    my $string = shift;
    ## Probably has problems if given more than 4 chars?
    my $long = unpack( "N*", pack( "a*", $string ) );
    return $long;
}

sub keep_it {
    my $time_in = shift
      or die "keep_it requires arg";

    our %Time_of;

    my ( $Baaa, $BAAA ) = ( $time_in, ( $IsUC ? uc $time_in : lc $time_in ) );
    $Baaa =~ s/^(.)/uc $1/ie;    ## Force capital, aaaa isn't until 2021.

    my $timet = bytes_to_nums($Baaa);
    $Time_of{$Baaa} = $timet;
    show($Baaa) if $show_while_keeping;

    if ( $Baaa ne $BAAA ) {
        $timet = bytes_to_nums($BAAA);
        $Time_of{$BAAA} = $timet;
        show($BAAA) if $show_while_keeping;
    }
}

### @TBD -- we could optionally use other dictionaries
open my $DICT, '<', '/usr/share/dict/words'
  or die "Dict open fails $OS_ERROR";

while (<$DICT>) {
    chomp;
    if( defined($Char) ){
	next unless m{ \A $Char \w{3} \Z }xism;    ## B... only
    }
    else{
       next unless m{ \A \w{4} \Z }xism;
    }
    keep_it($_);
}

exit if $show_while_keeping;

for my $word ( sort keys %Time_of ) {
    show($word) unless $show_while_keeping;
}

sub show {
    my $word  = shift;
    my $timet = $Time_of{$word};

    my ( $gmt, $localt ) = ( scalar gmtime $timet, scalar localtime $timet );
    print qq{$word  $gmt GMT . $localt ET}

}
