#! perl -l
### Purpose - Find Words that are time_t's or vice versa
use Time::HiRes qw{usleep};

# from FAQ http://perldoc.perl.org/perlfaq8.html#How-do-I-clear-the-screen%3F
our $cls;
if ( $^O =~ /MSWin/ ) {
    $cls = "";
}
else {
    use Term::Cap;
    my $terminal = Term::Cap->Tgetent( { OSPEED => 9600 } );
    my $clear_string = $terminal->Tputs('cl');
    $cls = $clear_string;
}

## simulate
if (@ARGV) {
    it( bytes_to_nums(shift) ) while @ARGV;
    exit 1;
}

sub bytes_to_nums {
    my $string = shift;
    ## Probably has problems if given more than 4 chars?
    my $long = unpack( "N*", pack( "a*", $string ) );
    return $long;
}

## run
sub nums_to_bytes {
    my $long = shift;
    ## Probably has problems if given more than 4 chars?
    my $string = unpack( "a*", pack( "N*", $long ) );
    return $string;
}

sub it {
    my @Bufs;
    my $i = 0;
    my $t = shift;

    push @Bufs, scalar($t);
    push @Bufs, scalar( sprintf "%o", $t );
    push @Bufs, scalar( sprintf "%X", $t );    # require 5.010; my $_ =
    push @Bufs,
      scalar
      do { local $_ = nums_to_bytes($t); s/[^[:print:]]/chr 0x3F/ge; "'$_'"; };
    push @Bufs, scalar localtime($t);
    push @Bufs, scalar gmtime($t);

    printf "%2d. %14s\n", $i++, $_ for @Bufs;
}

while (1) { print $cls; it( time() ); usleep(5e5); }
