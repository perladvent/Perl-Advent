#!/usr/local/bin/perl -w
# based on Tk/demos/timer

use Tk;
sub tick;

my $MW = MainWindow->new;
$MW->bind( '<Control-c>' => \&exit );
$MW->bind( '<Control-q>' => \&exit );

# %tinfo:  the Timer Information hash.
# Key       Contents
# w         Reference to MainWindow.
# p         1 IIF paused.
# t0..t9         Value of -textvariables
my (%tinfo) = ( 'w' => $MW, 'p' => 0, );

my $lines = scalar @{ [ it( time() ) ] };
my @lines = map {
    $MW->Label(
        -relief       => 'raised',
        -width        => 25,
        -textvariable => \$tinfo{ 't' . $_ },
        -foreground => 'green',
        -background => 'black',
    	);
	} 0 .. ( $lines - 1 );
$_->pack() for @lines;

$tinfo{'w'}->after( 100, \&tick );
MainLoop;

exit;

sub tick {

    # Update the counter every 50 milliseconds, or 5 hundredths of a second.

    return if $tinfo{'p'};
    my @ry = scalar(@ARGV) ? bytes_to_nums($ARGV[0]) : time;
    @tinfo{ 't0' .. "t$lines" } = it( @ry );
    $tinfo{'w'}->after( 50, \&tick );
}    # end tick

#Reused code
#################################
sub bytes_to_nums {
    my $string = shift;
    ## Probably has problems if given more than 4 chars?
    my $long = unpack( "N*", pack( "a*", $string ) );
    return $long;
}

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

    return wantarray ? @Bufs : \@Bufs;
}
